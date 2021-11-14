package require Tcl

package provide tclfilters 0.1.0

source [file join [file dirname [info script]] filter-dot.tcl]
source [file join [file dirname [info script]] filter-tsvg.tcl]
source [file join [file dirname [info script]] filter-mtex.tcl]

