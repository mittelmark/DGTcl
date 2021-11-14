#!/usr/bin/env tclsh
##############################################################################
#
#  Author        : Dr. Detlef Groth
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Sep 7 17:58:32 2021
#  Last Modified : <211109.0055>
#
#  Description	 : Standalone deployment tool for Tcl apps using uncompressed tar archives.
#
#  Notes         : - tpack application code comes at the end
#                  - no extra package are required, tar package is embedded 
#
#  History       : 2021-09-10 - release 0.1  
#                  
#	
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#  License:      MIT
# 
##############################################################################

# tar.tcl -- take form tar.tcl from tcllib
#
#       Creating, extracting, and listing posix tar archives
#
# Copyright (c) 2004    Aaron Faupell <afaupell@users.sourceforge.net>
# Copyright (c) 2013    Andreas Kupries <andreas_kupries@users.sourceforge.net>
#                       (GNU tar @LongLink support).
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: tar.tcl,v 1.17 2012/09/11 17:22:24 andreas_kupries Exp $

package require Tcl 8.4
package provide tar 0.11

namespace eval ::tar {}

proc ::tar::parseOpts {acc opts} {
    array set flags $acc
    foreach {x y} $acc {upvar $x $x}
    
    set len [llength $opts]
    set i 0
    while {$i < $len} {
        set name [string trimleft [lindex $opts $i] -]
        if {![info exists flags($name)]} {
	    return -errorcode {TAR INVALID OPTION} \
		-code error "unknown option \"$name\""
	}
        if {$flags($name) == 1} {
            set $name [lindex $opts [expr {$i + 1}]]
            incr i $flags($name)
        } elseif {$flags($name) > 1} {
            set $name [lrange $opts [expr {$i + 1}] [expr {$i + $flags($name)}]]
            incr i $flags($name)
        } else {
            set $name 1
        }
        incr i
    }
}

proc ::tar::pad {size} {
    set pad [expr {512 - ($size % 512)}]
    if {$pad == 512} {return 0}
    return $pad
}

proc ::tar::seekorskip {ch off wh} {
    if {[tell $ch] < 0} {
	if {$wh!="current"} {
	    return -code error -errorcode [list TAR INVALID WHENCE $wh] \
		"WHENCE=$wh not supported on non-seekable channel $ch"
	}
	skip $ch $off
	return
    }
    seek $ch $off $wh
    return
}

proc ::tar::skip {ch skipover} {
    while {$skipover > 0} {
	set requested $skipover

	# Limit individual skips to 64K, as a compromise between speed
	# of skipping (Number of read requests), and memory usage
	# (Note how skipped block is read into memory!). While the
	# read data is immediately discarded it still generates memory
	# allocation traffic, gets copied, etc. Trying to skip the
	# block in one go without the limit may cause us to run out of
	# (virtual) memory, or just induce swapping, for nothing.

	if {$requested > 65536} {
	    set requested 65536
	}

	set skipped [string length [read $ch $requested]]

	# Stop in short read into the end of the file.
	if {!$skipped && [eof $ch]} break

	# Keep track of how much is (not) skipped yet.
	incr skipover -$skipped
    }
    return
}

proc ::tar::readHeader {data} {
    binary scan $data a100a8a8a8a12a12a8a1a100a6a2a32a32a8a8a155 \
                      name mode uid gid size mtime cksum type \
                      linkname magic version uname gname devmajor devminor prefix

    foreach x {name type linkname} {
        set $x [string trim [set $x] "\x00"]
    }
    foreach x {uid gid size mtime cksum} {
        set $x [format %d 0[string trim [set $x] " \x00"]]
    }
    set mode [string trim $mode " \x00"]

    if {$magic == "ustar "} {
        # gnu tar
        # not fully supported
        foreach x {uname gname prefix} {
            set $x [string trim [set $x] "\x00"]
        }
        foreach x {devmajor devminor} {
            set $x [format %d 0[string trim [set $x] " \x00"]]
        }
    } elseif {$magic == "ustar\x00"} {
        # posix tar
        foreach x {uname gname prefix} {
            set $x [string trim [set $x] "\x00"]
        }
        foreach x {devmajor devminor} {
            set $x [format %d 0[string trim [set $x] " \x00"]]
        }
    } else {
        # old style tar
        foreach x {uname gname devmajor devminor prefix} { set $x {} }
        if {$type == ""} {
            if {[string match */ $name]} {
                set type 5
            } else {
                set type 0
            }
        }
    }

    return [list name $name mode $mode uid $uid gid $gid size $size mtime $mtime \
                 cksum $cksum type $type linkname $linkname magic $magic \
                 version $version uname $uname gname $gname devmajor $devmajor \
                 devminor $devminor prefix $prefix]
}

