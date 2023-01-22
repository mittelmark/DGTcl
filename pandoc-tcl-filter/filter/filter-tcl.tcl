#' ---
#' title: filter-tcl documentation
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2022-02-04
#' ---
#'
#' ------
#' 
#' ```{.tcl results="asis" echo=false eval=true}
#' include header.md
#' ```
#' 
#' ------
#'
#' ## NAME
#' 
#' _filter-tcl.tcl_ - filter to embed Tcl code in documentation.
#' 
#' The code for the Tcl filter is in pandoc-tcl-filter. It is to deeply involved into the main filter engine which drives the other Tcl and all other filters.
#'
#' ## CODE BLOCKS
#' 
#' Here an example:
#' 
#' ```
#'     # indentation just to avoid 
#'     # interpretation
#'     ```{.tcl}
#'     set x 1
#'     puts $x
#'     ```
#' ```
#' 
#' Here the output:
#' 
#' ```{.tcl}
#' set x 1
#' puts $x
#' ```
#' 
#' ### Code chunk options
#' 
#' The basic Tcl filter has three code chunk options:
#' 
#' - _eval_ - should the code be evaluated, default: true
#' - _results_ - should the code output be shown, either "show", "hide" or "asis", default: "show"
#' - _echo_ - should the code itself been shown, default: true
#' 
#' You can set these options in the YAML header of the document like this to make other defaults:
#' 
#' ```
#'     ---
#'     title: "your title"
#'     author: "your name"
#'     tcl:
#'        eval: 0
#'        results: "hide"
#'        echo: 1
#'     ---
#' ```
#' 
#' The eval option can be as well set to false or true using the environment variable `FILTEREVAL`. If you set this value to 0 the code chunks will  be not evaluated.
#'
#' Please note that in the document header *true* or *false* is not possible only using 1 and 0 as values.
#' 
#' Here an example where we hide the code itself and only show the output using the chunk argument `echo=false`:
#' 
#' ```
#'     ```{.tcl echo=false}
#'     puts "The sinus of 3 is [expr {round(sin(3))}]"
#'     ```
#' ```
#' 
#' And here the output where the code is as well hidden:
#' 
#' ```{.tcl echo=false}
#' puts "The sinus of 3 is [format %0.3f [expr {sin(3)}]]"
#' ```
#' 
#' With the option eval we can just avoid interpretations of code chunks.
#' 
#' ```
#'     ```{.tcl eval=false}
#'     puts "The sinus of 3 is [format %0.3f [expr {sin(3)}]]"
#'     ```
#' ```
#'
#' And here the "output":
#' 
#' ```{.tcl eval=false}
#' puts "The sinus of 3 is [format %0.3f [expr {sin(3)}]]"
#' ```
#'
#' As we can use the *echo* chunk option to hide and show the code itself, we can as well do the same with the output. 
#' So if we combine *echo="false"* and *results="hide"* the code will be evaluated but we will not seen anything in the output.
#' This option is useful if you like to hide the Tcl code and just use it in the background for some computations. 
#' 
#' But what does the code chunk option *results="asis"* mean? 
#' It allows you to create Markup code, such as Markdown if we you are writing
#' in Markdown, using the Tcl programmiong language. 
#' 
#' ```
#'     ```{.tcl results="asis"}
#'     set md "This is **bold** and this is _italic_ text.\n"
#'     append md "\nYou get the point?\n"
#'     set md
#'     ```
#' ```
#' 
#' And here is the output:
#' 
#' ```{.tcl results="asis"}
#' set md "This is **bold** and this is _italic_ text.\n"
#' append md "\nYou get the point?\n"
#' set md
#' ```
#' 
#' Let's create a table based on a nested Tcl list, code chunk options - `{.tcl results="show"}`:
#' 
#' ```{.tcl results="show"}
#' set l [list [list A B C D E] \
#'    [list 1 2 3 4 5] \
#'    [list 6 7 8 9 10] \
#'    [list 11 12 13 14 15]]
#' set md ""
#' set x 0
#' foreach row $l {
#'     incr x
#'     append md "|"
#'     foreach cell $row {
#'        append md " $cell |"
#'     }
#'     append md "\n"
#'     if {$x == 1} {
#'       append md "|"
#'       foreach cell $row {
#'           append md " ---- |"
#'       }
#'       append md "\n"
#'     }
#' }
#' set md
#' ```
#' 
#' If we now switch to `results="asis"` the output is this:
#' 
#' ```{.tcl results="asis"}
#' # variable md still exists from the 
#' # previous code chunk
#' set md "<center>\n$md</center>\n"
#' set md
#' ```
#' 
#' As the display of tabular data is quite a common problem,
#' the Tcl filter comes with a helper function *list2mdtab*, so we do not need to write this manual loop:
#' 
#' ```{.tcl results="asis"}
#' # syntax: list2mdtab header rows
#' # we need to flatten the row list
#' set r <center>\n
#' append r [list2mdtab [lindex $l 0] [concat {*}[lrange $l 1 end]]]
#' append r \n</center>\n
#' ```
#' 

