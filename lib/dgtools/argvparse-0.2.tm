##############################################################################
#  Created By    : Dr. Detlef Groth
#  Created       : Thu Nov 7 11:50:14 2019
#  Last Modified : <200105.0946>
#
#  Description	 : Command line parsing package similar to Pythons argparse library.
#
#  History       : 2019-11-07 code started
#                  2019-11-08 version 0.1 with documentation
#	
##############################################################################
#
#  Copyright (c) 2019 Dr. Detlef Groth.
# 
#  License      : MIT see below
##############################################################################
#' ---
#' documentclass: scrartcl
#' title: dgtools::argvparse __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgtools::argvparse** - command line parsing package similar to Pythons argparse library.
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
#'  - [DEMO](#demo)
#'  - [TEST](#test)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require snit
#' package require dgtools::argvparse
#' namespace import ::dgtools::argvparse
#' argvparse cmdName options
#' cmdName cget option
#' cmdName configure option value
#' cmdName argument shortopt longopt description ?key ...?
#' cmdName parse argv
#' cmdName usage
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **dgtools::argvparse** - is a snit type for parsing command line arguments for Tcl applications in the spirit of Pythons argparse library. Parsing command line options for this package is a three step process. 
#'  First create the parser object with application specific options, like application name and author, 
#'  in the second step define one or more arguments using the *argument* method for each option and at last
#'  use the parse function for parsing the argv array.

#' ## <a name='command'>COMMAND</a>
#'
#' **dgtools::argvparse** *cmdName ?options?*
#' 
#' > Creates and configures the **dgtools::argvparse**  type using the given command name and options.
#'  
#' ## <a name='options'>COMMAND OPTIONS</a>
#' 

package require snit
package provide dgtools::argvparse 0.2

namespace eval dgtools {}

# private type should be not used externally

