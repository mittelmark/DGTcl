#!/bin/sh
# A Tcl comment, whose contents don't matter \
exec tclsh "$0" "$@"
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created       : Fri Nov 15 10:20:22 2019
#  Last Modified : <220211.0646>
#
#  Description	 : Command line utility and package to extract Markdown documentation 
#                  from programming code if embedded as after comment sequence #' 
#                  manual pages and installation of Tcl files as Tcl modules.
#                  Copy and adaptation of dgw/dgwutils.tcl
#
#  History       : 2019-11-08 version 0.1
#                  2019-11-28 version 0.2
#                  2020-02-26 version 0.3
#                  2020-11-10 Release 0.4
#                  2020-12-30 Release 0.5 (rox2md)
#                  2022-02-09 Release 0.6
#	
##############################################################################
#
# Copyright (c) 2019-2022  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
# 
# This library is free software; you can use, modify, and redistribute it
# for any purpose, provided that existing copyright notices are retained
# in all copies and that this notice is included verbatim in any
# distributions.
# 
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
##############################################################################
#' ---
#' title: mkdoc::mkdoc __PKGVERSION__
#' author: Dr. Detlef Groth, Schwielowsee, Germany
#' documentclass: scrartcl
#' geometry:
#' - top=20mm
#' - right=20mm
#' - left=20mm
#' - bottom=30mm
#' ---
#'
#' ## NAME
#'
#' **mkdoc::mkdoc**  - Tcl package and command line application to extract and format 
#' embedded programming documentation from source code files written in Markdown and 
#' optionally converts them into HTML.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'      - [mkdoc::mkdoc](#mkdoc)
#'      - [mkdoc::run](#run)
#'  - [EXAMPLE](#example)
#'  - [BASIC FORMATTING](#format)
#'  - [INSTALLATION](#install)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE AND COPYRIGHT](#license)
#'
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' Usage as package:
#'
#' ```
#' package require mkdoc::mkdoc
#' mkdoc::mkdoc inputfile outputfile ?-html|-md|-pandoc -css file.css?
#' ```
#'
#' Usage as command line application for extraction of Markdown comments prefixed with `#'`:
#'
#' ```
#' mkdoc inputfile outputfile ?--html|--md|--pandoc --css file.css?
#' ```
#'
#' Usage as command line application for conversion of Markdown to HTML:
#'
#' ```
#' mkdoc inputfile.md outputfile.html ?--css file.css?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **mkdoc::mkdoc**  extracts embedded Markdown documentation from source code files and  as well converts Markdown output to HTML if desired.
#' The documentation inside the source code must be prefixed with the `#'` character sequence.
#' The file extension of the output file determines the output format. File extensions can bei either `.md` for Markdown output or `.html` for html output. The latter requires the tcllib Markdown extension to be installed. If the file extension of the inputfile is *.md* and file extension of the output files is *.html* there will be simply a conversion from a Markdown to a HTML file.
#'
#' The file `mkdoc.tcl` can be as well directly used as a console application. An explanation on how to do this, is given in the section [Installation](#install).
#'
#' ## <a name='command'>COMMAND</a>
#'
#'  <a name="mkdoc" />
#' **mkdoc::mkdoc** *infile outfile ?-mode -css file.css?*
#' 
#' > Extracts the documentation in Markdown format from *infile* and writes the documentation 
#'    to *outfile* either in Markdown  or HTML format. 
#' 
#' >  - *-infile filename* - file with embedded markdown documentation
#'   - *-outfile filename* -  name of output file extension
#'   - *-html* - (mode) outfile should be a html file, not needed if the outfile extension is html
#'   - *-md* - (mode) outfile should be a Markdown file, not needed if the outfile extension is md
#'   - *-pandoc* - (mode) outfile should be a pandoc Markdown file with YAML header, needed even if the outfile extension is md
#'   - *-css cssfile* if outfile mode is html uses the given *cssfile*
#'     
#' > If the *-mode* flag  (one of -html, -md, -pandoc) is not given, the output format is taken from the file extension of the output file, either *.html* for HTML or *.md* for Markdown format. This deduction from the filetype can be overwritten giving either `-html` or `-md` as command line flags. If as mode `-pandoc` is given, the Markdown markup code as well contains the YAML header.
#'   If infile has the extension .md than conversion to html will be performed, outfile file extension
#'   In this case must be .html. If output is html a *-css* flag can be given to use the given stylesheet file instead of the default style sheet embedded within the mkdoc code.
#'  
#' > Example:
#'
#' > ```
#' package require mkdoc::mkdoc
#' mkdoc::mkdoc mkdoc.tcl mkdoc.html
#' mkdoc::mkdoc mkdoc.tcl mkdoc.rmd -md
#' > ```

