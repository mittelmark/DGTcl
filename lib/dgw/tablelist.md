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

# dgw::tablelist 0.2
    
### Detlef Groth, Schwielowsee, Germany
    
### 2019-11-04


## NAME

**dgw::tablelist** - extended tablelist widget with icons and tree mode implementation.

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [WIDGET OPTIONS](#options)
 - [WIDGET COMMANDS](#commands)
 - [EXAMPLE](#example)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE also](#see)
 - [TODO](#todo)
 - [AUTHORS](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require Tk
    package require snit
    package require dgw::tablelist
    dgw::tablelist pathName ?options?
    pathName configure -option value
    pathName cget -option 
    pathName loadFile filename ?boolean?


## <a name='description'>DESCRIPTION</a>

The widget **dgw::tablelist** inherits from the standard tablelist widget 
all methods and options but has embedded standard icons. 
The treemode of tablelist is supported further with changing icons on opening and closing tree nodes.


## <a name='command'>COMMAND</a>

**dgw::tablelist** *pathName ?options?*

> Creates and configures the **dgw::tablelist**  widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

As the **dgw::tablelist** is an extension of the tablelist widget it has all the options of the tablelist widget. 
The following options are added or modified:

  __-browsecmd__ _script_ 

 > Set a command if the user double clicks an entry in the listbox or presses the `Return` key if the widget has the focus.
   The widget path and the index of the item getting the event are appended to the script call as function arguments. 
   So the implementation of the script should have two arguments in the parameter list as shown in the following example:

> ```
  proc click {tbl idx} {
     puts [$tbl itemcget $idx -text]
  }
  dgw::tablelist .tl -browsecmd click
> ```

__-collapsecommand__ _command_

> This options is per default configured to change the icons in the tree 
  for parent items which have child items if the node is opened. Can be overwritten by the user.

__-collapseicon__ _iconprefix_

> The imagw which should be displayed if a folder node is closed.
  Currently the default is a folder icon.

__-expandcommand__ _command_

> This options is per default configured to change the icons in the tree 
  for parent items which have child items. Can be overwritten by the user.
 
__-treestyle__ _stylename_

> Currently this option is just delegated to the standard tablelist widget.
## <a name='commands'>WIDGET COMMANDS</a>

Each **dgw::tablelist** widget supports all the commands of the standard tablelist widget. 
See the tablelist manual page for a description of those widget commands. 

## <a name='example'>EXAMPLE</a>


    proc click {tbl idx} {
         puts "clicked in $tbl on $idx"
    }
    dgw::tablelist .mtab   -columns {0 "Name"  left 0 "Page" left} \
           -movablecolumns no -setgrid no -treecolumn 0 -treestyle gtk -showlabels false \
           -stripebackground white -width 40 -height 25 \
           -browsecmd click
    
     pack .mtab -side left -fill both -expand yes
     dgw::tablelist .mtab2   -columns {0 "Name"  left 0 "Page" left} \
           -movablecolumns no -setgrid no -treecolumn 0 -treestyle ubuntu -showlabels false \
           -stripebackground grey90 -width 40 -height 25
    
     pack .mtab2 -side left -fill both -expand yes
     set x 0 
     while {[incr x] < 5} {
         set y 0
         set parent [.mtab insertchild root end [list Name$x $x]]
         set parent [.mtab2 insertchild root end [list Name$x $x]]        
         while {[incr y] < 5} {
             .mtab insertchild $parent end [list Child$y $y]
             .mtab2 insertchild $parent end [list Child$y $y]
         }
     }

## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::tablelist** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/tablelist-0.2.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of tablelist.tcl. 
Try "tclsh tablelist.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish tablelist.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish tablelist.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh tablelist.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh tablelist.tcl --html


This will directly create a HTML page `tablelist.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh tablelist.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    # man page
    tclsh tablelist.tcl --man | pandoc -s -f markdown -t man - > tablelist.n
    # html 
    tclsh tablelist.tcl --man > tablelist.md
    pandoc -i tablelist.md -s -o tablelist.html
    # pdf
    pandoc -i tablelist.md -s -o tablelist.tex
    pdflatex tablelist.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* more icons
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The dgw::**tablelist** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='license'>LICENSE</a>

dgw::tablelist widget dgw::tablelist, version 0.2.

Copyright (c) 

   * 2019-2020  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