proc ::tar::contents {file args} {
    set chan 0
    parseOpts {chan 0} $args
    if {$chan} {
	set fh $file
    } else {
	set fh [::open $file]
	fconfigure $fh -encoding binary -translation lf -eofchar {}
    }
    set ret {}
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
	HandleLongLink $fh header
        if {$header(name) == ""} break
	if {$header(prefix) != ""} {append header(prefix) /}
        lappend ret $header(prefix)$header(name)
        seekorskip $fh [expr {$header(size) + [pad $header(size)]}] current
    }
    if {!$chan} {
	close $fh
    }
    return $ret
}

proc ::tar::stat {tar {file {}} args} {
    set chan 0
    parseOpts {chan 0} $args
    if {$chan} {
	set fh $tar
    } else {
	set fh [::open $tar]
	fconfigure $fh -encoding binary -translation lf -eofchar {}
    }
    set ret {}
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
	HandleLongLink $fh header
        if {$header(name) == ""} break
	if {$header(prefix) != ""} {append header(prefix) /}
        seekorskip $fh [expr {$header(size) + [pad $header(size)]}] current
        if {$file != "" && "$header(prefix)$header(name)" != $file} {continue}
        set header(type) [string map {0 file 5 directory 3 characterSpecial 4 blockSpecial 6 fifo 2 link} $header(type)]
        set header(mode) [string range $header(mode) 2 end]
        lappend ret $header(prefix)$header(name) [list mode $header(mode) uid $header(uid) gid $header(gid) \
                    size $header(size) mtime $header(mtime) type $header(type) linkname $header(linkname) \
                    uname $header(uname) gname $header(gname) devmajor $header(devmajor) devminor $header(devminor)]
    }
    if {!$chan} {
	close $fh
    }
    return $ret
}

proc ::tar::get {tar file args} {
    set chan 0
    parseOpts {chan 0} $args
    if {$chan} {
	set fh $tar
    } else {
	set fh [::open $tar]
	fconfigure $fh -encoding binary -translation lf -eofchar {}
    }
    while {![eof $fh]} {
	set data [read $fh 512]
        array set header [readHeader $data]
	HandleLongLink $fh header
        if {$header(name) eq ""} break
	if {$header(prefix) ne ""} {append header(prefix) /}
        set name [string trimleft $header(prefix)$header(name) /]
        if {$name eq $file} {
            set file [read $fh $header(size)]
            if {!$chan} {
		close $fh
	    }
            return $file
        }
        seekorskip $fh [expr {$header(size) + [pad $header(size)]}] current
    }
    if {!$chan} {
	close $fh
    }
    return -code error -errorcode {TAR MISSING FILE} \
	"Tar \"$tar\": File \"$file\" not found"
}

proc ::tar::untar {tar args} {
    set nooverwrite 0
    set data 0
    set nomtime 0
    set noperms 0
    set chan 0
    parseOpts {dir 1 file 1 glob 1 nooverwrite 0 nomtime 0 noperms 0 chan 0} $args
    if {![info exists dir]} {set dir [pwd]}
    set pattern *
    if {[info exists file]} {
        set pattern [string map {* \\* ? \\? \\ \\\\ \[ \\\[ \] \\\]} $file]
    } elseif {[info exists glob]} {
        set pattern $glob
    }

    set ret {}
    if {$chan} {
	set fh $tar
    } else {
	set fh [::open $tar]
	fconfigure $fh -encoding binary -translation lf -eofchar {}
    }
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
	HandleLongLink $fh header
        if {$header(name) == ""} break
	if {$header(prefix) != ""} {append header(prefix) /}
        set name [string trimleft $header(prefix)$header(name) /]
        if {![string match $pattern $name] || ($nooverwrite && [file exists $name])} {
            seekorskip $fh [expr {$header(size) + [pad $header(size)]}] current
            continue
        }

        set name [file join $dir $name]
        if {![file isdirectory [file dirname $name]]} {
            file mkdir [file dirname $name]
            lappend ret [file dirname $name] {}
        }
        if {[string match {[0346]} $header(type)]} {
            if {[catch {::open $name w+} new]} {
                # sometimes if we dont have write permission we can still delete
                catch {file delete -force $name}
                set new [::open $name w+]
            }
            fconfigure $new -encoding binary -translation lf -eofchar {}
            fcopy $fh $new -size $header(size)
            close $new
            lappend ret $name $header(size)
        } elseif {$header(type) == 5} {
            file mkdir $name
            lappend ret $name {}
        } elseif {[string match {[12]} $header(type)] && $::tcl_platform(platform) == "unix"} {
            catch {file delete $name}
            if {![catch {file link [string map {1 -hard 2 -symbolic} $header(type)] $name $header(linkname)}]} {
                lappend ret $name {}
            }
        }
        seekorskip $fh [pad $header(size)] current
        if {![file exists $name]} continue

        if {$::tcl_platform(platform) == "unix"} {
            if {!$noperms} {
                catch {file attributes $name -permissions 0[string range $header(mode) 2 end]}
            }
            catch {file attributes $name -owner $header(uid) -group $header(gid)}
            catch {file attributes $name -owner $header(uname) -group $header(gname)}
        }
        if {!$nomtime} {
            file mtime $name $header(mtime)
        }
    }
    if {!$chan} {
	close $fh
    }
    return $ret
}