snit::type ::dgtools::argument {
    option -boolean false
    option -shortname ""
    option -longname ""
    option -description ""
    option -required false
    option -default ""
    option -script ""
    option -type ""
    constructor {args} {
        $self configurelist $args    
    }
    method isbool {} {
        return $options(-boolean)
    }
    method isscript {} {
        if {$options(-script) ne ""} {
            return true
        } else {
            return false
        }
    }
    method required {} {
        return $options(-required)
    }
    onconfigure -boolean value {
        if {$options(-default) eq ""} {
            set options(-default) false
        }
        set options(-boolean) $value
    }
    onconfigure -type value {
        if {$value eq "boolean"} {
            if {$options(-default) eq ""} {
                set options(-default) false
            }
            set options(-boolean) true
        }
        set options(-type) $value
    }
        

}
snit::type ::dgtools::argvparse {
    #' __-appname__ _string_
    #'
    #' > Will be used as the application name shown in the standard help page.
    #' 
    option -appname -default ""
    #' __-author__ _string_
    #'
    #' > Will be used as the author name shown in the standard help page.
    #' 
    option -author -default ""
    #' __-description__ _string_
    #'
    #' > Will be used as description string shown in the standard help page.
    #' 
    option -description -default ""
    #' __-usage__ _string_
    #'
    #' > Will be used as the usage string without the scriptname shown in the standard help page.
    #' 
    option -usage -default ""
    variable arguments 
    variable sopts
    variable lopts
    #variable descriptions
    constructor {args} {
        $self configurelist $args    
        array set arguments [list]
        $self argument -h --help "(show this help page)" -boolean true -required false -default false -script __usage__

    }
    #' ## <a name='commands'>TYPE COMMANDS</a>
    #' 
    #' The **argvparse** type supports the following commands to parse command line arguments:    
    #'

    #' *cmdName* **argument** *shortopt longopt description ?key value ...?*
    #' 
    #' > Installs a command line option using the given short- and longoption flags and the option description.
    #'   The latter will be used in the standard help message. The following key-value pairs are supported:
    #' 
    #' * *-boolean true|false* - indication if this is a boolean flag.
    #' * *-default value* - sets a default value if the argument is not given on the command line.
    #' * *-required true|false* - indication if this is a required i.e. non-optional argument.
    #' * *-script  procname* - the script to be executed if this option is given on the command line. The parsed argument list is appended as argument to the procedure automatically.
    #' * *-type typename* - the type of the argument, can be one of the known types for the Tcl command *string is* such as integer, ascii, boolean etc.
    method argument {args} {
        # syntax short long description ?-key value ...?
        # possible keys are -required, -boolean, -script -default
        set sopt [lindex $args 0]
        set lopt [lindex $args 1]            
        set desc [lindex $args 2]
        set arguments($sopt) [argument %AUTO% -shortname $sopt -longname $lopt -description $desc]
        set arguments($lopt) [argument %AUTO% -shortname $sopt -longname $lopt -description $desc]
                
                
        set args [lrange $args 3 end]
        foreach {key val} $args {
            $arguments($sopt) configure $key $val
            $arguments($lopt) configure $key $val
            if {$key eq "-script"} {
                $arguments($sopt) configure -boolean true
                $arguments($lopt) configure -boolean true
                $arguments($sopt) configure -default false
                $arguments($lopt) configure -default false
            }
                
        }
    }
    #'
    #' *cmdName* **cget** *option*
    #' 
    #' > Retrieves the given option value for the argvparse type. See [options](#options) for a list of available options.
    #'
    #' *cmdName* **configure** *option value ?option value ...?*
    #' 
    #' > Configures the given option for the argvparse type. See [options](#options) for a list of available options.
    #'
    #' *cmdName* **parse** *argv*
    #' 
    #' > Does the actual parsing of the argv array. Returns the parsing result as a key-value list.
    #'
    method parse {argv} {
        array set appargs [list]
        foreach key [array names arguments] {
            set appargs($key) [$arguments($key) cget -default]
        }
                
        while {[llength $argv] > 0} {
            set key [lindex $argv 0]
            if {[string length $key] == 2} {
                set oopt [$arguments($key) cget -longname]
            } else {
                set oopt [$arguments($key) cget -shortname]
            }
            set argv [lrange $argv 1 end]
            if {![info exists arguments($key)]} {
                $self usage "Error: Unknown argument $key\n"
            } else {
                if {[$arguments($key) isbool]} {
                    if {[lindex $argv 0] eq "true" || [lindex $argv 0] eq "false"} {
                        set appargs($key) [lindex $argv 0]
                        set appargs($oopt) [lindex $argv 0]
                        set argv [lrange $argv 1 end]
                    } else {
                        set appargs($key) true
                        set appargs($oopt) true
                    }
                } else {
                    set appargs($key) [lindex $argv 0]
                    set appargs($oopt) [lindex $argv 0]
                    set argv [lrange $argv 1 end]
                }
            }
        }
        # check required
        foreach key [array names arguments] {
            if {[$arguments($key) required] && ![info exists appargs($key)]} {
                $self usage "Error: Argument $key required but not given!\n"
                return false
            }
        }
        # check type
        foreach key [array names arguments] {
            set t [$arguments($key) cget -type]
            if {$t eq "" || ![info exists appargs($key)]} {
                continue
            }
            if {![string is $t $appargs($key)]} {
                $self usage "Error: Wrong type for $key given. Should be $t"
                return false
            }
        }
        
        # check help
        #parray appargs
        if {[info exists appargs(-h)] && $appargs(-h) ne "" && $appargs(-h)} {
            set cmd [$arguments(-h) cget -script]
            if {$cmd eq "__usage__"} {
                $self usage
            } else {
                $cmd
            }
            return true
        } else {
            # check if a proc needs to be executed
            set cmdex false
            foreach key [array names appargs -glob --*] {
                if {[$arguments($key) cget -script] ne "" && $appargs($key)} {
                    set cmd [$arguments($key) cget -script] 
                    {*}$cmd [array get appargs]
                    set cmdex true
                }
            }
            if {$cmdex} {
                return true
            }
        }
        return [array get appargs]

    }
    #' *cmdName* **usage** *?msg?*
    #' 
    #' > Standard usage message for the terminal if the user did not provide the correct
    #' command line arguments or if the user requests the help message using either the 
    #' with giving the short option *-h* or the long option *--help*.
    #'
    method usage {{msg ""}} {
        puts "$msg"
        set str [$self cget -appname]
        if {"[$self cget -author]" ne ""} {
            append str " - [$self cget -author]"
        }
        set str "[string repeat = [string length $str]]\n$str\n[string repeat = [string length $str]]"
        if {[$self cget -usage] ne ""} {
            append str "\nUsage: $::argv0 [$self cget -usage]\n"
        }
        puts $str
        set x 0
        foreach key [lsort [array names arguments -glob --*]] {
            set sopt [$arguments($key) cget -shortname]
            if {[$arguments($key) required]} {
                if {[incr x] == 1} {
                    puts "Mandatory arguments:"
                }
                puts " $sopt, $key [$arguments($key) cget -description]"
            } 
        }
        set x 0
        foreach key [lsort [array names arguments -glob --*]] {
            set sopt [$arguments($key) cget -shortname]
            if {![$arguments($key) required]} {
                if {[incr x] == 1} {
                    puts "Optional arguments:"
                }
                puts " $sopt, $key [$arguments($key) cget -description]"
            } 
        }
        
    }
}

