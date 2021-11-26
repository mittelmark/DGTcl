---
title: tpack 0.2.1 - Tcl application deployment
author: Detlef Groth, Caputh-Schwielowsee, Germany
date: 2021-11-26
---

## NAME 

_tpack_ - create single or two file Tcl applications based on libraries in tar archives

## SYNOPSIS

```
$ tpack --help               # display usage information
$ tpack wrap app.tapp        # wraps app.tcl and app.vfs into app.tapp 
                             # where app.vfs is attached as tar archive
$ tpack wrap app.tcl app.vfs # wraps app.tcl into app.ttcl and app.vfs into app.ttar
$ tpack wrap app             #            as above
$ tpack init app.tcl app.vfs # creates initial file app.tcl and folder app.vfs
$ tpack init app             #            as above
$ tpack init app.vfs         # create initial folder app.vfs
$ tpack unwrap app.tapp      # extracts app.tcl and app.ttar out of app.tapp
```

## DESCRIPTION

The _tpack_ application can be used to simplify deployment of Tcl applications to other computers and customers.
The application can create single and two file applications. 
Single file applications, called tapp-files contain at the top the tar extraction code, the main tcl script and an attached tar archive
containing the libraries required by this application file. At startup the tar file is detached from the file and 
unpacked into a temporary folder from where the libraries are loaded. 

The single file approach create as _app.tapp_ file out of _app.vfs_ and _app.tcl_.

The two file approach creates a ttcl-file for the application and a ttar-file for the library files. 
The unpacking of the library code in the tar archives is done only if the tapp file is newer then the files in the temporary directorywhere the files are extracted.
If we assume that we have the application code in a file _app.tcl_ and the Tcl libraries in a folder _app.vfs/lib_ together with a file _app.vfs/main.tcl_. The call
`$ tpack.tcl app.tcl app.vfs` will create two files:

> - _app.ttcl_ - text file containing the application code from _app.tcl_ and some code from the tar library to extract tar files
  - _app.ttar_ - the library files from _app.vfs_

The file _main.tcl_ should contain at least the following line:

```
lappend auto_path [file join [file dirname [info script]] lib]
```

The _tpack_ application provides as well a loader for default starkit layouts, so a fake starkit package so that 
as well existing starkits can be packed by _tpack_, here a _main.tcl_ file from the tknotepad application.

```
package require starkit
if {[starkit::startup] == "sourced"} return
package require app-tknotepad
```

In this case the application file tknotepad.tcl which is in the same directoy as _tknotepad.vfs_ can be just an empty file. It can as well contain code to handel command line arguments.
Here the file tknotepad.tcl:

```
proc usage {} {
    puts "Usage: tknotepad filename"
}
if {[info exists argv0] && $argv0 eq [info script] && [regexp tknotepad $argv0]} {
    if {[llength $argv] > -1 && [lsearch $argv --help] > -1} {
        usage
    } elseif {[llength $argv] > 0 && [file exists [lindex $argv 0]]} {
        openoninit [lindex $argv 0]
    }
}
```


That way you should be able to use your vfs-folder for creating tpacked applications
as well as for creating starkits.

## INSTALLATION

Make this file _tpack.tcl_ executable and copy it as _tpack_ into a directory belonging to your
PATH environment. There are no other Tcl libraries required to install, just a working installation
of Tcl/Tk is required.

## EXAMPLE

Let's demonstrate a minimal application:

```
## FILE mini.tcl
#!/usr/bin/env tclsh
package require test
puts mini
puts [test::hello]
## FILE mini.vfs/main.tcl
lappend auto_path [file join [file dirname [info script]] lib]
## FILE mini.vfs/lib/test/pkgIndex.tcl
package ifneeded test 0.1 [list source [file join $dir test.tcl]]
## FILE mini.vfs/lib/test/test.tcl
package require Tcl
package provide test 0.1
namespace eval ::test { }
proc ::test::hello { } { puts "Hello World!" }
## EOF's
```
There is the possibility to create such a minimal application automatically for you if you start a new project
by using the command line options:

```
$ tpack init appname
# - appname.tcl and appname.vfs folder with main.tcl and
#   lib/test Tcl files will be created automatically for you.
```

The string _appname_ has to be replaced with the name of your application. 
If a the Tcl file or the VFS folder does already
exists, _tpack_ for your safeness will refuse to overwrite them. 
If the files were created, you can overwrite the Tcl file (_appname.tcl_)
with your own application and move your libraries into the folder 
_appname.vfs_.  If you are ready you call `tpack wrap appname.tcl appname.vfs` and 
you end up with two new files, _appname.ttcl_ your application code file, containing 
your code as well as some code from the tcllib tar package  to unwrap your library 
file _appname.ttar_ at program runtime. The ttar file contains your library files
taken from the _appname.vfs_ folder. You can move those two files around together 
and execute _appname.ttcl_,  it will unpack the tar file into a temporary directory, 
only if the tar file is newer than the directory and load the libraries from there.
You can as well rename _appname.ttcl_ to _appname_ but your tar-file should always have the same 
basename.

Attention: if mini.ttcl is execute directly in the directory where mini.vfs is 
located not the tar file but the folder will be used for the libraries. That can simplify the development.

You can rename mini.ttcl to what every you like so `mini.bin` or even `mini`, 
but the extension for the tar file must stay unchanged and must be in the same folder as the mini application file.

The tpack.tcl script, the minimal application and this Readme are as well packed together in a Zip archive which is available here: TODO

## CHANGELOG

- 2021-09-10 - release 0.1  - two file applications (ttcl and ttar) are working
- 2021-11-10 - release 0.2.0 
    - single file applications (ttap = ttcl+ttar in one file) are working as well
    - fake starkit::startup to load existing starkit apps without modification
    - build sample apps tknotepad, pandoc-tcl-filter, 
- 2021-11-26 - release 0.2.1 
    - bugfix: adding `package forget tar` after tar file loading to catch users `package require tar`
 
## TODO

- tpack wrap napp.tapp - single file applications whith attached tar archive (done 0.2.0)
- tpack init napp - napp.tcl and napp.vfs will be created (done)
- tpack init napp.tcl - napp.tcl exists and napp.vfs will be created (done)
- tpack wrap napp.tcl - napp.ttcl and napp.ttar wull be created out of napp.tcl and napp.vfs (done)
- tpack wrap napp.tcl napp2.vfs  - napp.ttcl napp.ttar will be created out of napp.tcl and napp2.vfs (done)
- tpack unwrap napp.ttar - create napp.vfs  (just an untar, done) 
- tpack unwrap napp.tapp - create napp.tcl and napp.ttar  (done)
- using ttar.gz files with Tcl 8.6 and zlib and with Tcl 8.5/8.4 gunzip terminal app
- using Tcl only lz4 compression, option for Tcl 8.6
- nsis installer for Windows, to deploy minimal Tcl/Tk with the application

## AUTHOR

  - Copyright (c) 2021 Detlef Groth, Caputh-Schwielowsee, Germany, detlef(at)dgroth(dot)de (tpack code)
  - Copyright (c) 2013 Andreas Kupries andreas_kupries(at)users.sourceforge(dot)net (tar code)
  - Copyright (c) 2004 Aaron Faupell afaupell(at)users.sourceforge(sot)net (tar code)

## LICENSE

MIT - License