package require Tcl 8.4
if {[package provide Markdown] eq ""} {
    package require Markdown
}
if {![package vsatisfies [package provide Tcl] 8.6]} {
    proc lmap {_var list body} {
        upvar 1 $_var var
        set res {}
        foreach var $list {lappend res [uplevel 1 $body]}
        set res
    }
}
package provide mkdoc::mkdoc 0.6.0
package provide mkdoc [package present mkdoc::mkdoc]
package require yaml
namespace eval mkdoc {
    variable mkdocfile [info script]
    variable htmltemplate {
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: ; script-src 'self' 'nonce-d717cfb5d902616b7024920ae20346a8494f7832145c90e0' ; style-src 'self' 'unsafe-inline'" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="title" content="$document(title)">
<meta name="author" content="$document(author)">
<title>$document(title)</title>
<link rel="stylesheet" href="$document(css)">
</head>
<body>

}
variable htmlstart {
    <h1 class="title">$document(title)</h1>
    <h2 class="author">$document(author)</h2>
    <h2 class="date">$document(date)</h2>
}
variable style {
    body {
        margin-left: 5%; margin-right: 5%;
        font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
        max-width: 900px;
    }
pre {
padding-top:	1ex;
padding-bottom:	1ex;
padding-left:	2ex;
padding-right:	1ex;
width:		100%;
color: 		black;
background: 	#fff4e4;
border-top:		1px solid black;
border-bottom:		1px solid black;
font-family: Monaco, Consolas, "Liberation Mono", Menlo, Courier, monospace;

}
a { text-decoration: none }
pre.synopsis {
    background: #cceeff;
}
pre.code code.tclin {
    background-color: #ffeeee;
}
pre.code code.tclout {
    background-color: #ffffee;
}

code {
    font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
}
h1,h2, h3,h4 {
    font-family:	sans-serif;
    background: 	transparent;
}
h1 {
    font-size: 120%;
    text-align: center;
}

h2.author, h2.date {
    text-align: center;
    color: black;
}
h2 {
    font-size: 110%;
}
h3, h4 {
    font-size: 100%
}
div.title h1 {
    font-family:	sans-serif;
    font-size:	120%;
    background: 	transparent;
    text-align:	center;
    color: black;
}
div.author h3, div.date h3 {
    font-family:	sans-serif;
    font-size:	110%;
    background: 	transparent;
    text-align:	center;
    color: black ;
}
h2 {
margin-top: 	1em;
font-family:	sans-serif;
font-size:	110%;
color:		#005A9C;
background: 	transparent;
text-align:		left;
}

h3 {
margin-top: 	1em;
font-family:	sans-serif;
font-size:	100%;
color:		#005A9C;
background: 	transparent;
text-align:		left;
}
}
} 

proc ::mkdoc::pfirst {varname arglist} {
    upvar $varname x
    set varval $x
    if {[regexp {^-} $varval]} {
        set arglist [linsert $arglist 0 $varval]
        set x [lindex $args end]
        set arglist [lrange $arglist 0 end-1]
    } else {
        set x $varval
    }
    return $arglist
}
# argument parser for procedures
# places all --options or -options in an array given with arrayname
# recognises
# -option2 value -flag1 -flag2 -option2 value
proc ::mkdoc::pargs {arrayname defaults args} {
    upvar $arrayname arga
    array set arga $defaults
    set args {*}$args
    set kindex 0
    set args [lmap i $args { regsub -- {^--} $i "-" }]
    while {[llength $args] > 0} {
        set a [lindex $args 0]
        set args [lrange $args 1 end]
        if {[regexp {^-{1,2}(.+)} $a -> opt]} {
            if {[llength $args] == 0} {
                # odd number - take first key
                set key [lindex $defaults $kindex]
                set arga($key) $opt
            } elseif {([llength $args] > 0 && [regexp -- {^-} [lindex $args 0]]) || [llength $args] == 0} {
                set arga($opt) true
            } elseif {[regexp {^[^-].*} [lindex $args 0] value]} {
                #set opt [lindex $defaults $kindex]
                incr kindex 2
                set arga($opt) $value
                set args [lrange $args 1 end]
            }
        } 
    }
    
}

