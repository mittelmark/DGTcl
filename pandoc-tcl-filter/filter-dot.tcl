# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
proc filter-dot {cont dict} {
    global n
    incr n
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
    # TODO: error catching
    set res [exec dot -Tsvg $fname.dot -o $fname.svg]
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.svg
        }
    }
    return [list $res $img]
}
