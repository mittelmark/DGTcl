#' ---
#' documentclass: scrartcl
#' title: dgtools::repo __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' ---
#' 
#' ## NAME
#'
#' **dgtools::repo** - package and command line application for installation of tcl packages directly from hithubn and chiselapp
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' Usage as package:

#' ```
#' package require tls
#' package require json
#' package require dgtools::repo
#' namespace import ::dgtools::repo
#' repo import github user repository folder
#' repo import chiselapp user repository folder
#' repo download github url folder
#' repo download chiselapp url folder
#' ```
#'
#' Usage as command line application:
#'
#' ```
#' tclsh repo.tcl "https://chiselapp.com/user/dgroth/repository/tclcode/dir?ci=c50f458ca23f7ae5&name=dgw" dgw
#' tclsh repo.tcl https://github.com/tcltk/tcllib/tree/master/modules/des
#' ```
#' 
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **dgtools::repo** - is a package for directly downloading folders and packages 
#' from github and chiselapp repositories. I is useful if multiple packages are 
#' available within a certain repository  and the users only like to install one 
#' or a few of them. Further a command line interface is available to download specific directories from larger repositories.

#' ## <a name='command'>COMMAND</a>
#'
#' There are three sub commands available, *import* and *update* should be used to retrieve tcl packages and install them in a parallel directory to the actual script or the last directory given in auto_path. *download* downloads a specific subfolder of a directory.
#' 
#' **dgtools::repo** *provider cmd user repo directory*
#' 
#' Downloads and installs the given directory as a tcl package in parallel to the actual script. As package name the last part of the directory name is used. The arguments are explained below:
#' 
#' > - *provider*:  either github or chiselapp currently
#'   - *cmd*: either `import` which checks if the package was already download and only if not installes it, or `update` which will redo the download and possibly overwrite the current package.
#'   - *user*: the user id of the repository maintainer such as "tcltk" for example
#'   - *repo*: the repository name such as "tcllib" for example
#'   - *directory*: the relative folder within the repository such as "modules/snit" for example
#'  
#' **dgtools::repo** *provider download url directory*
#' 
#' Downloads a specific (sub)folder from a repository of github or chiselapp.
#' 
#' > - *provider* either github or chiselapp
#'   - *url* the url which is visible in standard view 
#'   - *directory* in which the repository folder should be stored locally

package require tls
package require http
::http::register https 443 ::tls::socket
namespace eval ::dgtools { 
    variable libdir [file normalize [file join [file dirname [info script]] ..]]
    if {[lsearch $::auto_path $libdir] == -1} {
        lappend auto_path $libdir
    }
    namespace export repo
}
package require json
package provide dgtools::repo 0.1

proc dgtools::repo {site cmd args} {
    if {$cmd eq "download"} {
        # args url folder
        ${site}::download [lindex $args 0] [lindex $args 1] false
    } else {
        # args: $owner $repo $dir
        ${site}::${site} $cmd [lindex $args 0] [lindex $args 1] [lindex $args 2]
    }
}

namespace eval ::github { } 

proc ::github::github {cmd owner repo dir} {
    variable libdir
    set url https://api.github.com/repos/$owner/$repo/contents/$dir
    #puts $url
    #puts [lindex $d 1]
    set folder [file join [lindex $::auto_path end] [file tail $dir]]
    if {$cmd eq "import" && [file exists $folder]} {
        return
    } elseif {$cmd eq "update" && [file exists $folder]} {
        file delete $folder
    }
    download $url $folder
}

