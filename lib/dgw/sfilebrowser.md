[dgw](dgw.html) - 
[basegui](basegui.html) - 
[combobox](combobox.html) - 
[drawcanvas](drawcanvas.html) - 
[hyperhelp](hyperhelp.html) - 
[sbuttonbar](sbuttonbar.html) - 
[seditor](seditor.html) - 
[sfilebrowser](sfilebrowser.html) - 
[sfinddialog](sfinddialog.html) - 
[sqlview](sqlview.html) - 
[statusbar](statusbar.html) - 
[tablelist](tablelist.html) - 
[tlistbox](tlistbox.html) - 
[tvmixins](tvmixins.html) - 
[txmixins](txmixins.html) 

# dgw::sfilebrowser
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-21


## NAME

> **dgw::sfilebrowser** - snit file browser widget

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [WIDGET OPTIONS](#options)
 - [WIDGET COMMANDS](#commands)
 - [WIDGET BINDINGS](#bindings)
 - [EXAMPLE](#example)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE ALSO](#see)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::sfilebrowser
    namespace import ::dgw::sfilebrowser
    sfilebrowser pathName options
    pathName configure -treemode true
    pathName configure -initialpath .
    pathName configure -viewcmd procName
    pathName configure -fileimage imgName
    pathName browse dirName


## <a name='description'>DESCRIPTION</a>

**sfilebrowser** - tablelist based file browser widget to explore 
the file system and to execute certain actions on the currently selected file, 
such as opening it in an editor.

## <a name='command'>COMMAND</a>

**sfilebrowser** *pathName ?options?*

> Creates and configures the *sfilebrowser* widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

__-fileimage__ *imgName*

> The image to be displayed left of filenames. Defaults to the embedded image for files.

__-initialpath__ *dirName*

> The directory from which the files and folders should be shown in the sfilebrowser widget. Defaults to the current working directory.

__-treemode__ *boolean*

> Should the browser be opened in tree mode or in listbox mode? Default is *true*, which is tree mode.

__-viewcmd__ *procName*

> The command to be executed id the user double clicks the entry. Default to empty string, i.e. no action is performed.

The **sfilebrowser** widget inherits all options and methods of its parent widget, 
the tablelist widget. See the manual for tablelist for thowse options and methods. 
Further it adds the following options in additional to tablelists options:


## <a name='commands'>WIDGET COMMANDS</a>

*pathName* **browse** *dirname*

> Opens the given directory name in the widget and displays its files and directories.

*pathName* **getDirectory** 

> Returns the path for the current opened directory.

*pathName* **setDirectory** *dirname*

> Opens the given directory name in the widget and displays its files and directories. Alias for the *browse* command.


Each **sfilebrowser** widget has all the standard widget commands ond options of a tablelist widget as well as the following commands:

## <a name='bindings'>WIDGET BINDINGS</a>

The *dgw::sfilebrowser* widget provides a few useful key bindings to browse the current directory. Such as Up and Down keys to walk one entry up and down, 
Backspace, to switch to the parent directory, 
Ctrl-Start to go the the first and Ctrl-End to go to the last directory entry. 
Further if you type alphanumeric characters the selection moves to the entry starting with these characters.


## <a name='example'>EXAMPLE</a>


       wm title . DGApp
       option add *Tablelist.stripeBackground	#c4e8ff
       option add *Tablelist.setGrid		yes
       pack [dgw::sfilebrowser .fb] -side top -fill both -expand yes
       option add *Tablelist.stripeBackground	white
       option add *Tablelist.setGrid		no
       pack [text .text] -side top -fill both -expand yes
       pack [dgw::sfilebrowser .fb2 -treemode false] -side top -fill both -expand yes
       proc viewCmd {filename} {
           if {[regexp {(txt|tcl|html)$} $filename]} {
               if [catch {open $filename r} infh] {
                   puts stderr "Cannot open $filename: $infh"
                   exit
               } else {
                   .text delete 1.0 end
                   while {[gets $infh line] >= 0} {
                       .text insert end "$line\n"
                   }
                   close $infh
               }
           }
       }
       .fb2 configure -viewcmd viewCmd
       .fb2 browse /home/groth/workspace/detlef


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::sfilebrowser** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/sfilebrowser-0.2.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of sfilebrowser.tcl. 
Try "tclsh sfilebrowser.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish sfilebrowser.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish sfilebrowser.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh sfilebrowser.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh sfilebrowser.tcl --html


This will directly create a HTML page `sfilebrowser.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh sfilebrowser.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    # man page
    tclsh sfilebrowser.tcl --man | pandoc -s -f markdown -t man - > sfilebrowser.n
    # html page
    tclsh ../sfilebrowser.tcl --man > sfilebrowser.md
    pandoc -i sfilebrowser.md -s -o sfilebrowser.html
    # pdf
    pandoc -i sfilebrowser.md -s -o sfilebrowser.tex
    pdflatex sfilebrowser.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
- [tablelist tutorial](https://www.nemethi.de/tablelist/tablelist.html) of Csaba Nemethi which formed the code basis for this widget

## <a name='todo'>TODO</a>

* sorting folders first, then filenames
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The **sfilebrowser** widget was written by Detlef Groth, Schwielowsee, Germany. The code is mainly based on Csaba Nemethi's demo code for his tablelist widget.

## <a name='license'>LICENSE</a>

The widget dgw::sfilebrowser, version 0.2.

Copyright (c) 

   * 2019  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



