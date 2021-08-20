#  Created By    : Dr. Detlef Groth
#  Created       : Sun Oct 27 15:16:15 2019
#  Last Modified : <210820.0830>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2019 Dr. Detlef Groth.
# 
##############################################################################
#' ---
#' documentclass: scrartcl
#' title: dgw::combobox __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2020-01-04
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::combobox** - snit widget derived from a ttk::combobox with added dropdown list and filtering
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgw::combobox
#' namespace import ::dgw::combobox
#' combobox pathName options
#' pathName configure -values list
#' pathName configure -hidenohits boolean
#' pathName configure -textvariable varname
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **dgw::combobox** - is a snit widget derived from a ttk::combobox but with the added possibility to display
#' the list of values available in the combobox as dropdown list. This dropdown list can further be filtered using the given 
#' options. If the user supplies the option -hidenohits false. He just gets the standard ttk::combobox
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::combobox** *pathName ?options?*
#' 
#' > Creates and configures the **dgw::combobox**  widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' As the **dgw::combobox** widget is derived from the standard ttk::combobox it interhits all options and methods from ttk::combobox. 
#' It only adds an additional option __-hidenohits__ - see below for an explanation. You should not use the option __-postcomand__ as this option is used to display the dropbdown list and apply the value filtering. If you overwrite the latter option you get again just a
#' normal ttk::combobox.

package require Tk 8.5
package require tile
package require snit
package require dgw::dgwutils
package provide dgw::combobox 0.2
namespace eval ::dgw { }

snit::widget ::dgw::combobox {
    option -values [list]
    # without -hidenohits true
    # we have a normal
    # ttk combobox
    #' 
    #'   __-hidenohits__ _boolean_ 
    #' 
    #'  > If _hidenohits_ is set to true, non-matching list entries are not displayed in the dropdown listbox.
    #'    Defaults to true.
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' As the dgw::combobox widget is dertived from the ttk::combobox, it has all methods available as a ttk::combobox, see the ttk::combobox 
    #' manual from the description of the widget commands.
    #' 
    option -hidenohits false
    variable Values
    delegate option * to combo except [list -values -postcommand]
    delegate method * to combo
    component combo
    constructor {args} {
        $self configurelist $args
        install combo using ttk::combobox $win.combo -values $options(-values) \
              -postcommand [mymethod UpdateValues]
        bind $combo <KeyRelease> [mymethod Post %K]        
        bind $combo <Control-space> [mymethod Post %K]
        pack $combo -side top -fill x -expand false
        set Values $options(-values)
    }
    onconfigure -values {vals} {
        set Values $vals
        set options(-values) $vals
        if {[winfo exists $combo]} {
            $combo configure -values $Values
        }
    }
    method UpdateValues {} {
        set text [string map [list {[} {\[} {]} {\]}] [$combo get]]
        $combo configure -values [lsearch -all -inline $Values $text*]
    }
    method Post {key} {
        #puts $key
        if {$options(-hidenohits)} {
            $self UpdateValues
            # save acces to internal function
            if {[string equal [info commands ::ttk::combobox::Post] ::ttk::combobox::Post]} {
                if {$key eq "Return"} { return }
                ::ttk::combobox::Post $combo
                if {$key ne "Down" && [llength [$combo cget -values]] > 1} {
                    after 100 [list focus $combo]
                } elseif {$key eq "Down"} {
                    set lb $combo.popdown.f.l
                    if {[winfo exists $lb]} {
                        after 100 [list focus $lb]
                    }
                }
            }
        }
    }
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#'    wm title . "DGApp"
#'    pack [label .l0 -text "standard combobox"]
#'    ttk::combobox .c0 -values [list  done1 done2 dtwo dthree four five six seven]
#'    pack .c0 -side top
#'    pack [label .l1 -text "combobox with filtering"]
#'    dgw::combobox .c1 -values [list done1 done2 dtwo dthree four five six seven] \
#'         -hidenohits true
#'    pack .c1 -side top     
#'    pack [label .l2 -text "combobox without filtering"]
#'    dgw::combobox .c2 -values [list done1 done2 dtwo dthree four five six seven] \
#'         -hidenohits false
#'    pack .c2 -side top 
#' ```
#' 
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **dgw::combbox** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation of dgw::combobox just put the folder _dgw_ in a folder belonging to your Tcl-library path 
#' or put combobox.tcl as combobox-__PKGVERSION__.tm to a folder dgw which belongs to your Tcl-Module path. 
#' The latter can be as well achieved using the _-install_ option such as `tclsh __BASENAME__.tcl --install` which will try to install dgw::combobox into your Tcl-module path.

#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --code
#' ```
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --markdown
#' ```
#'
#' This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --html
#' ```
#' 
#' This will directly create a HTML page `__BASENAME__.html` which contains the formatted documentation. 
#' Github-Markdown can be extracted by using the *--man* switch:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --man
#' ```
#'
#' The output of this command can be used to feed a markdown processor for conversion into a 
#' man page, a html or a pdf document. If you have pandoc installed for instance, 
#' you could execute the following commands:
#'
#' ```
#' # man page
#' tclsh __BASENAME__.tcl --man | pandoc -s -f markdown -t man - > __BASENAME__.n
#' # html page
#' tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' # pdf
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#'
#' ## <a name='todo'>TODO</a>
#'
#' * probably as usually more documentation
#' * more, real, tests
#' * github url for putting the code

#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' Text search dialog widget __PKGNAME__, version __PKGVERSION__.
#'
#' Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
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


if {[info exists argv] && $argv0 eq [info script] && [regexp combobox $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {
        # DEMO START
        wm title . "dgw::combobox demo"
        pack [label .l0 -text "standard combobox"]
        ttk::combobox .c0 -values [list  done1 done2 dtwo dthree four five six seven]
        pack .c0 -side top
        pack [label .l1 -text "combobox with filtering"]
        dgw::combobox .c1 -values [list done1 done2 dtwo dthree four five six seven] \
              -hidenohits true
        pack .c1 -side top     
        pack [label .l2 -text "combobox without filtering"]
        dgw::combobox .c2 -values [list done1 done2 dtwo dthree four five six seven] \
              -hidenohits false
        pack .c2 -side top 
        # DEMO END
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        set filename [info script]
        dgw::displayCode $filename
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a combobox with a filtered dropdown listbox."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install shistory as Tcl module"        
        puts "        --man     : printing the man page in markdown to the terminal"
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
