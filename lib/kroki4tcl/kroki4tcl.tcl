#!/usr/bin/env tclsh
##############################################################################
#
#  Created By    : Detlef Groth
#  Created       : Fri Feb 18 05:50:50 2022
#  Last Modified : <220224.0746>
#
#  Description	 : Using the kroki webservice to create diagram charts
#
#  Notes 
#
#  History       : 
#                - 2022-02-18 - initial version
#                - 2022-02-23 - Github release with extended GUI and Markdown code chunk support 
#	
##############################################################################
#
#  Copyright (c) 2022 Detlef Groth.
# 
#  License: MIT
# 
package require Tcl         8.6
package provide kroki4tcl 0.2
# initial code on the Wiki page
#proc dia2kroki {text {dia graphviz} {ext svg}} {
#    set b64 [string map {+ - / _ = ""}  [binary encode base64 [zlib compress $text]]]
#    set uri https://kroki.io//$dia/$ext/$b64
#}
#proc kroki2dia {url} {
#    set text [regsub {.+/} $url ""]
#    set dia [zlib decompress [binary decode base64 [string map {- + _ /} $text]]]
#}

namespace eval ::kroki4tcl { 
    variable status
    variable maps
    variable filetypes
    variable type
    variable helpfile
    variable scriptfile
    set type Ditaa
    set status "kroki4tcl-gui [package present kroki4tcl]"
    set helpfile [file join [file dirname [info script]] kroki4tcl.md]
    set scriptfile [info script]
    set maps [dict create adia actdiag bdia blockdiag ditaa ditaa dot graphviz erd erd puml plantuml \
              mmd mermaid nml nomnoml ndia nwdiag pik pikchr sbob svgbob sdia seqdiag]
    set filetypes {
        {{ActDiag Files}   {.adia}      }                        
        {{BlockDiag Files} {.bdia}      }                
        {{Ditaa     Files} {.ditaa}     }        
        {{Graphviz Files}  {.dot}       }        
        {{ERD      Files}  {.erd}       }        
        {{Mermaid  Files}  {.mmd}       }
        {{NwDiag   Files}  {.ndia}      }
        {{Nomnoml  Files}  {.nml}       }
        {{Pikchr   Files}  {.pik}       }                
        {{PlantUML Files}  {.puml}      }
        {{SeqDia   Files}  {.sdia}      }                        
        {{Svgbob   Files}  {.sbob}      }
        {{Markdown Files}  {.md .Rmd}   } 
        {{Text     Files}  {.txt}       }                                        
        {{All Files}        *           }
    }

}

proc ::kroki4tcl::dia2kroki {text {dia graphviz} {ext svg}} {
    set b64 [string map {+ - / _ = ""}  [binary encode base64 [zlib compress [encoding convertto utf-8 $text]]]]
    set uri https://kroki.io//$dia/$ext/$b64
}
proc ::kroki4tcl::kroki2dia {url} {
    set text [regsub {.+/} $url ""]
    set dia [encoding convertfrom utf-8 [zlib decompress [binary decode base64 [string map {- + _ /} $text]]]]
}

