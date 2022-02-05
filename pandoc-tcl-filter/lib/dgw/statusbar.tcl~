#!/usr/bin/env tclsh
#  Created By    : Dr. Detlef Groth
#  Created       : Wed Jan 18 04:46:02 2017
#  Last Modified : <200227.1426>
#
#  Description	
#
#  Notes
#
#  History
#	
#' ---
#' documentclass: scrartcl
#' title: dgw::statusbar __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::statusbar** - statusbar widget for Tk applications based on a ttk::label and a ttk::progressbar widget
#'
#' ## <a name='toc'></a>Table of Contents
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
#' package require dgw::statusbar
#' dgw::statusbar pathName options
#' pathName configure -textvariable varname
#' pathName configure -variable varname
#' pathName clear 
#' pathname progress value
#' pathName set message ?value?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **dgw::statusbar** - is a composite widget consisiting of a ttk::label and a ttk::progressbar widget. 
#' It should be normally packaged at the bottom of an appöication.
#' The text and the numerical progress value can be displayed either directly 
#' using the widget commands or via the *-textvariable* and *-variable* options which  will be given at initialization time, 
#' but these options can be also redifined at a later point.

#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::statusbar** *pathName ?options?*
#' 
#' > Creates and configures a new dgw::statusbar widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' The **dgw::statusbar** widget is a composite widget where the options 
#' are delegated to the original widgets.

package require Tk
package require snit
package require dgw::dgwutils

namespace eval dgw {}

package provide dgw::statusbar 0.2
snit::widget dgw::statusbar {
    component Lab -public label
    component pBar -public progressbar
    #' 
    #'   __-maximum__ _value_ 
    #' 
    #'  > A floating point number specifying the maximum -value. Defaults to 100. 
    delegate option -maximim to Pbar
    #' 
    #'   __-textvariable__ _varname_ 
    #' 
    #'  > Delegates the variable _varname_ to the ttk::label as such.
    delegate option -textvariable to Lab
    #' 
    #'   __-variable__ _varname_ 
    #' 
    #'  > Delegates the variable _varname_ to the ttk::progressbar. Note that the maximum value is 100. 
    #'    So you have to calculate the
    delegate option -variable to Pbar
    
    constructor {args} {
        install Lab using ::ttk::label $win.lab -relief sunken -anchor w -width 50 -padding 4
        install Pbar using ::ttk::progressbar $win.pb -length 60 -mode determinate
        $Pbar configure -value 30
        $self configurelist $args
        pack $Lab -side left -fill x -expand false -padx 4 -pady 2
        pack $Pbar -side right -fill none -expand false -padx 4 -pady 2
    }
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **dgw::combobox** widgets supports its own as well via the *pathName label cmd* and *pathName progressbar cmd* syntax all the commands of its component widgets.
    #' 
    #' *pathName* **clear** *message ?value?*
    #' 
    #' > Removes the message from the label and sets to progressbar to zero.
    method clear {} {
        $self set "" 0
        update idletasks
    }
    #' 
    #' *pathName* **label** *cmd ?option value ...?*
    #' 
    #' > Allows access to the commands of the embedded ttk::label widget. 
    #'   Via configure and cget you can as well configure this internal widget. 
    #'   For details on the available methods and options have a look at the 
    #'   ttk::label manual page.
    #' 
    #' *pathName* **progress** *value*
    #' 
    #' > Sets the progressbar to the given value.
    method progress {value} {
        $Pbar configure -value $value
        update idletasks
    }
    #' 
    #' *pathName* **progressbar** *cmd ?option value ...?*
    #' 
    #' > Allows access to the commands of the embedded ttk::progessbar widget. 
    #'   Via configure and cget you can as well configure this internal widget. 
    #'   For details on the available methods and options have a look at the 
    #'   ttk::progressbar manual page.
    
    #' 
    #' *pathName* **set** *message ?value?*
    #' 
    #' > Displays the given message and value. If the value is not given it is set to zero.
     method set {msg {value 0}} {
        $Lab configure -text $msg
        if {$value > 0} {
            $self progress $value
        }
        update idletasks
    }
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#' ```
#' package require dgw::progressbar
#' namespace import ::dgw::tlistbox
#' wm title . DGApp
#' pack [text .txt] -side top -fill both -expand yes
#' set stb [dgw::statusbar .stb]
#' pack $stb -side top -expand false -fill x
#' $stb progress 50
#' $stb set Connecting....
#' after 1000
#' $stb set "Connected, logging in..."
#' $stb progress 50
#' after 1000
#' $stb set "Login accepted..." 
#' $stb progress 75
#' after 1000
#' $stb set "Login done!" 90
#' after 1000
#' $stb set "Cleaning!" 95
#' after 1000
#' $stb set "" 100
#' set msg Sompleted
#' set val 90
#' $stb configure -textvariable msg
#' $stb configure -variable val
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can easily install and use this ** __PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file `dgw/__BASENAME__-__PKGVERSION__.tm` in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose.
#'
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```
#'
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
#' man page, a html or a pdf document. If you have pandoc installed for instance, you could execute the following commands:
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
#' Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
# LICENSE START
#' #include "license.md"
# LICENSE END
if {[info exists argv0] && [info script] eq $argv0 && [regexp statusbar $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        # DEMO START
        wm title . "StatusBar Demo"
        pack [text .txt] -side top -fill both -expand yes
        set stb [dgw::statusbar .stb]
        pack $stb -side top -expand false -fill x
        $stb progress 50
        $stb set Connecting....
        after 1000
        $stb set "Connected, logging in..."
        $stb progress 50
        after 1000
        $stb set "Login accepted..." 
        $stb progress 75
        after 1000
        $stb set "Login done!" 90
        after 1000
        $stb set "Cleaning!" 95
        after 1000
        set msg "Login completed!"
        set val 100
        $stb configure -textvariable msg
        $stb configure -variable val
        # DEMO END
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        dgw::displayCode [info script]
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
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a statusbar widget with"
        puts "a label for messages and a progressbar to show numerical progress."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install ${dpath}::$pfile as Tcl module"        
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
