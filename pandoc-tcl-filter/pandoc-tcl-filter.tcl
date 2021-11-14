#!/usr/bin/env tclsh

package require rl_json
package require tclfilters
package provide pandoc 0.3.1
#' ## NAME
#' 
#' _pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
#' application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
#' documentation and offers a plugin architecture to add other command line filters easily using Tcl
#' and the `exec` command. As examples are give:
#' 
#' * Graphviz dot filter plugin: `filter-dot.tcl`
#' * tsvg package plugin: `filter-tsvg.tcl`
#' * Math TeX plugin for single line equations: `filter-mtex.tcl`
#'
#' ## SYNOPSIS 
#' 
#' Embed code either inline or in form of code chunks like here (triple ticks without space):
#' 
#' ``` 
#'   ` ``{.tcl}
#'   # a code block
#'   # remove the space between backticks
#    # above and below, must be given here
#'   # to avoid Pandoc confusion
#'   set x 4
#'   ` ```
#'   
#'   Hello this is Tcl `tcl package provide Tcl`!
#' ```
#' 
#' The markers for the other filters are `{.dot}`, `{.tsvg}` and `{.mtex}`.
#' 
#' The Markdown document within this file could be processed as follows:
#' 
#' ```
#'  perl -ne "s/^#' ?(.*)/\$1/ and print " > pandoc-tcl-filter.md
#'  pandoc pandoc-tcl-filter.md -s \
#'    --metadata title="pandoc-tcl-filter.tcl documentation" \
#'    -o pandoc-tcl-filter.html  --filter pandoc-tcl-filter.tcl  \
#'    --css mini.css
#' ```
#' 
#  pandoc -s -t json dgtools/test.md > dgtools/test.ast
# cat dgtools/test.ast | tclsh dgtools/filter.tcl
# pandoc dgtools/test.md -s --metadata title="test run with tcl filter" -o dgtools.html --filter dgtools/filter.tcl
# read the JSON AST from stdin
#'
#' ## Plugins
#' 
#' The pandoc-tcl-filter.tcl application allows to create custom filters for other 
#' command line application quite easily. The Tcl files has to be named `filter-NAME.tcl`
#' where NAME hast to match the code chunk marker. Below an example:
#' 
#' ```
#'    ` ``{.dot label=dotgraph}
#'    digraph G {
#'      main -> parse -> execute;
#'      main -> init;
#'      main -> cleanup;
#'      execute -> make_string;
#'      execute -> printf
#'      init -> make_string;
#'      main -> printf;
#'      execute -> compare;
#'    }
#' 
#'    ![](dotgraph.svg)
#'    ` ``
#' ```
#' 
#' The main script pandoc-tcl-filter.tcl looks if in the same folders as the script is,
#' if there any other files named `filter-NAME.tcl` and source them. In case of the dot
#' filter the file is named `filter-dot.tcl` and its filter function filter-dot is 
#' executed. Below is the code: of this file `filter-dot.tcl`:
#' 
#' ```
#' # a simple pandoc filter using Tcl
#' # the script pandoc-tcl-filter.tcl 
#' # must be in the same filter directoy of the pandoc-tcl-filter.tcl file
#' proc filter-dot {cont dict} {
#'     global n
#'     incr n
#'     set def [dict create results show eval true fig true width 400 height 400 \
#'              include true fontsize Large envir equation imagepath images]
#'     set dict [dict merge $def $dict]
#'     set ret ""
#'     if {[dict get $dict label] eq "null"} {
#'         set fname dot-$n
#'     } else {
#'         set fname [dict get $dict label]
#'     }
#'     set out [open $fname.dot w 0600]
#'     puts $out $cont
#'     close $out
#'     # TODO: error catching
#'     set res [exec dot -Tsvg $fname.dot -o $fname.svg]
#'     if {[dict get $dict results] eq "show"} {
#'         # should be usually empty
#'         set res $res
#'     } else {
#'         set res ""
#'     }
#'     set img ""
#'     if {[dict get $dict fig]} {
#'         if {[dict get $dict include]} {
#'             set img $fname.svg
#'         }
#'     }
#'     return [list $res $img]
#' }
#' ```
#'
#' Automatic inclusion of the image would require more effort and dealing with the cblock
#' which is a copy of the current json block containing the source code. Using the label
#' We could create an image link and append this block after the `$cblock` part of the `$ret var`.
#' As an exercise you could create a filter for the neato application which creates graphics for undirected graphs.
#' 
#' ## ChangeLog
#' 
#' * 2021-08-22 Version 0.1
#' * 2021-08-28 Version 0.2
#'     * adding custom filters structure (dot, tsvg examples)
#'     * adding attributes label, width, height, results
#' * 2021-08-31 Version 0.3
#'     * moved filters into filter folder
#'     * plugin example mtex
#'     * default image path _images_
#' * 2021-11-03 Version 0.3.1
#'     * fix for parray and "puts stdout"
#'     
#' ## SEE ALSO
#' 
#' * [Readme.html](Readme.html) - more information and small tutorial
#' * [Tclers Wiki page](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) - place for discussion
#' * [Pandoc filter documentation](https://pandoc.org/filters.html) - more background and information on how to implement filters in Haskell and Markdown
#' * [Lua filters on GitHub](https://github.com/pandoc/lua-filters)
#' * [Plotting filters on Github](https://github.com/LaurentRDC/pandoc-plot)
#' * [Github Pandoc filter list](https://github.com/topics/pandoc-filter)
#' 
#' ## AUTHOR
#' 
#' Dr. Detlef Groth, Caputh-Schwielowsee, Germany, detlef(_at_)dgroth(_dot_).de
#'  
#' ## LICENSE
#' 
#' ```
#' MIT License
#' 
#' Copyright (c) 2021 Dr. Detlef Groth, Caputh-Schwielowsee, Germany
#' 
#' Permission is hereby granted, free of charge, to any person obtaining a copy
#' of this software and associated documentation files (the "Software"), to deal
#' in the Software without restriction, including without limitation the rights
#' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#' copies of the Software, and to permit persons to whom the Software is
#' furnished to do so, subject to the following conditions:
#' 
#' The above copyright notice and this permission notice shall be included in all
#' copies or substantial portions of the Software.
#' 
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#' SOFTWARE.
#' ```
#' 
## Global variables
set n 0
set jsonData {}
while {[gets stdin line] > 0} {
   append jsonData $line
}
interp create mdi
proc luniq {L} {
    # removes duplicates without sorting the input list
    set t {}
    foreach i $L {if {[lsearch -exact $t $i]==-1} {lappend t $i}}
    return $t
} 
mdi eval "set auto_path \[list [luniq $auto_path]\]"
mdi eval {
    set res ""
    set chunk 0
    rename puts puts.orig
    
    proc puts {args} {
        global res
        if {[lindex $args 0] eq "stdout"} {
            set args [lrange $args 1 end]
        }
        if {[regexp {^file} [lindex $args 0]]} {
            puts.orig [lindex $args 0] {*}[lrange $args 1 end]
        } else {
            if {[lindex $args 0] eq "-nonewline"} {
                append res "[lindex $args 1]"
            } else {
                append res "[lindex $args 0]\n"
            }
            return ""
        }
    }
}

