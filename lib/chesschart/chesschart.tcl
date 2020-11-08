##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Nov 2 20:24:20 2020
#  Last Modified : <201108.0934>
#
#  Description	 : creating flow charts using natural coordinate systems like 
#                  chessboard coordinates  
#  Notes         : TODO - coordinate Wkday:HH Sa10
#
#  History       : November 2nd, 2020 project started
#	
##############################################################################
#
#  Copyright (c) 2020 Dr. Detlef Groth.
# 
#  License       : MIT (see below)
#
##############################################################################

#' ---
#' title: chesschart 0.1 
#' author: Dr. Detlef Groth, Schwielowsee, Germany
#' documentclass: scrartcl
#' geometry:
#' - top=20mm
#' - right=20mm
#' - left=20mm
#' - bottom=30mm
#' output: 
#'   css: "dgw.css"
#' ---
#'
#' ## <a>NAME</a>
#'
#' **chesschart**  - Tk widget based on canvas to create flow charts using natural 
#'                    coordinate systems like the chessboard coordinate system.
#'
#' ## <a name='toc'>TABLE OF CONTENTS</a>
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'    - [arrow](#arrow) 
#'    - [figure](#figure)
#'    - [line](#line)
#'    - [mv](#mv)
#'    - [oval](#oval)
#'    - [rect](#rect)
#'    - [text](#text)
#'  - [EXAMPLE](#example)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE AND COPYRIGHT](#license)
#'
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require chesschart
#' chesschart pathName ?canvasoptions chesschartoption?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **chesschart** - is a flowchart widget based on the standard Tk canvas. Items like rectangles, ovals, 
#' circles, text, arrow, lines can be placed on the widget using an easy to remember coordiate system
#' such as chess coordinates. As the **chesschart** widget is based on the Tk canvas widget, all options 
#' and methods of the widget are support. See below for additional options and methods.
#' 
lappend auto_path [file join [file dirname [info script]] .. libs]

package require Tk
package require snit
catch {
    package require canvas::snap
}
package provide chesschart 0.1

#'
#' ## <a name='command'>COMMAND</a>
#'
#' **chesschart** *pathName ?canvas options chesschart options?*
#' 
#' > Creates and configures a new **chesschart** widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' The **chesschart** widget is Tk widget based on the standard Tk canvas widget.
#' It therefore supports the standard options and commands of the canvas widget.
#' 
#' The **chesschart** widgets modifies a few default options of the canvas widget and
#' adds the following options in addition to the options available for the canvas widget:

