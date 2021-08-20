#' ---
#' documentclass: scrartcl
#' title: dgtools::shistory __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: 
#'    pdf_document
#' ---
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Nov 5 07:21:48 2018
#  Last Modified : <200301.1840>
#
#' ## NAME
#'
#' **dgtools::shistory** - a snit type history command.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [TYPE OPTIONS](#options)
#'  - [TYPE COMMANDS](#commands)
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
#' package require dgtools::shistory
#' ::dgtools::shistory cmd ?option value?
#' cmd back 
#' cmd canBackward
#' cmd canForward
#' cmd canFirst
#' cmd canLast
#' cmd cget option
#' cmd configure option value
#' cmd current
#' cmd first
#' cmd forward
#' cmd getHistory
#' cmd home
#' cmd insert value
#' cmd last
#' cmd resetHistory
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **shistory** type is data structure to allow the storage of text strings in a history. 
#' this can be useful to store for instance a browser history or a move history in a board game like Chess or Go.
#'
#' ## <a name='options'>TYPE OPTIONS</a>
#'


package require snit
namespace eval ::dgtools {}
snit::type ::dgtools::shistory {
    #' __-home__ value
    #'
    #' > The value which is set as the home, it is stored in principle as the first item in the history. Defaults to an empty string.

    option -home ""
    variable index -1
    variable history
    constructor {args} {
        $self configurelist $args
        set history [list]
    }
    #' 
    #' ## <a name='commands'>TYPE COMMANDS</a>
    #' 
    #' The **shistory** type supports a few commands to navigate in a history list.
    #'
    
    #' *cmd* **back** 
    #' 
    #' > Walks back in history one step and retrieves the value of the history at this position.
    #' 
    
    method back {} {
        incr index -1
        return [lindex $history $index]
    }
    #' *cmd* **canBackward** 
    #' 
    #' > Returns true if the current position in history is not the first value in history and if the length of history is greater than 1.
    #' 
    #'
    method canBackward {} {
        if {$index > 0} {
            return true
        } else {
            return false
        }
    }
    #' *cmd* **canFirst** 
    #' 
    #' > Returns true if the current position in history is not the first value in history and if history length is greater than 1.
    #'
    method canFirst {} {
        if {$index == 0} {
            return false
        } else {
            return true
        }
        
    }
    #' *cmd* **canForward** 
    #' 
    #' > Returns true if the current position in history is not the last value in history.
    #'
    method canForward {} {
        if {[llength $history] > [expr {$index+1}]} {
            return true
        } else {
            return false
        }
    }
    #' *cmd* **canLast** 
    #' 
    #' > Returns true if the current position in history is not the last value in history.
    #'
    method canLast {} {
        if {$index == [expr {[llength $history] -1}]} {
            return false
        } else {
            return true
        }
    }
    #' *cmd* **cget** *option*
    #' 
    #' > Retrieves the given option value for the shistory type. Curently only the *-home* option is available for *cget*.
    #'
    #' *cmd* **configure** *option value ?option value ...?*
    #' 
    #' > Configures the given option for the shistory type. Curently only the *-home* option is available for *configure*.
    #'
    #' *cmd* **current** 
    #' 
    #' > Retrieves the current value of the history.
    #'
    method current {} {
        return [lindex $history $index]
    }
    
    #' *cmd* **first** 
    #' 
    #' > Jumps to the first entry in history and returns it.
    #'
    method first {} {
        set index 0
        return [lindex $history $index]
    }
    #' *cmd* **forward** 
    #' 
    #' > Gos one step forward in history and returns the value there.
    #'
    method forward {} {
        # to check if possible
        incr index +1
        return [lindex $history $index]
    }
    #' *cmd* **getHistory** 
    #' 
    #' > Returns the history, a list of text entries.
    #'
    method getHistory {} {
        return $history
    }
    
    #' *cmd* **insert**  *value*
    #' 
    #' > Inserts the value in the history at the actual index.
    #'
    method insert {item} {
        set item [regsub {/$} $item ""]
        if {$item ne [lindex $history $index]} {
            incr index
            if {$item ne [lindex $history $index]} {
                #puts "index=$index $item"
                set history [linsert $history $index $item]
            } else {
                incr index -1
            }
        }
        return $item
    }
    
    #' *cmd* **home** 
    #' 
    #' > Returns the home index value which was set using the _-home_ option.
    #'
    method home {} {
        return $options(-home)
    }
    
    method resetHistory {} {
        set index -1
        set history [list]

    }
    #' *cmd* **last** 
    #' 
    #' > Jumps to the last value in history and returns the value there.
    #'
    method last {} {
        set index [llength $history]
        incr index -1
        return [lindex $history $index]
    }
}

package provide dgtools::shistory 0.2

