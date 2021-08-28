# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
lappend auto_path [file join [file dirname [info script]] lib]
package require tsvg
proc filter-tsvg {cont dict cblock} {
    global n
    incr n
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname dot-$n
    } else {
        set fname [dict get $dict label]
    }
    set res [eval $cont]
    tsvg write $fname.svg
    if {[dict get $dict results] eq "show" && $res ne ""} {
        rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
        rl_json::json set cblock c 1 [rl_json::json string $res]
        set ret ",[::rl_json::json extract $cblock]"
    }
    return $ret
}

