# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same directoy as this file
lappend auto_path [file join [file dirname [info script]] lib]
package require tsvg
interp create tsvgi

tsvgi eval  "lappend auto_path [file join [file dirname [info script]] lib]"
tsvgi eval "package require tsvg"
proc filter-tsvg {cont dict} {
    global n
    incr n
    set def [dict create results hide eval true fig true width 100 height 100 \
             include true label null]
    set dict [dict merge $def $dict]
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

    if {[dict get $dict results] eq "show" && $res2 ne ""} {
        set res2 $res2 
    }  else {
        set res2 ""
    }
    set img ""
    if {[dict get $dict fig]} {
        tsvgi eval "tsvg write $fname.svg"
        if {[dict get $dict include]} {
            set img $fname.svg
        } else {
            set img ""
        }
    }
    return [list $res2 $img]
}