namespace eval dgtools {
    namespace export argvparse
}
#' 
#' ## <a name='example'>EXAMPLE</a>
#' ```
#'  package require dgtools::argvparse
#'  # simulate: tclsh script.tcl --filename test.txt -v 1 -h
#'  # on the terminal by manually setting argv
#'  set argv [list --filename test.txt -v 1 -h]
#'  proc mproc {args} {
#'     puts "proc mproc is executed with args $args"
#'  }
#'  set ap [::dgtools::argvparse %AUTO% -appname "Test Application" \
#'          -author "Detlef Groth" -usage "-f filename ?-t -m -v number -h?"]
#'  $ap argument -f --filename "filename (input file)" -required true
#'  $ap argument -t --test "(test flag)" -boolean true 
#'  $ap argument -m --mproc "(execute procedure mproc)" -script mproc
#'  $ap argument -v --verbosity "number (specifying verbosity, values from 0 to 5)" \
#'                  -type integer -default 0
#'  set res [$ap parse $argv]
#' ```
#' If this script is executed it gives the following help message:
#'
#' ```
#' ===============================
#' Test Application - Detlef Groth
#' ===============================
#' Usage: argvparse.tcl -f filename ?-t -m -v number -h?
#' 
#' Mandatory arguments:
#'  -f, --filename filename (input file)
#' Optional arguments:
#'  -h, --help (show this help page)
#'  -m, --mproc (execute procedure mproc)
#'  -t, --test (test flag)
#'  -v, --verbosity number (specifying verbosity, values from 0 to 5)
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy, you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgtools* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgtools* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgtools/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose in the terminal.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --demo
#' ```
#'
#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --code
#' ```
#'
#' ## <a name='test'>TEST</a>
#'
#' Some tcltest's are embedded in the source file as well, to run those tests you should
#' execute the following comamnd line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --test
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
#' The output of this command can be used to feed a markdown processor for conversion into a man page, 
#' a html or a pdf document. If you have pandoc installed for instance, you could execute the following commands:
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
#' - dgtools - package homepage [http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#' - cmdline - tcllib package for parsing of command line options n the spirit of getopt [https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/cmdline/cmdline.md](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/cmdline/cmdline.md)
#' - argparse - parsing of procedure arguments in Tcl spirit [https://wiki.tcl-lang.org/page/argparse](https://wiki.tcl-lang.org/page/argparse)
#'
#' ## <a name='todo'>TODO</a>
#'
#' * more tests
#' * github url for putting the code
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** snit type was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
# LICENSE START
#' 
#' Command line parsing library __PKGNAME__, version __PKGVERSION__.
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