## 
 # ::tar::statFile
 # 
 # Returns stat info about a filesystem object, in the form of an info 
 # dictionary like that returned by ::tar::readHeader.
 # 
 # The mode, uid, gid, mtime, and type entries are always present. 
 # The size and linkname entries are present if relevant for this type 
 # of object. The uname and gname entries are present if the OS supports 
 # them. No devmajor or devminor entry is present.
 ##

proc ::tar::statFile {name followlinks} {
    if {$followlinks} {
        file stat $name stat
    } else {
        file lstat $name stat
    }
    
    set ret {}
    
    if {$::tcl_platform(platform) == "unix"} {
        lappend ret mode 1[file attributes $name -permissions]
        lappend ret uname [file attributes $name -owner]
        lappend ret gname [file attributes $name -group]
        if {$stat(type) == "link"} {
            lappend ret linkname [file link $name]
        }
    } else {
        lappend ret mode [lindex {100644 100755} [expr {$stat(type) == "directory"}]]
    }
    
    lappend ret  uid $stat(uid)  gid $stat(gid)  mtime $stat(mtime) \
      type $stat(type)
    
    if {$stat(type) == "file"} {lappend ret size $stat(size)}
    
    return $ret
}

## 
 # ::tar::formatHeader
 # 
 # Opposite operation to ::tar::readHeader; takes a file name and info 
 # dictionary as arguments, returns a corresponding (POSIX-tar) header.
 # 
 # The following dictionary entries must be present:
 #   mode
 #   type
 # 
 # The following dictionary entries are used if present, otherwise 
 # the indicated default is used:
 #   uid       0
 #   gid       0
 #   size      0
 #   mtime     [clock seconds]
 #   linkname  {}
 #   uname     {}
 #   gname     {}
 #   
 # All other dictionary entries, including devmajor and devminor, are 
 # presently ignored.
 ##

proc ::tar::formatHeader {name info} {
    array set A {
        linkname ""
        uname ""
        gname ""
        size 0
        gid  0
        uid  0
    }
    set A(mtime) [clock seconds]
    array set A $info
    array set A {devmajor "" devminor ""}

    set type [string map {file 0 directory 5 characterSpecial 3 \
      blockSpecial 4 fifo 6 link 2 socket A} $A(type)]
    
    set osize  [format %o $A(size)]
    set ogid   [format %o $A(gid)]
    set ouid   [format %o $A(uid)]
    set omtime [format %o $A(mtime)]
    
    set name [string trimleft $name /]
    if {[string length $name] > 255} {
        return -code error -errorcode {TAR BAD PATH LENGTH} \
	    "path name over 255 chars"
    } elseif {[string length $name] > 100} {
	set common [string range $name end-99 154]
	if {[set splitpoint [string first / $common]] == -1} {
	    return -code error -errorcode {TAR BAD PATH UNSPLITTABLE} \
		"path name cannot be split into prefix and name"
	}
	set prefix [string range $name 0 end-100][string range $common 0 $splitpoint-1]
	set name   [string range $common $splitpoint+1 end][string range $name 155 end]
    } else {
        set prefix ""
    }

    set header [binary format a100A8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
                              $name $A(mode)\x00 $ouid\x00 $ogid\x00\
                              $osize\x00 $omtime\x00 {} $type \
                              $A(linkname) ustar\x00 00 $A(uname) $A(gname)\
                              $A(devmajor) $A(devminor) $prefix {}]

    binary scan $header c* tmp
    set cksum 0
    foreach x $tmp {incr cksum $x}

    return [string replace $header 148 155 [binary format A8 [format %o $cksum]\x00]]
}


proc ::tar::recurseDirs {files followlinks} {
    foreach x $files {
        if {[file isdirectory $x] && ([file type $x] != "link" || $followlinks)} {
            if {[set more [glob -dir $x -nocomplain *]] != ""} {
                eval lappend files [recurseDirs $more $followlinks]
            } else {
                lappend files $x
            }
        }
    }
    return $files
}

proc ::tar::writefile {in out followlinks name} {
     puts -nonewline $out [formatHeader $name [statFile $in $followlinks]]
     set size 0
     if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
         set in [::open $in]
         fconfigure $in -encoding binary -translation lf -eofchar {}
         set size [fcopy $in $out]
         close $in
     }
     puts -nonewline $out [string repeat \x00 [pad $size]]
}

proc ::tar::create {tar files args} {
    set dereference 0
    set chan 0
    parseOpts {dereference 0 chan 0} $args

    if {$chan} {
	set fh $tar
    } else {
	set fh [::open $tar w+]
	fconfigure $fh -encoding binary -translation lf -eofchar {}
    }
    foreach x [recurseDirs $files $dereference] {
        writefile $x $fh $dereference $x
    }
    puts -nonewline $fh [string repeat \x00 1024]

    if {!$chan} {
	close $fh
    }
    return $tar
}