proc ::mkdoc::getPackageInformation {filename} {
    set basename [file rootname [file tail $filename]]
    if {[file extension $filename] in [list .tm .tcl]} {
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                # Process line
                if {[regexp {^\s*package\s+provide\s+([^\s]+)\s+([.0-9a-z]+)} $line -> package version]} {
                    return [list name $package version $version basename $basename]
                }
            }
            close $infh
        }
    }
    return [list name "" version "" basename $basename]
}
proc mkdoc::mkdoc {filename outfile args} {
    variable mkdocfile
    variable htmltemplate
    variable htmlstart
    variable style
    # prepare sorting methods and options
    set dmeths [dict create]
    set methods false
    
    array set pkg [getPackageInformation $filename]
    if {[llength $args] == 1} {
        set args {*}$args
    }
    ::mkdoc::pargs arg [list mode "" css "mkdoc.css"] $args
    set mode $arg(mode)
    if {$mode ni [list "" html markdown man pandoc]} {
        set file [file join [file dirname $mkdocfile] ${mode}.tcl]
        lappend ::auto_path [file join [file dirname [info script]] ..]
        catch { package require mkdoc::${mode} }
        if {[lsearch [package names] mkdoc::${mode}] == -1} {
            error "package mkdoc::${mode} for mode $mode does not exist"
        } else {
            mkdoc::$mode $filename $outfile
        } 
        return
    }
    if {[file extension $filename] eq [file extension $outfile]} {
        error "Error: infile and outfile must have different file extensions"
    }
    if {[file extension $filename] eq ".md"} {
        if {[file extension $outfile] ne ".html"} {
            error "For converting Markdown files directly file extension of output file must be .html"
        }
        set mode "html"
        set extract false
    } else {
        set extract true
    }
    if {$mode eq ""} {
        if {[file extension $outfile] eq ".html"} {
            set mode "html"
        } elseif {[file extension $outfile] eq ".md"} {
            set mode "markdown"
        } else {
            error "Unknown output file format, must be either .html or .md"
        }
    } else {
        if {$mode ne "html" && $mode ne "markdown" && $mode ne "md" && $mode ne "pandoc"} {
            error "Unknown mode, must be either -html, -md, -markdown or -pandoc"
        } 
    }
    set markdown ""
    if {$mode eq "html"} {
        if {[package provide Markdown] eq ""} {
            error "Error: For html mode you need package Markdown from tcllib. Download and install tcllib from http://core.tcl.tk"
        } else {
            package require Markdown   
        }
    }
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set flag false
        while {[gets $infh line] >= 0} {
            if {$extract} {
                if {[regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
                    if [catch {open $include r} iinfh] {
                        puts stderr "Cannot open $filename: $include"
                        exit 0
                    } else {
                        #set ilines [read $iinfh]
                        while {[gets $iinfh iline] >= 0} {
                            # Process line
                            append markdown "$iline\n"
                        }
                        close $iinfh
                    }
                } elseif {[regexp {^\s*#' ?(.*)} $line -> md]} {
                    append markdown "$md\n"
                }
            } else {
                # simple markdown to html converter
                append markdown "$line\n"
            }
        }
        close $infh
        set yamldict [dict create title "Documentation [file tail [file rootname $filename]]" author "NN" date  [clock format [clock seconds] -format "%Y-%m-%d"] author NN css mkdoc.css]
        if {$arg(css) ne ""} {
            dict set yamldict css $arg(css)
        } 
        set mdhtml ""
        set yamlflag false
        set yamltext ""
        set hasyaml false
        set indent ""
        set header $htmltemplate
        set lnr 0
        foreach line [split $markdown "\n"] {
            incr lnr 
            # todo document pkgversion and pkgname
            set line [regsub {__PKGVERSION__} $line [package provide mkdoc::mkdoc]]
            set line [regsub -all {__PKGNAME__} $line mkdoc::mkdoc]
            if {$lnr < 5 && !$yamlflag && [regexp {^---} $line]} {
                set yamlflag true
            } elseif {$yamlflag && [regexp {^---} $line]} {
                set hasyaml true
                set yamldict [dict merge $yamldict [yaml::yaml2dict $yamltext]]
                set yamlflag false
                if {$arg(mode) ne "pandoc"} {
                    set yamltext ""
                } else {
                    set yamltext "---\n$yamltext---"
                }
                
            } elseif {$yamlflag} {
                append yamltext "$line\n"
            } else {
                if {$pkg(name) ne ""} {
                    set line [regsub -all {__PKGNAME__} $line $pkg(name)]
                } 
                if {$pkg(version) ne ""} {
                    set line [regsub -all {__PKGVERSION__} $line $pkg(version)]
                }
                set line [regsub -all {__DATE__} $line [clock format [clock seconds] -format "%Y-%m-%d"]] 
                set line [regsub -all {__BASENAME__} $line $pkg(basename)]
                # sorting code start: collect and sort methods alphabetically
                if {$methods && [regexp {^## <a\s+name} $line]} {
                    set methods false
                    foreach key [lsort [dict keys $dmeths]] {
                        if {[dict get $dmeths $key] ne ""} {
                            if {$mode eq "man"} {
                                puts [dict get $dmeths $key]
                            } else {
                                append mdhtml [dict get $dmeths $key]
                            }
                        }
                    }
                    
                }
                if {[regexp {<a\s+name='(methods|options|commands)'>} $line]} {
                    # clean up old keys, can't use dict unset for whatever reasons
                    foreach key [lsort [dict keys $dmeths]] {
                        dict set dmeths $key ""
                    }
                    set methods true
                }
                if {$methods && [regexp {[*_]{2}([-a-zA-Z0-9_]+?)[*_]{2}} $line -> meth]} {
                    set dkey $meth
                    dict set dmeths $dkey "$indent$line\n"
                    continue
                    
                } elseif {$methods && [info exists dkey]} {
                    set ometh [dict get $dmeths $dkey]
                    dict set dmeths $dkey "$ometh$indent$line\n"
                    continue
                }
                set line [regsub -all {!\[\]\((.+?)\)} $line "<image src=\"\\1\"></img>"]
                append mdhtml "$indent$line\n"
            }
        }
        if {$mode eq "html"} {
            set htm [Markdown::convert $mdhtml]
            set html ""
            # synopsis fix as in tcllib with blue background
            set synopsis false
            foreach line [split $htm "\n"] {
                if {[regexp {^<h2>} $line]} {
                    set synopsis false
                } 
                if {[regexp -nocase {^<h2>.*Synopsis} $line]} {
                    set synopsis true
                }
                if {$synopsis && [regexp {<pre>} $line]} {
                    set line [regsub {<pre>} $line "<pre class='synopsis'>"]
                }
                append html "$line\n"
            }
            set out [open $outfile w 0644]
            foreach key [dict keys $yamldict] {
                set document($key) [dict get $yamldict $key]
            }
            if {![dict exists $yamldict date]} {
                dict set yamldict date [clock format [clock seconds]]
            }
            set header [subst -nobackslashes -nocommands $header]
            if {$hasyaml} {
                set start [subst -nobackslashes -nocommands $htmlstart]            
                puts $out $start
            }
            puts $out $header
            puts $out $html
            puts $out "</body>\n</html>"
            close $out
            if {[dict get $yamldict css] eq "mkdoc.css" && ![file exists "mkdoc.css"]} {
                set out [open mkdoc.css w 0600]
                puts $out $style
                close $out
            }
            puts stderr "Success: file $outfile was written!"
        } elseif {$mode eq "pandoc"} {
            set out [open $outfile w 0644]
            puts $out $yamltext
            puts $out $mdhtml
            close $out
            
        } else {
            set out [open $outfile w 0644]
            puts $out $mdhtml
            close $out
        }
    }
}
#' 
#' <a name="run" />
#' **mkdoc::run** *infile* 
#' 
#' > Source the code in infile and runs the examples in the documentation section
#'    written with Markdown documentation. Below follows an example section which can be
#'    run with `tclsh mkdoc.tcl mkdoc.tcl -run`
#' 
#' ## <a name="example">EXAMPLE</a>
#' 
#' ```
#' puts "Hello mkdoc package"
#' puts "I am in the example section"
#' ```
#' 
proc ::mkdoc::run {argv} {
    set filename [lindex $argv 0]
    if {[llength $argv] == 3} {
        set t [lindex $argv 2]
    } else {
        set t 1
    }
    source $filename
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
        if {$t > -1} {
            catch {
                update idletasks
                after [expr {$t*1000}]
                destroy .
            }
        }
    }
}


if {[info exists argv0] && $argv0 eq [info script]} {
    
set Usage {
Usage: __APP__ INFILE OUTFILE [--html] [--md] [--pandoc] 
           [--css file.css] [--help] [--version]
           
mkdoc - code documentation tool to process embedded Markdown markup
        given after "#'" comments
        
Positional arguments (required):

    INFILE - input file with:
               - embedded Markdown comments: #' Markdown markup
               - pure Markdown code (file.md)
    OUTFILE - output file usually HTML or Markdown file,
              file format is deduced on file extension .html or .md,
              if other file extensions are used, give the 
              --html, --md or --pandoc flags
            
Optional arguments:

    --help   - display this help page
    
    --html   - output file format is HTML              
    --md     - output file format is Markdown
    --pandoc - output file format is Markdown with YAML header
    
    --css  CSSFILE  - use the given CSSFILE instead of default mkdoc.css
    
    --version - display version number
    
Examples:
    
    # create manual page for mkdoc.tcl itself 
    __APP__ mkdoc.tcl mkdoc.html
    
    # create manual code for a CPP file using an own style sheet
    __APP__ sample.cpp sample.html --css manual.css
    
    # extract code documentation as simple Markdown
    # ready to be processed further with pandoc
    __APP__ sample.cpp sample.md --pandoc
    
    # convert a Markdown file to HTML
    __APP__ sample.md sample.html
    
Author: @ Dr. Detlef Groth, Schwielowsee, 2019-2022
    
License: MIT
}
    if {[lsearch $argv {--version}] > -1} {
        puts "[package provide mkdoc::mkdoc]"
        return
    } elseif {[lsearch $argv {--license}] > -1} {
        puts "MIT License - see manual page"
        return
    }
    if {[llength $argv] < 2 || [lsearch $argv {--help}] > -1} {
        set usage [regsub -all {__APP__} $Usage [info script]]
        puts $usage
    } elseif {[llength $argv] >= 2 && [lsearch $argv {--run}] == 1} {
        mkdoc::run $argv 
    } elseif {[llength $argv] == 2} {
        mkdoc::mkdoc [lindex $argv 0] [lindex $argv 1]
    } elseif {[llength $argv] > 2} {
        mkdoc::mkdoc [lindex $argv 0] [lindex $argv 1] [lrange $argv 2 end]
    }
}

#'
#' ## <a name='format'>BASIC FORMATTING</a>
#' 
#' For a complete list of Markdown formatting commands consult the basic Markdown syntax at [https://daringfireball.net](https://daringfireball.net/projects/markdown/syntax). 
#' Here just the most basic essentials  to create documentation are described.
#' Please note, that formatting blocks in Markdown are separated by an empty line, and empty line in this documenting mode is a line prefixed with the `#'` and nothing thereafter. 
#'
#' **Title and Author**
#' 
#' Title and author can be set at the beginning of the documentation in a so called YAML header. 
#' This header will be as well used by the document converter [pandoc](https://pandoc.org)  to handle various options for later processing if you extract not HTML but Markdown code from your documentation.
#'
#' A YAML header starts and ends with three hyphens. Here is the YAML header of this document:
#' 
#' ```
#' #' ---
#' #' title: mkdoc - Markdown extractor and formatter
#' #' author: Dr. Detlef Groth, Schwielowsee, Germany
#' #' ---
#' ```
#' 
#' Those four lines produce the two lines on top of this document. You can extend the header if you would like to process your document after extracting the Markdown with other tools, for instance with Pandoc.
#' 
#' You can as well specify an other style sheet, than the default by adding
#' the following style information:
#'
#' ```
#' #' ---
#' #' title: mkdoc - Markdown extractor and formatter
#' #' author: Dr. Detlef Groth, Schwielowsee, Germany
#' #' output:
#' #'   html_document:
#' #'     css: tufte.css
#' #' ---
#' ```
#' 
#' Please note, that the indentation is required and it is two spaces.
#'
#' **Headers**
#'
#' Headers are prefixed with the hash symbol, single hash stands for level 1 heading, double hashes for level 2 heading, etc.
#' Please note, that the embedded style sheet centers level 1 and level 3 headers, there are intended to be used
#' for the page title (h1), author (h3) and date information (h3) on top of the page.
#' 
#' ```
#'   #'  ## <a name="sectionname">Section title</a>
#'   #'    
#'   #'  Some free text that follows after the required empty 
#'   #'  line above ...
#' ```
#'
#' This produces a level 2 header. Please note, if you have a section name `synopsis` the code fragments thereafer will be hilighted different than the other code fragments. You should only use level 2 and 3 headers for the documentation. Level 1 header are reserved for the title.
#' 
#' **Lists**
#'
#' Lists can be given either using hyphens or stars at the beginning of a line.
#'
#' ```
#' #' - item 1
#' #' - item 2
#' #' - item 3
#' ```
#' 
#' Here the output:
#'
#' - item 1
#' - item 2
#' - item 3
#' 
#' A special list on top of the help page could be the table of contents list. Here is an example:
#'
#' ```
#' #' ## Table of Contents
#' #'
#' #' - [Synopsis](#synopsis)
#' #' - [Description](#description)
#' #' - [Command](#command)
#' #' - [Example](#example)
#' #' - [Authors](#author)
#' ```
#'
#' This will produce in HTML mode a clickable hyperlink list. You should however create
#' the name targets using html code like so:
#'
#' ```
#' ## <a name='synopsis'>Synopsis</a> 
#' ```
#' 
#' **Hyperlinks**
#'
#' Hyperlinks are written with the following markup code:
#'
#' ```
#' [Link text](URL)
#' ```
#' 
#' Let's link to the Tcler's Wiki:
#' 
#' ```
#' [Tcler's Wiki](https://wiki.tcl-lang.org/)
#' ```
#' 
#' produces: [Tcler's Wiki](https://wiki.tcl-lang.org/)
#'
#' **Indentations**
#'
#' Indentations are achieved using the greater sign:
#' 
#' ```
#' #' Some text before
#' #'
#' #' > this will be indented
#' #'
#' #' This will be not indented again
#' ```
#' 
#' Here the output:
#'
#' Some text before
#' 
#' > this will be indented
#' 
#' This will be not indented again
#'
#' Also lists can be indented:
#' 
#' ```
#' > - item 1
#'   - item 2
#'   - item 3
#' ```
#'
#' produces:
#'
#' > - item 1
#'   - item 2
#'   - item 3
#'
#' **Fontfaces**
#' 
#' Italic font face can be requested by using single stars or underlines at the beginning 
#' and at the end of the text. Bold is achieved by dublicating those symbols:
#' Monospace font appears within backticks.
#' Here an example:
#' 
#' ```
#' #' > I am _italic_ and I am __bold__! But I am programming code: `ls -l`
#' ```
#'
#' > I am _italic_ and I am __bold__! But I am programming code: `ls -l`
#' 
#' **Code blocks**
#'
#' Code blocks can be started using either three or more spaces after the #' sequence 
#' or by embracing the code block with triple backticks on top and on bottom. Here an example:
#' 
#' ```
#' #' ```
#' #' puts "Hello World!"
#' #' ```
#' ```
#'
#' Here the output:
#'
#' ```
#' puts "Hello World!"
#' ```
#'
#' **Images**
#'
#' If you insist on images in your documentation, images can be embedded in Markdown with a syntax close to links.
#' The links here however start with an exclamation mark:
#' 
#' ```
#' #' ![image caption](filename.png)
#' ```
#' 
#' The source code of mkdoc.tcl is a good example for usage of this source code 
#' annotation tool. Don't overuse the possibilities of Markdown, sometimes less is more. 
#' Write clear and concise, don't use fancy visual effects.
#' 
#' **Includes**
#' 
#' mkdoc in contrast to standard markdown as well support includes. Using the `#' #include "filename.md"` syntax 
#' it is possible to include other markdown files. This might be useful for instance to include the same 
#' header or a footer in a set of related files.
#'
#' ## <a name='install'>INSTALLATION</a>
#' 
#' The mkdoc::mkdoc package can be installed either as command line application or as a Tcl module. It requires the markdown, cmdline, yaml and textutils packages from tcllib to be installed.
#' 
#' Installation as command line application is easiest by downloading the file [mkdoc-0.6.bin](https://raw.githubusercontent.com/mittelmark/DGTcl/master/bin/mkdoc-0.6.bin), which
#' contains the main script file and all required libraries, to your local machine. Rename this file to mkdoc, make it executable and coy it to a folder belonging to your PATH variable.
#' 
#' Installation as command line application can be as well done by copying the `mkdoc.tcl` as 
#' `mkdoc` to a directory which is in your executable path. You should make this file executable using `chmod`. 
#' 
#' Installation as Tcl package by copying the mkdoc folder to a folder 
#' which is in your library path for Tcl. Alternatively you can install it as Tcl mode by copying it 
#' in your module path as `mkdoc-0.6.0.tm` for instance. See the [tm manual page](https://www.tcl.tk/man/tcl8.6/TclCmd/tm.htm)
#'
#' ## <a name='see'>SEE ALSO</a>
#' 
#' - [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md) for the Markdown and the textutil packages
#' - [pandoc](https://pandoc.org) - a universal document converter
#' - [Ruff!](https://github.com/apnadkarni/ruff) Ruff! documentation generator for Tcl using Markdown syntax as well

#' 
#' ## <a name='changes'>CHANGES</a>
#'
#' - 2019-11-19 Release 0.1
#' - 2019-11-22 Adding direct conversion from Markdown files to HTML files.
#' - 2019-11-27 Documentation fixes
#' - 2019-11-28 Kit version
#' - 2019-11-28 Release 0.2 to fossil
#' - 2019-12-06 Partial R-Roxygen/Markdown support
#' - 2020-01-05 Documentation fixes and version information
#' - 2020-02-02 Adding include syntax
#' - 2020-02-26 Adding stylesheet option --css 
#' - 2020-02-26 Adding files pandoc.css and dgw.css
#' - 2020-02-26 Making standalone file using pkgDeps and mk_tm
#' - 2020-02-26 Release 0.3 to fossil
#' - 2020-02-27 support for \_\_DATE\_\_, \_\_PKGNAME\_\_, \_\_PKGVERSION\_\_ macros  in Tcl code based on package provide line
#' - 2020-09-01 Roxygen2 plugin
#' - 2020-11-09 argument --run supprt
#' - 2020-11-10 Release 0.4
#' - 2020-11-11 command line option  --run with seconds
#' - 2020-12-30 Release 0.5 (rox2md @section support with preformatted, emph and strong/bold)
#' - 2022-02-11 Release 0.6.0 
#'      - parsing yaml header
#'      - workaround for images
#'      - making standalone using tpack.tcl [mkdoc-0.6.bin](https://github.com/mittelmark/DGTcl/blob/master/bin/mkdoc-0.6.bin)
#'      - terminal help update and cleanup
#'      - moved to Github in Wiki
#'      - code cleanup
#'
#' ## <a name='todo'>TODO</a>
#'
#' - extract Roxygen2 documentation codes from R files (done)
#' - standalone files using something like mk_tm module maker (done, just using tpack ;)
#' - support for \_\_PKGVERSION\_\_ and \_\_PKGNAME\_\_ replacements at least in Tcl files and via command line for other file types (done)
#'
#' ## <a name='authors'>AUTHOR(s)</a>
#'
#' The **mkdoc::mkdoc** package was written by Dr. Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#'
#' Markdown extractor and converter mkdoc::mkdoc, version __PKGVERSION__
#'
#' Copyright (c) 2019-22  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#'


