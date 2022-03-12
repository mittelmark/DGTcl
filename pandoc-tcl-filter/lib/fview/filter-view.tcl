#!/usr/bin/env tclsh
#' ---
#' title: filter-view manual
#' author: Dr. Detlef Groth
#' date: 2022-02-07
#' ---
#' 
#' ------
#' 
#' ```{.tcl results="asis" echo=false}
#' include header.md
#' ```
#' 
#' ------
#' 
#' ## NAME
#' 
#' *filter-view* - graphical interface for various diagram and graphics generating tools like R, Octave, 
#' Python with Matplotlib for instance, fossil pikchr, PIC, mermaid, GraphViz dot and neato, PlantUML, 
#' ABC music, the Tcl libraries tsvg and tdot, equation system EQN and LaTeX math as well as to LaTeX 
#' graphical libraries such as TikZ.
#' 
#' ## SYNOPSIS
#' 
#' ```
#' pandoc-tcl-filter.tapp --gui ?FILENAME?
#' ```
#' 
##############################################################################
#  Created By    : Detlef Groth
#  Created       : Fri Feb 4 05:49:13 2022
#  Last Modified : <220222.1550>
#
#  Description	 : Graphical user interface to display
#                 results from graphical tools created based with simple text.
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
package provide fview 0.2
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
        {{Markdown Files}  {.md .Tmd .Rmd}       }                                        
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
    dgw::txmixin $t dgw::txtabspace
    $t configure -borderwidth 10 -relief flat 

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
    dgw::txmixin $t dgw::txtabspace
    $t configure -borderwidth 10 -relief flat 
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
    set ::fview::current txt2
    set ::fview::pwd1 $pwd
    set ::fview::pwd2 $pwd2
    set ::fview::lab1 $pwd.f0.img
    set ::fview::lab2 $pwd2.f0.img
    set ::fview::text $tf.text
    set ::fview::text2 $tf2.text    
    set ::fview::filename ""
    app status "Press Control-Shift H or V to change layout!" 100
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
proc ::fview::extractChunk {} {
    if {$::fview::current eq "txt1"} {
        set txt $::fview::text
    } else {
        set txt $::fview::text2
    }
    set ins [$txt index insert]
    if {$ins eq ""} {
        set start [$txt search -forwards ``` 1.0]
        set end [$txt search -forwards ``` "$start lineend"]
    } else {
        set start [$txt search -backwards ``` $ins]
        set end [$txt search -forwards ``` $ins]
    }
    if {$start eq "" || $end eq ""} {
        return [list "" ""]
    }
    set code [$txt get "$start linestart" "$end lineend"]
    if {[string length $code] > 5} {
        set fext [regsub {^```\{\.([a-z]+).*\}.+} $code "\\1"]
        set code [$txt get "$start lineend + 1c" "$end linestart - 1c"]
        return [list $fext $code]
    }
    return [list "" ""]
    
}
proc ::fview::fileSave {{savefile ""} } {
    if {$::fview::filename in [list "" "*new*"]} {
        ::fview::fileSaveAs
    } else {
        set savefile $::fview::filename
    }
    set tempfile ""
    if {$savefile ne ""} {
        set label [file tail [file rootname $savefile]]
        set d [dict create echo true results hide eval true fig true ext png label $label]
        set ext [string range [file extension $savefile] 1 end]
        set cnt [$::fview::text get 1.0 end]

        if {$ext in [list md Rmd Tmd]} {
            set res [::fview::extractChunk]
            set next [lindex $res 0]
            if {$next eq ""} {
                return
            }
            set out [open $savefile w 0600]
            puts $out $cnt
            close $out
            set cnt [lindex $res 1]
            set savefile [file tempfile].$next
            set tempfile $savefile
            set ext $next
        }
        set out [open $savefile  w 0600]
        foreach line [split $cnt \n] {
            if {[regexp {^.?```\{.+\}} $line]} {
                set dchunk [chunk2dict $line]
                set d [dict merge $d $dchunk]
            } 
            puts $out $line
        }
        close $out
        if {$tempfile ne ""} {
            file delete $tempfile
        }
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
    pack forget $::fview::pwd1
    set ::fview::current txt2
    pack $::fview::pwd2 -side top -fill both -expand yes
}
proc ::fview::paneHorizontal {} {
    pack forget $::fview::pwd2
    set ::fview::current txt1
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

#' ## DESCRIPTION
#' 
#' *filter-view* is a graphical user interface to the filters embedded in the *pandoc-tcl-filter* application.
#' The *filter-view* application can be used independent of pandoc by providing the command line option `--gui` 
#' and an optional filename to be loaded directly. The type of filter to be used is recognized by the file name extension. 
#' So if the file extension is *.abc* the the ABC filter is used, if the file extension is *.tsvg* 
#' the tsvg filter is  used. Below a list of the currently supported filters:
#' 
#' <center>
#' | filter | tool | comment |
#' | ------ | ----- | ---- | 
#' | .abc   | abcm2ps / cairosvg| music |
#' | .dot   | dot   |  diagrams |
#' | .eqn   | eqn2graph / convert | math | 
#' | .mmd   | mermaid-cli (mmdc) | diagrams |
#' | .mtex  | latex / dvipgn | math, diagrams, games |
#' | .pic   | pic2graph / convert | diagrams |
#' | .pik   | fossil  / cairosvg | diagrams |
#' | .pipe  | R / python / octave |  Statistics, Programming |
#' | .puml  | plantuml  |  diagrams |
#' | .rplot | R         | statistics, graphics |
#' | .tdot  | tclsh / dot   | diagrams |
#' | .tsvg  | tclsh / cairosvg | graphics |
#' </center>
#' 
#' As Tcl/Tk has currently no native support to display SVG graphics with text, 
#' the *cairosvg* application is used in cases where the native output is SVG. 
#' 
#' ## REQUIREMEMTS AND INSTALLATION
#' 
#' You need an existing installation of Tcl/Tk. The *tclsh* application must be in the PATH:
#' 
#' ```
#' $ echo 'puts $tcl_patchLevel' | tclsh
#' 8.6.10
#' ```
#' 
#' Ok, if tclsh is installed properly, download the standalone file `pandoc-tcl-filter.tapp` from here [https://github.com/mittelmark/DGTcl/releases/download/latest/pandoc-tcl-filter.tapp](https://github.com/mittelmark/DGTcl/releases/download/latest/pandoc-tcl-filter.tapp).
#' Make the file exexutable and copy this file to a folder belonging to your PATH like `~/bin`. Check if the file is executable directly:
#' 
#' ```
#' $ pandoc-tcl-filter.tapp --version
#' 0.7.0
#' ```
#' 
#' You should then install *cairosvg* for instance using your package manager. 
#' On Fedora you would write `sudo dnf install python3-cairosvg` on Ubunti/Debian `sudo apt-get install cairosvg`. On most systems you could as well use the Python package manager and 
#' use it for you as an user only: `pip3 install cairosvg --user`.
#' 
#' Let's check if it is there:
#' 
#' ```
#' $ cairosvg --version
#' 2.5.2
#' ```
#' 
#' Ok, that works as well. You must now install the tools for creating the graphics:
#' 
#' Here some install suggestions which worked for me on my Fedora Linux system:
#' 
#' * cairosvg - `sudo dnf install python3-cairosvg`
#' * ABC music - `sudo dnf install abcm2ps python3-cairosvg`
#' * EQN and PIC - `sudo dnf install groff`
#' * GraphViz dot - `sudo dnf install graphviz`
#' * Mermaid-cli - `npm install -g mermaid-cli`
#' * LaTeX mtex - `sudo dnf install texlive-standalone`
#' * Pikchr     - `sudo dnf install fossil python3-cairosvg`
#' * PlantUML   - `sudo dnf install plantuml`
#' * Rplot      - `sudo dnf install R`
#' * tdot       - `sudo dnf install graphviz`
#' * tsvg       - `sudo dnf install python3-cairosvg`
#' 
#' Ubuntu users usually use `sudo apt-get install package-name`. On MacOSX probably the *brew* package manager should be used.
#' On Windows I would recommend a Unix like system, for instance *msys2* but I have not yet tested this.
#' 
#' ## INTERFACE
#' 
#' The interface is simple, it provides the file dialogs to open and save your files, 
#' a simple text editor widget with basic highlighting, an image (label) widget to display the result. 
#' Based on the extension the filter will be choosen and the graphic will be generated..
#' 
#' After saving the file the image should be updated automatically.
#' The following keybings are provided:
#' 
#' - Ctrl-o - open a file
#' - Ctrl-s - save the file
#' - Ctrl-Plus - increase font-size
#' - Ctrl-Minus - decrease font-size
#' - Ctrl-x - cut text
#' - Ctrl-v - insert text
#' - Ctrl-c - copy text
#' - Ctrl-u - edit undo
#' - Ctrl-Shift-/ - select all text
#' - Ctrl-Shift-h - switch to horizontal layout, left image, right editor
#' - Ctrl-Shift-v - switch to vertical layout, top image, bottom editor
#' 
#' ## DOT example
#' 
#' The GraphViz tools have native PNG output, so we just need 
#' to install the GraphViz tools, see above. Let's check our installation in the terminal by using the
#' `-V command line flag`:
#' 
#' ```
#' $ dot -V
#' dot - graphviz version 2.48.0 (0)
#' ```
#'
#' Ok, we are ready to go, start the user interface:
#' 
#' ```
#' $ pandoc-tcl-filter.tapp --gui &
#' ```
#' 
#' If you have installed *cairosvg* a sample tsvg script is shown and visualized.
#' Delete the content and enter some dot code like this:
#' 
#' ```
#' digraph G {
#'    rankdir=LR;
#'    node[shape=box,style=filled,fillcolor=skyblue];
#'    A -> B -> C;
#' }
#' ```
#' 
#' Save this file as *digraph.dot*. 
#' You should immediatly see the output in the image on top.
#' Add the line: `C -> D;` below the ABC line and use `Ctrl-s` to save the file.
#' You should see immediately the changes in the image. See below for the output:
#' 
#' ![](filter-view/demo-dot.png)
#' 
#' If you prefere having the image on the left and the editor on the right you can switch the layout using the Ctrl-Shift-h shortcut, to go back use the Ctrl-Shift-v shortcut.
#' 
#' ![](filter-view/demo-dot2.png)
#'
#' You can continue to change the graph, every time you save the file, the image will be updated.
#' The image you see will be stored in a folder images in parallel to your current working directory. In a future version explicit saving as PNG, SVG or PDF might be supported.
#' 
#' For more information about the GraphViz tools you should consult the GraphViz documentation at:
#' [https://graphviz.org/](https://graphviz.org/).
#' 
#' ## Fossil example
#' 
#' In contrast to the GraphViz tools, *fossil pikchr* allows more explicit layout mechanism. Let's install fossil, 
#' you can either download the last recent binary from the fossil site: 
#' [https://fossil-scm.org/home/uv/download.html](https://fossil-scm.org/home/uv/download.html) 
#' and unpack and install the single file binary to a folder belonging to your PATH. 
#' Usually you should install it using your package manager as described above.
#' 
#' The fossil application since version 2.13 has a *pikchr* subcommand which allows us to create
#' SVG images based on the Pikchr language. For a manual about the Pikchr language look here:
#' [https://pikchr.org/home/doc/trunk/doc/userman.md](https://pikchr.org/home/doc/trunk/doc/userman.md).
#' 
#' Let's first check if our fossil has pikchr support:
#' 
#' ```
#' $ fossil version
#' This is fossil version 2.17 [f48180f2ff] 2021-10-09 14:43:10 UTC
#' $ fossil help pikchr | head -n 1
#' Usage: fossil pikchr [options] ?INFILE? ?OUTFILE?
#' ```
#' 
#' Ok, we have *pikchr* support. Let's create a new file in our editor and let's enter some *pikchr* commands:
#' 
#' ```
#' down
#'     line
#'     box  "Hello,"  "World!" fill salmon;
#'     arrow
#'     box "filter-view" "pik-demo" fill cornsilk
#' ```
#' 
#' If we save this file as *test2.pik* we should see the following output:
#' 
#' ![](filter-view/demo-pik.png)
#' 
#' In case you made an error, the text widget will be shortly marked as salmon and a
#' more ore less useful error message will be displayed in the
#' statusbar at the bottom. More examples could be found at the Pikchr filter manual page: [filter/filter-pik.html](filter/filter-pik.html).
#' 
#' ## LaTeX example
#' 
#' The LaTeX filter needs at least two LaTeX packages, 
#' the package *standalone* and the package *amsmath*, the latter should
#' be installed per default, the former should be installed using your package manager as 
#' described above (Fedora: `sudo dnf install texlive-standalone`).
#' 
#' Here an example for visualizing an equation:
#' 
#' ```
#' $ E = mc^2 $
#' ```
#' 
#' Should, after saving the text as for instance as *einstein.mtex*
#' immediately display the equation.
#'  
#' If you create graphics with other packages you must load the packages explicity, that will be done like in the code chunks within Markdown documents. Let's install the sudoku package: `sudo dnf install texlive-sudoku`. And enter the following code:
#' 
#' ```
#' %```{.mtex packages="sudoku"}
#' \begin{sudoku}
#' |2|5| | |3| |9| |1|.
#' | |1| | | |4| | | |.
#' |4| |7| | | |2| |8|.
#' | | |5|2| | | | | |.
#' | | | | |9|8|1| | |.
#' | |4| | | |3| | | |.
#' | | | |3|6| | |7|2|.
#' | |7| | | | | | |3|.
#' |9| |3| | | |6| |4|.
#' \end{sudoku}
#' %```
#' ```
#' 
#' The comment character is required to protect the chunk options
#' against LaTeX interpretation. After saving the file for instance as
#' *sudoku.mtex* you should see the following output:
#' 
#' ![](filter-view/demo-mtex.png)
#' 
#' More examples can be found in the filter-mtex manual [filter/filter-mtex.html]([filter/filter-mtex.html])
#' 
#' ## Other examples
#' 
#' TODO - R, Graphviz neato, tsvg, tdot
#' 
#' 
#' ## AUTHOR
#' 
#' Dr. Detlef Groth, Schwielowsee, Germany.
#' 
