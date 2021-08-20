#!/usr/bin/env tclsh
##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Thu Aug 12 12:00:00 2021
#  Last Modified : <210820.0641>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################
#' ---
#' documentclass: scrartcl
#' title: dgw::txmixins __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' ---
#' 
#' ## NAME
#'
#' **dgw::txmixins** - implementations of extensions for the *text* 
#'         widget which can be added dynamically using chaining of commands 
#'         at widget creation or using the *dgw::mixin* command after widget 
#'         creation.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [WIDGET COMMANDS](#commands)
#'     - [dgw::txmixin](#txmixin) - add one mixin to text widget after widget creation
#'     - [dgw::txautorep](#txautorep) - short abbreviations snippets invoked after closing parenthesis
#'     - [dgw::txfold](#txfold) - folding text editor
#'     - [dgw::txindent](#txindent) - keep indentation of previous line
#'     - [dgw::txrotext](#txrotext) - read only text widget
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
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
#' package require dgw::txmixins
#' ::dgw::txmixin pathName widgetAdaptor ?options?
#' ::dgw::txfold [tk::text pathName ?options?] ?options?
#' set txt [tk::text pathName ?options?]
#' dgw::txmixin $txt dgw::txfold ?options?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The package **dgw::txmixins** implements several *snit::widgetadaptor*s which 
#' extend the standard *tk::text* widget with different functionalities.
#' Different adaptors can be chained together to add the required functionalities. 
#' Furthermore at any later time point using the *dgw::mixin* command other adaptors can be installed on the widget.
#'
#' ## <a name='commands'>WIDGET COMMANDS</a>
#'
package require Tk
package require snit

namespace eval ::dgw {} 
package provide dgw::txmixins 0.1

#'
#' <a name="mixin">**dgw::mixin**</a> *pathName mixinWidget ?-option value ...?*
#' 
#' Adds the properties and methods of a snit::widgetadaptor specified with *mixinWidget* 
#' to the exising widget created before with the given *pathName* and configures the widget 
#' using the given *options*. 
#' 
#' Example:
#'
#' > ```
#' # demo: mixin
#' # standard text widget
#' set text [tk::text .txt]
#' pack $text -side top -fill both -expand true
#' dgw::txmixin $text dgw::txfold
#' # fill the widget
#' for {set i 1} {$i < 4} {incr i} { 
#'     $text insert end "## Header $i\n\n"
#'     for {set j 0} {$j < 2} {incr j} {
#'       $text insert end "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,\n"
#'       $text insert end "sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,\n" 
#'       $text insert end "sed diam voluptua. \nAt vero eos et accusam et justo duo dolores et ea rebum.\n"
#'       $text insert end "Stet clita kasd gubergren, no sea takimata sanctus est.\n\n" 
#'     }
#' }
#' $text insert end "\n## Hint\n\nPress F2 or F3 and see what happend!"
#' > ```

proc ::dgw::txmixin {pathName mixinWidget args} {
    return [$mixinWidget $pathName {*}$args]
}

#' 
#' <a name="txfold">**dgw::txfold**</a> *[tk::text pathName] ?-option value ...?*
#' 
#' Creates and configures the *dgw::txfold*  widget using the Tk window id _pathName_ and 
#'   the given *options*. The widgets supports text folding based on linestart regular expressions usually which allows fast navigation of larger
#'   documents by hiding and showing larger chunks of text within the folding marks.
#'
#' The following options are available:
#'
#' > - *-foldkey* *F2*  - the key to fold or unfold regions where the insert cursor is within
#'   - *-foldallkey* *F3* - the key to fold/unfold the complete text
#'   - *-foldstart* *^#* - the start folding marker, default is Markdown header folding
#'   - *-foldend* "^#* - the end fold marker, where the folding ends, if the end marker is the same as the start marker folding is ended in the line before the end line, otherwise on the end line
#' 
#' The following widget tags are created and can be modified at runtime:
#' 
#' > - *fold* - the folding line which remains visible, usually the background should be configured only, default is `#ffbbaa` a light salmon like color
#'   - *folded* - the hidden (-elide true) part which is invisible, usually not required to change it, as it is hidden
#' 
#' Example:
#' 
#' > ```
#' # demo: txfold
#' dgw::txfold [tk::text .txt]
#' foreach col [list A B C] { 
#'    .txt insert  end "# Header $col\n\nSome text\n\n"
#' }
#' .txt insert end "Place the cursor on the header lines and press F2\n"
#' .txt insert end "or press F3 to fold or unfold the complete text.\n"
#' .txt tag configure fold -background #cceeff
#' .txt configure -borderwidth 10 -relief flat
#' pack .txt -side top -fill both -expand yes
#' # next line would fold by double click (although I like F2 more ...)
#' # .txt configure -foldkey Double-1 
#' bind .txt <Enter> { focus -force .txt }
#' > ```

