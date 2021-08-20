##############################################################################
#  Author        : Dr. Detlef Groth
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Oct 28 08:57:22 2019
#  Last Modified : <200322.0713>
#
#  Description	 : Helper functions for dgtools-types source files for extracting
#                  manual pages and installation of Tcl files as Tcl modules.
#                  Copy and adaptation of dgw/dgwutils.tcl
#
#  History       : 2019-11-08 version 0.1
#	
##############################################################################
#
# dgwutil.tcl - generic utility functions for dgw widget library.
#
# Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
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


namespace eval dgtools {
    variable htmltemplate {
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: ; script-src 'self' 'nonce-d717cfb5d902616b7024920ae20346a8494f7832145c90e0' ; style-src 'self' 'unsafe-inline'" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="title" content="$document(title)">
<meta name="author" content="$document(author)">
<title>$document(title)</title>
<style>
body {
    margin-left: 5%; margin-right: 5%;
    font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
}
pre {
padding-top:	1ex;
padding-bottom:	1ex;
padding-left:	1.5ex;
padding-right:	1ex;
width:		100%;
color: 		black;
background: 	#ffefdf;
border-bottom:	1px solid black;
border-top:	1px solid black;
font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
}
pre.synopsis {
    background: #cceeff;
}
code {
    font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
}
h1 {
font-family:	sans-serif;
font-size:	120%;
background: 	transparent;
text-align:	center;
}
h3 {
font-family:	sans-serif;
font-size:	110%;
background: 	transparent;
text-align:	center;
}
h2 {
margin-top: 	1em;
font-family:	sans-serif;
font-size:	110%;
color:		#005A9C;
background: 	transparent;
text-align:		left;
}
</style>
</head>
<body>
<div class="title"><h1>$document(title)</h1></div>
<div class="author"><h3>$document(author)</h3></div>
<div class="date"><h3>$document(date)</h3></div>
}
} 
#' ---
#' documentclass: scrartcl
#' title: dgtools::dgtutils __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: 
#'    pdf_document
#' ---
#
#' ## NAME
#'
#' **dgtools::dgtutils** - internal helper procedures for the dgtools package
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMANDS](#commands)
#'  - [DOCUMENTATION](#docu)
#'  - [AUTHOR](#author)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgtools::dgtutils
#' dgtools::getVersion filename
#' dgtools::install filename
#' dgtools::manual mode filename
#' dgtools::runExample filename boolean
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **dgtools::dgtutils** package provide a few helper commands for other packages
#' in the *dgtools* package to format the documentation, to extract the help pages and to show and run example code
#' embedded within the package documentation.
#'
#' <a name="commands">COMMANDS</a>
#'
package provide  dgtools::dgtutils 0.1

# should be not used any more, instead use runExample filename false to get 
# the example code
#
# **dgtools::displayCode** *filename*
# 
# > Extracts and displays the code of the example section in the Markdown formatted 
# documentation. Documentation must be prefixed with a `#'` comment indicator
# and must be followed directly the example section header after two '##' signs.
# 

proc dgtools::displayCode {fname} {
    set filename $fname
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set flag false
        while {[gets $infh line] >= 0} {
            # Process line
            if {[regexp {^\s+# DEMO START} $line]} {
                set flag true
            } elseif {[regexp {^\s+# DEMO END} $line]} {
                break
            } elseif {$flag} {
                puts [string range $line 6 end]
            }
            
        }
        close $infh
    }
}


#' **dgtools::getVersion** *filename*
#' 
#' > Returns the package version of a given file. Please note, that the package must have the same name as the file basename.
#' 

proc dgtools::getVersion {fname} {
    set basename [file rootname [file tail $fname]]
    return [package present dgtools::$basename]
}

#' **dgtools::install** *filename*
#' 
#' > Installs the fiven file as Tcl module within the Tcl module path.
#'   Please note, that the package must have the same name as the file basename.
#' 

proc dgtools::install {filename} {
    set dpath dgtools
    set pfile [file rootname [file tail $filename]]
    set done false
    foreach dir [tcl::tm::path list] {
        if {[file writable $dir]} {
            puts "\nWriteable Tcl module path is: $dir"
            set ddir [file join $dir $dpath]
            if {![file exists $ddir]} {
                file mkdir $ddir
            }
            set fname [file join $dir $dpath $pfile-[package provide ${dpath}::$pfile].tm]
            file copy -force [info script] $fname
            puts "Done: ${dpath}::$pfile Tcl module installed to ${fname}!\n"
            puts "To test your installation try:\n"
            puts "\$ tclsh"
            puts "% package require ${dpath}::$pfile\n"
            
            set done true
            break
        }
    }  
    if {!$done} {
        puts "Error: No writable Tcl module path found!"
        puts "Create an environment variable TCL8_6_TM_PATH pointing to a directory where you can write files in."
        puts "In Linux for a bash shell you can do this for instance with: export TCL8_6_TM_PATH=/home/user/.local/lib/tcl8.6"
        puts "To make this permanent add this line to your .bashrc file!"
    }
}

#' **dgtools::manual** *mode filename*
#' 
#' > Extracts and formats the embedded documentation. Option *mode* can bei either *-html*, *-man* or *-markdown*.
#'  -*man* is pandoc markdown, an extended version for the pandoc document converter.
#'  Documentation in Markdown must be prefix with a `#'` comment sign.
#' 

proc dgtools::manual {mode filename} {
    variable htmltemplate
    set basename [file tail [file rootname $filename]]
    set version [package provide dgtools::$basename]
    set markdown ""
    if {$mode eq "--html"} {
        if {[package require Markdown] eq ""} {
            error "Error: For html mode you need package Markdown from tcllib. \nDownload and install tcllib from http://core.tcl.tk"
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
            if {$mode eq "--license"} {
                if {[regexp {^# LICENSE START} $line]} {
                    set flag true
                    puts ""
                    continue
                } elseif {$flag && [regexp {^# LICENSE END} $line]} {
                    puts ""
                    break
                } elseif {$flag && [regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
                    if [catch {open $include r} iinfh] {
                        puts stderr "Cannot open $filename: $include"
                        exit 0
                    } else {
                        while {[gets $iinfh iline] >= 0} {
                            # Process line
                            set md $iline
                            set md [regsub -all {<.+?>} $md ""]
                            set md [regsub -all {^\s*## (.+)} $md "\\1\n[string repeat - 15]"]
                            set md [regsub -all {__PKGNAME__} $md dgw::$basename]
                            set md [regsub -all {__BASENAME__} $md $basename]                        
                            set md [regsub -all {__PKGVERSION__} $md $version]
                            set md [regsub -all {__DATE__} $md [clock format [clock seconds] -format "%Y-%m-%d"]] 
                            puts "$md"
                        }
                        close $iinfh
                    }
                } elseif {$flag} {
                    set line [regsub -all {__PKGNAME__} $line dgtools::$basename]
                    set line [regsub -all {__BASENAME__} $line $basename]                        
                    set line [regsub -all {__PKGVERSION__} $line $version]
                    set line [regsub -all {__DATE__} $line [clock format [clock seconds] -format "%Y-%m-%d"]]
                    puts [string range $line 2 end]
                }
            } else {
                if {[regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
                    puts stderr "including $include"
                    if [catch {open $include r} iinfh] {
                        puts stderr "Cannot open $filename: $include"
                        exit 0
                    } else {
                        while {[gets $iinfh iline] >= 0} {
                            # Process line
                            set md "$iline"
                            set md [regsub -all {__PKGNAME__} $md dgw::$basename]
                            set md [regsub -all {__BASENAME__} $md $basename]                        
                            set md [regsub -all {__PKGVERSION__} $md $version]
                            set md [regsub -all {__DATE__} $md [clock format [clock seconds] -format "%Y-%m-%d"]] 
                            if {$mode eq "--man"} {
                                puts "$md" 
                            } else {
                                append markdown "$md\n"
                            }
                        }
                        close $iinfh
                    }
                } elseif {[regexp {^\s*#' ?(.*)} $line -> md]} {
                    set md [regsub -all {__PKGNAME__} $md dgtools::$basename]
                    set md [regsub -all {__BASENAME__} $md $basename]                        
                    set md [regsub -all {__PKGVERSION__} $md $version]
                    set line [regsub -all {__DATE__} $line [clock format [clock seconds] -format "%Y-%m-%d"]]                    
                    if {$mode eq "--man"} {
                        puts "$md" 
                    } else {
                        append markdown "$md\n"
                    }
                }
            }
            
        }
        close $infh
        if {$mode eq "--html" || $mode eq "--markdown"} {
            set titleflag false
            array set document [list title "Documentation" author "NN" date  [clock format [clock seconds] -format "%Y-%m-%d"]]
            set mdhtml ""
            set indent ""
            set header $htmltemplate
            foreach line [split $markdown "\n"] {
                if {$titleflag && [regexp {^---} $line]} {
                    set titleflag false
                    set header [subst -nobackslashes -nocommands $header]
                } elseif {$titleflag} {
                    if {[regexp {^([a-z]+): +(.+)} $line -> key value]} {
                        set document($key) $value
                    }
                } elseif {[regexp {^---} $line]} {
                    set titleflag true
                } elseif {[regexp {^```} $line] && $indent eq ""} {
                    append mdhtml "\n"
                    set indent "    "
                } elseif {[regexp {^```} $line] && $indent eq "    "} {
                    set indent ""
                    append mdhtml "\n"
                } else {
                    append mdhtml "$indent$line\n"
                }
            }
            if {$mode eq "--html"} {
                set htm [Markdown::convert $mdhtml]
                set html ""
                # synopsis fix as in tcllib with blue background
                set synopsis false
                foreach line [split $htm "\n"] {
                    if {[regexp {^<h2>} $line]} {
                        set synopsis false
                    } 
                    if {[regexp {^<h2>.*Synopsis} $line]} {
                        set synopsis true
                    }
                    if {$synopsis && [regexp {<pre>} $line]} {
                        set line [regsub {<pre>} $line "<pre class='synopsis'>"]
                    }
                    append html "$line\n"
                }
                set out [open [file rootname $filename].html w 0644]
                puts $out $header
                puts $out $html
                puts $out "</body>\n</html>"
                close $out
                puts stderr "Success: file [file rootname $filename].html was written!"
            } else {
                puts $mdhtml
            }
                
        }
    }
}

#' **dgtools::runExample** *filename ?eval:boolean?* 
#' 
#' > Extracts and executes the code of the example section in the Markdown formatted 
#' documentation. Documentation must be prefixed with a `#'` comment indicator
#' and must be followed directly the example section header after two '##' signs. If the option eval is set to false the code is only returned.
#' 

proc dgtools::runExample {fname {eval true}} {
    set filename $fname
    set example false
    set excode false
    set code ""
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        while {[gets $infh line] >= 0} {
            # Process line
            if {[regexp -nocase {^\s*#'\s+#{2,3}\s.+Example} $line]} {
                set example true
            } elseif {$example && [regexp {^\s*#'\s+```} $line]} {
                set example false
                set excode true
            } elseif {$excode && [regexp {^\s*#'\s+```} $line]} {
                if {$eval} {
                    namespace eval :: $code
                } else {
                    return $code
                }
                break
                # eval code
            } elseif {$excode && [regexp {^\s*#'\s(.+)} $line -> c]} {
                append code "$c\n"
            }
        }
        close $infh
    }
    return $code
}

#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. 
#' To extract the documentation you should use the following command line:
#'
#' ```
#' $ tclsh recover.tcl --man
#' ```
#'
#' The output of this command can be used to create a markdown document for conversion into a markdown 
#' document that can be converted thereafter into a html or pdf document. If, for instance, you have pandoc installed you could execute the following commands:
#'
#' ```
#' tclsh recover.tcl --man > recover.md
#' pandoc -i recover.md -s -o recover.html
#' pandoc -i recover.md -s -o recover.tex
#' pdflatex recover.tex
#' ```
#' 
#' Alternatively if the Markdown package of tcllib is available you can convert the documentation as well directly to html using the *--html* flag:
#'
#' ```
#' $ tclsh recover.tcl --html
#' ```
#' 
#' ## <a name='author'>AUTHOR</a>
#'
#' The **dgtools::recover** command was written Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' __PKGNAME__ package __PKGVERSION__  - private procedures to be used within the dgtools packages.
#'
#' Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#' 
# LICENSE END

if {[info exists argv0] && $argv0 eq [info script] && [regexp {dgtutils} $argv0]} {
    if {[llength $argv] > 0 && [lindex $argv 0] eq "--version"} {
        puts "[package present dgtools::dgtutils]"
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
    } else {
        puts "\n    -------------------------------------"
        puts "     The dgtools::[file rootname [file tail [info script]]] package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe dgtools::[file rootname [file tail [info script]]] package" 
        puts " Private helper procedures for other packages of the dgtools package."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts "        --version : printing the package version to the terminal"        
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
        
    }
}

    # do main task


