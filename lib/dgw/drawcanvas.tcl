#' ---
#' documentclass: scrartcl
#' title: dgw::drawcanvas __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' ---
#' 
#' ## NAME
#'
#' **dgw::drawcanvas** - simple drawing tool to sketch some text, lines, rectangles ovals on the fly.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [KEY BINDINGS](#bindings)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHORS](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require Tk
#' package require snit
#' package require dgw::drawcanvas
#  dgw::drawcanvas patName ?options?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The widget **dgw::drawcanvas** provides a simple drawing surface to place, lines, rextangles, ovales and text
#' in different in a fast manner on a canvas. It is based on code in the Tclers Wiki: 
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::drawcanvas** *pathName ?-option value ...?*
#' 
#' > Creates and configures the **dgw::drawcanvas**  widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' As the **dgw::drawcanvas** is an extension of the standard Tk canvas widget 
#' it supports all method and options of this widget. 
#' The following option(s) are added by the *dgw::drawcanvas* widget:

# Richard Suchenwirth 2004-03-29 - As I needed to produce a dataflow drawing,
# and did not want to bother with commercial drawing tools, I just hacked up
# the following thingy. Most of the code, regarding editable text items on
# the canvas, is borrowed from Brent Welch's book, and only slightly
# modified. 


# You can draw rectangles, ovals, and lines and place text at any canvas
# position (multiline is possible, just type <Return> for a new line),
# depending on the mode selected with the radiobuttons on top. In "move"
# mode, you can obviously move items around, until they look right.
# Right-click on an item (in any mode) to delete it. To save your drawing as
# a JPEG image, type Control-S. (GIF was rejected because of "too many
# colors"... I thought I only had black and white?) 

# Many more bells and whistles (selection of font family/style/size, line
# width, colors etc.) are conceivable, but the following code just did what I
# wanted, so here it is: 