proc ::kroki4tcl::gui {{path ""}} {
    package require Tk
    variable txt
    variable img
    variable lastfile
    variable filetypes
    variable maps
    variable type
    variable cb
    ttk::frame $path.top
    set l [list]
    foreach i $filetypes { lappend l [lindex [lindex $i 0] 0] }
    set l [lrange $l 0 end-3]
    # does not work
    set cb [ttk::combobox $path.top.ent -values $l -textvariable ::kroki4tcl::type]
    pack $path.top.ent -side left -padx 5 -pady 5
    #  Reload
    foreach btn [list New Open Save SaveAs Dia2Url Url2Dia Help Exit] {
        ttk::button "$path.top.[string tolower $btn]" -width 8 -text $btn -command ::kroki4tcl::file$btn
        pack "$path.top.[string tolower $btn]" -side left -padx 5 -pady 5
    }
    pack $path.top -side top
    ttk::panedwindow $path.pwd  -orient horizontal
    ttk::frame $path.pwd.frame
    ttk::label $path.pwd.frame.lbl -text "Hello"
    place $path.pwd.frame.lbl -relx 0.5 -rely 0.5 -anchor center
    tk::text $path.pwd.text -undo true
    $path.pwd add $path.pwd.text 
    $path.pwd add $path.pwd.frame 
    pack $path.pwd -side top -fill both -expand true
    pack [ttk::label $path.bottom -textvariable ::kroki4tcl::status] -side top -fill x -expand false -padx 10 -pady 5
    # variables
    set txt $path.pwd.text 
    set img $path.pwd.frame.lbl
    set lastfile ""
    # bindings
    bind $txt <Control-s> ::kroki4tcl::fileSave
    # styles
    ttk::style layout WLabel [ttk::style layout TLabel]
    ttk::style layout WFrame [ttk::style layout TFrame]    
    ttk::style configure WLabel -background white
    ttk::style configure WFrame -background white    
    $img configure -style WLabel
    $path.pwd.frame configure -style WFrame
}

proc ::kroki4tcl::fileReload {} {
    variable scriptfile
    set argv0 dummy
    source $scriptfile
}
proc ::kroki4tcl::fileNew {} {
    variable txt
    variable lastfile ""
    $txt delete 1.0 end
}
proc ::kroki4tcl::fileHelp {} {
    variable helpfile
    ::kroki4tcl::fileOpen $helpfile
}
proc ::kroki4tcl::fileUrl2Dia {} {
    variable txt
    variable lastfile
    variable maps
    variable status
    set clip [clipboard get]
    if {![regexp {^http.+kroki} $clip]} {
        set status "Wrong format in clipboard: [string range $clip 0 10]"
        return
    }
    set urls [regsub {.+/} $clip ""]
    set diatext [::kroki4tcl::kroki2dia $urls]
    clipboard clear
    clipboard append -format string  -type UTF8_STRING $diatext
    set status "Diagram text copied to clipboard [clock format [clock seconds]]"
}

proc ::kroki4tcl::fileDia2Url {} {
    variable txt
    variable lastfile
    variable maps
    variable status
    set text [$txt get 1.0 end]
    set ext [string range [file extension $lastfile] 1 end]
    # trial
    if {$ext eq "ditaa"} {
        set text [regsub {;} $text "\u2B24"]
    }
    if {$ext eq "txt"} {
        set ext ::kroki4tcl::getExtension $::kroki4tcl::type
    }
    if {$ext eq "md"} {
        set res [::kroki4tcl::extractChunk]
        set ext [lindex $res 0]
        set text [lindex $res 1]
    }
    set url [::kroki4tcl::dia2kroki $text [dict get $maps $ext] svg]
    clipboard clear
    clipboard append -format string $url 
    set status "URL copied to clipboard [clock format [clock seconds]]"
}
proc ::kroki4tcl::getExtension {type} {
    variable filetypes
    foreach l $filetypes {
        if {[lindex [lindex $l 0] 0] eq "$type"} {
            return [string range [lindex $l 1] 1 end]
        }
    }
    return txt
}

