# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
proc filter-dot {cont dict cblock} {
    global n
    incr n
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

    set def [dict create results show eval true fig true width 400 height 400 \
             include true]
    set dict [dict merge $def $dict]
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname dot-$n
    } else {
        set fname [dict get $dict label]
    }
    set out [open $fname.dot w 0600]
    puts $out $cont
    close $out
    set res [exec dot -Tsvg $fname.dot -o $fname.svg]
    if {[dict get $dict results] eq "show" && $res ne ""} {
        rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
        rl_json::json set cblock c 1 [rl_json::json string $res]
        set ret ",[::rl_json::json extract $cblock]"
    }
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            rl_json::json set jsonImg c 0 c 2 0 "$fname.svg"
            append ret ",[::rl_json::json extract $jsonImg]"
        }
    }

    return $ret
}
