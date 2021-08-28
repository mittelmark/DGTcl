#!/usr/binenv tclsh
##############################################################################
#  Created By    : Dr. Detlef Groth
#  Created       : Sat Aug 28 09:52:16 2021
#  Last Modified : <210828.1129>
#
#  Description	 : Minimal tcl package to write SVG code and write it to 
#                  a file.
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#  License: MIT 
# 
#
##############################################################################


package provide tsvg 0.1

# minimal OOP
proc thingy name {
    proc $name args "namespace eval $name \$args"
} 

# does not work
interp alias {} self {} namespace current 

;# our object
thingy tsvg

;# some variables
tsvg set code "" ;# the svg code
tsvg set header {<?xml version="1.0" encoding="utf-8" standalone="yes"?>
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" height="__HEIGHT__" width="__WIDTH__">}    
tsvg set footer {</svg>}
tsvg set width 100
tsvg set height 100

tsvg proc tag {args} {
    variable code
    set tag [lindex $args 0]
    set args [lrange $args 1 end]
    set ret "\n<$tag"
    # new check if attr="val" syntax  
    if {[regexp {=} [lindex $args 0]]} {
        set nargs [list]
        foreach kval $args {
            set idx [string first = $kval]
            set key [string range $kval 0 $idx-1]
            set val [string range $kval $idx+2 end-1]
            lappend nargs $key
            lappend nargs $val
        }
        set args $nargs
    } 
    # end of new check
    foreach {key val} $args {
       if {$val eq ""} {
           append ret ">\n$key\n</$tag>\n"
           break
       } else {
           append ret " $key=\"$val\""
       }
    }
    if {$val ne ""} {
        append ret " />\n"
    }
    append code $ret
}

namespace eval tsvg {
    namespace unknown tsvg::tag
}
tsvg proc write {filename} {
    variable width
    variable height
    variable header
    variable footer
    variable code
    set out [open $filename w 0600]
    set head [regsub {__HEIGHT__} $header $height]
    set head [regsub {__WIDTH__} $head $width]
    puts $out $head
    puts $out $code
    puts $out $footer
    close $out
}

tsvg proc figure {filename width height args} {
    set self [self]
    $self set width $width
    $self set height $height
    $self write $filename.svg
    return $filename.svg
}

tsvg proc demo {} {
    set self [self]
    $self circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
    $self text x 29 y 45 Hello
    $self text x 27 y 65 World!
    #$self figure 
    write hello-world.svg
}

                   
if {[info exists argv0] && $argv0 eq [info script] && [regexp tsvg.tcl $argv0]} {
    tsvg demo
    puts "writing file hello-world.svg"
}

