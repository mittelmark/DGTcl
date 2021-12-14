#!/usr/bin/env tclsh

package provide pandoc 0.5.0

if {[llength $argv] > 0 && [lsearch -regex $argv -v] >= 0} {
    puts "[package present pandoc]"
    exit 0
}   
if {[llength $argv] > 0 && [lsearch -regex $argv -h] >= 0} {
    puts "Usage (filter):    pandoc \[arguments\] --filter $argv0 \[arguments\]"
    puts "          This is the pandoc Tcl filter which should be run as filter"
    puts "          for the pandoc document converter with a syntax like shown above."
    puts "          This filter allows you to embed Tcl code within"
    puts "          ```{.tcl} ... ``` code blocks."   
    puts "          For a list of other filters which are available see below." 
    puts "Version:  [package present pandoc]"
    puts "Homepage: https://github.com/mittelmark/DGTcl"
    puts "Readme:   http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/Readme.html"
    puts "Filters:  "
    puts "       - ```{.tcl}    Tcl code```"
    puts "       - ```{.abc}    ABC music notation code```"    
    puts "       - ```{.dot}    GraphViz dot/neato code```"
    puts "       - ```{.eqn}    EQN equations```"    
    puts "       - ```{.mmd}    Mermaid diagram code```"            
    puts "       - ```{.mtex}   LaTeX equations```"        
    puts "       - ```{.pic}    PIC diagram code```"        
    puts "       - ```{.pik}    Pikchr diagram code```"
    puts "       - ```{.puml}   PlantUML diagram code```"    
    puts "       - ```{.rplot}  R plot code```"    
    puts "       - ```{.tsvg}   Tcl package tsvg code```\n"
    puts "Usage (standalone): $argv0 infile outfile"
    puts "                       converting infile to outfile"
    puts "                       if infile is a source code file like .tcl .py"
    puts "                       it is assumed that it contains mkdoc documentation"  
    puts "                       mkdoc documentation is embedded Markdown markup after a #' comment" 
    puts "                       in case pandoc is installed the pandoc-tcl-filter will be used after wards"
    puts "                    $argv0 --help               - display this help page"
    puts "                    $argv0 --version            - display the version"
    puts "                    $argv0 infile --tangle .tcl - extract all code from .tcl chunks"
    puts "Example: "
    puts "         ./pandoc-tcl-filter.tcl pandoc-tcl-filter.tcl pandoc-tcl-filter.html -s --css mini.css"
    puts "             will extract the documentation from itself and create a HTML file executing all filters available"
    puts "             all pandoc options can be passed after the output file name" 
    puts "Author: Detlef Groth, University of Potsdam, Germany"
    exit 0
}

