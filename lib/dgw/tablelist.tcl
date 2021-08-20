#!/usr/bin/env tclsh
#' ---
#' documentclass: scrartcl
#' title: dgw::tablelist __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2019-11-04
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::tablelist** - extended tablelist widget with icons and tree mode implementation.
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
#'  - [SEE also](#see)
#'  - [TODO](#todo)
#'  - [AUTHORS](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require Tk
#' package require snit
#' package require dgw::tablelist
#' dgw::tablelist pathName ?options?
#' pathName configure -option value
#' pathName cget -option 
#' pathName loadFile filename ?boolean?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The widget **dgw::tablelist** inherits from the standard tablelist widget 
#' all methods and options but has embedded standard icons. 
#' The treemode of tablelist is supported further with changing icons on opening and closing tree nodes.
#' 
## Scrollbars are as well added by default, if the autoscroll package of tklib is available they are only shown if neccessary.
#' 
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::tablelist** *pathName ?options?*
#' 
#' > Creates and configures the **dgw::tablelist**  widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' As the **dgw::tablelist** is an extension of the tablelist widget it has all the options of the tablelist widget. 
#' The following options are added or modified:

if {[info exists argv0] && $argv0 eq [info script]} {
    lappend auto_path [file join [file dirname [info script]] .. libs]
    ::tcl::tm::path add [file join [file dirname [info script]] .. libs]
}
package require tablelist
package require snit
package require dgw::dgwutils

# widget with default icons and open and close command

namespace eval ::dgw { }