# widget adaptor which does a folding text
snit::widgetadaptor ::dgw::txfold {
    delegate option * to hull 
    delegate method * to hull
    option -foldkey F2
    option -foldall F3
    option -foldstart "^#"
    option -foldend "^#"
    # problem:
    # can't avoid delegating insert as if it is 
    # overwritten parent insert can't be called
    # solved by adding trace executation
    # might slow down the widget
    constructor {args} {
        installhull $win
        $self configurelist $args
        set fold $options(-foldkey)
        set foldall $options(-foldall)
        bind $win <$fold> [mymethod FoldCurrent]
        bind $win <$foldall> [mymethod FoldAll]        
        $win tag configure fold -background #ffbbaa
        $win tag configure folded -elide true 

    }
    method FoldAll {} {
        set text $win
        set rng [$text tag ranges fold]
        if {[llength $rng] ==0} {
            set store [$text index insert]            
            set current [$text index insert]
            set lastrng [list]
            set start 1.0
            set start [$text search -regexp -forward $options(-foldstart) 1.0]
            set start [$text index "$start + 1 line"]
            tk::TextSetCursor $text $start
            set x 1
            while {true} {
                $self FoldCurrent
                set rng [$text tag ranges folded]
                if {[llength $lastrng] == [llength $rng]} {
                    break
                }
                set current1 [lindex $rng end]
                if {$options(-foldstart) eq $options(-foldend)} {
                    set current2 [$text index "$current1 - 1 line"]
                } else {
                    set current2 [$text index "$current1"]
                }
                set current2 [$text search -regexp -forward $options(-foldstart) $current2 end]
                if {$current2 eq ""} break
                tk::TextSetCursor $text $current2
                set lastrng $rng
            }
            tk::TextSetCursor $text $store
        } else {
            $text tag remove fold 1.0 end
            $text tag remove folded 1.0 end
            $text see insert
        }
    }
    onconfigure -foldkey value {
        if {$value ne ""} {
            set fold $options(-foldkey)
            bind $win <$fold> {}
            bind $win <$value> [mymethod FoldCurrent]
            set options(-foldkey) $value
        } 
        return $options(-foldkey)
    }
    onconfigure -foldall value {
        if {$value ne ""} {
            set fold $options(-foldall)
            bind $win <$fold> {}
            bind $win <$value> [mymethod FoldAll]
            set options(-foldall) $value
        } 
        return $options(-foldall)
    }

    method FoldCurrent {} {
        set text $win
        set folds [$self getFolds]
        puts $folds
        set current [$text index insert]
        if {[lsearch [$text tag names $current] fold] > -1} {
            $text tag remove fold "$current linestart" "$current lineend + 1 char"
            $text tag remove folded "$current lineend + 1 char" "[lindex $folds 1] lineend"
        } else {
            if {[llength $folds] > 0} {
                $text tag add fold "[lindex $folds 0] linestart" "[lindex $folds 0] lineend + 1char"
                $text tag add folded "[lindex $folds 0] lineend + 1 char" "[lindex $folds 1]"
                if {[$text compare "$current linestart" != "[lindex $folds 0] linestart"]} {
                    tk::TextSetCursor $text "[lindex $folds 0] linestart"
                }
            }
        }
        return
    }
    method isInFold {} {
        set text $win
        set current [$text index insert]
        set foldOpen [$text search -all -elide -regexp -forward $options(-foldstart) 1.0 end]
        set foldEnd  [$text search -all -elide -regexp -forward $options(-foldend) 1.0 end]
        set ret [list]
        for {set i 0} {$i < [llength $foldOpen]} {incr i 1} {
            if {[$text compare [lindex $foldOpen $i] <= $current]} {
                if {[$text compare $current <= [lindex $foldEnd $i]]} {
                    set ret [list [lindex $foldOpen $i] [$text index "[lindex $foldEnd $i] + 1 line"]]
                    break
                }
            }
        }
        return $ret
    }
    method getFolds {} {
        set text $win
        set current [$text index insert]
        set foldendb [$text search -elide -regexp -backward $options(-foldend) $current 1.0]
        set foldstart [$text search -elide -regexp -backward $options(-foldstart) "$current + 1 char" 1.0]

        if {$options(-foldstart) eq $options(-foldend)} {
            set foldende [$text search -elide -regexp -forward $options(-foldend) "$current + 1 char" end]
        } else {
            set foldende [$text search -elide -regexp -forward $options(-foldend) "$current" end]
        }
        #puts "foldendb: $foldendb"
        #puts "foldende: $foldende"        
        #puts "foldstart: $foldstart"
        #puts "current: $current"
        if {$options(-foldstart) eq $options(-foldend)} {
            if {$foldstart ne "" & $foldende eq ""} {
                return [list $foldstart end]
            } else {
                return [list [$text index "$foldstart linestart"] [$text index "$foldende linestart"]]
            }
        } else {
 
            return [$self isInFold]
 
        }
    }
}

