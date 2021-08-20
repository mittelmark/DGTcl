##############################################################################
#  Author        : Dr. Detlef Groth
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Oct 28 08:57:22 2019
#  Last Modified : <200412.1902>
#
#  Description	 : Helper functions for dgw-widget source files for extracting
#                  manual pages and installation of Tcl files as Tcl modules.
#
#  History       : 2019-10-28 version 0.0
#	
##############################################################################
#
# dgwutil.tcl - generic utility functions for dgw widget library.
#
# Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
# 
# This library is free software; you can use, modify, and redistribute it
# for any purpose, provided that existing copyright notices are retained
# in all copies and that this notice is included verbatim in any
# distributions.
# 
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
##############################################################################

package provide dgw::dgwutils 0.3
namespace eval dgw {
    variable htmltemplate {
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: ; script-src 'self' 'nonce-d717cfb5d902616b7024920ae20346a8494f7832145c90e0' ; style-src 'self' 'unsafe-inline'" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="title" content="$document(title)">
<meta name="author" content="$document(author)">
<title>$document(title)</title>
<style>
body {
    margin-left: 5%; margin-right: 5%;
    font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
}
pre {
padding-top:	1ex;
padding-bottom:	1ex;
padding-left:	2ex;
padding-right:	1ex;
width:		100%;
color: 		black;
background: 	#ffefdf;
border-top:        1px solid #6A6A6A;
border-bottom:     1px solid #6A6A6A;

font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
}
pre.synopsis {
    background: #ddefff;
}

code {
    font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
}

h1 {
font-family:	sans-serif;
font-size:	120%;
background: 	transparent;
text-align:	center;
}
h3 {
font-family:	sans-serif;
font-size:	110%;
background: 	transparent;
text-align:	center;
}
h2 {
margin-top: 	1em;
font-family:	sans-serif;
font-size:	110%;
color:		#005A9C;
text-align:	left;
background-color:  #eeeeee;
padding: 0.4em;

}
</style>
</head>
<body>
<div class="title"><h1>$document(title)</h1></div>
<div class="author"><h3>$document(author)</h3></div>
<div class="date"><h3>$document(date)</h3></div>
}
} 