proc ::kroki4tcl::extractChunk {} {
    variable txt
    set ins [$txt index insert]
    set start [$txt search -regexp -backwards {^>?\s?```\{.+\}} $ins]
    set end [$txt search -regexp -forwards {^>?\s?```\s*$} "$start lineend"]
    if {!([$txt compare $ins < $end] && [$txt compare $ins > $start])} {
        return
    }
    set code [$txt get "$start linestart" "$end lineend"]
    set fext [regsub {^```\{\.([a-z]+).*\}.+} $code "\\1"]
    if {$fext eq "kroki"} {
        set fext {^```\{.kroki\s.*dia="?([a-z]+)"?.*\}.*} $code "\\1"]
    }
    set code [$txt get "$start lineend + 1c" "$end linestart - 1c"]
    return [list $fext $code]
}
proc ::kroki4tcl::dia2file {infile outfile} {
    variable maps
    variable cb
    set TK false
    if { ({Tk} in [package names])} { 
        set TK true
    }
    set ext [string range [file extension $infile] 1 end]
    set oxt [string range [file extension $outfile] 1 end]
    if {$ext eq "txt"} {
        set ext [::kroki4tcl::getExtension $::kroki4tcl::type]
    } 
    if {![dict exists $maps $ext] && !($ext in [list md txt kroki])} {
        set msg "Wrong file extension `.$ext`!\nUse [join [dict keys $maps] ,]!"
        if {$TK} {
            tk_messageBox -title "Error!" -icon error -message $msg  -type ok
        } else {
            puts $msg
        }
        return
    }
    if {$oxt ne "svg" && $ext in [list mmd nml pik sbob]} {
        if {[auto_execok cairosvg] eq ""} {
            set msg "Error: Pikchr/Nonnoml/Svgbob diagrams need cairosvg!\nPlease install: pip3 install cairosvg --user"
            if {[package present Tk]} {
                tk_messageBox -title "Error!" -icon error \
                      -message  $msg \
                      -type ok
            } else {
                puts $msg
            }
            return
        }
    }
    if {$oxt eq "pdf" && [auto_execok cairosvg] eq ""} {
        set msg "Error: PDF output needs cairosvg!\nPlease install: pip3 install cairosvg --user"
        if {[package present Tk]} {
            tk_messageBox -title "Error!" -icon error \
                  -message  $msg \
                  -type ok
        } else {
            puts $msg
        }
        return
    }
    set text ""
    if [catch {open $infile r} infh] {
        puts "Cannot open $infile"
    } else {
        while {[gets $infh line] >= 0} {
            append text "$line\n"
            
        }
        close $infh
    }
    if {$oxt ne "svg" && $ext in [list sbob pik mmd nml] } {
        set uri [::kroki4tcl::dia2kroki $text [dict get $maps $ext] svg]
        puts "fetching $uri"
        exec -ignorestderr wget $uri -O [file rootname $outfile].svg 2>@1
        exec -ignorestderr cairosvg -f $oxt  -o $outfile [file rootname $outfile].svg 
    } elseif {$oxt eq "pdf"} {
        set uri [::kroki4tcl::dia2kroki $text [dict get $maps $ext] svg]
        puts "fetching $uri"
        exec -ignorestderr wget $uri -O [file rootname $outfile].svg 2>@1
        exec -ignorestderr cairosvg -f $oxt  -o $outfile [file rootname $outfile].svg 
    } else {
        set uri [::kroki4tcl::dia2kroki $text [dict get $maps $ext] $oxt]
        puts "fetching $uri"
        exec -ignorestderr wget $uri -O $outfile 2>@1
    }
}
proc ::kroki4tcl::fileSave {} {
    variable lastfile
    variable txt
    variable maps
    variable img
    variable cb
    if {$lastfile eq ""} {
        ::kroki4tcl::fileSaveAs
        return
    }
    if {$lastfile ne ""} {
        if {[file extension $lastfile] eq ".txt"}  {
            $cb state !disabled
        } else {
            $cb state disabled
        }
        set ext [string range [file extension $lastfile] 1 end]
        set text [$txt get 1.0 end] 
        set out [open $lastfile w 0600]
        puts $out "$text"
        close $out
        if {$ext in [list md Rmd Tmd]} {
            set ins [$txt index insert]
            set start [$txt search -regexp -backwards "^>?\s?```\{.+\}" $ins]
            set end [$txt search -regexp -forwards "^>?\s?```\s*$" "$start lineend"]
            if {!([$txt compare $ins < $end] && [$txt compare $ins > $start])} {
                return
            }
            puts "start: $start ins: $ins end: $end"
            set code [$txt get "$start linestart" "$end lineend"]
            if {[string length $code] > 10} {
                set fext [regsub {^```\{\.([a-z]+).*\}.+} $code "\\1"]
                if {$fext eq "kroki"} {
                    set fext [regsub {^```\{.kroki\s.*dia="?([a-z]+)"?.*\}.+} $code "\\1"]
                }
                set code [$txt get "$start lineend + 1c" "$end linestart - 1c"]
                set fname [file tempfile].$fext
                set out [open $fname w 0600]
                puts $out "$code"
                close $out 
                ::kroki4tcl::dia2file $fname [file rootname $fname].png
                if {[file exists [file rootname $fname].png]} {
                    image create photo ::kroki4tcl::img -file [file rootname $fname].png
                    $img configure -image ::kroki4tcl::img
                }
                file delete $fname
                file delete [file rootname $fname].png
            }
        } else {
            ::kroki4tcl::dia2file $lastfile [file rootname $lastfile].png
            if {[file exists [file rootname $lastfile].png]} {
                image create photo ::kroki4tcl::img -file [file rootname $lastfile].png
                $img configure -image ::kroki4tcl::img
            }
        }
        wm title . "kroki4tcl-gui [file tail $lastfile]"
    }
}
proc ::kroki4tcl::fileSaveAs {} {
    variable filetypes
    variable txt
    variable lastfile
    set types $filetypes
    unset -nocomplain savefile
    set savefile [tk_getSaveFile -filetypes $types \
                  -initialdir [file dirname $lastfile]]
    if {$savefile != ""} {
        set lastfile $savefile
        ::kroki4tcl::fileSave
    }
}
proc ::kroki4tcl::fileOpen {{filename ""}} {
    variable txt
    variable lastfile
    variable filetypes
    variable cb
    set types $filetypes
    if {$filename eq ""} {
        set filename [tk_getOpenFile -filetypes $types\
                      -initialdir [file dirname $lastfile]]
    }
    if {$filename != ""} {
        $txt delete 1.0 end
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                $txt insert end "$line\n"
            }
            close $infh
        }
        set lastfile $filename
        if {[file extension $filename] eq ".txt"} {
            $cb state !disabled
        } else {
            $cb state disabled
        }
    }
}
proc ::kroki4tcl::fileExit {} {
    set answer [tk_messageBox -title "Question!" -message "Really exit ?" -type yesno -icon question]
    if { $answer } {
        exit 0
    } 
}
if {[info exists argv0] && $argv0 eq [info script]} {
    proc usage {} {
        puts "Usage: kroki4tcl.tcl ?--gui? ?INFILE? ?OUTFILE?"
        puts "  Convert diagram code to SVG, PNG or PDF graphics."
        puts "  Possible  INFILE  file extensions are  [join [dict keys $::kroki4tcl::maps] ,]"
        puts "  Possible  OUTFILE file extensions are svg (default), png, pdf!"
    }
    if {[llength $argv] > 0} {
        if {"--help" in $argv || "-h" in $argv} {
            usage
            exit 0
        }
        if {"--gui" in $argv} {
            ::kroki4tcl::gui 
            if {[llength $argv] >= 2 && [file exists [lindex $argv 1]]} {
                ::kroki4tcl::fileOpen [lindex $argv 1]
                ::kroki4tcl::fileSave
            }
        } else {
            if {[file exists [lindex $argv 0]]} {
                if {[llength $argv] == 2} {
                    ::kroki4tcl::dia2file [lindex $argv 0] [lindex $argv 1]
                } else {
                    ::kroki4tcl::dia2file [lindex $argv 0] [file rootname [lindex $argv 0].svg]
                }
            } else {
                puts "Error: File [lindex $argv 0] does not exists!"
            }
        }
    } else {
        ::kroki4tcl::gui
    }
}
