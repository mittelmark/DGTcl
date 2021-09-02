#!/usr/bin/env tclsh
##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Thu Sep 2 04:27:43 2021
#  Last Modified : <210902.0641>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#  License:      MIT
# 
##############################################################################
package require Tk
package provide dotcanvas 0.1

namespace eval dotcanvas {
    variable fname ""
    proc wcanvas {w file {mtime -}} {
        set checkinterval 1000 ;# modify as needed
        if {$mtime eq "-"} {
            if [info exists ::_cwf] {after cancel $::_cwf}
            set file [file join [pwd] $file]
            [namespace current]::wcanvas $w $file [file mtime $file]
        } else {
            set newtime [file mtime $file]
            if {$newtime != $mtime} {
                [namespace current]::canvasupdate $w $file
                [namespace current]::wcanvas $w $file
            } else {set ::_cwf [after $checkinterval [info level 0]]}
        }
    }
    proc canvasupdate {w file} {
        variable fname 
        puts update
        if {$fname eq ""} {
            $w delete all
            return
        }
        set dot ""
        if {$::tcl_platform(os) eq "Linux"} {
            set dot dot
        } else {
            if {[file exists "C:/Program Files/GraphViz/bin/dot.exe"]} {
                set dot "C:/Program Files/GraphViz/bin/dot.exe"
            } elseif {[file exists "C:/Programme/Graphviz/bin/dot.exe"]} {
                set dot "C:/Programme/Graphviz/bin/dot.exe"
            } 
            if {$dot eq ""} {
                tk_messageBox -title "Error!" -icon error -message "GraphViz application not found!\nInstall GraphViz!" -type ok
                return
            }
        }
        if {[catch {
             set res [exec $dot -Ttk $file]
             #puts $res
             set c $w
             $c delete all
             eval $res
             set ::einfo "File [file tail $file] is ok! [clock format [file mtime $file]]"
         }]} {
                $w configure -background salmon
                update
                after 1000
                set ::einfo [regsub {.+dot:(.+)\n +while.+} $::errorInfo "\\1"]
                $w configure -background white
        }
    }
    proc dotcanvas {path {dotfile ""}} {
        variable fname
        set fname $dotfile
        canvas $path -background white -width 200 -height 200 -borderwidth 10 -relief flat
        if {$dotfile ne ""} {
            [namespace current]::wcanvas $path $dotfile
            [namespace current]::canvasupdate $path $dotfile
        }
        return $path
    }
}
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] > 0} {
        if {[lindex $argv 0] eq "--help"} {
            puts "dotcanvas dotfile.dot"
        } elseif  {[lindex $argv 0] eq "--version"} {
            puts "[package present dotcanvas]"
        } elseif {[file exists [lindex $argv 0]]} {
            set ::einfo ""
            pack [dotcanvas::dotcanvas .c [lindex $argv 0]] -fill both -expand true  -padx 5 -pady 5 -ipadx 5 -ipady 5
            pack [ttk::label .l -textvariable  ::einfo] -side top -fill x -expand false -padx 5 -pady 5
        } else {
            puts "Error: File [lindex $argv 0] does not exists!"
            exit 0
        }
    } else {
        puts "dotcanvas dotfile.dot"
    }
}
        
        
