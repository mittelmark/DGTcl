#!/bin/sh
# A Tcl comment, whose contents don't matter \
exec tclsh "$0" "$@"
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Feb 18 06:05:14 2020
#  Last Modified : <201109.0555>
#
##############################################################################
#
# Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
# 
#  Description	 : Command line utility and package to embed and evaluate Tcl code
#                  inside Markdown documents, a technique known as literate programming. 
#
#  History       : 2020-02-19 version 0.1
#                  2020-02-21 version 0.2 
#                  2020-02-23 version 0.3
#                  2020-11-09 version 0.4
#	
##############################################################################
#
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
#'
#' ---
#' title: tmdoc::tmdoc 0.4 
#' author: Dr. Detlef Groth, Schwielowsee, Germany
#' documentclass: scrartcl
#' geometry:
#' - top=20mm
#' - right=20mm
#' - left=20mm
#' - bottom=30mm
#' ---
#'
#' ## <a>NAME</a>
#'
#' **tmdoc::tmdoc**  - Literate Programming with Tcl and Markdown. 
#' Flexible framework for mixing Markdown text and Tcl code for 
#' automatic report generation. The results of the Tcl code evaluation 
#' are embedded into the output document.
#'
#' ## <a name='toc'>TABLE OF CONTENTS</a>
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [EXAMPLE](#example)
#'  - [BASIC FORMATTING](#format)
#'  - [DOCUMENTATION](#docu)
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
#' package require tmdoc::tmdoc
#' namespace import tmdoc::tmdoc
#' tmdoc infile ?-outfile outputfile -mode tangle?
#' ```
#'
#' Usage as command line application:
#'
#' ```
#' tclsh tmdoc.tcl infile ?--outfile outputfile --mode tangle?
#' ```
#'
##############################################################################
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **tmdoc::tmdoc** is a tool for literate programming. It either evaluates Tcl code
#'    embedded within Markdown documents in *weave* mode or it alternativly extracts 
#'    Tcl code from such documents in *tangle* mode. The results of the Tcl code 
#'    written in code chunks using backticks as code indicators oas well as the 
#'    Tcl code can be displayed or hidden by setting code chunk options.
#'    *tmdoc::tmdoc* can be used as Tcl package or standalone as a console application.
#'
namespace eval ::tmdoc {} 
package provide tmdoc::tmdoc 0.4
package provide tmdoc [package provide tmdoc::tmdoc]
# TODO: include into argparse
# check if a -option is first parameter if yes places last argument
# parameter in varname a#nd removes it first argument is places in front 
# of arglist that way it does not matter if argument order is
# func filename -option value -flag
# or 
# func -option value -flag filename
# returns: modified argument list 
proc tmdoc::pfirst {varname arglist} {
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
proc tmdoc::pargs {arrayname defaults args} {
    upvar $arrayname arga
    array set arga $defaults
    set args {*}$args
    if {[llength $args] > 0} {
        set args [lmap i $args { regsub -- {^--} $i "-" }]
        while {[llength $args] > 0} {
            set a [lindex $args 0]
            set args [lrange $args 1 end]
            if {[regexp {^-{1,2}(.+)} $a -> opt]} {
                if {([llength $args] > 0 && [regexp -- {^-} [lindex $args 0]]) || [llength $args] == 0} {
                    set arga($opt) true
                } elseif {[regexp {^[^-].*} [lindex $args 0] value]} {
                    set arga($opt) $value
                    set args [lrange $args 1 end]
                }
            } 
        }
    }
}

proc ::tmdoc::interpReset {} {
    if {[interp exists intp]} {
        interp delete intp
        interp delete try
    }
    interp create intp
    interp eval intp " set pres {} ;  set auto_path {$::auto_path}"
    interp eval intp { rename puts puts.orig }
    interp eval intp { 
        proc puts {args} { 

            # TODO: catch if channel stdout is given
            set l [llength $args]
            if {[lindex $args 0] eq "-nonewline"} {
                if {$l == 2} {
                    # no channel
                    append ::pres [lindex $args 1]
                } else {
                    if {[lindex $args 1] eq "stdout"} {
                        append ::pres [lindex $args 2]
                    } else {
                        return [puts.orig -nonewline [lindex $args 1] [lindex $args 2]]
                    }
                }
            } else {
                if {$l == 1} {
                    append ::pres "[lindex $args 0]\n"
                } else {
                    # channel given
                    #puts.orig stderr "channel given $args"
                    if {[lindex $args 0] eq "stdout"} {
                        append ::pres "[lindex $args 1]\n"
                    } else {
                        puts.orig [lindex $args 0] [lindex $args 1]
                    }
                }
            }
            return ""
        }
    } 
    interp eval intp { 
        proc gputs {} { 
            set res $::pres 
            set ::pres ""
            return $res 
        }
    }
    # todo handle puts options
    
    # this is the try interp for the catch statements
    # we first check statements and only if they are ok
    # the real interpreter intp will be used
    interp create try
    interp eval try { rename puts puts.orig }
    # todo handle puts options
    interp eval try { proc puts {args} {  } }
}
#' ## <a name='command'>COMMAND</a>
#'
#' **tmdoc::tmdoc** infile ?-outfile filename -mode weave\|tangle?
#'
#' > Reads the inputfile *infile* and either evaluates the Tcl code within '
#' the code chunks in the *infile* document and adds the evaluation results if
#' the given mode is *weave*, which is default. If the given mode is *tangle*  
#' the tcl code within code chunks is written out. The output is either send to
#' the *stdout* channel or to the given *outfile*. The following arguments or options can be given:
#'
#' > - *infile* (mandatory) the file which contains Tcl code embedded within Markdown or LaTeX documents, usually the file has an extension *.tmd*, if you process LaTeX files, given them an extension *.tnw* or *.Tnw* or choose the -outfile option. 
#'   - *-outfile filename* (optional) the file where the output is written to, if the file has the extension *.tex* the processing mode is LaTeX, default: *stdout*.
#'   - *-mode weave|tangle* (optional) either *weave* for evaluating the Tcl code or *tangle* for extracting the Tcl code, default: *weave*.
#' 
    
proc ::tmdoc::tmdoc {filename args} {
    # argv will be just a list
    if {[llength $args] == 1} {
        set args {*}$args
    }
    if {[string tolower [file extension $filename]] eq ".tnw"} {
        set inmode latex
    } else {
        set inmode md
    }
    #set args [lmap $args i { regsub -- {--} $i - }]
    #if {[regexp {^-} $filename]} {
    #    set args [linsert $args 0 $filename]
    #    set filename [lindex $args end]
    #    set args [lrange $args 0 end-1]
    #}
    set args [::tmdoc::pfirst filename $args]
    ::tmdoc::pargs arg [list mode weave outfile stdout infile ""] $args
    if {$arg(outfile) ne "stdout"} {
        if {[file extension $arg(outfile)] eq ".tex"} {
            set inmode latex
        }
        set out [open $arg(outfile) w 0600]
    } else {
        set out stdout
    } 
    if {$arg(mode) eq "tangle"} {
        puts stderr "$args tangle"
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            set flag false
            while {[gets $infh line] >= 0} {
                if {[regexp {^[> ]{0,2}```\{tcl[^a-zA-Z]} $line]} {
                    set flag true
                    continue
                } elseif {$flag && [regexp {^[> ]{0,2}```} $line]} {
                    set flag false
                    continue
                } elseif {$flag} {
                    puts $out $line
                }
            }
            close $infh
        }
        if {$arg(outfile) ne "stdout"} {
            close $out
        }
        return
    }
    set mode text
    set tclcode ""
    array set dopt [list echo true results show fig false include true \
                    fig.width 12cm fig.height 12cm fig.cap {} label chunk-nn ext png]
    interpReset
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set chunki 0
        while {[gets $infh line] >= 0} {
            if {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\{tcl\s*(.*)\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
                foreach opt [split $opts ","] {
                    set opt [string trim [string tolower $opt]]
                    set o [split $opt =] 
                    set key [lindex $o 0]
                    set value [lindex $o 1]
                    
                    set copt($key) $value
                }
                # setting default label if no label was given
                foreach key [array names copt] {
                    if {$key eq "label" && $copt($key) eq "chunk-nn"} {
                        set value [regsub {nn} $copt($key) $chunki]
                        set copt($key) $value
                    }
                }
                continue
            } elseif {$mode eq "code" && [regexp {```} $line]} {
                #puts stderr $tclcode
                #puts stderr [array get copt]
                if {$copt(echo)} {
                    if {$inmode eq "md"} {
                        puts $out "```{.tcl}"
                        puts -nonewline $out $tclcode
                        puts $out "```"
                    } else {
                        puts $out "\\begin{lcverbatim}"
                        puts -nonewline $out $tclcode
                        puts $out "\\end{lcverbatim}"
                    }
                }
                if {[catch {interp eval try $tclcode} res]} {
                    if {$inmode eq "md"} {
                        puts $out "```{.tclerr}\n$res\n```\n"
                    } else {
                        puts $out "\n\\begin{lrverbatim}\n$res\n\\end{lrverbatim}\n"
                    }
                } else {
                    set res [interp eval intp $tclcode]
                    set pres [interp eval intp gputs]
                    if {$copt(results) eq "show"} {
                        if {$inmode eq "md"} {
                            if {$res ne "" || $pres ne ""} {
                                puts $out "```{.tclout}"
                            }
                            if {$pres ne ""} {
                                puts -nonewline $out "$pres"
                            }
                            if {$res ne ""} {
                                puts $out "==> $res"
                            }
                            if {$res ne "" || $pres ne ""} {
                                puts $out "```"
                            }
                        } else {
                            if {$res ne "" || $pres ne ""} {
                                puts $out "\\begin{lbverbatim}"
                            }
                            if {$pres ne ""} {
                                puts -nonewline $out "$pres"
                            }
                            if {$res ne ""} {
                                puts $out "==> $res"
                            }
                            if {$res ne "" || $pres ne ""} {
                                puts $out "\\end{lbverbatim}"
                            }
                            
                        }
                    }
                    if {$copt(fig)} {
                        set imgfile [file tail [file rootname $filename]]-$copt(label).$copt(ext)
                        if {[interp eval intp "info commands figure"] eq ""} {
                            if {$inmode eq "md"} {
                                puts $out "```{.tclerr}\nYou need to define a figure procedure \nwhich gets a filename as argument"
                                puts $out "proc figure {filename} { }\n\nwhere within you create the image file```\n"
                            } else {
                                puts $out "\n\\begin{lrverbatim}\n\nYou need to define a figure procedure \nwhich gets a filename as argument\n"
                                puts $out "proc figure {filename} { }\n\nwhere within you create the image file\\end{lrverbatim}\n"
                            }
                        } else {
                            interp eval intp [list figure $imgfile]
                            if {$copt(include)} {
                                if {$inmode eq "md"} {
                                    puts $out "\n!\[\]($imgfile)\n"
                                } else {
                                    puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{$imgfile}\n"
                                }
                            }
                        }
                    }
                }
                set tclcode ""
                set mode text
                continue
            } elseif {$mode eq "text" && [regexp {[> ]{0,2}```} $line]} {
                set mode pretext
                puts $out $line
                continue
            } elseif {$mode eq "pretext" && [regexp {[> ]{0,2}```} $line]} {
                puts $out $line
                set mode text
            } elseif {$mode eq "text"} {
                # todo check for `tcl fragments`
                while {[regexp {(.*?)`tcl ([^`]+)`(.*)$} $line -> pre t post]} {
                    if {[catch {interp eval try $t} res]} {
                        if {$inmode eq "md"} {
                            set line "$pre*??$res??*$post"
                        } else {
                            set line [regsub -all {_} "$pre*??$res??*$post" {\\_}]
                        }
                    } else {
                        set res [interp eval intp $t]
                        if {$inmode eq "md"} {                                                
                            set line "$pre$res$post"
                        } else {
                            set line [regsub -all {_}  "$pre$res$post" {\\_}]
                        }
                    }

                }
                puts $out $line
            } elseif {$mode eq "pretext"} {
                puts $out $line
            } elseif {$mode eq "code"} {
                if {[regexp {^\s*::tmdoc::interpReset} $line]} {
                    puts stderr "resetting interp"
                    ::tmdoc::interpReset
                    append tclcode "# ::tmdoc::interpReset\n"
                } else {
                    append tclcode "$line\n"
                }
            } else {
                error "error on '$line' should be not reachable"
            }
            
        }
        close $infh
        if {[interp exists intp]} {
            interp eval intp { catch {destroy . } }
            interp delete intp
        }
        if {[interp exists try]} {
            interp eval try { catch { destroy . } }
            interp delete try
        }
    }
}
namespace eval ::tmdoc {
    namespace export tmdoc
}

#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#' package require tmdoc
#' namespace import tmdoc::tmdoc
#' tmdoc tmdoc-example.tmd --outfile tmdoc-example.md
#' tmdoc tmdoc-example.tmd --mode tangle --outfile tmdoc-example.tcl
#'```
#'
#' ## <a name='format'>BASIC FORMATTING</a>
#' 
#' For a complete list of Markdown formatting commands consult the basic 
#' Markdown syntax at [https://daringfireball.net](https://daringfireball.net/projects/markdown/syntax). 
#' 
#' ### <a>Code chunks</a>
#'
#' Tcl code is embedded as chunks into the Markdown documents using backticks. Code blocks are started with triple backticks and indicated with the the string "tcl" within curly braces. See the following example.
#' 
#' ```
#'  ```{tcl}
#'  set x 1
#'  ```
#' ```
#' 
#' This would show both the Tcl code as well the output of the last statement.
#'
#' Within the curly braces a few chunk options can be placed in the form of *prop=value* like in the example below:
#' 
#' ```
#'  ```{tcl label=mlabel,echo=false,results=hide}
#'  set x 1
#'  ```
#' ```
#' 
#' - *label=mlabel* option gives the chunk a label, sometimes useful for 
#'    debugging or for embedding images. For this see below.
#' - *echo=false* - hides the Tcl code in the output
#' - *results=hide* did not show the output of the Tcl command
#'
#' ### <a>Inline code chunks</a>
#'
#' Short Tcl codes can be as well evaluated within the standard text flow. For instance:
#'
#' ```
#'  The current date is `tcl clock format [clock seconds] -format "%Y-%m-%d"`
#' ```
#'
#' Would insert the current date into the text. So text inline code chunks are possible using single backticks such as here ` \`tcl set x\` `.
#' 
#' ### <a>Images</a>
#' 
#' Inside standard code chunks as well images with Tcl can be generated with normal Tcl code.
#'
#' To support the standard chunk properties *fig=true*, optionally with *include=false* however a Tcl procedure proc must be provided. Below is an example to use the tklib package *canvas::snap* to create images using the Tk canvas.
#'
#' ```
#'  ```{tcl}
#'  package require Tk
#'  package require canvas::snap
#'  pack [canvas .c -background beige] \
#'    -padx 5 -pady 5 -side top -fill both -expand yes
#'  proc figure {outfile}
#'     set img [canvas::snap .c]
#'     $img write $outfile -format png
#'  }
#'  ```
#' ```
#'
#' After preparing the canvas and the figure procedure the canvas can be used for 
#' making images like in the example below:
#' 
#' ```
#'  ```{tcl,fig=true,results=hide}
#'  .c create rectangle 60 60 90 90  -fill blue
#'  ```
#' ```
#' The code above will create a canvas figure and embeds it automatically. 
#' If you need more control on the figure placement you can 
#' use the option *include=false*
#'
#' ```
#'  ```{tcl,label=mfig,fig=true,results=hide,include=false}
#'  .c create rectangle 65 65 85 85  -fill blue
#'  ```
#' ```
#' You can now manually place the figure. The filename of the figure will 
#' be automatically created, it is the basename of the tmd-file  and the label.
#' So in principle: `basename-label.png`. You can embed the figure using Markdown 
#' figure markup such as:
#'
#' ```
#'   ![](basename-label.png)
#' ```
#' 
#' For a detailed tutorial on how to do literate programming with Tcl have a look at the [Tcl Markdown tutorial](tutorial/tmd.html)
#'

if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] == 0 || [regexp {^(-h|--help)} [lindex $argv 0]]} {
        puts "Tcl-markdown processor, 2020 - Version [package provide tmdoc::tmdoc]"
        puts "Author: by Detlef Groth, Caputh-Schwielowsee, Germany"
        puts "        Converts Markdown documents with embedded Tcl code "
        puts "        into pure Markdown documents."
        puts "Usage: $argv0 infile.tmd ?--outfile outfile --mode tangle|weave > outfile?"
        puts "       --outfile outfile write all output to the given outfile,"
        puts "         if outfile is not given, output is send to stdout"
        puts "       --mode weave (default) evaluates the source code within infile.tmd"
        puts "       --mode tangle just extract all Tcl code to the terminal or, "
        puts "         if given, to outfile"
        puts "License: MIT"
    } elseif {[regexp {^(-v|--version)} [lindex $argv 0]]}  {
        puts [package provide tmdoc::tmdoc]
    } elseif {[regexp {^(-m|--man)} [lindex $argv 0]]}  {
        set filename [info script]
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                if {[regexp {^\s*#'\s?(.*)} $line -> man]} {
                    puts $man
                }
            }
            close $infh
        }
    } elseif {[regexp {^(-l|--license)} [lindex $argv 0]]}  {
        set filename [info script]
        set flag false
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            while {[gets $infh line] >= 0} {
                if {$flag && [regexp {^\s*#'\s?(.*)} $line -> man]} {
                    puts $man
                }
                if {[regexp {^.{3,7}a name.+license.+LICENSE AND COPY} $line]} {
                    set flag true
                }
            }
            close $infh
        }
    } else {
        tmdoc::tmdoc [lindex $argv 0] [lrange $argv 1 end]
    }
}

#' ## <a name='install'>INSTALLATION</a>
#'
#' The *tmdoc::tmdoc* package needs a working installation of Tcl8.6 or Tcl8.7. Tcl 8.4 and 8.5 might wortk but are untested and not supported.
#' 
#' The *tmdoc::tmdoc* package can be installed either as command line application or as a Tcl module. 
#' 
#' Installation as command line application can be done by copying the `tmdoc.tcl` as 
#' `tmdoc` to a directory which is in your executable path. You should make this file executable using `chmod`.
#' 
#' Installation as Tcl module is achieved by copying the file `tmdoc.tcl` to a place 
#' which is your Tcl module path as `tmdoc/tmdoc-0.3.tm` for instance. See the [tm manual page](https://www.tcl.tk/man/tcl8.6/TclCmd/tm.htm)
#'
#' Installation as Tcl package is done if you copy the *tmdoc* folder with all it's files to a path that belongs to the list of your Tcl library paths.
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains it's own documentation written in Markdown. 
#' The documentation can be extracted by using the commandline swith *--man*
#'
#' ```
#' tclsh tmdoc.tcl --man
#' ```
#' 
#' The documentation can be converted to HTML, PDF or Unix manual pages with the 
#' aid of a Markdown processor such as pandoc ot the Tcl application [mkdoc](https://chiselapp.com/user/dgroth/repository/tclcode). Here an example for the conversion using mkdoc
#'
#' ```
#' 
#' ```
#' ## <a name='see'>SEE ALSO</a>
#' 
#' - [tmdoc tutorial](tutorial/tmd.html)
#' - [mkdoc](https://chiselapp.com/user/dgroth/repository/tclcode) for embedding Markdown code into Tcl code as source code documentation.
#' - [pandoc](https://pandoc.org/) a universal document converter
#' 
#' ## <a name='changes'>CHANGES</a>
#'
#' - 2020-02-19 Release 0.1
#' - 2020-02-21 Release 0.2
#'     - docu updates
#'     - nonewline puts fix
#'     - *-outfile filename* option 
#'     - *-mode tangle* option
#' - 2020-02-23 Release 0.3
#'     - fix for puts into channels
#' - 2020-11-09 Release 0.4
#'     - github release
#'     - LaTeX support
#'     - fig.width support LaTeX
#'     - documentation fixes
#'     - LaTeX sample document
#'     - fix for inline code special markup using underlines
#'     - other file type extensions for figure using ext option for code chunks
#'
#' ## <a name='todo'>TODO</a>
#'
#' - LaTeX mode if file extension is tnw intead of tmd (done)
#' - fig.width, fig.height options by using args argument in figure (for LaTeX done)
#' - your suggestions ...
#'
#' ## <a name='authors'>AUTHOR(s)</a>
#'
#' The **tmdoc::tmdoc** package was written by Dr. Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#'
#' Tcl Markdown processor tmdoc::tmdoc, version 0.4
#'
#' Copyright (c) 2020  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#'