package require Tk
package require snit 
package provide dgw::drawcanvas 0.1
namespace eval ::dgw {}
snit::widget ::dgw::drawcanvas {
    # http://www.science.smith.edu/dftwiki/index.php/Color_Charts_for_TKinter
    #' 
    #' __-colors__ _colorList_
    #'
    #' > List of colors which can be used to fill ovals and rectangles. Those colors are a set of pastel like colors.
    #' 
    option -colors [list linen azure orange salmon "pale green" "yellow green" "light blue" "deep sky blue" grey30 grey80]
    variable g
    variable can
    delegate option * to can
    delegate method * to can
    constructor {args} {
        $self configurelist $args
        set g(mode) ""
        frame $win.r
        if {[lsearch [font families] "Alegreya SC"] > -1} {
            font create canvfont -family "Alegreya SC" -size 20
        } else {
            font create canvfont -family Helvetica -size 20
        }
        pack [ttk::button $win.r.save -image filesaveas16] -side left -padx 3 -pady 5 
        pack [ttk::button $win.r.plus  -image viewmag+16 -command [mymethod changeSize +5]] -side left -padx 3 -pady 5 
        pack [ttk::button $win.r.minus -image viewmag-16 -command [mymethod changeSize -5]] -side left -padx 3 -pady 5 
        pack [ttk::button $win.r.erase -image actcross16 -command [mymethod eraseAll]] -side left -padx 3 -pady 5 

        foreach btn {move text line arrow rect oval} {
            pack [radiobutton $win.r.b$btn -indicatoron 0 -width 6 -text $btn -value $btn -var [myvar g(mode)]] -side left -fill x -padx 5 -pady 5
        }
        pack $win.r -side top -fill x -expand false         
        set g(col) [lindex $options(-colors) 0]
        foreach btn  $options(-colors) {
            pack [frame $win.r.f$btn -background $btn -borderwidth 0] -padx 1 -pady 5 -ipadx 1 -ipady 1 -side left
            pack [radiobutton $win.r.f${btn}.btn -background $btn -variable [myvar g(col)] -value $btn -indicatoron 0 -width 2 -relief ridge -borderwidth 0] -side top -padx 5 -pady 5 -anchor center -fill both -expand true
        }
        pack [canvas $win.c -bg white] -fill both -expand 1
        set can $win.c
        $win.r.save configure -command [mymethod canvas_save $can]
        trace var g(mode) w [mymethod changeMode $can]

        bind $win.c <Button-3> {%W delete withtag current}
        bind $win.c <Control-s> [mymethod canvas_save %W]
        set g(mode) rect
        bind $can <Control-plus> [mymethod changeFontSize +2]                
        bind $can <Control-minus> [mymethod changeFontSize -2]
        bind $can <Control-a> { puts A }
        $can bind current <Control-B> { puts B }
        $can bind text <Control-plus> [mymethod changeFontSize +5]
        $can bind text <Control-minus> [mymethod changeFontSize -5]
        #bind . <Escape> {exec wish $argv0 &; exit}

    }
    typeconstructor {
        ttk::style layout ToolButton [ttk::style layout TButton]
        ttk::style configure ToolButton [ttk::style configure TButton]
        ttk::style configure ToolButton -relief groove
        ttk::style configure ToolButton -borderwidth 2
        ttk::style configure ToolButton -padding {2 2 2 2} 

        image create photo filesaveas16 -data {
            R0lGODlhEAAQAIQAAAQCBPwCBPz+/PTizCQeHDQyNBweHAQGBAwKBDQ2NPzu
            5PTi3ERGRCQiJHR2dPTi1CwqLPz6/Mya/Mxm/GQCzFRWVGRmZAwODFxeXExO
            TExKTERCRBQWFMTCxKSipMzKzCH5BAEAAAEALAAAAAAQABAAAAV9ICCOQWkG
            IiqsQloCKCqy7UC8MC4URSsMhsDBNWOJEK4TYJfoGU8vmmJBGI5SyyYj0XDQ
            jMvVQwBxRCQTilowFGwrjG5kTo+0x4OdpcLvV0YXIhcGGH0ZFRobOSccfB2P
            HR4FiyYAGQwdAI8eEAdQKBsZmR+RBpSVVyMHfiEAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }
        image create photo viewmag+16 -data {
            R0lGODlhEAAQAIUAAPwCBCQmJDw+PAwODAQCBMza3NTm5MTW1HyChOTy9Mzq
            7Kze5Kzm7OT29Oz6/Nzy9Lzu7JTW3GTCzLza3NTy9Nz29Ize7HTGzHzK1AwK
            DMTq7Kzq9JTi7HTW5HzGzMzu9KzS1IzW5Iza5FTK1ESyvLTa3HTK1GzGzGzG
            1DyqtIzK1AT+/AQGBATCxHRydMTCxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaB
            QIAQEBAMhkikgFAwHAiC5FCASCQUCwYiKiU0HA9IRAIhSAcTSuXBsFwwk0wy
            YNBANpyOxPMxIzMgCyEiHSMkGCV+SAQQJicoJCllUgBUECEeKhAIBCuUSxMK
            IFArBIpJBCxmLQQuL6cAsLECrqeys7WxpqZdtK9Ct8C0fsHAZn5BACH+aENy
            ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
            IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
            ZGV2ZWxjb3IuY29tADs=
        }
        image create photo viewmag-16 -data {
            R0lGODlhEAAQAIUAAPwCBCQmJDw+PAwODAQCBMza3NTm5MTW1HyChOTy9Mzq
            7Kze5Kzm7OT29Oz6/Nzy9Lzu7JTW3GTCzLza3NTy9Nz29Ize7HTGzHzK1AwK
            DMTq7Kzq9JTi7HTW5HzGzMzu9KzS1IzW5Iza5FTK1ESyvLTa3HTK1GzGzGzG
            1DyqtIzK1AT+/AQGBATCxHRydMTCxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ+
            QIAQEBAMhkikgFAwHAiC5FCASCQUCwYiKiU0HA9IRAIhSAcTSuXBsFwwk0wy
            YNBANpyOxPMxIzMgCyEiHSMkGCV+SAQQJicoJCllUgBUECEeKhAIBCuUSxMK
            IFArBIpJBCxmLQQuL6eUAFCusJSzr7Kmpl0CtLGLvbW2Zn5BACH+aENyZWF0
            ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5
            OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2
            ZWxjb3IuY29tADs=
        }
        image create photo actcross16 -data {
            R0lGODlhEAAQAIIAAASC/PwCBMQCBEQCBIQCBAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAMuCLrc/hCGFyYLQjQsquLDQ2ScEEJjZkYfyQKlJa2j7AQn
            MM7NfucLze1FLD78CQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJz
            aW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVz
            ZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }

    }
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **dgw::drawcanvas** widget supports all usual methods of the Tk canvas widget and it adds the follwing method(s):
    #' 
    #' *pathName* **eraseAll** *?ask?*
    #' 
    #' > Deletes all items in the widget, if ask is true (default), then the user will get a message box to agree on deleting all items.
    #' 
    
    method eraseAll {{ask true}} {
        if {$ask} {
            set answer [tk_messageBox -title "Delete?!" -message "Really delete all items?" -type yesno -icon question]
            if { $answer } {
                # so delete 
                $can delete all
            } 
        } else {
            $can delete all
        }

    }
    method changeSize {i} {
        $self canvas_cmove $can $i
        #puts [$can itemcget $g(id) -tags]
    }
    method changeFontSize {i} {
        set fnt [$can itemcget text -font]
        set size [font configure  $fnt -size]
        if {$size < 0} {
            # pixel
            incr size [expr {$i*-1}]
        } else {
            incr size $i
        }
        font configure $fnt -size $size
        #return ""
    }


    method changeMode {w args} {
        bind $w <ButtonRelease-1> {}
        $w focus ""
        switch -- $g(mode) {
            move { $self canvas_movable $w }
            text { $self Canvas_EditBind $w }
            line { $self canvas_drawable line $w }
            arrow { $self canvas_drawable arrow $w }            
            rect { $self canvas_drawable rect $w }
            oval { $self canvas_drawable oval $w }
        }
    }
    
    #' *pathName* **saveCanvas** *?fileName?*
    #' 
    #' > Saves the content of the canvas either as ps or if the ghostscript 
    #' interpreter is available as well as pdf file using the given filename. If the filename is not given
    #'  the user will be asked for one.
    #' 
    method saveCanvas {{filename ""}} {
        $self canvas_save $can $filename
    }
    method canvas_save {w {filename ""}} {
        if {$filename eq ""} {
            set filename [tk_getSaveFile -defaultextension .ps \
                          -filetypes {{"PDF files" *.pdf} {"Postscript files" *.ps} {"All files" *}}]
        }
        if {$filename ne ""} {
            if {[file extension $filename] eq ".ps"} {
                $w postscript -file $filename
            } else {
                if {[auto_execok gs] eq ""} {
                    tk_messageBox -title "Error!" -icon error -message "You need a ghostscript interpreter to create pdf's" -type ok
                    return
                }
                set psfile ""
                foreach dir [list /tmp c:/tmp c:/temp] {
                    set psfile [file join $dir temp.ps]
                }
                if {$psfile eq ""} {
                    foreach v [list TEMP TMP TMPDIR] {
                        if {[info exists $::env($v)]} {
                            set psfile [file join $::env($v) temp.ps]
                            break
                        }
                    }
                }
                if {$psfile ne ""} {
                    $w postscript -file $psfile
                    exec gs -sDEVICE=pdfwrite -sOutputFile="$filename" -dNOPAUSE -dEPSCrop -c "<</Orientation 2>> setpagedevice" -f $psfile -dBATCH -c quit
                    file remove $psfile
                } else {
                    tk_messageBox -title "Error!" -icon error -message "Could not find a temporary directory where to write the file!" -type ok
                }
            }
        }
        # gs -sDEVICE=pdfwrite -sOutputFile="test.pdf" -dNOPAUSE -dEPSCrop -c "<</Orientation 2>> setpagedevice" -f "test.ps" -dBATCH -c quit
    }
    method doMovable {w x y} {
        set g(id)  [$w find withtag current] 
        set g(x) [$w canvasx $x] 
        set g(y) [$w canvasy $y]
        if {[info exists g(type)]} {
            if {$g(type) eq "text"} {
                $w raise $g(id)
            } else {
                $w lower $g(id)
            }
        }
        
    }
    method canvas_movable w {
        bind $w <Button-1> [mymethod doMovable %W %x %y]
        bind $w <B1-Motion> [mymethod canvas_move %W %x %y]
        #bind $w <Control-B1-Motion> [mymethod canvas_cmove %W %x %y 5]

        #bind $w <Shift-B1-Motion> [mymethod canvas_cmove %W %x %y -5]
        bind $w <Control-c> { puts copy }
        foreach event {<Button-1> <B1-Motion>} {
            $w bind text $event {}
        }
        $w config -cursor {}
    }
    method canvas_cmove {w i} {
        foreach {x0 y0 x1 y1} [$w coord $g(id)] break
        if {![info exists x0]} {
            return
        }
        set x0 [expr $x0-$i]
        set y0 [expr $y0-$i]
        set x1 [expr $x1+$i]
        set y1 [expr $y1+$i]
        $w coords $g(id) $x0 $y0 $x1 $y1
        set g(x) $x0
        set g(y) $y1
    }
    method canvas_down {w x y i} {
        # did not work
        $w select from current @$x,$y
        #set g(id) [$can select current]
        if {![info exists g(id)]} {
            set g(id) $w focus
        }
        foreach {x0 y0 x1 y1} [$w coord $g(id)] break
        if {![info exists x0]} {
            return
        }
        set y0 [expr $y0-$i]
        set y1 [expr $y1+$i]
        $w coords $g(id) $x0 $y0 $x1 $y1
        set g(x) $x0
        set g(y) $y1
    }
    method canvas_move {w xn yn} {
        $w move $g(id) [expr {$xn-$g(x)}] [expr {$yn-$g(y)}]
        set g(x) $xn
        set g(y) $yn
        if {[info exists g(type)]} {
            if {$g(type) eq "text"} {
                $w raise $g(id)
            } else {
                $w lower $g(id)
            }
        }
    }
    method doDrawable {w x y} {
        set g(x) $x
        set g(y) $y
        if {$g(type) eq "arrow"} {
            set g(id) [$w create line $g(x) $g(y) $g(x) $g(y) -width 5 -fill $g(col) -arrow last -arrowshape {20 40 10}]
        } else {
            set g(id) [$w create $g(type) $g(x) $g(y) $g(x) $g(y) -width 5 -fill $g(col)]
        }
        
    }
    method canvas_drawable {btype w} {
        set g(type) $btype
        bind $w <Button-1> [mymethod doDrawable %W %x %y]
        bind $w <B1-Motion> [mymethod canvas_draw %W %x %y]
        if {$btype in [list line arrow]} {
            bind $w <ButtonRelease-1> [mymethod canvas_straighten %W]
        }
        foreach event {<Button-1> <B1-Motion>} {$w bind text $event {}}
        $w config -cursor lr_angle
    }
    method canvas_draw {w xn yn} {
        set coords [concat [lrange [$w coords $g(id)] 0 1] $xn $yn]
        $w coords $g(id) $coords
    }
    method canvas_straighten w {
        set id [$w find withtag current]
        foreach {x0 y0 x1 y1} [$w coords $id] break
        if {abs($x0-$x1)<4 && abs($y0-$y1)>10} {set x1 $x0}
        if {abs($y0-$y1)<4 && abs($x0-$x1)>10} {set y1 $y0}
        $w coords $id $x0 $y0 $x1 $y1 
    }
    #-- Code from the Welch book
    
    method Canvas_EditBind { c } {
        bind $c <Button-1> [mymethod CanvasFocus $c %x %y]
        bind $c <Button-2> [mymethod CanvasPaste $c %x %y]
        bind $c <<Cut>>    [mymethod CanvasCut %W]
        bind $c <<Copy>>   [mymethod CanvasTextCopy %W]
        bind $c <<Paste>>  [mymethod CanvasPaste %W]
        $c bind text <Button-1>  [mymethod CanvasTextHit %W %x %y]
        $c bind text <B1-Motion> [mymethod CanvasTextDrag %W %x %y]
        $c bind text <Delete>    [mymethod CanvasDelete %W]
        $c bind text <Control-d> [mymethod CanvasDelChar %W]
        $c bind text <BackSpace> [mymethod CanvasBackSpace %W]
        $c bind text <Control-Delete> [mymethod CanvasErase %W]
        $c bind text <Return> [mymethod CanvasInsert %W \n]
        $c bind text <Any-Key> [mymethod CanvasInsert %W %A]
        $c bind text <Key-Right> [mymethod CanvasMoveRight %W]
        $c bind text <Key-Left> [mymethod CanvasMoveLeft %W]
        # did not work, like to move canvas item with keyboard 
        #$c bind text <Key-Down> [mymethod canvas_down %W %x %y -5]
        $c config -cursor xterm
    }
    method CanvasCut {c} {
        $self CanvasTextCopy $c
        $self CanvasTextDelete $c
    }
    method CanvasFocus {c x y} {
        focus $c
        set id [$c find overlapping [expr $x-2] [expr $y-2] \
                [expr $x+2] [expr $y+2]]
        if {($id == {}) || ([$c type $id] != "text")} {
            set t [$c create text $x $y -text "" \
                   -tags text -anchor nw -font canvfont]
            $c focus $t
            $c select clear
            $c icursor $t 0
            $c raise $t
        }
    }
    method CanvasTextHit {c x y {select 1}} {
        $c focus current
        $c icursor current @$x,$y
        $c select clear
        $c select from current @$x,$y
    }
    method CanvasTextDrag {c x y} {
        $c select to current @$x,$y
        $c raise current
    }
    method CanvasDelete {c} {
        if {[$c select item] != {}} {
            $c dchars [$c select item] sel.first sel.last
        } elseif {[$c focus] != {}} {
            $c dchars [$c focus] insert
        }
    }
    method CanvasTextCopy {c} {
        if {[$c select item] != {}} {
            clipboard clear
            set t [$c select item]
            set text [$c itemcget $t -text]
            set start [$c index $t sel.first]
            set end [$c index $t sel.last]
            clipboard append [string range $text $start $end]
        } elseif {[$c focus] != {}} {
            clipboard clear
            set t [$c focus]
            set text [$c itemcget $t -text]
            clipboard append $text
        }
    }
    method CanvasDelChar {c} {
        if {[$c focus] ne {}} {
            $c dchars [$c focus] insert
        }
    }
    method CanvasBackSpace {c} {
        if {[$c select item] != {}} {
            $c dchars [$c select item] sel.first sel.last
        } elseif {[$c focus] != {}} {
            set _t [$c focus]
            $c icursor $_t [expr {[$c index $_t insert]-1}]
            $c dchars $_t insert
        }
    }
    method CanvasErase  {c}       {$c delete [$c focus]}
    
    method CanvasInsert {c char}  {$c insert [$c focus] insert $char}
    
    method CanvasPaste  {c {x {}} {y {}}} {
        if {[catch {selection get} _s] &&
            [catch {selection get -selection CLIPBOARD} _s]} {
            return         ;# No selection
        }
        set id [$c focus]
        if {[string length $id] == 0 } {
            set id [$c find withtag current]
        }
        if {[string length $id] == 0 } {
            # No object under the mouse
            if {[string length $x] == 0} {
                # Keyboard paste
                set x [expr {[winfo pointerx $c] - [winfo rootx $c]}]
                set y [expr {[winfo pointery $c] - [winfo rooty $c]}]
            }
            $self CanvasFocus $c $x $y
        } else {
            $c focus $id
        }
        $c insert [$c focus] insert $_s
    }
    method CanvasMoveRight {c} {
        catch {
            $c icursor [$c focus] [expr [$c index current insert]+1]
        }
    }
    method CanvasMoveLeft {c} {
        catch {
            $c icursor [$c focus] [expr [$c index current insert]-1]
        }
    }
}





#' ## <a name='example'>EXAMPLE</a>
#'
#' In the example below we create a Markdown markup aware text editor.
#' 
#' ```
#' package require dgw::drawcanvas
#' dgw::drawcanvas .dc
#' pack .dc -side top -fill both -expand true
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --code
#' ```
#' #include "documentation.md"
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets
#'
#'  
#' ## <a name='changes'>CHANGES</a>
#'
#' * 2020-03-27 - version 0.1 started
#'
#' ## <a name='todo'>TODO</a>
#' 
#' * github url
#'
#' ## <a name='authors'>AUTHORS</a>
#'
#' The dgw::**__PKGNAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>Copyright</a>
#'
#' Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
# LICENSE START
#
#' #include "license.md"
#
# LICENSE END

if {[info exists argv0] && [info script] eq $argv0 && [regexp drawcanvas $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    package require dgw::dgwutils
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        dgw::runExample [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a canvas sketch surface for"
        puts "  fast sketching of text, lines, rectangles and ovals"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install ${dpath}::$pfile as Tcl module"        
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts ""
        puts ""
    }

}


#pack [dgw::drawcanvas .dc] -side top -fill both -expand true