#' 
#' <a name="txrotext">**dgw::txrotext**</a> *[tk::text pathName] ?-option value ...?*
#' 
#' Creates and configures the *dgw::txrotext*  widget using the Tk window id _pathName_ and 
#' the given *options*. All options are delegated to the standard text widget. 
#' This creates a readonly text widget.
#' Based on code from the snitfaq by  William H. Duquette.
#'
#' Example:
#' 
#' > ```
#' # demo: txrotext
#' dgw::txrotext [tk::text .txt]
#' foreach col [list A B C] { 
#'    .txt ins  end "# Header $col\n\nSome text\n\n"
#' }
#' pack .txt -side top -fill both -expand yes
#' > ```


::snit::widgetadaptor ::dgw::txrotext {
    delegate option * to hull 
    delegate method * to hull
    constructor {args} {
        installhull $win
        $self configure -insertwidth 0
        $self configurelist $args
    }

    # Disable the text widget's insert and delete methods, to
    # make this readonly.
    method insert {args} {}
    method delete {args} {}

    # Enable ins and del as synonyms, so the program can insert and
    # delete.
    delegate method ins to hull as insert
    delegate method del to hull as delete
}

#' 
#' <a name="txindent">**dgw::txindent**</a> *[tk::text pathName] ?-option value ...?*
#' 
#' Creates and configures the *dgw::txindent*  widget using the Tk window id _pathName_ and 
#' the given *options*. All options are delegated to the standard text widget. 
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.
#'
#' Example:
#' 
#' > ```
#' # demo: txindent
#' dgw::txindent [tk::text .txt]
#' foreach col [list A B C] { 
#'    .txt insert  end "# Header $col\n\nSome text\n\n"
#' }
#' .txt insert end "  * item 1\n  * item 2 (press return here)"
#' pack .txt -side top -fill both -expand yes
#' > ```


::snit::widgetadaptor ::dgw::txindent {
    delegate option * to hull 
    delegate method * to hull
    constructor {args} {
        installhull $win
        $self configurelist $args
        bind $win <Return> "[mymethod indent]; break"
    }
    
    method indent {{extra "    "}} {
        set w $win
        set lineno [expr {int([$w index insert])}]
        set line [$w get $lineno.0 $lineno.end]
        regexp {^(\s*)} $line -> prefix
        if {[string index $line end] eq "\{"} {
            tk::TextInsert $w "\n$prefix$extra"
        } elseif {[string index $line end] eq "\}"} {
            if {[regexp {^\s+\}} $line]} {
                $w delete insert-[expr [string length $extra]+1]c insert-1c
                tk::TextInsert $w "\n[string range $prefix 0 end-[string length $extra]]"
            } else {
                tk::TextInsert $w "\n$prefix"
            }
        } else {
            tk::TextInsert $w "\n$prefix"
        }
    }
}