if {[llength $argv] > 1 && [lsearch -regex $argv -tangle] > -1} {
    if {[file exists [lindex $argv 0]]} {
        set filename [lindex $argv 0]
        if {[llength $argv] == 3} {
            set mode [lindex $argv 2]
        } else {
            set mode .tcl
        }
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            set flag false
            while {[gets $infh line] >= 0} {
                if {[regexp "^\[> \]\{0,2\}``` {0,2}\{$mode" $line]} {
                    set l [regsub {.+```} $line ""]
                    puts stdout "# $l"
                    set flag true
                } elseif {$flag && [regexp "^\[> \]\{0,2\}```" $line]} {
                    set flag false
                } elseif {[regexp "^\s*#' \[> \]\{0,2\}``` {0,2}\{$mode" $line]} {
                    set l [regsub {.+```} $line ""]
                    puts stdout "# $l"
                    set flag true
                } elseif {$flag && [regexp "^\s*#' \[> \]\{0,2\}```" $line]} {
                    set flag false
                } elseif {$flag} {
                    set line [regsub {^\s*#' } $line ""]
                    puts stdout $line
                }
            }
            close $infh
        }
    }
    return
}

set css {
    html {
        overflow-y: scroll;
    }
    body {
        color: #444;
        font-family: Georgia, Palatino, 'Palatino Linotype', Times, 'Times New Roman', serif;
        line-height: 1.2;
        padding: 1em;
        margin: auto;
        max-width:  900px;
    }
    h1, h2, h3, h4, h5, h6 {
        color: #111;
        line-height: 115%;
        margin-top: 1em;
        font-weight: normal;
    }
    h1 {
        text-align: center;
        font-size: 120%;
    }
    a {
        color: #0645ad;
        text-decoration: none;
    }
    a:visited {  color: #0b0080; }
    a:hover   {  color: #06e;    }
    a:active  {  color: #faa700; }
    a:focus   {  outline: thin dotted; }
    
    p {  margin: 0.5em 0;    }
    p.author, p.date {
        font-size: 110%;
        text-align: center;
    }
    img {  max-width: 100%;    }
    figure { text-align: center ; } 
    pre, blockquote pre {
        border-top: 0.1em #9ac solid;
        background: #e9f6ff;
        padding: 10px;
        border-bottom: 0.1em #9ac solid;
    }
    pre, code, kbd, samp {
        color: #000;
        font-family: Monaco, 'courier new', monospace;
        font-size: 90%; 
    }
    code.r {
        color: #770000;
    }
    pre {
        white-space: pre;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
    code span.kw { color: #007020; font-weight: normal; }
    pre.sourceCode {  background: #fff6f6;  } 
    blockquote {
        margin: 0;
        padding-left: 3em; 
    }
    hr {
        display: block;
        height: 2px;
        border: 0;
        border-top: 1px solid #aaa;
        border-bottom: 1px solid #eee;
        margin: 1em 0;
        padding: 0;
    }
    table {    
        border-collapse: collapse;
        border-bottom: 2px solid;
    }
    table thead tr th { 
        background-color: #fde9d9;
        text-align: left; 
        padding: 10px;
        border-top: 2px solid;
        border-bottom: 2px solid;
    }
    table td { 
        background-color: #fff9e9;
        text-align: left; 
        padding: 10px;
    }
}    
if {[llength $argv] > 1 && [file exists [lindex $argv 0]]} {
    if {[auto_execok pandoc] eq ""} {
        puts "Error: Document conversion needs pandoc installed"
        exit 0
    }
    if {[file extension [lindex $argv 0]] in [list .tcl .tm .py .R .r .c .cxx .cpp]} {
        set tempfile [file tempfile].md 
        set filename [lindex $argv 0]
        set out [open $tempfile w 0600]
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                if {[regexp {^\s*#' ?} $line]} {
                    set line [regsub {^\s*#' ?} $line ""]
                    puts $out $line
                }
                
            }
            close $infh
        }
        close $out
        if {[file extension [lindex $argv 1]] eq ".html" && [lsearch [lrange $argv 1 end] --css] == -1} {
            if {![file exists pandoc-filter.css]} {
                set out [open pandoc-filter.css w 0600]
                puts $out $css
                close $out
            }
            lappend argv --css
            lappend argv pandoc-filter.css
            exec pandoc $tempfile --filter $argv0 -o {*}[lrange $argv 1 end] 
        } else {
            exec pandoc $tempfile --filter $argv0 -o {*}[lrange $argv 1 end]
        }
        file delete $tempfile
        puts "converting [lindex $argv 0] to [lindex $argv 1] done"
        exit 0
    } else {
        if {[file extension [lindex $argv 1]] eq ".html" && [lsearch [lrange $argv 1 end] --css] == -1} {
            set out [open temp.css w 0600]
            puts $out $css
            close $out
            exec pandoc [lindex $argv 0] --filter $argv0 -o {*}[lrange $argv 1 end] --css temp.css
            file delete temp.css
        } else {
            exec pandoc [lindex $argv 0] --filter $argv0 -o {*}[lrange $argv 1 end]
        }
        puts "converting [lindex $argv 0] to [lindex $argv 1] done"
    }
    exit 0
}
set appdir [file dirname [info script]]
if {[file exists  [file join $appdir lib]]} {
    lappend auto_path [file normalize [file join $appdir lib]]
    package require tsvg
}
if {[file exists  [file join $appdir filter]]} {
    lappend auto_path [file join $appdir filter]
}
package require rl_json
catch {
    # if available load filters
    package require tclfilters
}
#' ---
#' title: pandoc-tcl-filter documentaion - 0.5.0
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2021-12-10
#' ---
#'
#' ## NAME
#' 
#' _pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
#' application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
#' documentation and offers a plugin architecture to add other command line filters easily using Tcl
#' and the `exec` command. As examples are given in the filter folder of the project:
#'
#' * Tcl filter {.tcl} - implemented in this file pandoc-tcl-filter.tcl 
#' * ABC music filter {.abc}: `filter-abc.tcl` [filter/filter-abc.html](filter/filter-abc.html)
#' * Graphviz dot filter {.dot}: `filter-dot.tcl` [filter/filter-dot.html](filter/filter-dot.html)
#' * EQN filter plugin for equations written in the EQN language {.eqn}: `filter-eqn` [filter/filter-eqn.html](filter/filter-eqn.html)
#' * Math TeX filter for single line equations {.mtex}: `filter-mtex.tcl`
#' * Mermaid filter for diagrams {.mmd}: `filter-mmd.tcl` [filter/filter-mmd.html](filter/filter-mmd.html)
#' * Pikchr filter plugin for diagram creation {.pikchr}: `filter-pik.tcl` [filter/filter-pik.html](filter/filter-pik.html)
#' * PIC filter plugin for diagram creation (older version) {.pic}: `filter-pic.tcl` [filter/filter-pic.html](filter/filter-pic.html)
#' * PlantUMLfilter plugin for diagram creation {.puml}: `filter-puml.tcl` [filter/filter-puml.html](filter/filter-puml.html)
#' * R plot filter plugin for displaying plots in the R statistical language {.rplot}: `filter-rplot.tcl` [filter/filter-rplot.html](filter/filter-rplot.html)
#' * tsvg package filter {.tsvg}: `filter-tsvg.tcl` [filter/filter-tsvg.html](filter/filter-tsvg.html)
#'
#' ## SYNOPSIS 
#' 
#' ```
#' # standalone
#' pandoc-tcl-filter.tcl infile outfile ?options?
#' # as filter
#' pandoc infile --filter pandoc-tcl-filter.tcl ?options?
#' ```
#' 
#' Where options are the usual pandoc options. For HTML conversion you should use for instance:
#' 
#' ```
#' pandoc-tcl-filter.tcl infile.md outfile.html --css style.css -s --toc
#' ```
#'
#' Embed code either inline or in form of code chunks like here (triple ticks):
#' 
#' ``` 
#'     ```{.tcl}
#'     set x 4
#'     incr x
#'     set x
#'     ```
#'   
#'     Hello this is Tcl `tcl package provide Tcl`!
#' ```
#' 
#' The markers for the other filters are 
#' `{.abc}, `{.dot}`, `{.eqn}`, `{.mmd}`, `{.mtex}`, `{.pic}`,
#' `{.pikchr}, `{.puml}`, `{.rplot}`,`{.sqlite}` and `{.tsvg}`. 
#' For details on how to use them have a look at the manual page links on top.
#' 
#' The Markdown document within this file could be extracted and converted as follows:
#' 
#' ```
#'  ./pandoc-tcl-filter.tcl pandoc-tcl-filter.tcl pandoc-tcl-filter.html \
#'    --css mini.css -s
#' ```
#' 
#'
#' ## Example Tcl Filter
#' 
#' #### Tcl-filter
#' 
#' ```
#'     ```{.tcl}
#'     set x 1
#'     puts $x
#'     ```
#' ```
#'
#' And here the output:
#' 
#' ```{.tcl}
#' set x 1
#' puts $x
#' ```
#'
#' ## Filter - Plugins
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
#' The main script `pandoc-tcl-filter.tcl` evaluates if in the same folder as the script is,
#' if there any other files named `filter/filter-NAME.tcl` and sources them. In case of the dot
#' filter the file is named `filter-dot.tcl` and its filter function `filter-dot` is 
#' executed. Below is the simplified code: of this file `filter-dot.tcl`:
#' 
#' ```{.tcl eval=false results="hide"}
#' # a simple pandoc filter using Tcl
#' # the script pandoc-tcl-filter.tcl 
#' # must be in the same filter directoy of the pandoc-tcl-filter.tcl file
#' proc filter-dot {cont dict} {
#'     global n
#'     incr n
#'     set def [dict create app dot results show eval true fig true 
#'              label null ext svg width 400 height 400 \
#'              include true imagepath images]
#'     # fuse code chunk options with defaults
#'     set dict [dict merge $def $dict]
#'     set ret ""
#'     if {[dict get $dict label] eq "null"} {
#'         set fname dot-$n
#'     } else {
#'         set fname [dict get $dict label]
#'     }
#'     # save dot file
#'     set out [open $fname.dot w 0600]
#'     puts $out $cont
#'     close $out
#'     # TODO: error catching
#'     set res [exec [dict get $dict app] -Tsvg $fname.dot -o $fname.svg]
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
#' Using the label and the option `include=false` we could create an image link manually using Markdown syntax. The 
#' The image filename should be then images/label.svg for instance.
#' 
#' ## Dot Example
#' 
#' Here a longer dot-example where the code is include in 
#' 
#' ```{.dot}
#' digraph G {
#'   margin=0.1;
#'   node[fontname="Linux Libertine";fontsize=18];
#'   node[shape=box,style=filled;fillcolor=skyblue,width=1.2,height=0.9];    
#'   { rank=same; Rst[group=g0,fillcolor=salmon] ; 
#'     Docx [group=g1,fillcolor=salmon]
#'   }
#'   { rank=same; Md[group=g0,fillcolor=salmon]  ; 
#'     pandoc ; AST1 ; filter[fillcolor=cornsilk] ; AST2 ; pandoc2;  
#'     Html[group=g1,fillcolor=salmon] 
#'   }
#'   { rank=same; Tex[group=g0,fillcolor=salmon] ; 
#'     Pdf[group=g1,fillcolor=salmon]; filters[fillcolor=cornsilk]; 
#'   }
#'   node[fillcolor=cornsilk]; 
#'   { rank=same; dot ; eqn; mtex; pic; pik; rplot; tsvg;}
#'   Rst -> pandoc -> AST1 -> filter -> AST2 -> pandoc2 -> Html ;
#'   Md -> pandoc;
#'   Tex -> pandoc;
#'   Rst -> Md -> Tex -> dot[style=invis] ;
#'   pandoc2 -> Docx;
#'   pandoc2 -> Pdf ;
#'   Docx -> Html -> Pdf -> tsvg[style=invis];
#'   pandoc2[label=pandoc];
#'   filter[label="pandoc-\ntcl-\nfilter"];
#'   filter->filters;
#'   filters -> dot ;
#'   filters -> eqn ;
#'   filters -> mtex;
#'   filters -> pic ;
#'   filters -> pik ; 
#'   filters -> rplot;
#'   filters -> tsvg; 
#' }
#' ```
#' 
#' ## Creating Markdown Code
#' 
#' Since version 0.5.0 it is as well possible to create Markup code within code blocks and to return it. 
#' To achieve this you to set use code chunk option results like this: `results="asis"` -
#' which should be usually used together with `echo=false`. Here an example:
#' 
#' ``` 
#'      ```{.tcl echo=false results="asis"}
#'      return "**this is bold** and _this is italic_ text!"
#'      ```    
#' ```
#' 
#' which gives this output:
#' 
#' ```{.tcl echo=false results="asis"}
#' return "**this is bold** and _this is italic_ text!"
#'
#' ``` 
#' 
#' This can be as well used to include other Markup files. Here an example:
#' 
#' ```{.tcl results="asis"}
#' include tests/inc.md
#' ```
#' 
#' Please note, that currently no filters are applied on the included files. 
#' You should process them before using the pandoc filters and choose output format Markdown to include them later
#' in your master document.
#' 
#' ## Documentation
#' 
#' To use this pipeline and to create pandoc-tcl-filter.html out of the code documentation 
#' in pandoc-tcl-filter.tcl your command in the terminal is still just:
#' 
#' ```
#' ./pandoc-tcl-filter.tcl pandoc-tcl-filter.tcl pandoc-tcl-filter.html -s --css mini.css
#' ```
#' 
#' The result should be the file which you are looking currently.
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
#' * 2021-11-15 Version 0.3.2
#'     * --help argument support
#'     * --version argument support
#'     * filters for Pikchr, PIC and EQN
#' * 2021-11-30 Version 0.3.3
#'     * filter for R plots: `.rplot`
#' * 2021-12-04 Version 0.4.0
#'     * pandoc-tcl-filter can be as well directly used for conversion 
#'       being then a frontend which calls pandoc internally with 
#'       itself as a filter ...
#' * 2021-12-12 Version 0.5.0
#'    * support for Markdown code creation in the Tcl filter with results="asis"
#'    * adding list2mdtab proc to the Tcl filter
#'    * adding include proc to the Tcl filter with results='asis' other Markdown files can be included.
#'    * support for `pandoc-tcl-filter.tcl infile --tangle .tcl`  to extract code chunks to the terminal
#'    * support for Mermaid diagrams
#'    * support for PlantUML diagrams 
#'    * support for ABC music notation
#'    * bug fix for Tcl filters for `eval=false`
#'    * documentation improvements for the filters and for the pandoc-tcl-filter
#'     
#' ## SEE ALSO
#' 
#' * [Readme.html](Readme.html) - more information and small tutorial
#' * [Examples](examples/example-eqn.html) - more examples for the filters 
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
#' *MIT License*
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
#' 
## Actual filter code for Tcl and infratstucture to add other filters by writing
## proc filter-NAME function in a file filter/filter-NAME.tcl

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
proc getTempDir {} {
    if {[file exists /tmp]} {
        # standard UNIX
        return /tmp
    } elseif {[info exists ::env(TMP)]} {
        # Windows
        return $::env(TMP)
    } elseif {[info exists ::env(TEMP)]} {
        # Windows
        return $::env(TEMP)
    } elseif {[info exists ::env(TMPDIR)]} {
        # OSX
        return $::env(TMPDIR)
    }
}

mdi eval "set auto_path \[list [luniq $auto_path]\]"
mdi eval {
    set res ""
    set chunk 0
    rename puts puts.orig
    package provide pandoc 0.3.2
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

# load other tcl based filters
foreach file [glob -nocomplain [file join [file dirname [info script]] filter filter*.tcl]]  {
    catch {
        source $file
    }
}

proc debug {jsonData} {
    puts [::rl_json::json keys $jsonData]
}

proc filter-tcl {cont a} {
    set ret ""
    set b [dict create fig false width 400 height 400 include true \
            label null]
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
            set d [getMetaDict $meta $type]
            set a [dict merge $a $d]
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
                #rl_json::json unset jsonData blocks $i
                # add an empty paragraph instead
                append blocks {{"t":"Para","c":[{"t":"Str","c":""}]}}
                #append blocks [::rl_json::json extract $jsonData blocks $i]\n"
            }
            if {$type ne ""} {
                if {[info command filter-$type] eq "filter-$type"} {
                    set res [filter-$type $cont $a]
                    if {[llength $res] >= 1} {
                        set code [lindex $res 0]
                        if {$code ne ""} {
                            if {[dict get $a results] ne "asis"} {
                                rl_json::json set cblock c 0 1 [rl_json::json array [list string ${type}out]]
                                rl_json::json set cblock c 1 [rl_json::json string $code]
                                append blocks ",[::rl_json::json extract $cblock]"
                            } else {
                                set cres $code
                                set mdfile [file tempfile].md
                                set out [open $mdfile w 0600]
                                puts $out $code
                                close $out
                                set cres [exec pandoc -t json $mdfile]
                                file delete $mdfile
                                set cres [regsub {^.+"blocks":\[(.+)\],"pandoc-api-version".+} $cres "\\1"]
                                append blocks ,
                                append blocks $cres
                            }
                        }
                        if {[llength "$res"] == 2} {
                            set img [lindex $res 1]
                            if {$img ne ""} {
                                rl_json::json set jsonImg c 0 c 2 0 "$img"
                                append blocks ",[::rl_json::json extract $jsonImg]"
                            }
                        }

                    }
                }
            }
     
        } elseif {$blockType in [list "Para"]} {
            # BulletList Header not working
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