proc ::github::download {url folder {debug true}} {
    if {![file exists $folder]} {
        file mkdir $folder
    }
    if {[regexp {https://github.com/([^/]+)/([^/]+)/tree/master/(.+)} $url -> owner repo gfolder]} {
        set url https://api.github.com/repos/$owner/$repo/contents/$gfolder
    } 
    set data [http::data [http::geturl $url]]
    set d [json::json2dict $data]
    set l [llength $d]
    set files [list]
    for {set i 0} {$i < $l} {incr i 1} {
        set dic [dict create {*}[lindex $d $i]]
        set file [dict get $dic download_url]
        set type [dict get $dic type]
        if {$file eq "null" &&  $type eq "dir"} {
            set file [dict get $dic url]
            set file [regsub {.ref=master} $file ""]
        }
        lappend files [list $type $file]
    }

    # TODO subfolders (done)
    foreach item $files {
        set file [lindex $item 1]
        set type [lindex $item 0]
        if {$debug} {
            puts "fetching $file"
        }
        if {$type eq "file"} {
            set fname [file tail $file]
            set fname [file join $folder $fname]
            set f [open $fname w]
            fconfigure $f -translation binary
            set tok [http::geturl $file -channel $f]
            set Stat [::http::status $tok]
            flush $f
            close $f
            http::cleanup $tok
        } else {
            if {$debug} {
                puts "fetch new folder $file ..."
            }
            set nfolder [file join $folder [file tail $file]]
            download $file $nfolder $debug
        }
    }
    
}

namespace eval ::chiselapp { }

proc ::chiselapp::download {url folder {debug true}} {
    if {[regexp {https://chiselapp.com/user/.+repository.+dir\?.+} $url]} {
        if {![regexp {/json/} $url]} {
            set url [regsub {/dir\?} $url {/json/dir?}]
        }
    } else {
        error "Unkown url type $url"
    }
    puts $url
    if {![file exists $folder]} {
        file mkdir $folder
    }
    set data [http::data [http::geturl $url]]
    set d [json::json2dict $data]
    #puts [dict get $d payload entries]
    foreach entry [dict get $d payload entries] {
        set e [dict create {*}$entry]
        if {[dict exists $e isDir] && [dict get $e isDir]} {
            ::chiselapp::download $url/[dict get $e name] $folder/[dict get $e name]
        } else {
            set raw [regsub {(.+?/repository/[^/]+)/json.+$} $url "\\1"]
            set path $raw[dict get $e downloadPath]
            set fname [file join $folder [dict get $e name]]
            if {$debug} {
                puts "fetching name: [dict get $e name] path=$path"
            }
            set f [open $fname w]
            fconfigure $f -translation binary
            set tok [http::geturl $path -channel $f]
            set Stat [::http::status $tok]
            flush $f
            close $f
            http::cleanup $tok

        }
    }
}
proc ::chiselapp::chiselapp {cmd user repo dir} {
    set url https://chiselapp.com/user/$user/repository/$repo/json/dir?ci=tip&name=$dir
    # https://chiselapp.com/user/dgroth/repository/tclcode/json/dir?ci=tip&name=dgtools
    set folder [file join [lindex $::auto_path end] [file tail $dir]]
    if {$cmd eq "import" && [file exists $folder]} {
        return
    } elseif {$cmd eq "update" && [file exists $folder]} {
        file delete $folder
    }
    
    download $url $folder
               
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp {repo} $argv0]} {
    if {false} {
        namespace import ::dgtools::repo
        repo github import tcltk tcllib modules/snit
        repo github import tcltk tklib modules/tablelist
        repo chiselapp import dgroth tclcode tmdoc
        puts [package require snit]
        puts [package require tablelist]
        puts [package require tmdoc]
        repo chiselapp download "https://chiselapp.com/user/dgroth/repository/tclcode/dir?ci=c50f458ca23f7ae5&name=dgw" dgw2
        repo github download https://github.com/tcltk/tklib/tree/master/modules/tablelist  tlist2
        exit 0
    }
    set dpath dgtools
    set pfile [file rootname [file tail [info script]]]
    package require dgtools::dgtutils
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgtools::getVersion [info script]]
        exit 0
    } elseif {[lsearch -regexp $argv -test] >= 0} {
        set argv [list]
        package require tcltest
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        exit 0
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
        exit 0
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgtools::install [info script]
        exit 0
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgtools::install [info script]
        exit 0
    } elseif {[lsearch -regexp $argv --help] >= 0} {
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides command line parsing for Tcl applications similar to Pythons argparse."
        puts ""
        puts "Usage: [info script] ?option? url ?directory?\n\n     if directory is not given, current directory is assumed for placing files and folders\n"
        puts "    Valid options are:\n"
        puts "        --silent  : supress download messages"
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

        exit 0
    }
    set debug true
    set idx [lsearch -regexp $argv -silent]
    if {$idx > -1} {
        set debug false
    }
    set argv [lsearch -all -inline -regexp -not $argv -silent] 
    if {[llength $argv] == 0} {
        puts "Usage: $argv0 ?--silent? github-url ?directory?\nif directory is not given, current directory is assumed"
        exit 0
    } 
    set url [lindex $argv 0]
    # removing trailing slash
    set url [regsub {/$} $url ""]
    set folder [file tail $url]
    if {[llength $argv] > 1} {
        set folder [lindex $argv 1]
    }
    if {[regexp {https://github.com/([^/]+)/([^/]+)/tree/master/(.+)} $url -> owner repo gfolder]} {
        set url https://api.github.com/repos/$owner/$repo/contents/$gfolder
        ::github::download $url $folder $debug
    } elseif {[regexp {https://chiselapp.com/user/.+repository.+dir\?.+} $url]} {
        set url [regsub {/dir\?} $url {/json/dir?}]
        ::chiselapp::download $url $folder $debug
    } else {
        puts stderr "Unkown url type $url"
        exit 0
    }
}

#' 
#' ## <a name='example'>EXAMPLE</a>
#' 
#' Below an example which install the snit package from tcllib 
#' and the dgw package from
#' the chiselapp tclcode repository of dgroth.
#' 
#' ```
#' package require dgtools::repo
#' namespace import dgtool::repo
#' repo github import tcltk tcllib modules/snit
#' repo chiselapp import dgroth tclcode dgw
#' package require snit
#' package require dgw
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy, you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the Tcl tls package  and the json package from  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
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
#' - dgw - package homepage [http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#'
#' ## <a name='todo'>TODO</a>
#'
#' * tests
#' * github repo as automatic copy of the chiselapp repo
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **dgtools::__BASENAME__** package type was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
# LICENSE START
#' 
#' package  __PKGNAME__, version __PKGVERSION__.
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