::snit::widgetadaptor dgw::tablelist {
    #' 
    #'   __-browsecmd__ _script_ 
    #' 
    #'  > Set a command if the user double clicks an entry in the listbox or presses the `Return` key if the widget has the focus.
    #'    The widget path and the index of the item getting the event are appended to the script call as function arguments. 
    #'    So the implementation of the script should have two arguments in the parameter list as shown in the following example:
    #' 
    #' > ```
    #'   proc click {tbl idx} {
    #'      puts [$tbl itemcget $idx -text]
    #'   }
    #'   dgw::tablelist .tl -browsecmd click
    #' > ```
    option -browsecmd ""
    
    #'
    #' __-collapsecommand__ _command_
    #'
    #' > This options is per default configured to change the icons in the tree 
    #'   for parent items which have child items if the node is opened. Can be overwritten by the user.
    option -collapsecommand ""
    
    #'
    #' __-expandcommand__ _command_
    #'
    #' > This options is per default configured to change the icons in the tree 
    #'   for parent items which have child items. Can be overwritten by the user.
    option -expandcommand ""
    
    #'  
    #' __-collapseicon__ _iconprefix_
    #'
    #' > The imagw which should be displayed if a folder node is closed.
    #'   Currently the default is a folder icon.
    option -collapseicon folder

    #'
    #' __-treestyle__ _stylename_
    #'
    #' > Currently this option is just delegated to the standard tablelist widget.
    
    option -treestyle -configuremethod SetTreeStyle \
          -cgetmethod GetTreeStyle -default winnative

    delegate option * to hull except [list -treestyle -expandcommand \
        -collapsecommand -collapseicon -browsecmd]
    delegate method * to hull except insertchildlist
    constructor {args} {
        installhull using tablelist::tablelist
        $hull configure -expandcommand [mymethod ExpandCmd] -collapsecommand [mymethod CollapseCmd]
        $self configurelist $args
        # todo
        bind all <Double-1> +[mymethod Browse %W]
        bind all <KeyPress-Return> +[mymethod Browse %W]
    }
    typeconstructor {
        image create photo appbook16 -data {
            R0lGODlhEAAQAIQAAPwCBAQCBDyKhDSChGSinFSWlEySjCx+fHSqrGSipESO
            jCR6dKTGxISytIy6vFSalBxydAQeHHyurAxubARmZCR+fBx2dDyKjPz+/MzK
            zLTS1IyOjAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVkICCOZGmK
            QXCWqTCoa0oUxnDAZIrsSaEMCxwgwGggHI3E47eA4AKRogQxcy0mFFhgEW3M
            CoOKBZsdUrhFxSUMyT7P3bAlhcnk4BoHvb4RBuABGHwpJn+BGX1CLAGJKzmK
            jpF+IQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
            qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
            dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo appbookopen16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBExCNGSenHRmVCwqJPTq1GxeTHRqXPz+/Dwy
            JPTq3Ny+lOzexPzy5HRuVFSWlNzClPTexIR2ZOzevPz29AxqbPz6/IR+ZDyK
            jPTy5IyCZPz27ESOjJySfDSGhPTm1PTizJSKdDSChNzWxMS2nIR6ZKyijNzO
            rOzWtIx+bLSifNTGrMy6lIx+ZCRWRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAae
            QEAAQCwWBYJiYEAoGAFIw0E5QCScAIVikUgQqNargtFwdB9KSDhxiEjMiUlg
            HlB3E48IpdKdLCxzEAQJFxUTblwJGH9zGQgVGhUbbhxdG4wBHQQaCwaTb10e
            mB8EBiAhInp8CSKYIw8kDRSfDiUmJ4xCIxMoKSoRJRMrJyy5uhMtLisTLCQk
            C8bHGBMj1daARgEjLyN03kPZc09FfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo appfolderopen16 -data {
            R0lGODlhEAAOAPcAAAAAAJycAM7OY//OnP//nP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAAQAA4A
            AAhnAP8JHEiwIMEACBEaPFigYcMAC/8FKECgYsUCCRMKnGixo8MCAgBIpNixJIGQGVMmFHASAMeS
            AwgMCCkAJcmKMWW2rCnypcWYAwYEcNmTJFCZQVGKHHk0aNKhS1WqBLD0H9WrWLEGBAA
        }
        image create photo appfolder16 -data {
            R0lGODlhEAAOAPcAAAAAAJycAM7OY//OnP//nP//zvf39wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAAQAA4A
            AAhjAP8JHEiw4MAACBECMHjQQIECBAgEWGgwgICLGAUkTCgwwMOPIB8SELDQY8STKAkMIPnPZEqV
            MFm6fDlApUyIKGvqHFkSZ06YK3ue3KkzaMsCRIEOMGoxo1OMFAFInUqV6r+AADs=
        }
        image create photo filedocument16 -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJSWjPz+/Ozq7GxqbJyanPT29HRy
            dMzOzDQyNIyKjERCROTi3Pz69PTy7Pzy7PTu5Ozm3LyqlJyWlJSSjJSOhOzi
            1LyulPz27PTq3PTm1OzezLyqjIyKhJSKfOzaxPz29OzizLyidIyGdIyCdOTO
            pLymhOzavOTStMTCtMS+rMS6pMSynMSulLyedAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaQ
            QIAQECgajcNkQMBkDgKEQFK4LFgLhkMBIVUKroWEYlEgMLxbBKLQUBwc52Hg
            AQ4LBo049atWQyIPA3pEdFcQEhMUFYNVagQWFxgZGoxfYRsTHB0eH5UJCJAY
            ICEinUoPIxIcHCQkIiIllQYEGCEhJicoKYwPmiQeKisrKLFKLCwtLi8wHyUl
            MYwM0tPUDH5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        # classes
        image create photo appboxes16 -data {
            R0lGODlhEAAQAIMAAPwCBAQCBMT+xAT+BASCBATCBMT+/AT+/ASChATCxPz+
            xPz+BISCBMTCBAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARaEEgZwrwYBCFq
            vhs3DNYXjChRlWBRjIRqGN4UuEUczMZxsDeXykdEsDQVVSLhQxhBCkVlmXA+
            KVHFYhFYOoHbMGN6pTQaW8YYiQmcG+q16a0+Zipw+4e9B/gjACH+aENyZWF0
            ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5
            OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2
            ZWxjb3IuY29tADs=
        }
        # function
        image create photo actrun16 -data {
            R0lGODlhEAAQAIMAAPwCBAQCBPz+/ISChKSipMTCxLS2tLy+vMzOzMTGxNTS
            1AAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARlEMgJQqDYyiDG
            rR8oWJxnCcQXDMU4GEYqFN4UEHB+FEhtv7EBIYEohkjBkwJBqggEMB+ncHha
            BsDUZmbAXq67EecQ02x2CMWzkAs504gCO3qcDZjkl11FMJVIN0cqHSpuGYYS
            fhEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkg
            RGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0
            cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }


    }
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **dgw::tablelist** widget supports all the commands of the standard tablelist widget. 
    #' See the tablelist manual page for a description of those widget commands. 

    method insertchild {parent place lst}  {
        set node [$hull insertchild $parent $place $lst]
        if {$parent ne "root"} {
            $hull cellconfigure $parent,0 -image app$options(-collapseicon)open16
        }
        $hull cellconfigure $node,0 -image filedocument16
        return $node
    }
    method SetTreeStyle {option value} {
        set options($option) $value
        $hull configure -treestyle $value 
        # todo all rows mit den entsprechenden icons ausstatten
    }
    method GetTreeStyle {option} {
        set options($option) 
    }
    method ExpandCmd {tbl row} {
        if {[llength [$tbl childkeys $row]] > 0} {
            $tbl cellconfigure $row,0 -image app$options(-collapseicon)open16            
        } else {
            $tbl cellconfigure $row,0 -image filedocument16
        }
    }
    method CollapseCmd {tbl row} {
        if {[llength [$tbl childkeys $row]] > 0} {
            $tbl cellconfigure $row,0 -image app$options(-collapseicon)16
        } else {
            $tbl cellconfigure $row,0 -image filedocument16
        }
    }
    method Browse {w} {
        #puts $w
        #puts $hull
        if {$options(-browsecmd) ne ""} {
            if {[$hull curselection] ne ""} {
            #if {[winfo parent $w] eq $hull || [winfo parent $w] eq [$hull bodypath]} {
                $options(-browsecmd) $hull [$hull curselection]
            #}
            }
        }
    }

}
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#' proc click {tbl idx} {
#'      puts "clicked in $tbl on $idx"
#' }
#' dgw::tablelist .mtab   -columns {0 "Name"  left 0 "Page" left} \
#'        -movablecolumns no -setgrid no -treecolumn 0 -treestyle gtk -showlabels false \
#'        -stripebackground white -width 40 -height 25 \
#'        -browsecmd click
#' 
#'  pack .mtab -side left -fill both -expand yes
#'  dgw::tablelist .mtab2   -columns {0 "Name"  left 0 "Page" left} \
#'        -movablecolumns no -setgrid no -treecolumn 0 -treestyle ubuntu -showlabels false \
#'        -stripebackground grey90 -width 40 -height 25
#' 
#'  pack .mtab2 -side left -fill both -expand yes
#'  set x 0 
#'  while {[incr x] < 5} {
#'      set y 0
#'      set parent [.mtab insertchild root end [list Name$x $x]]
#'      set parent [.mtab2 insertchild root end [list Name$x $x]]        
#'      while {[incr y] < 5} {
#'          .mtab insertchild $parent end [list Child$y $y]
#'          .mtab2 insertchild $parent end [list Child$y $y]
#'      }
#'  }
#' ```
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **dgw::__BASENAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
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
#' man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:
#'
#' ```
#' # man page
#' tclsh __BASENAME__.tcl --man | pandoc -s -f markdown -t man - > __BASENAME__.n
#' # html 
#' tclsh __BASENAME__.tcl --man > __BASENAME__.md
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
#' * more icons
#' * more, real, tests
#' * github url for putting the code

#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The dgw::**__BASENAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' dgw::__BASENAME__ widget __PKGNAME__, version __PKGVERSION__.
#'
#' Copyright (c) 
#' 
#'    * 2019-2020  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>
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

package provide dgw::tablelist 0.2

if {[info exists argv0] && $argv0 eq [info script]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        dgw::runExample [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        destroy .
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
        puts "\nThe ${dpath}::$pfile package provides a button toolbar with nice graphical buttons."
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