#' ### Graphics
#' 
#' R has no default graphics engine for plotting etc. There is however the *tsvg* package which allows us to create SVG graphics. 
#' As this package is included in the pandoc-tcl-filter application we can use it here and later include the generated graphis using the Markdown image markup:
#' 
#' ```{.tcl}
#' package require tsvg
#' tsvg set code ""
#' tsvg circle -cx 50 -cy 50 -r 45 -stroke black \
#'    -stroke-width 2 -fill green
#' tsvg text -x 29 -y 45 Hello
#' tsvg text -x 27 -y 65 World!
#' tsvg write hw.svg
#' ```
#' 
#' ![](hw.svg)
#' 
#' If [cairosvg](https://cairosvg.org/) is installed as well png files can be created. 
#' Here an other example which creates a barplot and saves it as a PNG:
#' 
#' ```{.tcl}
#' tsvg set code ""
#' tsvg set width 400
#' tsvg set height 400
#' tsvg rect -x 10 -y 10 -width 380 -height 380 -fill #eeeee
#' tsvg rect -x 20 -y 20 -width 360 -height 360 -fill #eeeee \
#'    -style "stroke-width: 1px;stroke:black;"
#' set col [list #ffaaaa #ffccaa #ffaacc #aaffff]
#' set labels [list A B C D]
#' foreach i [list  0 1 2 3] {
#'     set val [expr {round(rand()*300)}]
#'     tsvg rect -x [expr {($i+1)*70}] -y [expr {340-$val}] \
#'           -width 50 -height $val \
#'           -fill [lindex $col $i]
#'     tsvg text -x [expr {($i+1)*70+20}] -y 370 [lindex $labels $i]
#' }
#' tsvg write barplot.png
#' ```
#' 
#' ![](barplot.png)
#' 
#' PDF and PNG output might be prefered if your final document is a PDF document created via LaTeX.
#' 
#' For more information about the tsvg package you might consult the 
#' [tsvg package documentation](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/lib/tsvg/tsvg.html).
#' 
#' ## INCLUDE FILES
#' 
#' An other utility function is the include function where
#' e can include other files, for instance some which contain as well Markdown markup. This can be used for instance to include common header and footers in your documents. 
#' Below an example we create an external file and the include this file afterwards,
#' we would like to have links to all filters here in the document (chunk options - `{.tcl results="asis"})`.
#' 
#' ```{.tcl results="asis"} 
#' set md \n
#' foreach html [lsort [glob filter*.html]] {
#'     append md "* \[[regsub {.html} $html {}]\]($html)\n"
#' }
#' append md \n
#' set out [open links.md w 0600]
#' puts $out $md
#' close $out
#' include links.md
#' ```
#' 
#' This allows in a nice way to create the same links for all documentation files such as these
#' which are on top of this document visible.
#' 
#' ## INLINE CODE
#' 
#' Short statements can be as well directy embedded into the main text. Here an example:
#' 
#' ```
#' The current time of document creation is : `tcl clock format [clock seconds]`.
#' ```
#' 
#' Here the output:
#' 
#' The current time of document creation is : `tcl clock format [clock seconds]`.
#' 
#' ## TODO:
#' 
#' - more flexible list2mdtab function
#' - res bug - fixed (vars are now in namespace filter)
#' 
#' ```{.tcl}
#' set vars [lsort [info vars ::*]]
#' set vars 
#' ```
#' 
#' ## SEE ALSO
#' 
#' * [Readme](../Readme.html) - more background
#' * [pandoc-tcl-filter](../pandoc-tcl-filter.html) - the main filter engine
#' * [filter-pipe](filter-pipe.html) - Embedding Python, R and Octave code in a similar way like Tcl in the Tcl filter
#' 
#' ## AUTHOR
#' 
#' * Dr. Detlef Groth, Schwielowsee, Germany
#' 
#' ## LICENSE
#' 
#' MIT - License
#' 
proc luniq {L} {
    # removes duplicates without sorting the input list
    set t {}
    foreach i $L {if {[lsearch -exact $t $i]==-1} {lappend t $i}}
    return $t
} 

