# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
lappend auto_path [file join [file dirname [info script]] lib]
package require tsvg
package require rl_json
# TODO: create interpreter
interp create tsvgi
set jsonImg {
  {
            "t": "Para",
            "c": [
                {
                    "t": "Image",
                    "c": [
                        [
                            "",
                            [],
                            []
                        ],
                        [],
                        [
                            "image.svg",
                            ""
                        ]
                    ]
                }
            ]
  }
}

tsvgi eval  "lappend auto_path [file join [file dirname [info script]] lib]"
tsvgi eval "package require tsvg"
proc filter-tsvg {cont dict cblock} {
    global jsonImg
    global n
    set def [dict create results hide eval true fig true width 100 height 100 \
             include true label null]
    set dict [dict merge $def $dict]
    incr n
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname tsvg-$n
    } else {
        set fname [dict get $dict label]
    }
    set code [regsub -all {([^ ]);} $cont "\\1\\\\;"]
    if {[catch {
         set res2 [tsvgi eval $code]
     }]} {
         set res2 "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
     }

    #set res2 [regsub -all {___SEMI___} $res2 ";"]
    #tsvg set code "$code"
    if {[dict get $dict results] eq "show" && $res2 ne ""} {
        rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
        rl_json::json set cblock c 1 [rl_json::json string $res2]
        set ret ",[::rl_json::json extract $cblock]"
    } 
    if {[dict get $dict fig]} {
        tsvgi eval "tsvg write $fname.svg"
        if {[dict get $dict include]} {
            rl_json::json set jsonImg c 0 c 2 0 "$fname.svg"
            append ret ",[::rl_json::json extract $jsonImg]"
        }
    }
    return $ret
}


#puts [rl_json::json keys $jsonImg] ;#type
#puts [rl_json::json get $jsonImg c 0 c 2 0] ;#type
#puts [rl_json::json set jsonImg c 0 c 2 0 "hello2.svg"] ;#type
#puts [rl_json::json get $jsonImg c 0 c 2 0] ;#type