proc ::tar::add {tar files args} {
    set dereference 0
    set prefix ""
    set quick 0
    parseOpts {dereference 0 prefix 1 quick 0} $args
    
    set fh [::open $tar r+]
    fconfigure $fh -encoding binary -translation lf -eofchar {}
    
    if {$quick} then {
        seek $fh -1024 end
    } else {
        set data [read $fh 512]
        while {[regexp {[^\0]} $data]} {
            array set header [readHeader $data]
            seek $fh [expr {$header(size) + [pad $header(size)]}] current
            set data [read $fh 512]
        }
        seek $fh -512 current
    }

    foreach x [recurseDirs $files $dereference] {
        writefile $x $fh $dereference $prefix$x
    }
    puts -nonewline $fh [string repeat \x00 1024]

    close $fh
    return $tar
}

proc ::tar::remove {tar files} {
    set n 0
    while {[file exists $tar$n.tmp]} {incr n}
    set tfh [::open $tar$n.tmp w]
    set fh [::open $tar r]

    fconfigure $fh  -encoding binary -translation lf -eofchar {}
    fconfigure $tfh -encoding binary -translation lf -eofchar {}

    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} {
            puts -nonewline $tfh [string repeat \x00 1024]
            break
        }
	if {$header(prefix) != ""} {append header(prefix) /}
        set name $header(prefix)$header(name)
        set len [expr {$header(size) + [pad $header(size)]}]
        if {[lsearch $files $name] > -1} {
            seek $fh $len current
        } else {
            seek $fh -512 current
            fcopy $fh $tfh -size [expr {$len + 512}]
        }
    }

    close $fh
    close $tfh

    file rename -force $tar$n.tmp $tar
}