#' 
#' ## <a name='example'>EXAMPLE</a>
#' ```
#'  package require dgtools::shistory
#'  set sh [::dgtools::shistory %AUTO% -home h]
#'  $sh insert a
#'  $sh insert a ;# should not give duplicates
#'  $sh insert a
#'  $sh insert b
#'  puts "\ncanback: [$sh canBackward]"
#'  puts "canforw: [$sh canForward]"
#'  $sh back
#'  $sh insert z
#'  puts [$sh getHistory]
#'  puts [$sh home]
#'  puts "last: [$sh last]"
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy, you can install and use this **dgtools::shistory** package if you have a working install of the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md).
#' To use the **dgtools::shistory**  package then, you can either sourc it within your Tcl-code: 
#' `source /path/to/dgtools/shistory.tcl`, or by copying the folder *dgtools* to a path belonging to your Tcl `$auto_path` variable or by installing it as an Tcl-module. 
#' To do this, make either yourself a copy of `shistory.tcl` to a file like `shistory-0.1.tm` and put this file into a folder named `dgtools` where the parent folder belongs to your module path.
#' You must eventually adapt your Tcl-module path by using in your Tcl code the command: 
#' `tcl::tm::path add /parent/dir/` of the `dgtools` directory. 
#' For details of the latter consult see the [manual page of tcl::tm](https://www.tcl.tk/man/tcl/TclCmd/tm.htm).
#'
#' Alternatively there is an install option you can use as well. 
#' Try `tclsh shistory.tcl --install` which should perform the procedure described above automatically. 
#' This requires eventually the setting of an environment variables if you have no write access to all 
#' of your module paths. For instance on my computer I have the following entry in my `.bashrc`
#'
#' ```
#' export TCL8_6_TM_PATH=/home/groth/.local/lib/tcl8.6
#' ```
#' 
#' If I execute `tclsh shistory.tcl --install` the file `shistory.tcl` will be copied to <br/>
#' `/home/groth/.local/lib/tcl8.6/dgtools/shistory-0.1.tm` and is thereafter available for a<br/> 
#' `package require dgtools::shistory`.
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:

#' ```
#' $ tclsh shistory.tcl --man
#' ```
#'
#' The output of this command can be used to create a markdown document for conversion into a markdown 
#' document that can be converted thereafter into a html or pdf document. If, for instance, you have pandoc installed you could execute the following commands:
#'
#' ```
#' tclsh ../shistory.tcl --man > shistory.md
#' pandoc -i shistory.md -s -o shistory.html
#' pandoc -i shistory.md -s -o shistory.tex
#' pdflatex shistory.tex
#' ```
#' 
#' ## <a name='todo'>TODO</a>
#'
#' * probably as usually more documentation
#' * github url for putting the code
#'
#' ## <a name='author'>AUTHOR</a>
#'
#' The **shistory** snit type was written Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' dgtools:shistory package - data structure, a list of text entries 
#' which can be navigated as history, version __PKGVERSION__.
#'
#' Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
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

if {[info exists argv0] && $argv0 eq [info script] && [regexp {shistory} $argv0]} {
    set dpath dgtools
    set pfile [file rootname [file tail [info script]]]
    package require dgtools::dgtutils
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgtools::getVersion [info script]]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::test history-1.1 {
            Starting a history
        } -body {
            set sh [::dgtools::shistory %AUTO% -home h]
            return [$sh home]
        } -result {h}
        tcltest::test history-1.2 {
            insert a value
        } -body {
            $sh insert a
            return [$sh current]
        } -result {a}
        tcltest::test history-1.3 {
            insert a value repeated
        } -body {
            $sh insert a
            $sh insert a
            $sh insert a
            llength [$sh getHistory]
        } -result {1}
        tcltest::test history-1.4 {
            can back with 1 item
        } -body {
             $sh canBackward
        } -result {false}
        tcltest::test history-1.5 {
            can back with 2 items
        } -body {
            $sh insert b
            $sh canBackward
        } -result {true}
        tcltest::test history-1.6 {
            can forward at the end?
        } -body {
            $sh canForward
        } -result {false}
        tcltest::test history-1.7 {
            can forward if going back?
        } -body {
            $sh back
            $sh canForward
        } -result {true}
        tcltest::test history-1.8 {
            insert in the middle
        } -body {
            $sh insert c
            $sh insert c
            $sh getHistory
        } -result {a c b}
        tcltest::test history-1.9 {
            check first
        } -body {
            $sh first
        } -result {a}
        tcltest::test history-1.10 {
            canBackward at first
        } -body {
            $sh canBackward
        } -result {false}
        tcltest::test history-1.11 {
            canForward at first
        } -body {
            $sh canForward
        } -result {true}
        tcltest::test history-1.12 {
            canForward at end
        } -body {
            $sh last
            $sh canForward
        } -result {false}
        tcltest::test history-1.13 {
            canBackward at last
        } -body {
            $sh canBackward
        } -result {true}
        tcltest::cleanupTests
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgtools::install [info script]
    } else {
        puts "\n    -------------------------------------"
        puts "     The dgtools::[file rootname [file tail [info script]]] package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe dgtools::[file rootname [file tail [info script]]] package provides a list with text entries which can used as" 
        puts "history data structure for programmers of the Tcl/Tk Programming language"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install shistory as Tcl module"        
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
