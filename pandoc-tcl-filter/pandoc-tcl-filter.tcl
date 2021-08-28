#!/usr/bin/env tclsh
package require rl_json
package provide pandoc 0.2

#' ## NAME
#' 
#' _pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
#' application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
#' documentation and offers a plugin architecture to add other command line filters easily using Tcl
#' and the `exec` command. As an example a dot filter plugin is given as `filter-dot.tcl`.
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
#' proc filter-dot {cont dict cblock} {
#'    global n
#'    incr n
#'    set ret ""
#'    if {[dict get $dict label] eq "null"} {
#'        set fname dot-$n
#'    } else {
#'         set fname [dict get $dict label]
#'    }
#'    set out [open $fname.dot w 0600]
#'    puts $out $cont
#'    close $out
#'    set res [exec dot -Tsvg $fname.dot -o $fname.svg]
#'    if {[dict get $dict results] eq "show" && $res ne ""} {
#'        rl_json::json set cblock c 0 1 [rl_json::json array [list string dotout]]
#'        rl_json::json set cblock c 1 [rl_json::json string $res]
#'        set ret ",[::rl_json::json extract $cblock]"
#'    }
#'    return $ret
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
#'     * adding custom filters structure (dot, tsvg)
#'     * adding attributes label, width, height, results
#'     
#' ## SEE ALSO
#' 
#' * [Readme.html](Readme.html) - more information and small tutorial
#' * [Tclers Wikipage](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) - palce for discussion
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
mdi eval {
    set res ""
    set chunk 0
    rename puts puts.orig
    
    proc puts {args} {
        global res
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
foreach file [glob -nocomplain [file join [file dirname [info script]] filter*.tcl]]  {
    #puts stderr "sourcing $file"
    catch { source $file }
}

proc debug {jsonData} {
    puts [::rl_json::json keys $jsonData]
}

# a filter for Markdown code blocks of type
# ```{.tcl}
# set x 5
# puts $x
# ```
#
proc filter-tcl {cont a cblock} {
    set ret ""
    set jsimg ""
    if {[dict get $a eval]} {
        mdi eval "set res {}; incr chunk"
        if {[catch {
             set eres [mdi eval $cont]
             set eres "[mdi eval {set res}]$eres"
        }]} {
             set eres "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
        }
        if {[dict get $a fig]} {
            #append eres "figure in chunk [mdi eval { set chunk }] is true!\n"
            # figure command check
            
            if {[mdi eval {info command figure}] eq "figure"} {
                if {[dict get $a label] eq "null"} {
                    set lab fig-[mdi eval { set chunk }]
                } else {
                    set lab [dict get $a label]
                }
                #append eres "figure procedure exists!\n"
                set filename [mdi eval "figure $lab [dict get $a width] [dict get $a height]"]
                #append eres "file $filename was created!\n"
                set eres ""
            }
        }

       if {[dict get $a results] eq "show" && $eres ne ""} {
          rl_json::json set cblock c 0 1 [rl_json::json array [list string tclout]]
          rl_json::json set cblock c 1 [rl_json::json string [regsub {\{(.+)\}} $eres "\\1"]]
          set ret ",[::rl_json::json extract $cblock]"
      }
    }
    return $ret
}

# the main method parsing the json data
proc main {jsonData} {
    set blocks ""
    for {set i 0} {$i < [llength [::rl_json::json get $jsonData blocks]]} {incr i} {
        if {$i > 0} {
            append blocks ","
        }
        set blockType [::rl_json::json get $jsonData blocks $i t]
        if {$blockType eq "CodeBlock"} {
            set type [rl_json::json get $jsonData blocks $i c 0 1] ;#type
            set attr [rl_json::json get $jsonData blocks $i c 0 2] ;# attributes
            set a [dict create echo true results show eval true fig false width 400 height 400 include true label null]
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
                #rl_json::json set jsonData blocks $i c 1 [rl_json::json string ""]
                rl_json::json unset jsonData blocks $i
                #rl_json::json set jsonData blocks $i c 0 [rl_json::json array [list string ""] "" ""]]
                #rl_json::json set jsonData blocks $i {}
                #rl_json::json set jsonData blocks $i t "Par"                

                #rl_json::json set jsonData blocks $i c 0 0 array [list]                
                #puts stderr  "[::rl_json::json extract $jsonData blocks $i]\n"
                append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
            }
            #puts $cblock
            #puts [::rl_json::json  get $cblock t]
            #exit
            if {$type eq "tcl"} {
                append blocks [filter-tcl $cont $a $cblock]
            } elseif {$type ne ""} {
                if {[info command filter-$type] eq "filter-$type"} {
                    append blocks [filter-$type $cont $a $cblock]
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