proc ::tar::HandleLongLink {fh hv} {
    upvar 1 $hv header thelongname thelongname

    # @LongName Part I.
    if {$header(type) == "L"} {
	# Size == Length of name. Read it, and pad to full 512
	# size.  After that is a regular header for the actual
	# file, where we have to insert the name. This is handled
	# by the next iteration and the part II below.
	set thelongname [string trimright [read $fh $header(size)] \000]
	seekorskip $fh [pad $header(size)] current
	return -code continue
    }
    # Not supported yet: type 'K' for LongLink (long symbolic links).

    # @LongName, part II, get data from previous entry, if defined.
    if {[info exists thelongname]} {
	set header(name) $thelongname
	# Prevent leakage to further entries.
	unset thelongname
    }

    return
}
## EOF tar.tcl
## File tpack.tcl
#' ---
#' title: tpack 0.2.0 - Tcl application deployment
#' author: Detlef Groth, Caputh-Schwielowsee, Germany
#' date: 2021-11-09
#' ---
#' 
#' ## NAME 
#' 
#' _tpack_ - create single or two file Tcl applications based on libraries in tar archives
#' 
#' ## SYNOPSIS
#' 
#' ```
#' $ tpack --help               # display usage information
#' $ tpack wrap app.tapp        # wraps app.tcl and app.vfs into app.tapp 
#'                              # where app.vfs is attached as tar archive
#' $ tpack wrap app.tcl app.vfs # wraps app.tcl into app.ttcl and app.vfs into app.ttar
#' $ tpack wrap app             #            as above
#' $ tpack init app.tcl app.vfs # creates initial file app.tcl and folder app.vfs
#' $ tpack init app             #            as above
#' $ tpack init app.vfs         # create initial folder app.vfs
#' $ tpack unwrap app.tapp      # extracts app.tcl and app.ttar out of app.tapp
#' ```
#' 
#' ## DESCRIPTION
#' 
#' The _tpack_ application can be used to simplify deployment of Tcl applications to other computers and customers.
#' The application can create single and two file applications. 
#' Single file applications, called tapp-files contain at the top the tar extraction code, the main tcl script and an attached tar archive
#' containing the libraries required by this application file. At startup the tar file is detached from the file and 
#' unpacked into a temporary folder from where the libraries are loaded. 
#' 
#' The single file approach create as _app.tapp_ file out of _app.vfs_ and _app.tcl_.
#' 
#' The two file approach creates a ttcl-file for the application and a ttar-file for the library files. 
#' The unpacking of the library code in the tar archives is done only if the tapp file is newer then the files in the temporary directorywhere the files are extracted.
#' If we assume that we have the application code in a file _app.tcl_ and the Tcl libraries in a folder _app.vfs/lib_ together with a file _app.vfs/main.tcl_. The call
#' `$ tpack.tcl app.tcl app.vfs` will create two files:
#' 
#' > - _app.ttcl_ - text file containing the application code from _app.tcl_ and some code from the tar library to extract tar files
#'   - _app.ttar_ - the library files from _app.vfs_
#' 
#' The file _main.tcl_ should contain at least the following line:
#' 
#' ```
#' lappend auto_path [file join [file dirname [info script]] lib]
#' ```
#' 
#' The _tpack_ application provides as well a loader for default starkit layouts, so a fake starkit package so that 
#' as well existing starkits can be packed by _tpack_, here a _main.tcl_ file from the tknotepad application.
#'
#' ```
#' package require starkit
#' if {[starkit::startup] == "sourced"} return
#' package require app-tknotepad
#' ```
#' 
#' In this case the application file tknotepad.tcl which is in the same directoy as _tknotepad.vfs_ can be just an empty file. It can as well contain code to handel command line arguments.
#' Here the file tknotepad.tcl:
#' 
#' ```
#' proc usage {} {
#'     puts "Usage: tknotepad filename"
#' }
#' if {[info exists argv0] && $argv0 eq [info script] && [regexp tknotepad $argv0]} {
#'     if {[llength $argv] > -1 && [lsearch $argv --help] > -1} {
#'         usage
#'     } elseif {[llength $argv] > 0 && [file exists [lindex $argv 0]]} {
#'         openoninit [lindex $argv 0]
#'     }
#' }
#' ```
#' 
#' 
#' That way you should be able to use your vfs-folder for creating tpacked applications
#' as well as for creating starkits.
#'
#' ## INSTALLATION
#' 
#' Make this file _tpack.tcl_ executable and copy it as _tpack_ into a directory belonging to your
#' PATH environment. There are no other Tcl libraries required to install, just a working installation
#' of Tcl/Tk is required.
#' 
#' ## EXAMPLE
#' 
#' Let's demonstrate a minimal application:
#' 
#' ```
#' ## FILE mini.tcl
#' #!/usr/bin/env tclsh
#' package require test
#' puts mini
#' puts [test::hello]
#' ## FILE mini.vfs/main.tcl
#' lappend auto_path [file join [file dirname [info script]] lib]
#' ## FILE mini.vfs/lib/test/pkgIndex.tcl
#' package ifneeded test 0.1 [list source [file join $dir test.tcl]]
#' ## FILE mini.vfs/lib/test/test.tcl
#' package require Tcl
#' package provide test 0.1
#' namespace eval ::test { }
#' proc ::test::hello { } { puts "Hello World!" }
#' ## EOF's
#' ```
#' There is the possibility to create such a minimal application automatically for you if you start a new project
#' by using the command line options:
#' 
#' ```
#' $ tpack init appname
#' # - appname.tcl and appname.vfs folder with main.tcl and
#' #   lib/test Tcl files will be created automatically for you.
#' ```
#' 
#' The string _appname_ has to be replaced with the name of your application. 
#' If a the Tcl file or the VFS folder does already
#' exists, _tpack_ for your safeness will refuse to overwrite them. 
#' If the files were created, you can overwrite the Tcl file (_appname.tcl_)
#' with your own application and move your libraries into the folder 
#' _appname.vfs_.  If you are ready you call `tpack wrap appname.tcl appname.vfs` and 
#' you end up with two new files, _appname.ttcl_ your application code file, containing 
#' your code as well as some code from the tcllib tar package  to unwrap your library 
#' file _appname.ttar_ at program runtime. The ttar file contains your library files
#' taken from the _appname.vfs_ folder. You can move those two files around together 
#' and execute _appname.ttcl_,  it will unpack the tar file into a temporary directory, 
#' only if the tar file is newer than the directory and load the libraries from there.
#' You can as well rename _appname.ttcl_ to _appname_ but your tar-file should always have the same 
#' basename.
#' 
#' Attention: if mini.ttcl is execute directly in the directory where mini.vfs is 
#' located not the tar file but the folder will be used for the libraries. That can simplify the development.
#' 
#' You can rename mini.ttcl to what every you like so `mini.bin` or even `mini`, 
#' but the extension for the tar file must stay unchanged and must be in the same folder as the mini application file.
#' 
#' The tpack.tcl script, the minimal application and this Readme are as well packed together in a Zip archive which is available here: TODO
#' 
#' ## CHANGELOG
#' 
#' - 2021-09-10 - release 0.1  - two file applications (ttcl and ttar) are working
#' - 2021-11-10 - release 0.2.0 
#'     - single file applications (ttap = ttcl+ttar in one file) are working as well
#'     - fake starkit::startup to load existing starkit apps without modification
#'     - build sample apps tknotepad, pandoc-tcl-filter, 
#' 
#' ## TODO
#' 
#' - tpack wrap napp.tapp - single file applications whith attached tar archive (done 0.2.0)
#' - tpack init napp - napp.tcl and napp.vfs will be created (done)
#' - tpack init napp.tcl - napp.tcl exists and napp.vfs will be created (done)
#' - tpack wrap napp.tcl - napp.ttcl and napp.ttar wull be created out of napp.tcl and napp.vfs (done)
#' - tpack wrap napp.tcl napp2.vfs  - napp.ttcl napp.ttar will be created out of napp.tcl and napp2.vfs (done)
#' - tpack unwrap napp.ttar - create napp.vfs  (just an untar, done) 
#' - tpack unwrap napp.tapp - create napp.tcl and napp.ttar  (done)
#' - using ttar.gz files with Tcl 8.6 and zlib and with Tcl 8.5/8.4 gunzip terminal app
#' - using Tcl only lz4 compression, option for Tcl 8.6
#' - nsis installer for Windows, to deploy minimal Tcl/Tk with the application
#'
#' ## AUTHOR
#' 
#'   - Copyright (c) 2021 Detlef Groth, Caputh-Schwielowsee, Germany, detlef(at)dgroth(dot)de (tpack code)
#'   - Copyright (c) 2013 Andreas Kupries andreas_kupries(at)users.sourceforge(dot)net (tar code)
#'   - Copyright (c) 2004 Aaron Faupell afaupell(at)users.sourceforge(sot)net (tar code)
#' 
#' ## LICENSE
#'
#' MIT - License
 