# load other tcl based filters
foreach file [glob -nocomplain [file join [file dirname [info script]] filter filter*.tcl]]  {
    source $file
}

proc debug {jsonData} {
    puts [::rl_json::json keys $jsonData]
}

proc filter-tcl {cont a} {
    set ret ""
    set b [dict create fig false width 400 height 400 include true label null]
    set a [dict merge $b $a]
    if {[dict get $a eval]} {
        mdi eval "set res {}; incr chunk"
        if {[catch {
             set eres [mdi eval $cont]
             set eres "[mdi eval {set res}]$eres"
        }]} {
             set eres "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
        }
        if {[dict get $a fig]} {
            # figure command there?
            if {[mdi eval {info command figure}] eq "figure"} {
                if {[dict get $a label] eq "null"} {
                    set lab fig-[mdi eval { set chunk }]
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
        } else {
            set eres ""
        }
    }
    return [list $eres $img]
}

# parse Meta data
proc getMetaDict {meta fkey} {
    set d [dict create]
    if {[rl_json::json exists $meta $fkey c]} {
        foreach key [rl_json::json keys $meta $fkey c] {
            dict set d $key [rl_json::json get $meta $fkey c $key c 0 c]
        }
    }
    return $d    
}

# the main method parsing the json data
proc main {jsonData} {
    set blocks ""
    set jsonImg {
       {
            "t": "Para",
            "c": [
                {
                    "t": "Image",
                    "c": [
                        [
                            "",
                            [],
                            []
                        ],
                        [],
                        [
                            "image.svg",
                            ""
                        ]
                    ]
                }
            ]
      }
    }
    set meta  [rl_json::json extract $jsonData meta] 
    for {set i 0} {$i < [llength [::rl_json::json get $jsonData blocks]]} {incr i} {
        if {$i > 0} {
            append blocks ","
        }
        set blockType [::rl_json::json get $jsonData blocks $i t]
        if {$blockType eq "CodeBlock"} {
            set type [rl_json::json get $jsonData blocks $i c 0 1] ;#type
            set attr [rl_json::json get $jsonData blocks $i c 0 2] ;# attributes
            set a [dict create echo true results show eval true] 
            if {[llength $attr] > 0} {
                foreach el $attr {
                    dict set a [lindex $el 0] [lindex $el 1]
                }
                #puts [dict keys $a]
            }
            set cont [rl_json::json get $jsonData blocks $i c 1]
            set cblock "[::rl_json::json extract $jsonData blocks $i]"
            if {[dict get $a echo]} {
                append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
            } else {
                rl_json::json unset jsonData blocks $i
                append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
            }
            if {$type ne ""} {
                if {[info command filter-$type] eq "filter-$type"} {
                    set d [getMetaDict $meta $type]
                    set a [dict merge $a $d]
                    set res [filter-$type $cont $a]
                    if {[llength $res] >= 1} {
                        set code [lindex $res 0]
                        if {$code ne ""} {
                            rl_json::json set cblock c 0 1 [rl_json::json array [list string ${type}out]]
                            rl_json::json set cblock c 1 [rl_json::json string $code]
                            append blocks ",[::rl_json::json extract $cblock]"
                        }
                        if {[llength $res] == 2} {
                            set img [lindex $res 1]
                            if {$img ne ""} {
                                rl_json::json set jsonImg c 0 c 2 0 "$img"
                                append blocks ",[::rl_json::json extract $jsonImg]"
                            }
                        }

                    }
                }
            }
     
        } elseif {$blockType eq "Para"} {
            for {set j 0} {$j < [llength [::rl_json::json get $jsonData blocks $i c]]} {incr j} {
                set type [rl_json::json get $jsonData blocks $i c $j t] ;#type
                if {$type eq "Code"} {
                    set code [rl_json::json get $jsonData blocks $i c $j c]
                    set code [lindex $code 1]
                    if {[regexp {\.?tcl } $code]} {
                        set c [regsub {^[^ ]+} $code ""]
                        if {[catch {
                             set ::errorInfo {}
                             set res [interp eval mdi $c]
                         }]} {
                                set res "error: $c"
                                set res "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
                        }

                        #set res [interp eval mdi $c]
                        set jsonData [rl_json::json set jsonData blocks $i c $j c [rl_json::json string "$res"]]
                        set jsonData [rl_json::json set jsonData blocks $i c $j t Str]
                    }
                }
            }
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        } else {
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        }
    }
    set ret "\"blocks\":\[$blocks\]"
    append ret ",\"pandoc-api-version\":[::rl_json::json extract $jsonData pandoc-api-version]"
    append ret ",\"meta\":[::rl_json::json extract $jsonData meta]"
    return "{$ret}"
}

# just demo code from the Tclers wiki (not used): 
proc incrHeader {jsonData} {
    for {set i 0} {$i < [llength [::rl_json::json get $jsonData blocks]]} {incr i} {
        set blockType [::rl_json::json get $jsonData blocks $i t]
        if {$blockType eq "Header"} {
            set headerLevel [::rl_json::json get $jsonData blocks $i c 0]
            set jsonData [::rl_json::json set jsonData blocks $i c 0 [expr {$headerLevel + 1}]]
        } 
    }
    return $jsonData
}

# give the modified document back to Pandoc again:
puts -nonewline [main $jsonData]