set appdir [file dirname [info script]]
if {[file exists  [file join $appdir .. lib]]} {
    #puts here
    lappend auto_path [file normalize [file join $appdir lib]]
}

interp create mdi

mdi eval "set auto_path \[list [luniq $auto_path]\]"

mdi eval {
    namespace eval filter { 
        variable res 
        variable chunk
        set res ""
        set chunk 0
    }
    rename puts puts.orig
    package provide pandoc 0.7.0
    proc puts {args} {
        if {[lindex $args 0] eq "stdout"} {
            set args [lrange $args 1 end]
        }
        if {[regexp {^file} [lindex $args 0]]} {
            puts.orig [lindex $args 0] {*}[lrange $args 1 end]
        } else {
            if {[lindex $args 0] eq "-nonewline"} {
                append ::filter::res "[lindex $args 1]"
            } else {
                append ::filter::res "[lindex $args 0]\n"
            }
            return ""
        }
    }
    proc list2mdtab {header values} {
        set ncol [llength $header]
        set nval [llength $values]
        if {[llength [lindex $values 0]] > 1 && [llength [lindex $values 0]] != [llength $header]} {
            error "Error: list2table - number of values if first row is not a multiple of columns!"
        } elseif {[expr {int(fmod($nval,$ncol))}] != 0} {
            error "Error: list2table - number of values is not a multiple of columns!"
        }
        set res "|" 
        foreach h $header {
            append res " $h |"
        }   
        append res "\n|"
        foreach h $header {
            append res " ---- |"
        }
        append res "\n"
        set c 0
        foreach val $values {
            if {[llength $val] > 1} {    
                # nested list
                append res "| "
                foreach v $val {
                    append res " $v |"
                }
                append res "\n"
            } else {
                if {[expr {int(fmod($c,$ncol))}] == 0} {
                    append res "| " 
                }    
                append res " $val |"
                incr c
                if {[expr {int(fmod($c,$ncol))}] == 0} {
                    append res "\n" 
                }    
            }
        }
        return $res
    }
    proc include {filename} {
        if [catch {open $filename r} infh] {
            return "Cannot open $filename"
        } else {
            set res ""
            while {[gets $infh line] >= 0} {
                append res "$line\n"
            }
            close $infh
            return $res
        }
    }
}
proc filter-tcl {cont a} {
    set ret ""
    set b [dict create fig false width 400 height 400 include true \
            label null]
    set a [dict merge $b $a]
    if {[dict get $a eval]} {
        mdi eval "set ::filter::res {}; incr ::filter::chunk"
        if {[catch {
             set eres [mdi eval $cont]
             set eres "[mdi eval {set ::filter::res}]$eres"
        }]} {
             set eres "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
        }
        if {[dict get $a fig]} {
            # figure command there?
            if {[mdi eval {info command figure}] eq "figure"} {
                if {[dict get $a label] eq "null"} {
                    set lab fig-[mdi eval { set ::filter::chunk }]
                } else {
                    set lab [dict get $a label]
                }
                set filename [mdi eval "figure $lab [dict get $a width] [dict get $a height]"]
                set eres ""
            }
        }
        set img ""
        if {[dict get $a results] eq "show" && $eres ne ""} {
            set eres [regsub {\{(.+)\}} $eres "\\1"]
            #rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
            #rl_json::json set cblock c 1 [rl_json::json string [regsub {\{(.+)\}} $eres "\\1"]]
            #set ret ",[::rl_json::json extract $cblock]"
        } elseif {[dict get $a results] eq "asis" && $eres ne ""} { 
            set eres $eres
        } else {
            set eres ""
        }
    } else {
        set eres ""
        set img ""
    }
    return [list "$eres" $img]
}