package require Tcl
package require tar
package provide tpack 0.2.0

namespace eval tpack {
    proc usage { } {
        puts "tar application packer [package present tpack]\n\n"
        puts "Usage: tpack \[OPTIONS\] \[CMD\] \[BASENAME\] \[TCLFILE\] \[VFSFOLDER\]\n\n"
        puts "Commands:\n"
        puts "    init file     - creates file.tcl and file.vfs with initial files and code"
        puts "    init file.tcl - creates file.vfs  directory with initial files"
        puts "    wrap file     - creates file.ttcl and file.ttar out of file.tcl and file.vfs"        
        puts "    wrap file.tapp - creates standalone file.tapp out of file.tcl and folder.vfs"        
        puts "    wrap file.tcl - creates file.ttcl and file.ttar out of file.tcl and file.vfs"
        puts "    wrap file.tcl folder.vfs - creates file.ttcl and file.ttar out of file.tcl and folder.vfs"
        puts "    unwrap file.ttar - just unpack the file.ttar into the file.vfs without overwriting existing files"
        puts "    --help        - display this help page"
        puts "    --version     - display version number"
        puts "==========================================="
        puts " - app.tcl main application file"
        puts " - app.vfs library folder with file tpack.tcl or main.tcl"
        puts "           tpack.tcl contains just a lappend:"
        puts "           lappend auto_path \[file join \[file dirname \[info script\]\] lib\]"
        puts "           lib folder contains the packages"
        puts "Deployment: Just copy app.ttcl and app.ttar to the same folder."
        puts "            Please note, that they must have the same basename without the file extension" 
    }
}

namespace eval tpack {
    variable loader 
    set loader {
package provide starkit 0.1

namespace eval starkit {
    proc startup { } {
        lappend ::auto_path [file join [file dirname [info script]] lib]
        return starkit
    }
}
proc getTempDir {} {
    if {[file exists /tmp]} {
        # standard UNIX
        return /tmp
    } elseif {[info exists ::env(TMP)]} {
        # Windows
        return $::env(TMP)
    } elseif {[info exists ::env(TEMP)]} {
        # Windows
        return $::env(TEMP)
    } elseif {[info exists ::env(TMPDIR)]} {
        # OSX
        return $::env(TMPDIR)
    }
}
set rname [file rootname [info script]]
if {[file exists $rname.vfs]} {
    source [file join $rname.vfs main.tcl]
} else {
    set tail [file tail $rname]
    set time [file mtime [info script]]
    set appname [info script]
    set tmpdir [getTempDir]
    set f [open $appname]
    fconfigure $f -translation binary
    set data [read $f][close $f]
    set ctrlz [string first \u001A $data]
    if {$ctrlz > 0} {
        # todo check file dates
        ## standalone file with attached tar archive
        set script [string range $data 0 [expr {$ctrlz - 2}]]
        set archive [string range $data [incr ctrlz] end]
        set scriptfile [file join $tmpdir [file rootname $appname].ttcl]
        set tarfile [file join $tmpdir [file tail [file rootname $appname]].ttar]
        if {[file exists $tarfile]} {
            set ttime [file mtime $tarfile]
            if {$ttime < $time} {
                # script is newer than tar file
                set tmp [open $tarfile w 0600]
                fconfigure $tmp -translation binary
                puts -nonewline $tmp $archive
                close $tmp
            }
        } else {
            set tmp [open $tarfile w 0600]
            fconfigure $tmp -translation binary
            puts -nonewline $tmp $archive
            close $tmp
        }
        #set tmp [open $scriptfile w 0600]
        #fconfigure $tmp -translation binary
        #puts -nonewline $tmp $script
        #close $tmp
    } else {
        set tarfile [file rootname [info script]].ttar
        if {![file exists $tarfile]} {
            puts "Error: File $tarfile does not exists"
            exit 0
        }
    }
    set ttime [file mtime $tarfile]
    set appdir [file join $tmpdir $tail-$ttime]
    foreach dir [glob -nocomplain [file join $tmpdir $rname]*] {
        if {$dir ne $appdir && [file isdir $dir]} {
            file delete -force $dir
        } 
    }
    if {![file exists $appdir]} {
        file mkdir $appdir
        #tar::untar $tarfile -dir $appdir
        tar::untar $tarfile -dir $appdir
    }
    set vfspath [lindex [glob [file join $appdir *]] 0]
    if {[file exists [file join $vfspath tpack.tcl]]} {
        source [file join $vfspath tpack.tcl]
    } elseif {[file exists [file join $vfspath main.tcl]]} {
        source [file join $vfspath main.tcl]
    } else {
        error "Neither tpack.tcl or main.tcl found in tar archive!"
    }
}
}
}

