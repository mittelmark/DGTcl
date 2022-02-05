#!/usr/bin/env tclsh
# pandoc-tcl-filter - standalone application and pandoc filter
#                     for literate programming
# Author: Detlef Groth, Schwielowsee, Germany
# Version: 0.7.0 - 2022-02-XX

package provide pandoc 0.7.0

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
    puts "       - ```{.cmd}    Command line application code```"        
    puts "       - ```{.dot}    GraphViz dot/neato code```"
    puts "       - ```{.eqn}    EQN equations```"    
    puts "       - ```{.mmd}    Mermaid diagram code```"            
    puts "       - ```{.mtex}   LaTeX equations```"        
    puts "       - ```{.pic}    PIC diagram code```"        
    puts "       - ```{.pik}    Pikchr diagram code```"
    puts "       - ```{.pipe}   Embed Python, R or Octave code```" 
    puts "       - ```{.puml}   PlantUML diagram code```"    
    puts "       - ```{.rplot}  R plot code```"    
    puts "       - ```{.sqlite} SQLite3 code code```\n"
    puts "       - ```{.tcrd}   Songs with embedded chords```\n"        
    puts "       - ```{.tdot}   Tcl package tdot code```\n"    
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
    puts "\nUsage (GUI)      : $argv0 --gui \[infile]"
    puts "                     supported infiles: abc, dot, eqn, mmd, mtex, pic, pik, puml, rplot, tdot, tsvg"
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
    h2.author, h2.date {
        text-align: center;
        font-size: 110%;
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
    pre code.tclinn {
        color: #ff2222;
    }
    pre code.tclout {
        color: #3366ff;
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
# some helper functions
# some generic helper functions

proc luniq {L} {
    # removes duplicates without sorting the input list
    set t {}
    foreach i $L {if {[lsearch -exact $t $i]==-1} {lappend t $i}}
    return $t
} 

# allow loading Tcl packages and filters
set appdir [file dirname [info script]]
if {[file exists  [file join $appdir lib]]} {
    lappend auto_path [file normalize [file join $appdir lib]]
    package require tsvg
}

interp create mdi

mdi eval "set auto_path \[list [luniq $auto_path]\]"

catch {
    # if available load filters
    package require tclfilters
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

proc lineFilter {argv} {
    set args [split $argv " "]
    set infile [lindex $args 0]
    set outfile [lindex $args 1]
    set mode md
    if {![regexp {.+\.[a-zA-Z]*md$} $outfile] && ![regexp -nocase {.+\.html} $outfile]} {
        puts "Error: currently only conversion from Markdown to Markdown or to HTML is possible!"
        exit 0
    }
    if {[regexp -nocase {.+\.html} $outfile]} {
        set mode html
        set outfile [regsub {\.html} $outfile "-out.md"]
    }
    if {![file exists $infile]} {
        puts  "Error: $infile does not exists"
        exit 0
    }
    if [catch {open $infile r} infh] {
        puts stderr "Cannot open $infile: $infh"
        exit
    } else {
        set out [open $outfile w 0600]
        set i 0
        set n 0
        set flag false
        set yamlflag false
        set yamltext ""
        set filt "xxx"
        set ind ""
        set ddef [dict create echo true results show eval true] 
        set yamldict [dict create]
        set pre false
        while {[gets $infh line] >= 0} {
            incr n
            # TODO: simple YAML parsing
            if {$n < 5 && !$yamlflag && [regexp {^---} $line]} {
                set yamlflag true
            } elseif {$yamlflag && [regexp {^---} $line]} {
                set yamldict [yaml::yaml2dict $yamltext]
                set yamlflag false
                set yamltext ""
            } elseif {$yamlflag} {
                append yamltext "$line\n"
            }
            # TODO: indentation parsing "> ```"
            if {[regexp {^>? ?\s{0,2}```} $line]} {
                if {$pre} {
                    set pre false
                } else {
                    set pre true
                }
            }
            if {[regexp {^>? ?\s{0,2}```\{\.} $line]} {
                set dchunk [dict create]    
                set dchunk [dict merge $ddef $dchunk]                    
                set ind ""
                if {[regexp {^> } $line]} {
                    set ind "> "
                }
                regexp {```\{\.([a-zA-Z0-9]+)\s*(.*).*\}.*} $line -> filt options    
                if {[dict exists $yamldict $filt]} {
                    set dchunk [dict merge $dchunk [dict get $yamldict $filt]]
                }
                foreach {op} [split $options " "] {
                    foreach {key val} [split $op "="] {
                        set val [regsub -all {"} $val ""] ;#"
                        dict set dchunk $key $val         
                    }
                }
                set flag true
                set cont ""
                
            } elseif {$flag && [regexp {^>? ?\s{0,2}```} $line]} {
                set flag false
                #puts $cont
                if {[info procs filter-$filt] ne ""} {
                    puts "processing chunk filter[incr i] $filt $options"

                    set res [filter-$filt $cont $dchunk]
                    if {[dict get $dchunk echo]} {
                        # TODO: indentation adding if was there"
                        puts $out "$ind```${filt}inn\n$cont\n$ind```"
                    }
                    if {[lindex $res 0] ne ""} {
                        if {[dict get $dchunk results] eq "show"} {
                            # TODO: indentation adding if was there"
                            # remove trailing newline as we add our own
                            set r [regsub {\n$} [lindex $res 0] ""]
                            puts $out "\n$ind```${filt}out\n$r\n$ind```"
                        } elseif {[dict get $dchunk results] eq "asis"} {
                            puts $out "\n[lindex $res 0]\n"
                        }
                    }
                    if {[lindex $res 1] ne ""} {
                        set title ""
                        if {[dict exists $dchunk title]} {
                            set title [dict get $dchunk title]
                        }
                        puts $out "\n!\[$title\]([lindex $res 1])"
                    }
                    
                }
                set cont ""
            } elseif {$flag} {
                append cont "$line\n"
            } else {
                # TODO: more than one inline code per line
                if {!$pre} {
                    if {[regexp {`\.?[a-z]{2,4} .+`} $line]} {
                        set filt [regsub {.*`\.?([a-z]{2,4}) .+`.+} $line "\\1"]
                        if {[info procs filter-$filt] eq "filter-$filt"} {
                            set code [regsub {.*`\.?[a-z]{2,4} ([^`]+)`.+} $line "\\1"]
                            puts "processing inline code $code"
                            set res [lindex [filter-$filt $code [dict create eval true results show echo false]] 0]
                            set line [regsub {(.*)`\.?[a-z]{2,4} ([^`]+)`(.+)} $line "\\1$res\\3"]
                        }
                    }
                }
                puts $out $line
            }
        }
        close $infh
    }
    close $out
    if {$mode eq "html"} {
        mkdoc::mkdoc $outfile [regsub -- {-out.md} $outfile ".html"] {*}[lrange $argv 2 end]
    }
}

# Gui mode
if {[llength $argv] > 0 && [lsearch $argv --gui] > -1} {
    package require fview
    fview::gui
    set file false
    foreach arg $argv {
        if {[file exists $arg]} {
            set ext [string range [file extension $arg] 1 end]
            #puts $ext
            fview::fileOpen $arg
            fview::fileSave $arg
            set file true
            break
        }
    }
    if {!$file} {
        set ftemp [file temp].tsvg
        set out [open $ftemp w 0600]
        puts $out {package require tsvg
tsvg set code "" ;
tsvg set width 400
tsvg set height 400

tsvg rect -x 10 -y 10 -width 380 -height 380 \
        -fill cornsilk
tsvg circle -cx 200 -cy 200 -r 120 -stroke black -stroke-width 2 -fill #eeffee
tsvg text -x 155 -y 180 "Hello TSVG"
tsvg text -x 135 -y 220 "Filter View World!"
Hello
}
        close $out
        fview::fileOpen $ftemp
        fview::fileSave $ftemp
        file delete $ftemp
    }
    return
}
# Standalone processing 
# calling pandoc eventually itself

if {[llength $argv] > 1 && [file exists [lindex $argv 0]]} {
    set pandoc true
    if {[lsearch $argv --no-pandoc] > 1} {
        package require yaml
        package require mkdoc::mkdoc
        set pandoc false
    } elseif {[auto_execok pandoc] eq ""} {
        puts "Error: Document conversion needs pandoc installed"
        exit 0
    }
    if {[file extension [lindex $argv 1]] eq ".html" && [lsearch [lrange $argv 1 end] --css] == -1} {
        if {![file exists pandoc-filter.css]} {
            set out [open pandoc-filter.css w 0600]
            puts $out $css
            close $out
        }
        lappend argv --css
        lappend argv pandoc-filter.css
    }
    if {[file extension [lindex $argv 0]] in [list .tcl .tm .py .R .r .c .cxx .cpp .m .pl .pm .h .hpp .hxx]} {
        set tempfile [file tempfile].md 
        set filename [lindex $argv 0]
        set infile [lindex $argv 0]
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
        if {$pandoc} {
            exec pandoc $tempfile --filter $argv0 -o {*}[lrange $argv 1 end] 
        }  else {
            set argv [lset argv 0 $tempfile]
            lineFilter $argv
        }
        file delete $tempfile
        puts "converting $infile to [lindex $argv 1] done"
        exit 0
    } else {
        if {$pandoc} {
            exec pandoc [lindex $argv 0] --filter $argv0 -o {*}[lrange $argv 1 end]
        }  else {
            lineFilter $argv
        }
        puts "converting [lindex $argv 0] to [lindex $argv 1] done"
    }
    exit 0
}
package require rl_json

#' ---
#' title: pandoc-tcl-filter documentation - 0.7.0
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2022-01-22
#' tcl:
#'    echo: "true"
#'    results: show
#' ---
#'
#' ## NAME
#' 
#' _pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
#' application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
#' documentation and offers a plugin architecture to add other command line filters easily using Tcl
#' and the `exec` command. As examples are given in the filter folder of the project:
#'
#' * Tcl filter {.tcl}: `filter-tcl.tcl` [filter/filter-tcl.html](filter/filter-tcl.html)
#' * ABC music filter {.abc}: `filter-abc.tcl` [filter/filter-abc.html](filter/filter-abc.html)
#' * command line application filter {.cmd}: `filter-cmd.tcl` [filter/filter-abc.html](filter/filter-cmd.html)
#' * Graphviz dot filter {.dot}: `filter-dot.tcl` [filter/filter-dot.html](filter/filter-dot.html)
#' * EQN filter plugin for equations written in the EQN language {.eqn}: `filter-eqn` [filter/filter-eqn.html](filter/filter-eqn.html)
#' * Math TeX filter for single line equations {.mtex}: `filter-mtex.tcl` [filter/filter-mtex.html](filter/filter-mtex.html)
#' * Mermaid filter for diagrams {.mmd}: `filter-mmd.tcl` [filter/filter-mmd.html](filter/filter-mmd.html)
#' * Pikchr filter plugin for diagram creation {.pikchr}: `filter-pik.tcl` [filter/filter-pik.html](filter/filter-pik.html)
#' * PIC filter plugin for diagram creation (older version) {.pic}: `filter-pic.tcl` [filter/filter-pic.html](filter/filter-pic.html)
#' * pipe filter for R, Python and Octave {.pipe}: `filter-pipe.tcl` [filter/filter-pipe.html](filter/filter-pipe.html)
#' * PlantUMLfilter plugin for diagram creation {.puml}: `filter-puml.tcl` [filter/filter-puml.html](filter/filter-puml.html)
#' * R plot filter plugin for displaying plots in the R statistical language {.rplot}: `filter-rplot.tcl` [filter/filter-rplot.html](filter/filter-rplot.html)
#' * sqlite3 filter plugin to evaluate SQL code {.sqlite}: `filter-sqlite.tcl` [filter/filter-sqlite.html](filter/filter-sqlite.html)
#' * tcrd filter for music songs with chords {.tcrd}: `filter-tcrd.tcl` [filter/filter-tcrd.html](filter/filter-tcrd.html)
#' * tdot package filter {.tsvg}: `filter-tdot.tcl` [filter/filter-tdot.html](filter/filter-tdot.html)
#' * tsvg package filter {.tsvg}: `filter-tsvg.tcl` [filter/filter-tsvg.html](filter/filter-tsvg.html)
#'
#' ## SYNOPSIS 
#' 
#' ```
#' # standalone application
#' pandoc-tcl-filter.tapp infile outfile ?options?
#' # as filter
#' pandoc infile --filter pandoc-tcl-filter.tapp ?options?
#' # as graphics user interface
#' pandoc-tcl-filter.tapp --gui
#' ```
#' 
#' Where options for the filter and the standalone mode
#' are the usual pandoc options. For HTML conversion you should use for instance:
#' 
#' ```
#' pandoc-tcl-filter.tapp infile.md outfile.html --css style.css -s --toc
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
#' You can combine all filters in one document  just by using the appropiate markers. 
#' 
#' Here an overview about the required tools:
#' 
#' <center>
#' 
#' | filter | tool | svg | png | pdf | comment |
#' | ------ | ----- | ---- | ---- | ---- | ---- |
#' | .tcl   | tclsh   | tsvg | cairosvg | cairosvg | programming | 
#' | .abc   | abcm2ps | abcm2ps | cairosvg | cairosvg | music |
#' | .dot   | dot   | native | native | native | diagrams |
#' | .eqn   | eqn2graph | no | convert | no | math | 
#' | .mmd   | mermaid-cli (mmdc) | native | native | native | diagrams |
#' | .mtex  | latex  | dvisgm | dvipng | dvipdfm | math, diagrams, games |
#' | .pic   | pic2graph | no | convert | no | diagrams |
#' | .pik   | fossil    |  native | cairosvg | cairosvg | diagrams |
#' | .pipe  | R / python / octave |  native | native | native | Statistics, Programming |
#' | .puml  | plantuml  |  native | native | native | diagrams |
#' | .rplot | R         | native  | native | native | statistics, graphics |
#' | .tcrd  | tclsh       | no      | no    |  no | music, songs with chords |
#' | .tdot  | tclsh/dot   | native  | native |  native | diagrams |
#' | .tsvg  | tclsh       | native  | cairosvg | cairosvg | graphics |
#' 
#' </center>
#' 
#' The Markdown document within this file could be extracted and converted as follows:
#' 
#' ```
#'  pandoc-tcl-filter.tapp pandoc-tcl-filter.tcl pandoc-tcl-filter.html \
#'    --css mini.css -s
#' ```
#'
#' ## Required Tools
#' 
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
#' Does indented code blocks works as well?
#' 
#' > ```{.tcl}
#'   set x 2
#'   puts $x
#' >  ```
#' 
#' > Yes, since version 0.7.0!!
#' 
#' There is as well the possibility to inline Tcl code like here:
#' 
#' ```
#' This document was processed using Tcl `tcl set tcl_patchLevel`!
#' ```
#' 
#' will produce:
#' 
#' This document was processed using Tcl `tcl set tcl_patchLevel`!
#' 
#' This works as well in nested structures like lists or quotes.
#' 
#' > This document was processed using Tcl `tcl set tcl_patchLevel`!
#' 
#' > - This document was processed using Tcl `tcl set tcl_patchLevel`!
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
#' ```
#'     ```{.tcl results="asis"}
#'     include tests/inc.md
#'     ```
#' ```
#'
#' And here is the result:
#' 
#' ```{.tcl results="asis"}
#' include tests/inc.md
#' ```
#' 
#' Please note, that currently no filters are applied on the included files. 
#' You should process them before using the pandoc filters and choose output format Markdown to include them later
#' in your master document.
#' 
#' To just show some file content as it is, remove the results="asis", 
#' this can be as well useful to display some source code, let's here simply show here the content of *tests/inc.md* without interpreting it as Markdown in a source code block:
#' 
#' ```
#'     ```{.tcl results="show"}
#'     include tests/inc.md
#'     ```
#' ```
#'
#' And here is the result:
#' 
#' ```{.tcl results="show"}
#' include tests/inc.md
#' ```
#' 
#' ## Documentation
#' 
#' To use this pipeline and to create pandoc-tcl-filter.html out of the code documentation 
#' in pandoc-tcl-filter.tapp your command in the terminal is still just:
#' 
#' ```
#' pandoc-tcl-filter.tapp pandoc-tcl-filter.tcl pandoc-tcl-filter.html -s --css mini.css
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
#' * 2022-01-09 - version 0.6.0
#'    * adding filter-cmd.tcl for shell scripts for all type of programming languages and tools
#'    * filter-mtex.tcl with more examples for different LaTeX packages like tikz, pgfplot, skak, sudoku, etc.
#'    * adding filter-tdot.tcl for tdot Tcl package
#'    * adding filter-tcrd.tcl for writing music chords above song lyrics
#' * 2022-01-XX - version 0.7.0
#'    * graphical user interface to the graphical filters (abc, dot, eqn, mmd, mtex, pic, pikchr, puml, rplot, tdot, tsvg) using the command line option *--gui*
#'    * can now as well work without pandoc standalone for conversion of Markdown with code chunks into 
#'      Markdown with evaluated code chunks and HTML code using the
#'      Markdown library of tcllib
#'    * that way it deprecates the use of tmdoc::tmdoc and mkdoc::mkdoc as it contains now the same functionality
#'    * support for inline code evaluations for Tcl, Python (pipe filter) and R (pipe filter) statements as well in nested paragraphs, lists and headers
#'    * support for indented code blocks with evaluation
#'    * new - filter-pipe:
#'        * initial support for R code block features and inline evaluation and error catching
#'        * initial support for Python with code block features and inline evaluation and error catching
#'        * initial support for Octave with code block features and error checking
#'    * more examples filter-mtex, filter-puml, filter-pikchr 
#'    * fix for filter-tcl making variables chunk and res namespace variables, avoiding variable collisions
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
#' Copyright (c) 2021-2022 Dr. Detlef Groth, Caputh-Schwielowsee, Germany
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

# walk and search for inlineCodes
set inlineCodes [list]
proc walk {key {ind 1}} {
    global jsonData
    global inlineCodes
    #puts "key: {*}$key"
    set sind [string repeat " " [expr {$ind*4}]] 
    set type [::rl_json::json type $jsonData blocks {*}$key]
    set l 0 
    if {$type eq "array"} {
        set l [llength [rl_json::json get $jsonData blocks {*}$key]]
    } elseif {$type eq "object"} {
        set l [llength [rl_json::json get $jsonData blocks {*}$key]]
    } 
 
    #puts "$sind type: $type length $l"
    #puts "$sind cnt:   [::rl_json::json get $jsonData blocks {*}$key]"
    incr ind
    if {$type eq "array"} {
        for {set j 0} {$j < $l} {incr j} {
            set nkey $key
            lappend nkey $j
            walk $nkey $ind
        }
    }
    if {$type eq "object"} {
        set tkey $key
        set ckey $key
        if {$l > 2} {
            lappend tkey t
            lappend ckey c
            set t [::rl_json::json get $jsonData blocks {*}$tkey]
            if {$t eq "Code"} {
                lappend ckey 1
                #lappend ckey
                set code [::rl_json::json get $jsonData blocks {*}$ckey]
                #puts "$sind  code: $code" 
                if {[regexp {^[a-zA-Z0-9]{1,3} .+} $code]} {
                    lappend inlineCodes [list $ckey $code]
                }
            } else {
                walk $ckey $ind 
            }
        }
    }
    return
}

proc codeBlock {} {
    uplevel 1 {
        set type [rl_json::json get $jsonData blocks {*}$tkey] ;#type
        set attr [rl_json::json get $jsonData blocks {*}$akey] ;# attributes
        set a [dict create echo true results show eval true] 
        set d [getMetaDict $meta $type]
        set a [dict merge $a $d]
        if {[llength $attr] > 0} {
            foreach el $attr {
                dict set a [lindex $el 0] [lindex $el 1]
            }
            #puts [dict keys $a]
        }
        set cont [rl_json::json get $jsonData blocks {*}$ckey]
        set cblock "[::rl_json::json extract $jsonData blocks {*}$bkey]"
        
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
                            if {$blockType eq "CodeBlock"} {
                                rl_json::json set cblock c 0 1 [rl_json::json array [list string ${type}out]]
                                rl_json::json set cblock c 1 [rl_json::json string $code]
                                append blocks ",[::rl_json::json extract $cblock]"
                            } elseif {$blockType eq "BlockQuote"} {
                                rl_json::json set cblock c 0 c 0 1 [rl_json::json array [list string ${type}out]]
                                rl_json::json set cblock c 0 c 1 [rl_json::json string $code]
                                append blocks ",[::rl_json::json extract $cblock]"
                            }
                        } else {
                            set cres $code
                            set mdfile [file tempfile].md
                            set out [open $mdfile w 0600]
                            puts $out $code
                            close $out
                            set cres [exec pandoc -t json $mdfile]
                            file delete $mdfile
                            # pandoc 2.9 (block first then meta)
                            set cres [regsub {^.+"blocks":\[(.+)\],"pandoc-api-version".+} $cres "\\1"]
                            # pandoc 2.12++ (meta first, then block)
                            set cres [regsub {^\{"pandoc-api-version".+"blocks":\[(.+)\]\}} $cres "\\1"]                                
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
    }
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
            set tkey [list $i c 0 1]
            set akey [list $i c 0 2]
            set ckey [list $i c 1]
            set bkey [list $i]
            codeBlock
        } elseif {$blockType in [list BulletList Header Para BlockQuote]}  {
            if {$blockType eq "BlockQuote" && [::rl_json::json get $jsonData blocks $i c 0 t] eq "CodeBlock"} {
                set tkey [list $i c 0 c 0 1]
                set akey [list $i c 0 c 0 2]
                set ckey [list $i c 0 c 1]
                set bkey [list $i]
                codeBlock
                continue
            }
            set ::inlineCodes [list]
            set k [llength [::rl_json::json get $jsonData blocks $i c]]
            #puts stderr $blockType
            #puts stderr [::rl_json::json get $jsonData blocks $i c]
            if {$blockType eq "Header" && $k == 3} {
                walk [list $i c 2]
            } else {
                for {set j 0} {$j < $k} {incr j} {
                    walk [list $i c $j]
                }
            }
            foreach item $::inlineCodes {
                foreach {key code} $item {
                    set ckey [lrange $key 0 end-1]
                    set tkey [lrange $key 0 end-2]
                    lappend tkey t
                    set c [regsub {^[^ ]+} $code ""]
                    if {[regexp {\.?tcl } $code]} {
                        if {[catch {
                             set ::errorInfo {}
                             set res [interp eval mdi $c]
                         }]} {
                                set res "error: $c"
                                set res "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
                         }
                         set jsonData [rl_json::json set jsonData blocks {*}$ckey [rl_json::json string "$res"]]
                         set jsonData [rl_json::json set jsonData blocks {*}$tkey Str]
                     } elseif {[regexp -nocase {\.?R } $code]} {
                         set d [dict create results show echo false pipe R]
                         set res [lindex [filter-pipe $c $d] 0]
                         set res [regsub {^>.+\[1\]} $res ""]
                         set jsonData [rl_json::json set jsonData blocks {*}$ckey [rl_json::json string "$res"]]
                         set jsonData [rl_json::json set jsonData blocks {*}$tkey Str]
                     } elseif {[regexp -nocase {\.?oc } $code]} {
                         set d [dict create results show echo false pipe octave]
                         set res [regsub {.+?> } [lindex [filter-pipe "$c\n" $d] 0] ""]
                         set jsonData [rl_json::json set jsonData blocks {*}$ckey [rl_json::json string "$res"]]
                         set jsonData [rl_json::json set jsonData blocks {*}$tkey Str]
                     } elseif {[regexp {\.?py } $code]} {
                         # this does not work (yet)
                         set d [dict create pipe python3 terminal true]
                         set res [regsub {.+> } [lindex [filter-pipe [string trim $c] $d] 0] ""]
                         #set res [regsub {^>.+\[1\]} $res ""]
                         set jsonData [rl_json::json set jsonData blocks {*}$ckey [rl_json::json string "$res"]]
                         set jsonData [rl_json::json set jsonData blocks {*}$tkey Str]
                     }
                 }
            }
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        } else  {
            append blocks "[::rl_json::json extract $jsonData blocks $i]\n"
        }
    }
    set ret "\"blocks\":\[$blocks\]"
    
    append ret ",\"pandoc-api-version\":[::rl_json::json extract $jsonData pandoc-api-version]"
    
    append ret ",\"meta\":[::rl_json::json extract $jsonData meta]"
    set out [open out.json w 0600]
    puts $out "{$ret}"
    close $out
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