proc dgw::displayCode {fname} {
    destroy .
    set filename $fname
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set flag false
        while {[gets $infh line] >= 0} {
            # Process line
            if {[regexp {^\s+# DEMO START} $line]} {
                set flag true
            } elseif {[regexp {^\s+# DEMO END} $line]} {
                break
            } elseif {$flag} {
                puts [string range $line 6 end]
            }
            
        }
        close $infh
    }
}

proc dgw::getVersion {fname} {
    set basename [file rootname [file tail $fname]]
    return [package present dgw::$basename]

}
proc dgw::runExample {fname {eval true} {extext ""}} {
    set filename $fname
    set example false
    set excode false
    set code ""
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        while {[gets $infh line] >= 0} {
            # Process line
            if {$extext eq "" && [regexp -nocase {^\s*#'\s+#{2,3}\s.+Example} $line]} {
                set example true
            } elseif {$extext ne "" && [regexp -nocase "^\\s*#'.*\\s# demo: $extext" $line]} {
                set excode true
            } elseif {$example && [regexp {^\s*#'\s+>?\s*```} $line]} {
                set example false
                set excode true
            } elseif {$excode && [regexp {^\s*#'\s+>?\s*```} $line]} {
                if {$eval} {
                    namespace eval :: $code
                } else {
                    return $code
                }
                break
                # eval code
            } elseif {$excode && [regexp {^\s*#'\s(.+)} $line -> c]} {
                append code "$c\n"
            }
        }
        close $infh
    }
    return $code
}

proc dgw::manual {mode filename} {
    variable htmltemplate
    destroy .
    set basename [file tail [file rootname $filename]]
    set version [package provide dgw::$basename]
    set markdown ""
    set dmeths [dict create]
    set methods false
    if {$mode eq "--html"} {
        if {[package version Markdown] eq ""} {
            error "Error: For html mode you need package Markdown from tcllib. \nDownload and install tcllib from http://core.tcl.tk"
        } else {
            package require Markdown   
        }
    }
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set flag false
        while {[gets $infh line] >= 0} {
            if {$mode eq "--license"} {
                if {[regexp {^# LICENSE START} $line]} {
                    set flag true
                    continue
                } elseif {$flag && [regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
                    if [catch {open $include r} iinfh] {
                        puts stderr "Cannot open $filename: $include"
                        exit 0
                    } else {
                        while {[gets $iinfh iline] >= 0} {
                            # Process line
                            set md $iline
                            set md [regsub -all {<.+?>} $md ""]
                            set md [regsub -all {^\s*## (.+)} $md "\\1\n[string repeat - 15]"]
                            set md [regsub -all {__PKGNAME__} $md dgw::$basename]
                            set md [regsub -all {__BASENAME__} $md $basename]                        
                            set md [regsub -all {__PKGVERSION__} $md $version]
                            set md [regsub -all {__DATE__} $md [clock format [clock seconds] -format "%Y-%m-%d"]] 
                            puts "$md"
                        }
                        close $iinfh
                    }
                } elseif {$flag && [regexp {^# LICENSE END} $line]} {
                    puts ""
                    break
                } elseif {$flag} {
                    set line [regsub -all {__PKGNAME__} $line dgw::$basename]
                    set line [regsub -all {__BASENAME__} $line $basename]                        
                    set line [regsub -all {__PKGVERSION__} $line $version]
                    set line [regsub -all {__DATE__} $line [clock format [clock seconds] -format "%Y-%m-%d"]]
                    puts [string range $line 2 end]
                }
            } else {
                if {[regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
                    puts stderr "including $include"
                    if [catch {open $include r} iinfh] {
                        puts stderr "Cannot open $filename: $include"
                        exit 0
                    } else {
                        while {[gets $iinfh iline] >= 0} {
                            # Process line
                            set md "$iline"
                            set md [regsub -all {__PKGNAME__} $md dgw::$basename]
                            set md [regsub -all {__BASENAME__} $md $basename]                        
                            set md [regsub -all {__PKGVERSION__} $md $version]
                            set md [regsub -all {__DATE__} $md [clock format [clock seconds] -format "%Y-%m-%d"]] 
                            if {$mode eq "--man"} {
                                puts "$md" 
                            } else {
                                append markdown "$md\n"
                            }
                        }
                        close $iinfh
                    }
                } elseif {[regexp {^\s*#' ?(.*)} $line -> md]} {
                    set md [regsub -all {__PKGNAME__} $md dgw::$basename]
                    set md [regsub -all {__BASENAME__} $md $basename]                        
                    set md [regsub -all {__PKGVERSION__} $md $version]
                    set md [regsub -all {__DATE__} $md [clock format [clock seconds] -format "%Y-%m-%d"]] 
                    # sorting code start: collect and sort methods alphabetically
                    if {$methods && [regexp {^## <a\s+name} $md]} {
                        set methods false
                        foreach key [lsort [dict keys $dmeths]] {
                            if {[dict get $dmeths $key] ne ""} {
                                if {$mode eq "--man"} {
                                    puts [dict get $dmeths $key]
                                } else {
                                    append markdown [dict get $dmeths $key]
                                }
                            }
                        }
                                                        
                    }
                    if {[regexp {<a\s+name='(methods|options)'>} $md]} {
                        # clean up old keys, can't use dict unset for whatever reasons
                        foreach key [lsort [dict keys $dmeths]] {
                            dict set dmeths $key ""
                        }
                        set methods true
                    }
                    if {$methods && [regexp {[*_]{2}([-a-zA-Z0-9_]+?)[*_]{2}} $md -> meth]} {
                        set dkey $meth
                        dict set dmeths $dkey "$md\n"
                        continue
                        
                    } elseif {$methods && [info exists dkey]} {
                        set ometh [dict get $dmeths $dkey]
                        dict set dmeths $dkey "$ometh$md\n"
                        continue
                    }
                    # sorting code end
                    if {$mode eq "--man"} {
                        puts "$md"  ;# fix
                    } else {
                        append markdown "$md\n"
                    }
                }
            }
            
        }
        close $infh
        if {$mode eq "--html" || $mode eq "--markdown"} {
            set titleflag false
            array set document [list title "Documentation" author "NN" date  [clock format [clock seconds] -format "%Y-%m-%d"]]
            set mdhtml ""
            set indent ""
            set header $htmltemplate
            foreach line [split $markdown "\n"] {
                if {$titleflag && [regexp {^---} $line]} {
                    set titleflag false
                    set header [subst -nobackslashes -nocommands $header]
                } elseif {$titleflag} {
                    if {[regexp {^([a-z]+): +(.+)} $line -> key value]} {
                        set document($key) $value
                    }
                } elseif {[regexp {^---} $line]} {
                    set titleflag true
                } elseif {[regexp {^```} $line] && $indent eq ""} {
                    append mdhtml "\n"
                    set indent "    "
                } elseif {[regexp {^```} $line] && $indent eq "    "} {
                    set indent ""
                    append mdhtml "\n"
                } else {
                    append mdhtml "$indent$line\n"
                }
            }
            if {$mode eq "--html"} {
                set htm [Markdown::convert $mdhtml]
                set html ""
                # synopsis fix as in tcllib with blue background
                set synopsis false
                foreach line [split $htm "\n"] {
                    if {[regexp {^<h2>} $line]} {
                        set synopsis false
                    } 
                    if {[regexp -nocase {^<h2>.*SYNOPSIS} $line]} {
                        set synopsis true
                    }
                    if {$synopsis && [regexp {<pre>} $line]} {
                        set line [regsub {<pre>} $line "<pre class='synopsis'>"]
                    }
                    append html "$line\n"
                }
                set out [open [file rootname $filename].html w 0644]
                puts $out $header
                puts $out $html
                puts $out "</body>\n</html>"
                close $out
                puts stderr "Success: file [file rootname $filename].html was written!"
            } else {
                puts $mdhtml
            }
                
        }
    }
}

proc dgw::install {filename} {
    destroy .
    set dpath dgw
    set pfile [file rootname [file tail $filename]]
    set done false
    foreach dir [tcl::tm::path list] {
        if {[file writable $dir]} {
            puts "\nWriteable Tcl module path is: $dir"
            set ddir [file join $dir $dpath]
            if {![file exists $ddir]} {
                file mkdir $ddir
            }
            set fname [file join $dir $dpath $pfile-[package provide ${dpath}::$pfile].tm]
            file copy -force [info script] $fname
            puts "Done: ${dpath}::$pfile Tcl module installed to ${fname}!\n"
            puts "To test your installation try:\n"
            puts "\$ tclsh"
            puts "% package require ${dpath}::$pfile\n"
            
            set done true
            break
        }
    }  
    if {!$done} {
        puts "Error: No writable Tcl module path found!"
        puts "Create an environment variable TCL8_6_TM_PATH pointing to a directory where you can write files in."
        puts "In Linux for a bash shell you can do this for instance with: export TCL8_6_TM_PATH=/home/user/.local/lib/tcl8.6"
        puts "To make this permanent add this line to your .bashrc file!"
    }
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp dgwutils $argv0]} {
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {
        puts [package provide dgw::dgwutils]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--html"} {
        set out [open dgwutils.html w 0600]
        puts $out "dgw::dgwutils [package provide dgw::dgwutils] - private package"
        close $out
    }

    # do main task
}

