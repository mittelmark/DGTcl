#!/bin/env tclsh
# file: autoPather.tcl
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] == 0} {
        puts "Usage: [info script] pathname app.tcl ?other args?"
        exit 0
    }
    lappend auto_path [lindex $argv 0]
    set ::argv0 [lindex $argv 1]
    set ::argv [lrange $argv 2 end]
    source $argv0 
}

