package require Tcl

package provide tclfilters 0.2.0

source [file join [file dirname [info script]] filter-dot.tcl]
source [file join [file dirname [info script]] filter-tsvg.tcl]
source [file join [file dirname [info script]] filter-mtex.tcl]
source [file join [file dirname [info script]] filter-pik.tcl]
source [file join [file dirname [info script]] filter-pic.tcl]
source [file join [file dirname [info script]] filter-eqn.tcl]