proc rglob {dir {files {}}} {
    foreach file [glob -type f -nocomplain -directory $dir *] {
        if {![regexp {~$} $file]} {
            lappend files $file
        }
    }
    foreach cdir [glob -type d -nocomplain -directory $dir *] {
        set files [rglob $cdir $files]
        
    }
    return $files
}
proc tardir {folder tarfile}  {
    set files [rglob $folder] 
    tar::create $tarfile $files -dereference
}
proc untarfile {file} {
    #puts untar
    set vfsfile [file dirname [lindex [tar::contents $file] 0]]
    if {[file exists $vfsfile]} {
        puts "Error: $vfsfile already exists - not overwriting it!"
    } else {
        tar::untar $file -nooverwrite
    }   
}
proc unwraptapp {tappfile} {
    set appname $tappfile
    set rname [file rootname [file tail $appname]]
    set ttarfile $rname.ttar
    set tclfile $rname.tcl
    set tmp [open $ttarfile w 0600]
    fconfigure $tmp -translation binary
    set f [open $appname]
    fconfigure $f -translation binary
    set data [read $f][close $f]
    set ctrlz [string first \u001A $data]
    fconfigure $tmp -translation binary
    puts -nonewline $tmp [string range $data [incr ctrlz] end]
    close $tmp 
    set data [string range $data 0 [expr {$ctrlz - 2}]]
    set eoarchive [string first "## ARCHIVE LOADER END" $data]
    puts $eoarchive
    set data [string range $data [incr eoarchive 22] end]
    set shebang [string first "#!/usr/bin/env tclsh" $data]
    puts $shebang
    if {$shebang > 0} {
        set data [string range $data $shebang end]
    }
    set out [open $tclfile w 0600]
    fconfigure $out -translation binary 
    puts -nonewline $out $data
    close $out
    puts stdout "Done: unwrapped $appname to $ttarfile and $tclfile"
}
proc wrapfile {tclfile ttclfile scriptfile} {
    set infile $tclfile
    set ttcl $ttclfile
    set out [open $ttcl w 0600]
    # the tpack.tcl file with tar header
    # extracts tar functions to untar 
    # files
    set filename $scriptfile
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        #file operations
        set flag  true
        set pflag false
        while {[gets $infh line] >= 0} {
            if {[regexp {^proc ::tar::skip} $line]} {
                set flag false
            } elseif {[regexp {proc ::tar::(readHeader|untar|HandleLongLink)} $line]} {
                set pflag true
                puts $out $line
            } elseif {$pflag && [regexp {^\}} $line]} { ;#\{
                set pflag false
                 puts $out $line
            } elseif {$flag || $pflag} {
                 puts $out $line
            } elseif {[regexp {## EOF tar.tcl} $line]} {
                break
            }
        }
        close $infh
    }
    # the tttcl tar unpack routines
    # stored
    puts $out $::tpack::loader
    puts $out "## ARCHIVE LOADER END"

    # the actual Tcl code from the original script
    # TODO: place some lines on top and the actual main 
    # part at the end
    set filename $infile
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        # Process line
        while {[gets $infh line] >= 0} {
             puts $out $line
        }
        close $infh
    }
    
    close $out
}

proc wraptapp {ttclfile ttarfile tappfile} {
    set outf [open $tappfile w 0755]
    fconfigure $outf -translation lf
    set utf [open $ttclfile r]
    set data [read $utf]
    puts -nonewline $outf $data
    set f [open $ttarfile]
    fconfigure $f    -translation binary
    puts $outf return
    puts -nonewline $outf \u001A
    fconfigure $outf -translation binary
    fcopy $f $outf
    close $f
    close $outf
}