#' 
#' <a name="txautorep">**dgw::txautorep**</a> *[tk::text pathName] ?-option value ...?*
#' 
#' Creates and configures the *dgw::txautorep*  widget using the Tk window id _pathName_ and 
#' the given *options*. All options are delegated to the standard text widget. 
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/autoreplace started by Richard Suchenwirth in 2008.
#'
#' The following option is available:
#'
#' > - *-automap* *list*  - list of abbreviations and their replacement, the abbreviations must end with a closing 
#'     parenthesis such as [list DG) {Detlef Groth}].
#' 
#' Example:
#' 
#' > ```
#' # demo: txautorep
#' dgw::txautorep [tk::text .txt] -automap [list (TM) \u2122 (C) \
#'      \u00A9 (R) \u00AE (K) \u2654 D) {D Groth} \
#'      (DG) {Detlef Groth, University of Potsdam}]
#' .txt insert end "type a vew abbreviations like (TM), (C), (R) or (K) ..."
#' pack .txt -side top -fill both -expand yes
#' > ```
#'
#' TODO: Take abbreviations from file
#' 
#' 

::snit::widgetadaptor ::dgw::txautorep {
    delegate option * to hull 
    delegate method * to hull
    option -automap [list (DG) {Detlef Groth\nUniversity of Potsdam}]
    constructor {args} {
        installhull $win
        $self configurelist $args ;#(
        bind $win <KeyRelease-)> [mymethod autochange]
    }
     method autochange {} {
        set w $win
        foreach {abbrev value} $options(-automap) {
            set n [string length $abbrev]
            if {[$w get "insert-$n chars" insert] eq $abbrev} {
                $w delete "insert-$n chars" insert
                $w insert insert $value
                break
            }
        }
    }
}

# More ideas:
# https://wiki.tcl-lang.org/page/File+watch
# https://wiki.tcl-lang.org/page/Simple+Block+Selection+for+Text+Widget
# https://wiki.tcl-lang.org/page/block%2Dselect
# https://wiki.tcl-lang.org/page/Simple+Text+Widget+Sort
# https://wiki.tcl-lang.org/page/A+little+logic+notation+editor
# https://wiki.tcl-lang.org/page/Text+Drag+%2DDrag+and+Drop+for+Text+Widget+Selections
# https://wiki.tcl-lang.org/page/text+line+coloring
# https://wiki.tcl-lang.org/page/Displaying+tables
# https://wiki.tcl-lang.org/page/Time%2Dstamp
# https://wiki.tcl-lang.org/page/Balloon+Help%2C+Generalised
# https://wiki.tcl-lang.org/page/Super+and+Subscripts+in+a+text+widget
namespace eval dgw {
    namespace export txmixin txfold txrotext txindent
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp {txmixins} $argv0]} {
    # dgwutils is only required for doucmentation and script execution
    package require dgw::dgwutils
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] >= 1 && [lindex $argv 0] eq "--demo"} {    
        if {[llength $argv] == 1} {
            dgw::runExample [info script] true 
        } else {
            puts "running [lindex $argv 1]"
            dgw::runExample [info script] true [lindex $argv 1]
        }
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        #destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--example"} {
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
        puts "Copyright (c) 2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a text editor widget with syntax hilighting facilities and and toolbar"
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
        puts ""
    }
    return
}

