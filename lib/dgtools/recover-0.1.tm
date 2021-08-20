##############################################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Fri Mar 22 16:51:29 2019
#  Last Modified : <200302.0637>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2020 Dr. Detlef Groth.
# 
##############################################################################

#' ---
#' documentclass: scrartcl
#' title: dgtools::recover __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: 
#'    pdf_document
#' ---
#
#' ## NAME
#'
#' **dgtools::recover** - debugging command
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DOCUMENTATION](#docu)
#'  - [TODO](#todo)
#'  - [AUTHOR](#author)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgtools::recover
#' dgtools::recover
#' dgtools::recover_onerror
#' dgtools::recover_stop
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **dgtools::recover** command allows to debug interactively errors pr problems in 
#' Tcl terminal programs in the same spirit as the R recover command.
#'
#' <a name="commands">COMMANDS</a>
#' 
package provide dgtools::recover 0.1

namespace eval dgtools {
    namespace export recover recover_onerror recover_stop
}

#' **dgtools::recover**
#' 
#' > Manually jumps in debugging mode. This command can be placed into critical code fragments and then you can jump directly during debugging in this procedure. See the following example:
#' 
#' > ```
#' proc test {x} {
#'    set y $x
#'    incr y
#'    dgtools::recover
#'    incr x
#'    return $y
#' }
#' test 5
#' > ```
#'

proc dgtools::recover {{err ""}} {
    if {$err ne ""} {
        puts "$err"
    } else {
        puts ""
    }
    uplevel 1 {
        set code ""
        puts -nonewline "\ndebug % "
        while {true} {
            gets stdin code
            if {[regexp {^Q\s*} $code]} {
                break
            }
            catch { eval $code } err
            if {$err ne "" } {
                puts "Error: $err"
            }
            puts -nonewline "\ndebug % "
        }
    }
}
#' **dgtools::recover_onerror** 
#' 
#' > This replaces the error command, instead of reporting the error there will be an interactive terminal 
#'   where you can debug all variables in the current procedure or method.
#' 

proc dgtools::recover_onerror {} {
    # use rename during debugging to recover in all cases an error occured
    uplevel 1 {
        rename error error.orig
        interp alias {} error {} ::dgtools::recover 
    }
}

#' **dgtools::recover_stop** 
#' 
#' > This resets the error handling by the recover command to the normal error command.
#'
proc dgtools::recover_stop {} {
    # stop recover on error handling
    uplevel 1 {
        rename error.orig error
        interp alias {} error {} error
    }
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#' 
#' The following example shows how you can jump into your own error calls in your code.
#' As you normally report critical parts of your code with such error calls it allows you to jump directly into those places and debug them.
#' Unfortunately, I don't know how to jump automatically into the error call of Tcl.
#'
#' ```
#' package require dgtools::recover
#' ::dgtools::recover_onerror
#' proc test {x} {
#'   set y $x
#'   # the next line with the error 
#'   # will jump into the recover moce
#'   error "z does not exists"
#'   return $z
#' }
#' test 6
#' ```
#' 
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
#' dgtools:recover package - debugging tool in spirit of R's recover function.
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

if {[info exists argv0] && $argv0 eq [info script] && [regexp recover $argv0]} {
    set dpath dgtools
    set pfile [file rootname [file tail [info script]]]
    package require dgtools::dgtutils

    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {
        puts "[package provide dgtools::recover]"
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
    } else {
        puts "\n    -------------------------------------"
        puts "     The dgtools::[file rootname [file tail [info script]]] package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe dgtools::[file rootname [file tail [info script]]] packages" 
        puts "debugging tool in spirit of R's recover function"
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



return

# use instead of error during development
# jump in procedure codse if nasty things happen
proc recover::sample1 {x} {
    variable v
    array set a [list a 1 b c c 4]
    incr v 1
    if {$x > 5} {
        recover "something went wrong inside sample1"
    }
}

# jump into problematic code
# by adding recover without checks
proc recover::sample2 {x} {
    variable v
    incr v 1
    array set a [list a 1 b c c 4]
    # more complex things
    # something is dubious, place temporarily recover here
    recover
}

proc recover::sample3 {x} {
    variable v
    incr v
    set x 3
    error "Let's recover inside sample 3"
    incr v
}

recover::sample3 4

3

dgroth@ukulele(4:1059):dgtools$ rlwrap tclsh recover.tcl
Let's recover inside sample 3

debug % puts [info vars]
x v code

debug % puts $x
3

debug % puts $v
1

debug % recover::sample1
Error: wrong # args: should be "recover::sample1 x"

debug % recover::sample1 3
Error: wrong # args: should be "incr varName ?increment?"

debug % source recover.tcl
Let's recover inside sample 3

debug % Q
Error: 3

debug % puts [namespace::current]
Error: invalid command name "namespace::current"

debug % puts [namespace current]
::recover

debug % recover::sample1 4

debug % recover::sample1 6
something went wrong inside sample1

debug % puts [namespace current]
::recover::recover

debug % puts [info vars]
x v a err code

debug % puts [array names a]
a b c


''italic text''
'''bold text'''
`monospaced`

**your heading1**

***your heading2***


****your heading3****

---- ruler

   * your bullet item
   1. your numbered item
   
   
!!!!!!
your centered text
!!!!!!

[your wiki page name]
http://here.com/what.html%|%link name%|%

======
your script
======


%|header|row|%
&|data|row|&
&|data|row|&
&|data|row|&

 ****
 ******
bold ''''''
 ''''
 ``
----
 
   *    1.  []  texttext
   ========
   
   ======
%|header|row|%

rename error error.orig
interp alias {} error {} dgtools::recover 

proc sample3 {x} {
    variable v
    incr v
    set x 3
    error "Let's recover inside sample 3"
    incr v
}

proc sample3 {x} {
    variable v
    incr v
    set x 3
    set y $z
    incr v
}

sample3 4

