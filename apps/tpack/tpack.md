---
title: tpack application - application deployment with libraries in tar archives
author: Detlef Groth, Caputh-Schwielowsee, Germany
date: 2021-09-09
---

## NAME 

_tpack_ - create two file standalone Tcl applications based on tar archives

## SYNOPSIS

```
$ tpack.tcl --help               # display usage information
$ tpack.tcl wrap app.tcl app.vfs # wraps app.tcl into app.ttcl and app.vfs into app.ttar
$ tpack.tcl wrap app             #            as above
$ tpack.tcl init app.tcl app.vfs # creates intial file app.tcl and folder app.vfs
$ tpack.tcl init app             #            as above
$ tpack.tcl init app.vfs         # create intial folder app.vfs
```

## DESCRIPTION

The _tpack_ application can be used to simplify deployment of Tcl applications to other computers and customers.
The application created usually two files, one for the application and one for the library files. 
If we assume that we have the application code in a file _app.tcl_ and the Tcl libraries in a folder _app.vfs/lib_ together with a file _app.vfs/main.tcl_. The call
`$ tpack.tcl app.tcl app.vfs` will create two files:

> - _app.ttcl_ - text file containing the application code from _app.tcl_ and some code from the tar library to extract tar files
  - _app.ttar_ - the library files from _app.vfs_

The file _main.tcl_ should contain at least the following line:

```
lappend auto_path [file join [file dirname [info script]] lib]
```

To make this approch compatibe there can be as well starkit code added like this:

```
catch { package require starkit }
if {[package versions starkit] ne ""} {
    starkit::startup
    package require app-appname
}
```

That way you should be able to use your vfs-folder as well for creating starkits.

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
## EOF
```
There is the possibility to create such a minimal application automatically for you if you start a new project
by using the command line options:

```
tpack.tcl init appname
# - appname.tcl and appname.vfs folder with main.tcl and
#   lib/test Tcl files will be created automatically for you.
```

The appname could be replaced with whatever you like, mini, maxi etc. If a the Tcl file or the VFS folder does already
exists, tpack.tcl for your safeness will refuse to overwrite them. 
If the files wre created, after calling for instance thereafter 
`tpack.tcl wrap mini.tcl mini.vfs` we have two files,
_mini.ttcl_ the application code file and _mini.ttar_ the tar file with the
library code. You can move those two files around together and execute _mini.ttcl_, 
it will unpack the tar file into a temporary directory, only if the tar file is newer than
the directory and load the libraries from there.

Attention: if mini.ttcl is execute directly in the directory where mini.vfs is 
located not the tar file but the folder will be used for the libraries. That can simplify the development.

You can rename mini.ttcl to what every you like so `mini.bin` or even `mini`, 
but the extension for the tar file must stay unchanged and must be in the same folder as the mini application file.

The tpack.tcl script, the minimal application and this Readme are as well packed together in a Zip archive which is available here: TODO

## TODO

- tpack init napp - napp.tcl and napp.vfs will be created (done)
- tpack init napp.tcl - napp.tcl exists and napp.vfs will be created (done)
- tpack wrap napp.tcl - napp.ttcl and napp.ttar wull be created out of napp.tcl and napp.vfs (done)
- tpack wrap napp.tcl napp2.vfs  - napp.ttcl napp.ttar will be created out of napp.tcl and napp2.vfs (done)
- tpack unwrap napp.ttar - create napp.vfs
- sample project dcanvas with txmixins for the editor for popup - Windows port
- nsis installer for Windows

## AUTHOR

  - Copyright (c) 2021 Detlef Groth, Caputh-Schwielowsee, Germany, detlef(at)dgroth(dot)de (tpack code)
  - Copyright (c) 2013 Andreas Kupries andreas_kupries(at)users.sourceforge(dot)net (tar code)
  - Copyright (c) 2004 Aaron Faupell afaupell(at)users.sourceforge(sot)net (tar code)

## LICENSE

MIT - License
