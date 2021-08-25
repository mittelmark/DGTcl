#!/usr/bin/env tclsh
#lappend auto_path /home/groth/workspace/delfgroth/mytcl/libs
package require rl_json
package provide pandoc 0.1
# pandoc -s -t json dgtools/test.md > dgtools/test.ast
# cat dgtools/test.ast | tclsh dgtools/filter.tcl
# pandoc dgtools/test.md -s --metadata title="test run with tcl filter" -o dgtools.html --filter dgtools/filter.tcl
# read the JSON AST from stdin

set jsonData {}
while {[gets stdin line] > 0} {
   append jsonData $line
}

proc debug {jsonData} {
    puts [::rl_json::json keys $jsonData]
}
# just demo code from the Tclers wiki: 
proc incrHeader {jsonData} {
    for {set i 0} {$i < [llength [::rl_json::json get $jsonData blocks]]} {incr i} {
        set blockType [::rl_json::json get $jsonData blocks $i t]
        if {$blockType eq "Header"} {
            set headerLevel [::rl_json::json get $jsonData blocks $i c 0]
            set jsonData [::rl_json::json set jsonData blocks $i c 0 [expr {$headerLevel + 1}]]
        } 
    }
    return $jsonData
}

proc evalTclCode {jsonData} {
    interp create mdi
    mdi eval {
        set res ""
        
        rename puts puts.orig
        
        proc puts {args} {
            global res
            if {[lindex $args 0] eq "-nonewline"} {
                append res "[lindex $args 1]"
            } else {
                append res "[lindex $args 0]\n"
            }
            return ""
        }
    }
    set blocks ""
    for {set i 0} {$i < [llength [::rl_json::json get $jsonData blocks]]} {incr i} {
        if {$i > 0} {
            append blocks ","
        }
        set blockType [::rl_json::json get $jsonData blocks $i t]
        if {$blockType eq "CodeBlock"} {
            set type [rl_json::json get $jsonData blocks $i c 0 1] ;#type
            set attr [rl_json::json get $jsonData blocks $i c 0 2] ;# attributes
            set a [dict create echo true results show eval true]
            if {[llength $attr] > 0} {
                foreach el $attr {
                    dict set a [lindex $el 0] [lindex $el 1]
                }
                #puts [dict keys $a]
            }
            if {[dict get $a echo]} {
                append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
            }
            set cont [rl_json::json get $jsonData blocks $i c 1]
            set cblock "[::rl_json::json extract $jsonData blocks $i]"
            #puts $cblock
            #puts [::rl_json::json  get $cblock t]
            #exit
            if {$type eq "tcl"} {
                if {[dict get $a eval]} {
                    mdi eval "set res {}"
                    if {[catch {
                         set eres [mdi eval $cont]
                         set eres "[mdi eval {set res}]$eres"
                    }]} {
                         set eres "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
                    }
                    #set eres [mdi eval $cont]
                    #set eres "[mdi eval {set res}]$eres"
                    if {[dict get $a results] eq "show"} {
                        rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
                        #rl_json::json set cblock c 0 2 [rl_json::json array [list string "a" string ""]]
                        rl_json::json set cblock c 1 [rl_json::json string [regsub {\{(.+)\}} $eres "\\1"]]
                        append blocks ",[::rl_json::json extract $cblock]"
                    }
                }
            }
        } elseif {$blockType eq "Para"} {
            for {set j 0} {$j < [llength [::rl_json::json get $jsonData blocks $i c]]} {incr j} {
                set type [rl_json::json get $jsonData blocks $i c $j t] ;#type
                if {$type eq "Code"} {
                    set code [rl_json::json get $jsonData blocks $i c $j c]
                    set code [lindex $code 1]
                    if {[regexp {\.?tcl } $code]} {
                        set c [regsub {^[^ ]+} $code ""]
                        if {[catch {
                             set ::errorInfo {}
                             set res [interp eval mdi $c]
                         }]} {
                                set res "error: $c"
                                set res "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
                        }

                        #set res [interp eval mdi $c]
                        set jsonData [rl_json::json set jsonData blocks $i c $j c 1 [rl_json::json string $res]]
                    }
                }
            }
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        } else {
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        }
    }
    set ret "\"blocks\":\[$blocks\]"
    append ret ",\"pandoc-api-version\":[::rl_json::json extract $jsonData pandoc-api-version]"
    append ret ",\"meta\":[::rl_json::json extract $jsonData meta]"
    return "{$ret}"
}
puts -nonewline [evalTclCode $jsonData]

# give the modified document back to Pandoc again:
