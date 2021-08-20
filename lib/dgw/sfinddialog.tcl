# sfinddialogs.tcl --
#
#       Snit toplevel dialog for search widgets for text
#
# Copyright (c) 2003    Dr. Detlef Groth <dgroth@gmx.de>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# Last Modified : <200227.1427>

# HISTORY
#    20/11/2003 Version 0.1 initial release
#    25/11/2003 Version 0.1.1 changed puts to wm title .
#    27/11/2003 Version 0.2 update to snit 0.91 removing the component subcommand instead 
#                           using expose
#    25/19/2019 Version 0.3 
#                           - redefining as dgw namespace
#                           - removed snit version number
#    04/01/2010 Version 0.4 - docu updates, --version option
 
#' ---
#' documentclass: scrartcl
#' title: dgw::sfinddialog __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::sfinddialog** - snit toplevel dialog for text search in other widgets. A implementation to search a text widget inbuild.
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
#' package require dgw::sfinddialog
#' namespace import ::dgw::sfinddialog
#' sfinddialog pathName options
#' pathName configure -findcmd script
#' pathName configure -findnextcmd script
#' pathName configure -textvariable varname
#' pathName configure -nocase boolean
#' pathName configure -word boolean
#' pathName configure -regexp boolean
#' pathName configure -title string
#' pathName cancel cmd options
#' pathName entry cmd options
#' pathName find cmd options
#' pathName next cmd options
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **sfinddialog** - is a toplevel search dialog to perform a text search in other widgets.
#' As such functionalitye is mostly required for the Tk text widget, a implementation to search a Tk text widget is embedded within the **sfinddialog** widget. 
#' The buttons and the text entry are exposed to the programmer, so the programmer has for instance the possibility to manually insert a value in the search entry or to click a button programmatically.


#'
#' ## <a name='command'>COMMAND</a>
#'
#' **sfinddialog** *pathName ?options?*
#' 
#' > Creates and configures the sfinddialog toplevel widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 

package require Tk
package require snit
package require dgw::dgwutils
package provide dgw::sfinddialog 0.4

namespace eval dgw {}