if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] > 0} {
        if {[lindex $argv 0] eq "--help"} {
            tpack::usage
            exit
        } elseif  {[lindex $argv 0] eq "--version"} {
            puts "[package present tpack]"
            exit
        }
    }
    # create variables
    set mode wrap
    set tclfile ""
    set ttclfile ""
    set basename ""
    set vfsfolder ""
    set ttarfile ""
    set scriptfile [info script]
    if {[lindex $argv 0] eq "wrap"} {
        set argv [lrange $argv 1 end]
    } elseif {[lindex $argv 0] eq "init"} {
        set mode init
        set argv [lrange $argv 1 end]
    } elseif {[lindex $argv 0] eq "unwrap"} {
        set mode unwrap
        set argv [lrange $argv 1 end]
        if {[llength $argv] == 0} {
            puts "Error: Missing ttar file argument!"
            exit 0
        }   
        set ttarfile [lindex $argv 0]
        if {![file exists $ttarfile]} {
            puts "Error: file $ttarfile does not exists!"
            exit 0
        }   
        if {[lsearch [list .ttar .tar .tlib .tapp .bin] [file extension $ttarfile]] == -1} {
            puts "Error: $ttarfile is not a tarfile!"
            exit 0
        }   
    }
    set tapp false
    foreach arg $argv {
        if {[file extension $arg] eq ""} {
            set basename $arg
            set tclfile $arg.tcl
            set ttclfile $arg.ttcl            
            set vfsfolder $arg.vfs
            set ttarfile $arg.ttar
            
        } elseif {[file extension $arg] eq ".tcl"} { 
            set tclfile $arg
            set ttclfile [file rootname $arg].ttcl
        } elseif {[file extension $arg] eq ".tapp"} {
            set tappfile $arg
            set tclfile [file rootname $arg].tcl
            set ttclfile  [file rootname $arg].ttcl
            set vfsfolder [file rootname $arg].vfs
            set ttarfile [file rootname $arg].ttar
            set tapp true
        } elseif {[file extension $arg] eq ".ttcl"} { 
            set ttclfile $arg
            set tclfile [file rootname $arg].tcl
        } elseif {[file extension $arg] eq ".vfs"} { 
            set vfsfolder $arg
            set ttarfile [file rootname $arg].ttar
        } elseif {[file extension $arg] eq ".ttar"} { 
            set vfsfolder [file rootname $arg].vfs
            set ttarfile $arg
        }
    }
    if {$mode eq "wrap"} {
        if {$tapp} {
            set t1 [clock seconds]
            puts -nonewline "wrapping $tclfile into $vfsfolder into $tappfile ..."            
            wrapfile $tclfile $ttclfile $scriptfile
            tardir $vfsfolder $ttarfile
            wraptapp $ttclfile $ttarfile $tappfile
            set t2 [expr {[clock seconds]-$t1}]
            puts " in $t2 seconds done!"
            exit 0
        } elseif {[file exists $tclfile]} {
            set t1 [clock seconds]
            puts -nonewline "wrapping $tclfile into $ttclfile ..."
            wrapfile $tclfile $ttclfile $scriptfile
            set t2 [expr {[clock seconds]-$t1}]
            puts " in $t2 seconds done!"
        }
        if {[file exists $vfsfolder] && [file isdirectory $vfsfolder]} {
            set t1 [clock seconds]
            puts -nonewline "wrapping $vfsfolder into $ttarfile ..."
            tardir $vfsfolder $ttarfile
            set t2 [expr {[clock seconds]-$t1}]
            puts " in $t2 seconds done!"
            
        } 
        if {![file exists $tclfile] && ![file exists $vfsfolder]} {
            tpack::usage
        }
    } elseif {$mode eq "unwrap"} {
        if {$tapp} {
            puts [file extension $ttarfile]
            puts "end"
            unwraptapp $tappfile
            exit 0
        } else {
            untarfile $ttarfile    
        }
    } elseif {$mode eq "init"} {
        if {[file exists $tclfile]} {
            puts stdout "Error: can't overwrite existing Tcl file!"
            puts stdout "Move $tclfile or remove $tclfile to start a new one!"
        } elseif {$tclfile ne ""} {
            set out [open $tclfile w 0600]
            puts $out "#!/usr/bin/env tclsh"
            puts $out "package require test"
            puts $out "package provide [file tail [file rootname $tclfile]] 0.1"
            puts $out "puts \"here is [file tail [file rootname $tclfile]] package!\""
            puts $out "puts \[test::hello\]"
            close $out
            puts stdout "Created $tclfile!\n\nUse: `tpack.tcl wrap $tclfile` to wrap it into $ttclfile\n"
        }
        if {[file exists $vfsfolder]} {
            puts stdout "Error: can't overwrite existing Folder $vfsfolder!"
            puts stdout "Move $vfsfolder or remove $vfsfolder to start a new one!"
        } elseif {$vfsfolder ne ""} {
            file mkdir $vfsfolder
            file mkdir [file join $vfsfolder lib]
            file mkdir [file join $vfsfolder lib test]
            set out [open [file join $vfsfolder main.tcl] w 0600]
            puts $out "lappend auto_path \[file join \[file dirname \[info script\]\] lib\]"
            close $out
            set out [open [file join $vfsfolder lib test pkgIndex.tcl] w 0600]
            puts $out "package ifneeded test 0.1 \[list source \[file join \$dir test.tcl\]\]"
            close $out
            set out [open [file join $vfsfolder lib test test.tcl] w 0600]
            puts $out "package require Tcl"
            puts $out "package provide test 0.1"
            puts $out "namespace eval ::test { }"
            puts $out "proc ::test::hello { } { puts \"Hello Test World!\" }"
            close $out
            puts stdout "Created $vfsfolder!\n\nUse: `tpack.tcl wrap $vfsfolder` to wrap it into $ttarfile\n"
        }
        
    }   
}
