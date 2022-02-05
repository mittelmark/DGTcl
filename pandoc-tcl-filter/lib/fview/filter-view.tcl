##############################################################################
#  Created By    : Detlef Groth
#  Created       : Fri Feb 4 05:49:13 2022
#  Last Modified : <220205.0858>
#
#  Description	 : Graphical user interface to display
#'                 results from graphical tools created based with simple text.
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2022 Detlef Groth.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from Detlef Groth.
#
##############################################################################
#lappend auto_path ../libs
if {[file isdir lib]} {
    lappend auto_path lib
}
package require dgw::basegui
package require dgw::txmixins
package require tclfilters
package provide fview 0.1
namespace eval fview { 
    variable filetypes 
    set filetypes {
        {{ABC Music Files} {.abc}        }        
        {{GraphViz Dot Files}  {.dot}    }
        {{Eqn Files}       {.eqn}        }        
        {{Mermaid Files}   {.mmd}        }                        
        {{Mtex Files}      {.mtex}       }                
        {{Pic Files}       {.pic}        }                
        {{Pikchr Files}    {.pik}        }                        
        {{PlantUML Files}  {.puml}       }        
        {{Rplot Files}     {.rplot}      }                
        {{Tdot  Files}     {.tdot}       }                        
        {{Tsvg  Files}     {.tsvg}       }                                
        {{All Files}        *            }
    }


}
proc ::fview::gui {} {
    variable filetypes
    ::dgw::basegui app -style clam -title "DGFilterView, 2022"
    app addStatusBar
    set info "\nValid and installed filters are:\n  - abc, dot, eqn, mmd,\n  - mtex, pic, pik, puml,\n  - rplot, tdot, tsvg\n"
    app setAppname DGFilterView [package provide fview] "Detlef Groth" 2022 $info
    set fmenu [app getMenu "File"]
    $fmenu insert 0 command -label New -underline 0 -command ::fview::fileNew    
    $fmenu insert 1 command -label "Open ..." -underline 0 -command ::fview::fileOpen
    $fmenu insert 2 separator 
    $fmenu insert 3 command -label Save -underline 0 -command ::fview::fileSave
    $fmenu insert 4 command -label "Save as ..." -underline 1 -command ::fview::fileSaveAs
    bind all <Control-o> fview::fileOpen
    bind all <Control-s> fview::fileSave
    bind all <Control-V> fview::paneVertical
    bind all <Control-H> fview::paneHorizontal
    ttk::style layout WLabel [ttk::style layout TLabel]
    ttk::style layout WFrame [ttk::style layout TFrame]    
    ttk::style configure WLabel -background white
    ttk::style configure WFrame -background white    
    set f [app getFrame]
    set pwd [ttk::panedwindow $f.tframe -orient horizontal]
    set tf [ttk::frame $pwd.fr]
    set t [tk::text $tf.text -wrap none -undo true]
    dgw::txmixin $t dgw::txhighlight
    dgw::txmixin $t dgw::txpopup
    dgw::txmixin $t dgw::txfontsize
    dgw::txmixin $t dgw::txtabbind
    $t configure -highlights {
        {dot comment ^\s*(@|#|%|//).+}
        {dot keyword {(digraph|node)}}
        {dot string {"[^"]+"}}} ;#"
    app autoscroll $t
    $t insert end "digraph G {\n   A -> B ;\n}"
    $t configure -mode dot
    set f0 [ttk::frame $pwd.f0 -width 300 -height 100 -style WFrame]
    set img [ttk::label $pwd.f0.img -width 10 -text "Output" -style WLabel]
    place $img -relx 0.5 -rely 0.5 -anchor center
    $pwd add $f0
    $pwd add $tf
    set pwd2 [ttk::panedwindow $f.tframe2 -orient vertical]
    set tf2 [ttk::frame $pwd2.fr]
    set t [$tf.text peer create $tf2.text]
    dgw::txmixin $t dgw::txhighlight
    dgw::txmixin $t dgw::txpopup   
    dgw::txmixin $t dgw::txfontsize
    dgw::txmixin $t dgw::txtabbind
    
    $t configure -highlights {
        {dot comment ^\s*(@|#|%|//).+}
        {dot keyword {(digraph|node)}}
        {dot string {['"][^'"]+['"]}}} ;#"
    $t configure -mode dot
    app autoscroll $t
    set f0 [ttk::frame $pwd2.f0 -width 100 -height 300 -style WFrame]
    set img [ttk::label $pwd2.f0.img -width 10 -text "Output" -style WLabel]
    place $img -relx 0.5 -rely 0.5 -anchor center
    $pwd2 add $f0
    $pwd2 add $tf2
    pack $pwd2 -side top -fill both -expand yes
    set ::fview::pwd1 $pwd
    set ::fview::pwd2 $pwd2
    set ::fview::lab1 $pwd.f0.img
    set ::fview::lab2 $pwd2.f0.img
    set ::fview::text $tf.text
    set ::fview::text2 $tf2.text    
    set ::fview::filename ""
    app status "Press Control-Shift H or V to change layout!" 100
}

snit::widgetadaptor dgw::txfontsize {
    delegate option * to hull
    delegate method * to hull
    constructor {args} {
        installhull $win
        set textw $win
        $self configurelist $args
        $self configure -borderwidth 10 -relief flat 
        bind $win <Control-plus>  [mymethod changeFontSize +2]
        bind $win <Control-minus> [mymethod changeFontSize -2]
    }
    method changeFontSize {x} {
        set font [$win cget -font]
        font configure $font -size [expr {[font configure $font -size] + $x}]
    }
}
    
snit::widgetadaptor dgw::txtabbind {
    delegate option * to hull
    delegate method * to hull
    constructor {args} {
        installhull $win
        set textw $win
        $self configurelist $args
        $self configure -borderwidth 10 -relief flat 
        bind $self <Tab> { if { [string equal [%W cget -state] "normal"] } {
                tk::TextInsert %W "    "
                focus %W
                break
            }
        }
        bind $self <Key-F2> { if { [string equal [%W cget -state] "normal"] } {
                tk::TextInsert %W \t
                focus %W
                break
            }
        }
    }
}

proc ::fview::fileNew {} {
    set win $::fview::text
    if {[$win edit modified]} {
        set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
        switch -- $answer  {
            yes  {
                ::fview::fileSave
            }
            cancel { return }
        }
    } 
    $win delete 1.0 end       
    set ::fview::filename "*new*"
    app configure -title "DGFilterView, 2022 - *new*"
}
proc ::fview::fileOpen {{filename ""}} {
    set types $::fview:::filetypes
    if {$filename eq ""} {
        set filename [tk_getOpenFile -filetypes $types]
    }
    if {$filename ne ""} {
        set ::fview::filename $filename
        app configure -title "DGFilterView, 2022 - [file tail $filename]"
        $::fview::text delete 1.0 end
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                $::fview::text insert end "$line\n"
            }
            close $infh
        }
    }
}
proc ::fview::fileSaveAs { } {
    set types $::fview:::filetypes    
    unset -nocomplain savefile
    set savefile [tk_getSaveFile -filetypes $types]
    if {$savefile ne ""} {
        set ::fview::filename $savefile
        ::fview::fileSave $savefile
    }
}
proc ::fview::fileSave {{savefile ""} } {
    if {$::fview::filename in [list "" "*new*"]} {
        ::fview::fileSaveAs
    } else {
        set savefile $::fview::filename
    }
    if {$savefile ne ""} {
        set label [file tail [file rootname $savefile]]
        set d [dict create echo true results hide eval true fig true ext png label $label]
        
        set cnt [$::fview::text get 1.0 end]
        set out [open $savefile  w 0600]
        foreach line [split $cnt \n] {
            if {[regexp {^.?```\{.+\}} $line]} {
                set dchunk [chunk2dict $line]
                set d [dict merge $d $dchunk]
            } 
            puts $out $line
        }
        close $out
        set ext [string range [file extension $savefile] 1 end]
        set label [file rootname [file tail $savefile]]
        if {[info procs ::filter-$ext] ne ""} {
            if {[catch {
                 set res [::filter-$ext $cnt $d]
             }]} {
                    set msg "Error:"
                    puts $::errorInfo
                    append msg [regsub {.+?:.+?:} [lindex [split $::errorInfo \n] 0] ""]
                    app status $msg
                    $::fview::text configure -background salmon
                    $::fview::text2 configure -background salmon
                    update
                    after 2000 
                    $::fview::text configure -background white
                    $::fview::text2 configure -background white
                    
            } else {
                app status [lindex $res 0]
                if {[lindex $res 1] ne ""} {
                    image create photo ::fview::img -file [lindex $res 1]
                    $::fview::lab1 configure -image ::fview::img
                    $::fview::lab2 configure -image ::fview::img
                }
            }
        }
    }
}
proc ::fview::paneVertical {} {
    puts vertical
    pack forget $::fview::pwd1
    pack $::fview::pwd2 -side top -fill both -expand yes
}
proc ::fview::paneHorizontal {} {
    puts horizontal
    pack forget $::fview::pwd2
    pack $::fview::pwd1 -side top -fill both -expand yes
}
if {[info exists argv0] && $argv0 eq [info script]} {
    #puts "Usage: filter-view.tcl \[filename\]"
    fview::gui
    if {[llength $argv] > 0}  {
        fview::fileOpen [lindex $argv 0]
        fview::fileSave [lindex $argv 0]

    }
}
