#!/usr/bin/env tclsh
##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Thu Sep 2 04:27:43 2021
#  Last Modified : <210903.0823>
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
package provide dotcanvas 0.2.0

namespace eval dotcanvas {
    variable fname ""
    variable einfo ""
    variable _cwf
    variable dotpath ""
    variable w
    proc wcanvas {w file {mtime -}} {
        variable _cwf
        set checkinterval 1000 ;# modify as needed
        if {$mtime eq "-"} {
            if [info exists _cwf] {after cancel $_cwf}
            set file [file join [pwd] $file]
            [namespace current]::wcanvas $w $file [file mtime $file]
        } else {
            set newtime [file mtime $file]
            if {$newtime != $mtime} {
                [namespace current]::canvasupdate $w $file
                [namespace current]::wcanvas $w $file
            } else {set _cwf [after $checkinterval [info level 0]]}
        } 
    }
    proc getDot {} {
        variable dot
        if {[lindex $::tcl_platform(platform) 0] eq "windows"} {
            if {[file exists "C:/Program Files/GraphViz/bin/dot.exe"]} {
                set dot "C:/Program Files/GraphViz/bin/dot.exe"
            } elseif {[file exists "C:/Programme/Graphviz/bin/dot.exe"]} {
                set dot "C:/Programme/Graphviz/bin/dot.exe"
            } 
            if {$dot eq ""} {
                tk_messageBox -title "Error!" -icon error -message "GraphViz application not found!\nInstall GraphViz!" -type ok
                return
            }
        } else {
            if {[auto_execok dot] eq ""}  {
                tk_messageBox -title "Error!" -icon error -message "GraphViz application not found!\nInstall GraphViz!" -type ok
                set dot ""
            } else {
                set dot [auto_execok dot]
            }
        }
    }
    proc canvasupdate {path file} {
        variable fname 
        variable einfo
        variable dot
        variable w
        set w $path
        set fname $file
        if {$fname eq ""} {
            $w delete all
            return
        }
        [namespace current]::dot2file
    }
    proc dotcanvas {path {dotfile ""}} {
        variable fname
        variable dot 
        set fname $dotfile
        canvas $path -background white -width 500 -height 400 -borderwidth 10 -relief flat
        [namespace current]::getDot
        if {$dot eq ""} {
            $path create text 250 100 -text "Error: No GraphViz found!" -font "TkDefaultFont 20" -justify center -fill red
            return $path
        }
        bind all <Control-c> [namespace current]::saveGraph
        if {$dotfile ne ""} {
            [namespace current]::wcanvas $path $dotfile
            [namespace current]::canvasupdate $path $dotfile
        }
        return $path
    }
    proc dot2file {{outfile ""}} {
        variable fname
        variable w
        variable dot
        variable einfo
        if {$outfile eq ""} {
            set ext tk
        } else {
            set ext [string range [file extension $outfile] 1 end]
        }
        if {[catch {
             set res [exec $dot -Ttk $fname]
             set c $w
             $c delete all
             eval $res
             set einfo "File [file tail $fname] is ok! [clock format [file mtime $fname]] - Use <Control-c> to save the Graph!"
             if {$ext ne "tk"} {
                 exec $dot -T$ext $fname -o $outfile
                 set einfo "File [file tail $outfile] saved! [clock format [file mtime $outfile]]"
             }
         }]} {
                $w configure -background salmon
                update
                after 1000
                set einfo [regsub {.+dot:(.+)\n +while.+} $::errorInfo "\\1"]
                $w configure -background white
        }
    }
        
    proc saveGraph {{filename ""}} {
        variable fname
        variable w
        if {$filename eq ""} {
            set types {
                {{Png Files}       {.png}         }
                {{Pdf Files}       {.pdf}         }                
                {{Svg Files}       {.svg}         }
                {{Jpeg Files}       {.jpg}         }
                {{All Files}        *             }
            }
            set savefile [tk_getSaveFile -filetypes $types -initialdir [file dirname $fname] -initialfile [file rootname $fname].png]
            if {$savefile != ""} {
                set filename $savefile
                
            }
        }
        if {$filename eq ""} {
            return
        }
        [namespace current]::dot2file $filename
    }

}
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] > 0} {
        if {[lindex $argv 0] eq "--help"} {
            puts "tclsh dotcanvas.tcl dotfile.dot"
            exit 0
        } elseif  {[lindex $argv 0] eq "--version"} {
            puts "[package present dotcanvas]"
            exit 0
        } elseif {[file exists [lindex $argv 0]]} {
            pack [dotcanvas::dotcanvas .c [lindex $argv 0]] -fill both -expand true  -padx 5 -pady 5 -ipadx 5 -ipady 5
            pack [ttk::label .l -textvariable  ::dotcanvas::einfo] -side top -fill x -expand false -padx 5 -pady 5
        } else {
            puts "Error: File [lindex $argv 0] does not exists!"
            exit 0
        }
    } else {
        puts "dotcanvas dotfile.dot"
        exit 0
    }
}

# TODO:
#   * make einfo namespace var (done)
#   * tied text and canvas widget together
#   * other layout engines, neato, fdp etc
#   * widget docu
#   * OSX port

#' ## ChangeLog
#' 
#' * 2021-09-02 0.1 initial version         
#' * 2021-09-02 0.2.0 
#'     * all variables are now namespaces variables
#'     * file saving using Control-c as svg, png, jpeg, etc
#' 
