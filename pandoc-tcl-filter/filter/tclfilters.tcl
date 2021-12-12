package require Tcl

package provide tclfilters 0.3.0

source [file join [file dirname [info script]] filter-abc.tcl]
source [file join [file dirname [info script]] filter-dot.tcl]
source [file join [file dirname [info script]] filter-mmd.tcl]
source [file join [file dirname [info script]] filter-mtex.tcl]
source [file join [file dirname [info script]] filter-pik.tcl]
source [file join [file dirname [info script]] filter-pic.tcl]
source [file join [file dirname [info script]] filter-eqn.tcl]
source [file join [file dirname [info script]] filter-puml.tcl]
source [file join [file dirname [info script]] filter-sqlite.tcl]
source [file join [file dirname [info script]] filter-rplot.tcl]
source [file join [file dirname [info script]] filter-tsvg.tcl]

