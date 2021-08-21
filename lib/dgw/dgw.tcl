
# this script just adjusts the module path to simplify reading of 
# all dgw widgets

#' ---
#' title:  dgw::dgw __PKGVERSION__
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
#' **dgw::dgw**  - Detlef Groth's Tk Widgets

#' 
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require Tk 8.6
#' package require snit
#' package require dgw::dgw
#' dgw::basegui app
#' dgw::combobox pathname
#' dgw::sbuttonbar pathname
#' dgw::seditor pathname
#' dgw::statusbar pathname
#' package require tablelist::tablelist
#' dgw::sfilebrowser pathname
#' dgw::tablelist pathname
#' dgw::tlistbox pathname
#' ```

#' 
#' ## <a name='command'>COMMAND</a>
#'
#' **package::require dgw::dgw**
#' 
#' > The *dgw::dgw* package is just a wrapper package to load all the dgw widgets with one package call.
#' The following packages are loaded via the *package require dgw::dgw* call.
#'
#' > - [dgw::basegui](basegui.html) - framework to build up Tk application, contains as well a few standalone widgets which can be used inside existing Tk applications:
#'       - [autoscroll](basegui.html#autoscroll) - add scrollbars to Tk widgets which appear only when needed.
#'       - [balloon](basegui.html#balloon) - add tooltips to Tk widgets
#'       - [cballoon](basegui.html#cballoon) - add tooltips to canvas tags
#'       - [center](basegui.html#center) - center toplevel widgets
#'       - [console](basegui.html#console) - embedded Tcl console for debugging
#'       - [dlabel](basegui.html#dlabel) - label widget with dynamic fontsize fitting the widget size
#'       - [labentry](basegui.html#labentry) - composite widget of label and entry
#'       - [notebook](basegui.html#notebook) - ttk::notebook with interactive tab management faciltities
#'       - [rotext](basegui.html#rotext) - read only text widget
#'       - [splash](basegui.html#splash) - splash window with image and message faciltites
#'       - [timer](basegui.html#timer) - simple timer to measure execution times
#'       - [treeview](basegui.html#treeview) - ttk::treeview widget with sorting facilities
#'   - [dgw::combobox](combobox.html) - ttk::combobox with added dropdown list and filtering
#'   - [dgw::sbuttonbar](sbuttonbar.html) - buttonbar with round image buttons and text labels
#'   - [dgw::seditor](seditor.html) - extended text editor widget with toolbar and syntax hilighting 
#'   - [dgw::sfinddialog](sfinddialog.html) - find and search dialog for instance for text widgets
#'   - [dgw::statusbar](statusbar.html) - statusbar widget with label for text messages and ttk::progressbar
#'   - [dgw::tvmixins](tvmixins.html) - treeview widget adaptors usable as mixins for the ttk::treeview widget.
#'   - [dgw::txmixins](txmixins.html) - text widget adaptors usable as mixins for the tk::text widget.
#'
#' > The following widgets must be loaded separately using `package dgw::widgetname` as they depend on other non-standard packages such as `tablelist::tablelist`, `tdbc::sqlite3` or `dgtools::shistory`
#' 
#' > - [dgw::hyperhelp](hyperhelp.html) - help system with hypertext facilitites and table of contents outline (requires dgtools package)
#'   - [dgw::sfilebrowser](sfilebrowser.html) - snit file browser widget (requires tablelist package)
#'   - [dgw::sqlview](sqlview.html) - SQLite database browser widget (requires tdbc::sqlite3 package)
#'   - [dgw::tablelist](tablelist.html) - tablelist widget with a few icons and implemention of icon changes if tree nodes are opened (requires tablelist package)
#'   - [dgw::tlistbox](tlistbox.html) - listbox widget based on tablelist with wrap facilities for multiline text and filtering (requires tablelist package)
#'
#if {[catch {package require dgw::seditor}]} {
#    tcl::tm::path add [file join [file dirname [info script]] .. libs]
#}
namespace eval dgw {} 

# mandatory packages
package provide dgw 0.6
package provide dgw::dgw 0.6
package require dgw::dgwutils
package require dgw::basegui
package require dgw::combobox
package require dgw::drawcanvas
package require dgw::sbuttonbar
package require dgw::sfinddialog
package require dgw::seditor
package require dgw::statusbar
package require dgw::tvmixins
package require dgw::txmixins

# packages which require addon packages
#catch {
#    package require dgw::sqlview
#}
#package require dgw::hyperhelp

#package require dgw::sfilebrowser
#catch {
    #package require dgw::tablelist
#}
#package require dgw::tlistbox



#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can easily install and use this ** __PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. 
#' To extract the documentation you should use the following command line:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --markdown
#' ```
#'
#' This will extract the embedded manual pages in standard Markdown format. 
#' You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.
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
#' html or pdf document. If you have pandoc installed for instance, you could execute the following commands:
#'
#' ```
#' tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - dgw - package homepage: [https://github.com/mittelmark/DGTcl](https://github.com/mittelmark/DGTcl)
#' - download via Downgit: https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/dgw
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** command was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
# LICENSE START
#' #include "license.md" 
# LICENSE END



if {[info exists argv0] && $argv0 eq [info script]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
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
        puts "\nThe ${dpath}::$pfile package provides Tk widget and a basic application" 
        puts "                       framework for building Tk applications using ."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
    }
}