#' ## <a name='example'>EXAMPLE</a>
#'
#' In the examples below we create a foldable text widget which can fold Markdown headers.
#' Just press the button F2 and F3 to fold or unfold regions or the complete text.
#' Thereafter a demonstration on how to use the *dgw::txmixin* command which simplifies the addition of 
#' new behaviors to our *tk::text* in a stepwise manner. 
#' The latter approach is as well nice to extend existing widgets in a more controlled manner 
#' avoiding restarts of applications during developing the widget.
#' 
#' ```
#' package require dgw::txmixins
#' # standard text widget
#' set f [ttk::frame .f]
#' set text [tk::text .f.txt -borderwidth 5 -relief flat]
#' pack $text -side left -fill both -expand true 
#' dgw::txmixin $text dgw::txfold
#' # fill the widget
#' for {set i 0} {$i < 5} {incr i} { 
#'     $text insert end "## Header $i\n\n"
#'     for {set j 0} {$j < 2} {incr j} {
#'       $text insert end "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,\n"
#'       $text insert end "sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,\n" 
#'       $text insert end "sed diam voluptua. \nAt vero eos et accusam et justo duo dolores et ea rebum.\n"
#'       $text insert end "Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\n\n" 
#'     }
#' }
#' set tcltxt [tk::text .f.tcl -borderwidth 5 -relief flat]
#' dgw::txmixin $tcltxt dgw::txfold -foldstart "^\[A-Za-z\].+\{" -foldend "^\}"
#' $tcltxt tag configure fold -background #aaccff
#' $tcltxt insert end "package require Tk\nproc test {} {\n    puts Hi\n}\n\nsnit::widget wid {\n\n}\n"
#' pack $tcltxt -side left -fill both -expand true
#' pack $f -side top -fill both -expand yes
#' set f2 [ttk::frame .f2]
#' dgw::txrotext [tk::text $f2.rotxt]
#' foreach col [list A B C] { 
#'    $f2.rotxt ins  end "# Header $col\n\nSome text\n\n"
#' }
#' pack $f2.rotxt -side left -fill both -expand yes
#' dgw::txindent [tk::text $f2.intxt]
#' dgw::txmixin $f2.intxt dgw::txfold
#' $f2.intxt insert end "# Header 1\n\n* item\n    * subitem 1\n    * subitem2"
#' $f2.intxt insert end "# Header 2\n\n* item\n    * subitem 1\n    * subitem2"
#' $f2.intxt insert 5.0 "\n" ;  $f2.intxt tag add line 5.0 6.0 ; 
#' $f2.intxt tag configure line -background black -font "Arial 1" 
#' pack $f2.intxt -side left -fill both -expand yes
#' pack $f2 -side top -fill both -expand yes
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path. 
#' 
#' Only if you you like to extract the HTML documentation and run the examples, 
#' you need the complete dgw package and for the HTML generation the tcllib Markdown package.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package in the *EXAMPLE* section can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```
#' 
#' Specific code examples outside of the EXAMPLE section can be executed using the string after the *demo:* prefix string in the code block for the individual code adaptors such as:
#' 
#' 
#' ```
#' $ wish __BASENAME__.tcl --demo txfold
#' ```
#'
#' The example code used for the demo in the EXAMPLE section can be seen in the terminal by using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --code
#' ```
#' #include "documentation.md"
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets
#' - [tk::text widget manual](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_treeview.htm) standard manual page for the ttk::treeview widget
#'
#'  
#' ## <a name='changes'>CHANGES</a>
#'
#' * 2021-08-12 - version 0.1 initial starting the widget.
#' * 2021-08-19 
#'     * completing docu
#'     * finalize txfold
#'     * adding txrotext, txindent, txautorep
#'
#' ## <a name='todo'>TODO</a>
#' 
#' * File watch: https://wiki.tcl-lang.org/page/File+watch
#' * Block selection: https://wiki.tcl-lang.org/page/Simple+Block+Selection+for+Text+Widget
#' * Text sorting: https://wiki.tcl-lang.org/page/Simple+Text+Widget+Sort
#' * Logic notation https://wiki.tcl-lang.org/page/A+little+logic+notation+editor
#' * Drag and drop of text: https://wiki.tcl-lang.org/page/Text+Drag+%2DDrag+and+Drop+for+Text+Widget+Selections
#' * text line coloring https://wiki.tcl-lang.org/page/text+line+coloring
#' * table display https://wiki.tcl-lang.org/page/Displaying+tables
#' * time stamp https://wiki.tcl-lang.org/page/Time%2Dstamp
#' * balloon help https://wiki.tcl-lang.org/page/Balloon+Help%2C+Generalised
#' * sub and superscripts https://wiki.tcl-lang.org/page/Super+and+Subscripts+in+a+text+widget
#'
#' ## <a name='authors'>AUTHORS</a>
#'
#' The **__PKGNAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>Copyright</a>
#'
#' Copyright (c) 2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
# LICENSE START
#
#' #include "license.md"
#
# LICENSE END