if {[info exists argv0] && $argv0 eq [info script]} {
    set dpath dgtools
    set pfile [file rootname [file tail [info script]]]
    source [file join [file dirname [info script]] dgtutils.tcl]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgtools::getVersion [info script]]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        # DEMO START
        set argv [list --filename test.txt -v 1 -h]
        proc mproc {args} {
            puts "proc mproc is executed with args $args"
        }
        proc mhelp {} {
            puts "own help command is executed"
        }
        set ap [::dgtools::argvparse %AUTO% -appname "Test Application" \
                -author "Detlef Groth" -usage "-f filename ?-t -m -v number -h?"]
        $ap argument -f --filename "filename (input file)" -required true
        $ap argument -t --test "(test flag)" -boolean true 
        $ap argument -m --mproc "(execute procedure mproc)" -script mproc
        $ap argument -v --verbosity "number (specifying verbosity, values from 0 to 5)" -type integer -default 0
        # overwrite existing standard help
        #$ap argument -h --help "execute function mproc" -script mhelp 
        puts [$ap parse $argv]
        # DEMO END
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        dgtools::displayCode [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test demo-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::test param-1.1 {
            executing the demo code
        } -body {
            set argv [list --filename test.txt]
            set ap [::dgtools::argvparse %AUTO% -appname "Test Application" -author "Detlef Groth"]
            $ap argument -f --filename "<input-filename>" -required true
            $ap argument -t --test "test flag" -boolean true 
            $ap argument -m --mproc "execute function mproc" -script mproc
            # overwrite existing standard help
            $ap argument -h --help "execute function mproc" -script mhelp 
            set results [$ap parse $argv]
        } -result {-h false -t false --test false -m false --help false -f test.txt --filename test.txt --mproc false}
        tcltest::test param-1.2 {
            check integer parameter
        } -body {
            set argv [list --filename test.txt -v 3]
            set ap [::dgtools::argvparse %AUTO% -appname "Test Application" -author "Detlef Groth"]
            $ap argument -f --filename "<input-filename>" -required true
            # overwrite existing standard help
            $ap argument -v --verbosity "number - set verbosity level" -type integer -default 0
            set d [dict create {*}[$ap parse $argv]]
            #parray results
            dict get $d -v
        } -result {3}
        tcltest::test param-1.3 {
            check wrong integer parameter
        } -body {
            set argv [list --filename test.txt -v dummy]
            set ap [::dgtools::argvparse %AUTO% -appname "Test Application" -author "Detlef Groth"]
            $ap argument -f --filename "<input-filename>" -required true
            # overwrite existing standard help
            $ap argument -v --verbosity "number - set verbosity level" -type integer -default 0
            set res [$ap parse $argv]
        } -result {false}
        tcltest::test param-1.4 {
            check flag
        } -body {
            #puts here
            set argv [list --filename test.txt -v 5 --test]
            set ap [::dgtools::argvparse %AUTO% -appname "Test Application" -author "Detlef Groth"]
            $ap argument -f --filename "<input-filename>" -required true
            # overwrite existing standard help
            $ap argument -v --verbosity "number - set verbosity level" -type integer -default 0
            $ap argument -t --test "    flag - set flag to true" -type boolean
            set res [dict create {*}[$ap parse $argv]]
            dict get $res -t
        } -result {true}
        tcltest::test param-1.5 {
            check flag
        } -body {
            set argv [list -v 5 --test]
            set ap [::dgtools::argvparse %AUTO% -appname "Test Application" -author "Detlef Groth"]
            $ap argument -f --filename "<input-filename>" -required true
            # overwrite existing standard help
            $ap argument -v --verbosity "number - set verbosity level" -type integer -default 0
            $ap argument -t --test "    flag - set flag to true" -boolean true
            set res [dict create {*}[$ap parse $argv]]
            #puts $res
            dict get $res -t
        } -result {true}
        tcltest::cleanupTests
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgtools::install [info script]
    } else {
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides command line parsing for Tcl applications similar to Pythons argparse."
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

