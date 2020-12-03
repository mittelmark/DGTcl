##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Nov 2 20:24:20 2020
#  Last Modified : <201203.0637>
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
#' title: chesschart 0.2 
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
#'      - [arrow](#arrow) 
#'      - [background](#background)
#'      - [figure](#figure)
#'      - [line](#line)
#'      - [mv](#mv)
#'      - [oval](#oval)
#'      - [rect](#rect)
#'      - [spline](#spline)
#'      - [text](#text)
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


package require Tk
package require snit
catch {
    package require canvas::snap
}

# TODO: splines with arrows using libtclspline
# load ../libs/tclspline/libtclspline1.1.so
# package require tclspline
# rename ::spline ::tspline

package provide chesschart 0.2

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

snit::widget ::chesschart {
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
    
    #'   __-columns__ _colnames_ 
    #' 
    #'  > Default column names for the coordinate system, starting from left to 
    #'    right, default: letters [list A B C D E F G H], which mimic a chessboard.
    #'    There are other coordinate systems possible for instance [list Mo Tu We Th Fr Sa Su] to create a weekly schedule, 
    #' 
    option -columns [list A B C D E F G H]

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
    
    #'   __-rows__ _rows_ 
    #' 
    #'  > Default row names for the coordinate system, starting from top to 
    #'    bottom, default: numbers 8 to 1: [list 8 8 6 5 4 3 2 1], which mimic 
    #'    together with the columns A:H chessboard.
    #'    There are other coordinate systems possible for instance 
    #'    [list 08 10 12 16 18 20] together with the weekdays can create
    #'    a time scheduler for the week.
    #' 
    option -rows [list 8 7 6 5 4 3 2 1]
    
    #'   __-xincr__ _100_ 
    #' 
    #'  > Default incr in pixel per coordinate system in x-direction
    #' 
    option -xincr 100
    
    #'   __-yincr__ _100_ 
    #' 
    #'  > Default incr in pixel per coordinate system in y-direction.
    #' 
    option -yincr 80

    variable can
    delegate option * to can
    delegate method * to can
    variable apos
    variable TopX
    variable TopY
    variable BotX
    variable BotY
    constructor {args} {
        install can using canvas $win.c -width 820 -height 660 
        $self configurelist $args
        pack $can -padx  0 -pady 0 -side top -fill both \
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
    #'   - _color_ col - the color of the arrow, default: black
    #'
    method arrow {from to args} {
        array set arg [list -width 3 -cut 0.6 -color black]
        array set arg $args
        set fromx [lindex $apos($from) 0]
        set fromy [lindex $apos($from) 1]
        set tox   [lindex $apos($to) 0]
        set toy   [lindex $apos($to) 1]
        set arrx [expr {($fromx+$tox)/2}]
        set arry [expr {($fromy+$toy)/2}]
        set arrx [expr {(1 - $arg(-cut)) * $fromx + $arg(-cut) * $tox}]
        set arry [expr {(1 - $arg(-cut)) * $fromy + $arg(-cut) * $toy}]        
        $win.c create line $fromx $fromy $arrx $arry -arrow last -width $arg(-width) -tag [list arrow $from$to] -smooth true -arrowshape [list 20 20 5] -fill $arg(-color)
        $win.c create line $fromx $fromy $tox $toy -arrow last -width $arg(-width) -tag [list arrow $from$to] -smooth true -fill $arg(-color)
        $win.c lower arrow
        if {[$win.c type background] ne ""} {
            $win.c raise arrow background
        }

        return ""
    }
    #' <a name='background'>*pathName* **background** *-color white*</a>
    #' 
    #' > Draw and background over the current coordinate system.
    #'   This will instruct snap tools like the *canvas::snap* package from
    #'   tklib to snap the complete coordinate system regardless if their are
    #'   already items or not.
    #'
    #' >  The following argument to modify the background is available:
    #' 
    #' > - _-color white_ - the strength of the arrow, default: 3
    #' 
    #' > An item with the tag *background* is created.
    #'
    method background {top bottom args} {
        array set arg [list -color white]
        array set arg $args
        $self getCoords
        $can create rectangle \
              [expr {[lindex $apos($top) 0]-$options(-xincr)*0.5}] \
              [expr {[lindex $apos($top) 1]-$options(-yincr)*0.5}] \
              [expr {[lindex $apos($bottom) 0]+$options(-xincr)*0.5}] \
              [expr {[lindex $apos($bottom) 1]+$options(-yincr)*0.5}] \
              -fill $arg(-color) -outline $arg(-color) -tag [list background]
        
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
            error "Package canvas::snap not available for creating png images"
        }
    }    
    # private
    onconfigure -columns cols {
        set options(-columns) $cols
        $self getCoords
    }
    onconfigure -rows rows {
        set options(-rows) $rows
        $self getCoords
    }
    onconfigure -xincr val {
        set options(-xincr) $val
        $self getCoords
    }
    onconfigure -yincr val {
        set options(-yincr) $val
        $self getCoords
    }
    method getCoords {} {
        #array unset apos
        array set apos [list]
        set x 50
        set TopX $x
        set BotX $x
        foreach col $options(-columns) {
            incr x $options(-xincr)
            set BotX $x 
            set y 50
            set TopY $y
            foreach row $options(-rows) {
                incr y $options(-yincr)
                set apos($col$row) [list $x $y]
            }
            set BotY $y
        }
        incr BotX $options(-xincr)
        incr BotY $options(-yincr)
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
    #' <a name='line'>*pathName* **line** *from to args*</a>
    #' 
    #' > Draw an line *from* position 1 *to* position 2. 
    #'   The resulting line gets the tags *line* and *pos1pos2*.
    #'   Positions can be currently only given using chessboard 
    #'   coordinates like A1, C7, etc.
    #'
    #' > The following additional argument to modify the line item is available:
    #' 
    #' > - _-width px_ - the strength of the arrow, default: 3
    #'   - _-color_ color - the color for the line
    #'
    method line {from to args} {
        array set arg [list -width 3 -color black]
        array set arg $args
        set fromx [lindex $apos($from) 0]
        set fromy [lindex $apos($from) 1]
        set tox   [lindex $apos($to) 0]
        set toy   [lindex $apos($to) 1]
        $win.c create line $fromx $fromy $tox $toy -width $arg(-width) \
              -fill $arg(-color) -tag [list line $from$to]
        $win.c lower line
        if {[$win.c type background] ne ""} {
            $win.c raise line background
        }
        return ""
    }
    #' <a name='spline'>*pathName* **spline** *from over to args*</a>
    #' 
    #' > Draw an smoothed line from pos *from* to pos *to* using *over* as the 
    #'   spline anker. The resulting spline gets the tags *line* and *fromoverto*.
    #'   Positions can be currently given using chessboard coordinates like A1, C7, 
    #'   or using a coordinate system created using the widgets options 
    #'   *-rows* and *-columns*.
    #'
    #' > The following additional argument to modify the line item is available:
    #' 
    #' > - _-width px_ - the strength of the arrow, default: 3
    #'   - _-color_ color - the color for the spline
    #'   - _splinesteps_ - number of smothing
    #'
    method spline {from over to args} {
        array set arg [list -width 3 -color black -splinesteps 10]
        array set arg $args
        set fromx [lindex $apos($from) 0]
        set fromy [lindex $apos($from) 1]
        set overx [lindex $apos($over) 0]
        set overy [lindex $apos($over) 1]
        set tox   [lindex $apos($to) 0]
        set toy   [lindex $apos($to) 1]
        if {[info commands ::tspline] eq "::tspline"} {
            # arrows did not look good
            set coords [tspline $arg(-splinesteps) [list $fromx $fromy $overx $overy $tox $toy]]
            set l [llength $coords]
            set i [expr {$l/2+2}]
            $win.c create line {*}$coords \
              -width $arg(-width) -fill black -tag [list spline $from$over$to] \
              -smooth true
            $win.c create line {*}[lrange $coords 0 $i]\
              -width $arg(-width) -fill black -tag [list spline $from$over$to] \
              -smooth true -arrow last

        } else {
            $win.c create line $fromx $fromy $overx $overy $tox $toy \
                  -width $arg(-width) -fill $arg(-color) -tag [list spline $from$over$to] \
                  -smooth true -splinesteps $arg(-splinesteps)
        }
        $win.c lower spline
        if {[$win.c type background] ne ""} {
            $win.c raise spline background
        }
        return ""
    }
    
    #' <a name='mv'>*pathName* **mv** *from to*</a>
    #' 
    #' > Moves the items at pos from to pos to. To gradually shift items you should use the canvas move command (not really recommended).
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
            $win.c create text  [lindex $xy 0] [expr {[lindex $xy 1]+4}] -fill black -text $arg(-text) -font $options(-font) \
                  -tag [list text $pos]
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
                  -fill $arg(-color) -outline black -tag [list rect $pos]
        } else {
            $can create rectangle  $x1 $y1 $x2 $y2 \
                  -fill $arg(-color) -outline black -tag [list rect $pos]
        }
        if {$arg(-text) ne ""} {
            $win.c create text  [lindex $xy 0] [expr {[lindex $xy 1]+4}] -fill black -text $arg(-text) -font $options(-font) -tag [list text $pos]
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
#'
#' ```
#'  package require chesschart
#'  
#'  set chart [chesschart .chart -rectwidth 100 -rectheight 50 \
#'    -rows [list 10 9 8 7 6] -columns [list A B C D]] 
#'  pack $chart -side top -fill both -expand true
#'  $chart rect A8 -text Tcl/Tk
#'  $chart rect C8
#'  $chart oval C6 -text chesschart -width 120
#'  $chart line A8 C6
#'  $chart oval B10 -text tmdoc -width 120
#'  $chart oval B9 -text del -color "light blue"
#'  $chart arrow A8 B10 -cut 0.7
#'  $chart spline A8 B7 C8 -color red -width 5
#'  # canvas commands still work
#'  $chart itemconfigure oval -fill "light blue"
#'  $chart delete B9
#'  $chart move all +10 +80
#'
#'  catch {
#'    # requires canvas::snap from tklib
#'    $chart figure chesschart-example.png
#'  }
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
#' - Nov 10th 2020 
#'     - tags for rect fixed
#' - Nov 11th 2020 
#'     - option for rows and columns to change the coordinate system
#'     - color option for line 
#'     - adding spline (with three coordinates) 
#'     - adding  tutorial
#' - Dec 3rd 2020 - version 0.2
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
#' Chesschart - Tcl/Tk widget to display flowcharts, version 0.2.
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