snit::widget dgw::sfinddialog {
    hulltype toplevel
    expose entry
    expose find
    expose next
    expose cancel
    #' 
    #'   __-findcmd__ _script_ 
    #' 
    #'  > Set a command if the user clicks on the find button. Please note, that if you would like to add search functionality to a Tk text
    #'    widget, just use the _-textwidget_ option described below.
    delegate option -findnextcmd to next as -command
    
    #' 
    #'   __-findnext__ _script_ 
    #' 
    #'  > Set a command if the clicks on the next button. Please note, that if you would like to add search functionality to a Tk text
    #'    widget, just use the _-textwidget_ option described below.
    #' 
    #' ```
    #'     global textvar
    #'     testing mFind
    #'     proc Next {} {
    #'        global textvar
    #'        wm title .s "Next $textvar words: [.s cget -word]"
    #'        puts "Next $textvar words: [.s cget -word]"
    #'     }
    #'     proc Find {} {
    #'        global textvar
    #'        wm title .s "Find $textvar words: [.s cget -word]"
    #'        puts "Find $textvar words: [.s cget -word]"
    #'     }
    #'     set textvar test
    #'     dgw::sfinddialog .s -nocase 1 -findnextcmd Next -findcmd Find -textvariable textvar
    #'     wm title .s "Search "
    #' ```
    #' 
    delegate option -findcmd to find as -command
    
    #' 
    #'  __-forward__ _boolean_ 
    #' 
    #' > Checkbox configuration to indicate the search direction. This value can be modified by the user later by clicking the checkbutton belonging to this option.
    option -forward yes
    
    #' 
    #'  __-nocase__ _boolean_ 
    #' 
    #' > Sets the default value for the checkbox related to case insensitive search. This value can be modified by the user later by clicking the checkbutton belonging to this option.
    option -nocase 0
    
    #' 
    #'  __-regexp__ _boolean_ 
    #' 
    #' > Checkbox configuration to indicate if the search string should be used as regular expression. This value can be modified by the user later by clicking the checkbutton.
    option -regexp 0
    
    #' 
    #'   __-textvariable__ _varname_ 
    #' 
    #'  > Configures the entry text to be synced with the variable  _varname_.
    delegate option -textvariable to entry
    
    #' 
    #'   __-textwidget__ _pathname_ 
    #' 
    #'  > The existing textwidget will get functionality to be searched by the sfinddialog. Here is an example on how to use it for a text widget:
    #' 
    #' ```
    #'      pack [text .text]
    #'      dgw::sfinddialog .st -nocase 0 -textwidget .text -title "Search"
    #'      .text insert end "Hello\n"
    #'      .text insert end "Hello World!\n"
    #'      .text insert end "Hello Search Dialog!\n"
    #'      .text insert end "End\n"
    #'      .text insert end "How are your?\n"
    #'      .text insert end "I am not prepared :(\n"
    #'    
    #'      bind .text <Control-f> {wm deiconify .st}
    #' ```
    option -textwidget ""
    
    #' 
    #'   __-title__ _string_ 
    #' 
    #'  > Sets the title of the sfinddialog toplevel.
    option -title "Search"
    
    #' 
    #'   __-word__ _boolean_ 
    #' 
    #'  > Checkbox configuration to indicate that the search should be performed on complete words. 
    #'    This value can be modified by the user later by clicking the checkbutton belonging to this option. 
    #'    Please note that this works currently only together with regular expressions, even if the option is not set in the dialog.
    option -word 0
    variable searchtext
    variable lastfound insert
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **sfinddialog** toplevel supports the following widget commands. 
    #' 
    #' *pathName* **cancel** *cmd ?option ...?*
    #' 
    #' > This function provides access for the programmer to the cancel button. For instance 
    #' to close the dialog it is possible to use: _pathName cancel invoke_. See the button manual page for other commands.
    #'
    
    #' *pathName* **cget** *option*
    #' 
    #' > Returns the given sfinddialog configuration value for the option.
    #'
    #' *pathName* **configure** *option value ?option value?*
    #' 
    #' > Configures the sfinddialog toplevel with the given options.
    #'
    
    #' *pathName* **entry** *cmd ?option ...?*
    #' 
    #' > This function provides access for the programmer to the embedded entry widget. For instance 
    #' to get the current text you could use:  _pathName entry get_. See the entry manual page for other commands available for the entry widget.
    #'
    
    #' *pathName* **find** *cmd ?option ...?*
    #' 
    #' > This function provides access for the programmer to the find button. For instance 
    #' to execute the search it is possible to use: _pathName find invoke_. See the button manual page for other commands.
    #'
    
    #' *pathName* **findnext** *cmd ?option ...?*
    #' 
    #' > This function provides access for the programmer to the findnext button. For instance 
    #' to execute the next search it is possible to use: _pathName findnext invoke_. See the button manual page for other commands.
    #'
    
    constructor {args} {
        wm resizable $win false false
        pack [frame $win.left] -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 \
                  -expand yes -fill both
        pack [frame $win.right] -side left -padx 5 -pady 20 -ipadx 5 -ipady 5 \
                  -expand yes -fill both
        
        install find using button $win.right.search -text " Find " -width 15  
        
        pack $find -side top -padx 5 -pady 6
        
        install next using button $win.right.searchnext -text " Find Next " -width 15
        pack $next -side top -padx 5 -pady 6
        
        install cancel using button $win.right.cancel -text " Cancel " -width 15 \
                  -command [mymethod Withdraw]
        pack $cancel -side top -padx 5 -pady 6
        install entry using entry $win.left.entry
        pack $entry -side top -padx 5 -pady 12 -expand no -fill x
        
        pack [frame $win.left.bottom ] -side top -ipady 1
        pack [labelframe $win.left.bottom.left -text " Options: "] -side left -padx 5
        pack [checkbutton $win.left.bottom.left.words -text "Whole Words ?  " \
              -variable [varname options(-word)]] -side top -padx 5 -pady 3 -anchor w
        
        pack [checkbutton $win.left.bottom.left.uclc -text  "Case insensitive ?" \
              -variable [varname options(-nocase)]]  -side top -padx 5 -pady 3 -anchor w
       
        pack [checkbutton $win.left.bottom.left.regex -text  "Regular expression ?" \
              -variable [varname options(-regexp)]]  -side top -padx 5 -pady 3 -anchor w
       
        pack [labelframe $win.left.bottom.right -text " Direction: "] -side left \
                  -expand yes -fill both -padx 5
        pack [radiobutton $win.left.bottom.right.forward -text "Forward " \
              -variable [varname options(-forward)] -value yes] -side top -anchor w -padx 5 -pady 7
        pack [radiobutton $win.left.bottom.right.backward -text "Backward" \
              -variable [varname options(-forward)] -value no] -side top -anchor w  -padx 5 -pady 7
        $self configurelist $args
        if {$options(-textwidget) ne ""} {
            set options(-findcommand) [mymethod TextWidgetSearch]
            set options(-nextcommand) [mymethod TextWidgetSearchNext]
            $find configure -command [mymethod TextWidgetSearch]
            $next configure -command [mymethod TextWidgetSearchNext]
            $entry configure -textvariable [myvar searchtext]
            $options(-textwidget) tag configure hilite -background grey80
            
        }
        wm title $win $options(-title)

    }
    method TextWidgetSearch {{nexts false}} {
        set text $options(-textwidget)
        set cnt 1.end
        
        set cmd [list $text search]
        if {$options(-forward)} {
            lappend cmd -forward
        } else {
            lappend cmd -backward
        }
        if {$options(-nocase)} {
            lappend cmd -nocase
        }
        if {$options(-word)} {
            set stext "\\y$searchtext\\y"
            lappend cmd -regexp
        } elseif {$options(-regexp)} {
            lappend cmd -regexp
            set stext $searchtext
        } else {
            set stext $searchtext
        }
        lappend cmd -count
        lappend cmd cnt
        lappend cmd $stext
        if {$nexts && $options(-forward)} {
            lappend cmd $lastfound+1c
        } else {
            lappend cmd $lastfound
        } 
        set pos [{*}$cmd]
        if {$pos ne ""} {
            set lastfound $pos
            $text tag remove hilite 0.0 end
            set idx [split $pos "."]
            set line [lindex $idx 0]
            set epos [lindex $idx 1]
            incr epos $cnt
            $text see $pos
            $text tag add hilite $pos $line.$epos
            after 3000 [list $text tag remove hilite $pos $line.$epos]
        }
    }
    method TextWidgetSearchNext {} {
        $self TextWidgetSearch true
    }
    method Withdraw {} {
        grab release $win
        wm withdraw $win
    }
  
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#' proc Test_Find {} {
#'    global textvar
#'    # testing mFind
#'    proc Next {} {
#'        global textvar
#'        wm title .s "Next $textvar words: [.s cget -word]"
#'        puts "Next $textvar words: [.s cget -word]"
#'    }
#'    proc Find {} {
#'        global textvar
#'        wm title .s "Find $textvar words: [.s cget -word]"
#'       puts "Find $textvar words: [.s cget -word]"
#'    }
#'    
#'    set textvar test
#'    dgw::sfinddialog .s -nocase 1 -findnextcmd Next -findcmd Find -textvariable textvar
#'    wm title .s "Search "
#'   
#'    .s find configure -bg red
#'    set btn [.s find]
#'    $btn configure -bg blue
#'    bind .s <Control-f> {wm deiconify .s}
#'    pack [button .btn -text "Open find dialog again ..." -command {wm deiconify .s}]
#'    pack [text .text]
#'    dgw::sfinddialog .st -nocase 0 -textwidget .text -title "Search"
#'    .text insert end "Hello\n"
#'    .text insert end "Hello World!\n"
#'    .text insert end "Hello Search Dialog!\n"
#'    .text insert end "End\n"
#'    .text insert end "How are your?\n"
#'    .text insert end "I am not prepared :(\n"
#'    
#'    bind .text <Control-f> {wm deiconify .st}
#' }
#' Test_Find
#' ```
#' 
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **dgw::sfinddialog** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' If you have the snit Tcl packages installed, you can either use the __BASENAME__ package by sourcing it with: 
#' `source /path/to/__BASENAME__.tcl`, by copying the folder `dgw` to a path belonging to your Tcl `$auto_path` variable or by installing it as a Tcl module. 
#' To do the latter, make a copy of `__BASENAME__.tcl` to a file like `__BASENAME__-__PKGVERSION__.tm` and put this file into a folder named `dgw` where the parent folder belongs to your module path.
#' You must eventually adapt your Tcl-module path by using in your Tcl code the command: 
#' `tcl::tm::path add /parent/dir/` of the `dgw` directory. 
#' For details of the latter, consult the [manual page of tcl::tm](https://www.tcl.tk/man/tcl/TclCmd/tm.htm).
#'
#' Alternatively there is an `--install` option you can use as well. 
#' Try: `tclsh __BASENAME__.tcl --install` which should perform the procedure described above automatically. 
#' This requires eventually the setting of an environment variables like if you have no write access to all 
#' your module paths. For instance on my computer I have the following entry in my `.bashrc`
#'
#' ```
#' export TCL8_6_TM_PATH=/home/groth/.local/lib/tcl8.6
#' ```
#' 
#' If I execute `tclsh __BASENAME__.tcl --install` the file `__BASENAME__.tcl` will be copied to <br/>
#' `/home/groth/.local/lib/tcl8.6/dgw/__BASENAME__-0.1.tm` and is thereafter available for a<br/> `package require dgw::__BASENAME__`.
#'
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


if {[info exists argv0] && $argv0 eq [info script] && [regexp sfinddialog $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {
        # DEMO START
        pack [text .text]
        dgw::sfinddialog .st -nocase 0 -textwidget .text -title "Search"
        for {set i 0} {$i < 50} {incr i 1} {
            .text insert end "Hello $i\n"
            .text insert end "Hello World!\n"
            .text insert end "Hello Search Dialog!\n"
            .text insert end "End\n"
            .text insert end "How are your?\n"
            .text insert end "I am not prepared :(\n"
        }
        bind .text <Control-f> {wm deiconify .st}
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
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a text search dialog toplevel to"
        puts "be used for instance for a text widget search function."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install shistory as Tcl module"        
        puts "        --man     : printing the man page in github-markdown to the terminal"
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
