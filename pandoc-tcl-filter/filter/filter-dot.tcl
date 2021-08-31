# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
proc filter-dot {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 400 height 400 \
             include true imagepath images app dot]
    set dict [dict merge $def $dict]
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] dot-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.dot w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app] -Tsvg $fname.dot -o $fname.svg]
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