snit::widget chesschart {
    #' 
    
    #'   __-bg__ _color_ 
    #' 
    #'  > Default background for the canvas widget, here changed to white.
    #' 
    option -bg -default white
    
    #'   __-color__ _color_ 
    #' 
    #'  > Default color for oval and rect items, default: salmon
    #' 
    option -color salmon
    
    #'   __-font__ _fontname_ 
    #' 
    #'  > Default font for the text items on the widget, defaults to times16, there are as well 
    #'    times10, times12, times14, times16, times18, times20, times24, times28 available. 
    #'    During construction the widget as well tries to initialize nice the true type font Purisa
    #'    which must be downloaded from the internet: [https://www.onlinewebfonts.com/fonts/purisa](https://www.onlinewebfonts.com/fonts/purisa) to use it. It is then available as well in the sizes purisa10 ... purisa28.
    #' 
    option -font -default times16
    
    #'   __-ovalheight__ _px_ 
    #' 
    #'  > Default height of oval items, default: 70. If height and weight of ovals are the same
    #'    you get an circle. If height and weight of ovals are the same
    #'    you get an circle. Default for both is 70 - you get a circle per default.
    #' 
    option -ovalheight 70
    
    #'   __-ovalwidth__ _px_ 
    #' 
    #'  > Default width of oval items, default: 70. 
    #' 
    option -ovalwidth  70
    
    #'   __-rectheight__ _px_ 
    #' 
    #'  > Default height of rect items, default: 40.
    #' 
    option -rectheight 40
    
    #' 
    #'   __-rectwidth__ _px_ 
    #' 
    #'  > Default width of rect items, default: 80.
    #' 
    option -rectwidth  80
    
    variable can
    delegate option * to can
    delegate method * to can
    variable apos
    constructor {args} {
        install can using canvas $win.c -width 820 -height 660 
        $self configurelist $args
        pack $can -padx  5 -pady 5 -side top -fill both \
              -expand yes
        array set apos [$self getCoords]
        
    }
    typeconstructor {
        catch {
            # https://www.onlinewebfonts.com/fonts/purisa
            foreach size [list 10 12 14 16 18 20 24 28] {
                font create purisa$size -family "Purisa" -size $size
            }
        }
        catch {
            foreach size [list 10 12 14 16 18 20 24 28] {
                font create times$size -family "Times" -size $size
            }
        }
    }
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **chesschart** widgets supports all the Tk canvas commands. 
    #' Further additional methods are implmented which should be the major
    #' methods used by the chesschart user to create flow charts.
    #'
    #' <a name='arrow'>*pathName* **arrow** *pos1 pos2 args*</a>
    #' 
    #' > Draw and arrow from pos1 to pos2. The resulting arrow gets the tags *arrow* and *pos1pos2*.
    #'   Positions can be currently only given using chessboard coordinates like A1, C7, etc.
    #'
    #' >  The following additional arguments to modify the item are available:
    #' 
    #' > - _-width px_ - the strength of the arrow, default: 3
    #'   - _-cut 0.0..1.0_ - the position of the arrow head, default: 0.6 
    #'
    method arrow {from to args} {
        array set arg [list -width 3 -cut 0.6]
        array set arg $args
        set fromx [lindex $apos($from) 0]
        set fromy [lindex $apos($from) 1]
        set tox   [lindex $apos($to) 0]
        set toy   [lindex $apos($to) 1]
        set arrx [expr {($fromx+$tox)/2}]
        set arry [expr {($fromy+$toy)/2}]
        set arrx [expr {(1 - $arg(-cut)) * $fromx + $arg(-cut) * $tox}]
        set arry [expr {(1 - $arg(-cut)) * $fromy + $arg(-cut) * $toy}]        
        $win.c create line $fromx $fromy $arrx $arry -arrow last -width $arg(-width) -tag [list arrow $from$to] -smooth true -arrowshape [list 20 20 5]
        $win.c create line $fromx $fromy $tox $toy -arrow last -width $arg(-width) -tag [list arrow $from$to] -smooth true
        $win.c lower arrow
        return ""
    }
    #'
    #' <a name='figure'>*pathName* **figure** *filename.png*</a>
    #' 
    #' > Saves the current items on the canvas into the given filename. 
    #'   This functionality currently with Tcl/Tk 8.6 requires the additional package 
    #'   *canvas::snap* from the *tklib* library.
    #' 
    method figure {filename args} {
        if {[lsearch [package names] canvas::snap] > -1} {
            set image [canvas::snap $win.c]
            $image write $filename -format png
        } else {
            error "Package cnavas::snap not available for creating png images"
        }
    }    
    # private
    method getCoords {} {
        array set apos [list]
        set x 50
        foreach col [list A B C D E F G H I J K L] {
            incr x 100
            set y 40
            foreach row [list 10 9 8 7 6 5 4 3 2 1 ] {
                incr y 80   
                set apos($col$row) [list $x $y]
            }
        }
        return [array get apos]
    }
    # private
    method rrect {x0 y0 x3 y3 radius args} {
        
        set r [winfo pixels $can $radius]
        set d [expr { 2 * $r }]
        
        # Make sure that the radius of the curve is less than 3/8
        # size of the box!
        
        set maxr 0.75
        
        if { $d > $maxr * ( $x3 - $x0 ) } {
            set d [expr { $maxr * ( $x3 - $x0 ) }]
        }
        if { $d > $maxr * ( $y3 - $y0 ) } {
            set d [expr { $maxr * ( $y3 - $y0 ) }]
        }
        
        set x1 [expr { $x0 + $d }]
        set x2 [expr { $x3 - $d }]
        set y1 [expr { $y0 + $d }]
        set y2 [expr { $y3 - $d }]
        
        set cmd [list $can create polygon]
        lappend cmd $x0 $y0
        lappend cmd $x1 $y0
        lappend cmd $x2 $y0
        lappend cmd $x3 $y0
        lappend cmd $x3 $y1
        lappend cmd $x3 $y2
        lappend cmd $x3 $y3
        lappend cmd $x2 $y3
        lappend cmd $x1 $y3
        lappend cmd $x0 $y3
        lappend cmd $x0 $y2
        lappend cmd $x0 $y1
        lappend cmd -smooth 1
        return [eval $cmd $args]
    }
    #' <a name='line'>*pathName* **line** *pos1 pos2 args*</a>
    #' 
    #' > Draw an line from pos1 to pos2. The resulting line gets the tags *line* and *pos1pos2*.
    #'   Positions can be currently only given using chessboard coordinates like A1, C7, etc.
    #'
    #' > The following additional argument to modify the line item is available:
    #' 
    #' > - _-width px_ - the strength of the arrow, default: 3
    #'
    method line {from to args} {
        array set arg [list -width 3]
        array set arg $args
        set fromx [lindex $apos($from) 0]
        set fromy [lindex $apos($from) 1]
        set tox   [lindex $apos($to) 0]
        set toy   [lindex $apos($to) 1]
        $win.c create line $fromx $fromy $tox $toy -width $arg(-width) -tag [list line $from$to]
        $win.c lower line
        return ""
    }
    #' <a name='mv'>*pathName* **mv** *pos1 pos2*</a>
    #' 
    #' > Moves the items at pos1 to pos2. To gradually shift items you should use the canvas move command (not really recommended).
    #'   Items at a certain coordinates have the position as an added tag.
    #'   Positions can be currently only given using chessboard coordinates like A1, C7, etc. The position tag will be updated automatically.
    #'
    method mv {from to} {
        set xyold $apos($from)
        set xy $apos($to)
        set x1 [expr {[lindex $xy 0] - [lindex $xyold 0]}]
        set y1 [expr {[lindex $xy 1] - [lindex $xyold 1]}]
        $can move $from $x1 $y1 
        $can addtag $to withtag $from
        $can dtag $to $from 
        return ""
    }
    #' <a name='oval'>*pathName* **oval** *pos args*</a>
    #' 
    #' > Adds a oval or cicle on the coordinate given with pos. 
    #'   Positions can be currently only given using chessboard coordinates like A1, C7, etc.
    #'   The coordinate system is currently limited to the letters A-L and the numbers 1-10.
    #'   To get a circle the options _-height_ and _-width_ should have the same value.
    #'   The resulting oval gets the tags *oval* and *pos*.
    #'   The following additional arguments to modify the item are available:
    #' 
    #' > - _-color colorname_ - fill color of the item, default: salmon
    #'   - _-height px_ - height of the oval, default: widget -ovalheight option
    #'   - _-width px_ -  width of the oval, default: widget -ovalwidth option
    #'   - _-text text_ - display text in the rectangle, default the given position, to display nothing give an empty string as argument
    #'
    method oval {pos args} {
        array set arg [list -color "salmon" -width $options(-ovalwidth) \
                       -height $options(-ovalheight) -text $pos]
        array set arg $args
        set xy $apos($pos)
        set x1 [expr {[lindex $xy 0] - $arg(-width)/2}]
        set y1 [expr {[lindex $xy 1] - $arg(-height)/2}]
        set x2 [expr {$x1 + $arg(-width)}]
        set y2 [expr {$y1 + $arg(-height)}]
        $win.c create oval  $x1 $y1 $x2 $y2 \
              -fill $arg(-color) -tag [list oval $pos]
        if {$arg(-text) ne ""} {
            $win.c create text  [lindex $xy 0] [lindex $xy 1] -fill black -text $arg(-text) -font $options(-font) -tag [list text $pos]
        }
        return ""

    }
    #' <a name="rect">*pathName* **rect** *pos args*</a>
    #' 
    #' > Adds a rectangle on the coordinate given with pos. 
    #'   Positions can be currently only given using chessboard coordinates like A1, C7 etc.
    #'   The coordinate system is currently limited to the letters A-L and the numbers 1-10.
    #'   The resulting rectange gets the tags *rect* and *pos*.
    #'   The following additional arguments to modify the item are available:
    #' 
    #' > - _-color colorname_ - fill color of the item, default: salmon
    #'   - _-height px_ - height of the rectangle, default: widget -rectheight option
    #'   - _-radius int_ - for rounded corners the radius, the larger the more round, default: 10
    #'   - _-round bool_ - should the rectangle have rounded corners, default: false
    #'   - _-width px_ -  width of the rectangle, default: widget -rectwidth option
    #'   - _-text text_ - display text in the rectangle, default the given position, to display nothing give an empty string as argument
    #'
    method rect {pos args} {
        array set arg [list -color salmon -width $options(-rectwidth) \
                       -height $options(-rectheight) -text $pos -round false \
                       -radius 10]
        array set arg $args
        set xy $apos($pos)
        set x1 [expr {[lindex $xy 0] - $arg(-width)/2}]
        set y1 [expr {[lindex $xy 1] - $arg(-height)/2}]
        set x2 [expr {$x1 + $arg(-width)}]
        set y2 [expr {$y1 + $arg(-height)}]
        if {$arg(-round)} {
            $self rrect $x1 $y1 $x2 $y2 $arg(-radius) \
                  -fill $arg(-color) -outline black
        } else {
            $can create rectangle  $x1 $y1 $x2 $y2 \
                  -fill $arg(-color) -outline black 
        }
        if {$arg(-text) ne ""} {
            $win.c create text  [lindex $xy 0] [lindex $xy 1] -fill black -text $arg(-text) -font $options(-font)
        }
        return ""
        
    }
    # method unknown {method args} {
        # instrad of delegation of methods
        # we intercept here to create the coordinates
        # if the command wasn't one of our special one's,
        # pass control over to the original canvas widget
        #
    #    if {[catch {$can $method {*}$args} result]} {
    #        return -code error $result
    #    }
    #    return $result
    # }
    
    #' <a name="test">*pathName* **text** *pos text*</a>
    #' 
    #' > At the coordinate given with pos place the given text,
    #'   The resulting text gets the tags *text* and *pos*.
    #'   Positions can be currently only given using chessboard coordinates like A1, C7, etc.
    #'
    
    method text {pos text} {
        set x [lindex $apos($pos) 0]
        set y [lindex $apos($pos) 1]
        $win.c create text  $x $y \
              -fill black -text $text -font $options(-font) -tag [list text $pos]
        return ""
    }
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#' ```
#'  package require chesschart
#'  
#'  set chart [chesschart .chart -rectwidth 100 -rectheight 50]
#'  pack $chart -side top -fill both -expand true
#'  $chart rect A8 -text Tcl/Tk
#'  $chart rect C8
#'  $chart oval C6 -text chesschart -width 120
#'  $chart line A8 C6
#'  $chart oval B10 -text tmdoc -width 120
#'  $chart oval B9 -text del -color "light blue"
#'  $chart arrow A8 B10 -cut 0.7
#'  # canvas commands still work
#'  $chart move all -10 -40
#'  $chart itemconfigure oval -fill "light blue"
#   $chart delete B9
#' ```
#'
#' ![chesschart example](chesschart-example.png "chesschart example")
#'
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish chesschart.tcl --demo
#' ```
#'
#' ## <a name='changes'>CHANGES</a>
#'
#' - Nov 2nd 2020 - project started
#' - Nov 8th 2020 - version 0.1 released
#'
#' ## <a name='todo'>TODO</a>
#'
#' - Other coordinate system likes WeekdayHour (Mo08, Sa10)
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **chesschart** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE</a>
#' 
#' Chesschart - Tcl/Tk widget to display flowcharts, version 0.1.
#'
#' Copyright (c) 2020  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#' 
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [package present chesschart]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "-d" || [lindex $argv 0] eq "--demo"} {
        # DEMO START
        set filename [info script]
        set extext ""
        set example false
        set excode false
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                # Process line
                if {$extext eq "" && [regexp -nocase \
                      {^\s*#'\s+#{2,3}\s.+Example} $line]} {
                    set example true
                } elseif {$extext ne "" && \
                         [regexp -nocase "^\\s*#'.*\\s# demo: $extext" $line]} {
                    set excode true
                } elseif {$example && [regexp {^\s*#'\s+>?\s*```} $line]} {
                    set example false
                    set excode true
                } elseif {$excode && [regexp {^\s*#'\s+>?\s*```} $line]} {
                    namespace eval :: $code
                    break
                    # eval code
                } elseif {$excode && [regexp {^\s*#'\s(.+)} $line -> c]} {
                    append code "$c\n"
                }
            }
            close $infh
            destroy .
        }
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--man"} {
        set filename [info script]
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                if {[regexp {^\s*#'\s(.+)} $line -> man]} {
                    puts $man
                } elseif {[regexp {^\s*#'\s*$} $line]} {
                    puts ""
                }
            }
            close $infh
            destroy .
        }
    } else {
        destroy .
        puts "\n    ---------------------------------"
        puts "     The chesschart package for Tcl/Tk"
        puts "    ---------------------------------\n"
        puts "Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe chesschart package provides a flowchart widget where text, rectangles,"
        puts "oval, circles, lines and arrows can be placed using chess coordinates."
        puts "It is used for programming graphical user interfaces with"
        puts "the Tcl/Tk Programming language"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : starting a demo"
        puts "        --man     : printing the man page in Github-markdown to the terminal"
        puts "        --version : printing the package version to the terminal"                
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [info script] --man | pandoc -t html -s > [file rootname [file tail [info script]]].html"

    }
}

