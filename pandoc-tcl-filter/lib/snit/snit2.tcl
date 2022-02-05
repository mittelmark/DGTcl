
package require Tcl 8.5


namespace eval ::snit:: {
    set library [file dirname [info script]]
}

source [file join $::snit::library main2.tcl]

source [file join $::snit::library validate.tcl]

package provide snit 2.3.2
