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

# dgw::sqlview 0.6
    
### Dr. Detlef Groth, Schwielowsee, Germany
    
### 2021-08-21



## NAME

**dgw::sqlview**  - database browser widget and standalone application


## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [METHODS](#methods)
 - [EXAMPLE](#example)
 - [MARKUP LANGUAGE](#formatting)
 - [INSTALLATION](#install)
 - [SEE ALSO](#see)
 - [CHANGES](#changes)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [LICENSE AND COPYRIGHT](#license)


## <a name='synopsis'>SYNOPSIS</a>

Usage as package:


    package require Tk
    package require snit
    package require tdbc::sqlite3 
    package require dgw::seditor 
    package require dgw::hyperhelp
    package require dgw::basegui
    package require dgw::sqlview
    dgw::sqlview pathName -database filename ?-funcfile sqlfunc.tcl?
    dgw::sqlview tedit insert "sql statement"
    dgw::sqlview tedit doHilights sql


Usage as command line application:


    tclsh sqlview.tcl databasename


## <a name='description'>DESCRIPTION</a>

The **dgw::sqlview** package provides a SQL database browser widget as well 
as a standalone application. It main parts a treeview database structure viewer, 
a text editor with SQL syntax hilighting, and a tableview widget for viewing the
results of the entered SQL statements. The editor widget provides shortcuts to execute either the current selection, the current line or the complete
text entered in the text widget.

## <a name='command'>COMMAND</a>

**dgw::sqlview** *pathName -database fileName ?-option value ...?*

> creates a new *sqlview* widget using the given widget *pathName* and with the given *-database fileName*. 
Please note, that the filename must be currently a sqlite3 database. Support for other database types can be added on request.

## <a name='options'>OPTIONS</a>

The *dgw::sqlview* snit widget supports the following options:

  __-database__ _filename_

 > Configures the database used within the widget. Should be set already at
   widget initialization.

  __-funcfile__ _filename(s)_

 > Load SQL functions from the file given with the *-funcfile* option. 
Please note, that all SQL functions written in Tcl must be created 
within the *sqlfunc* namespace.  If the *filenames* are a list, every file of this list  will be loaded.
See the following example for the beginning of such a `funcfile.tcl`:

> ```
namespace eval ::sqlfunc {}
# replace all A's with B's
proc ::sqlfunc::mmap args {
  return [string map {A B} [lindex $args 0]]
}
# support for regexp: rgx('^AB',colname)
proc ::sqlfunc::rgx {args} {
    return [regexp [lindex $args 0] [lindex $args 1]]
}
# support for replacements: rsub('^AB',colname,'')
proc ::sqlfunc::rsub {args} {
    return [regsub [lindex $args 0] [lindex $args 1] [lindex $args 2]]
}
> ```

  __-log__ _boolean_

 > Should all executed statements written into the logfile. Default true.

  __-logfile__ _filename_

 > The file where all executed statements of the sqlview editor widget are written into.
   If not given, defaults to an the file sqlview.log in the users home directory.

  __-type__ _sqlite3_

 > Configures the database type, currently only the type sqlite3 is supported. 
   Other types can be added on request. Should be set only at
   widget initialisation.

## <a name='methods'>METHODS</a>

The *dgw::sqlview* widget provides the following methods:

*pathName* **changeFontSize** *integer*

> Increase (positive integer values) or decrease widget (negative integer values) font size of all text and ttk::treeview widgets.

*pathName* **closeSQLview** 

> Destroys the sqlview widget. A message box will be shown to verify that the 
  widget should be really destroyed. This as well disconnects the database cleanly.

*pathName* **dbConnect**

> Connect to the actual database. Currently only SQLite 3 is supported.

*pathName* **dbDisconnect**

> Disconnect the actual database. Currently only SQLite 3 is supported.

*pathName* **dbSelect** *statement*

> Execute the given statement against the database and insert the result
  into the tableview widget at the bottom.

*pathName* **executeSQL** *mode*

> Execute a SQL statement against the current database. 
If mode is 'all' (default) the complete text entered in the text editor
widget will be used as statement. The *mode* can be as well 'line' where only the current line is executed, 
or 'selection' where only the currently selected text is send to the database.

*pathName* **getDBVersion**

> Returns the SQLite 3 version of the current database implementation.

*pathName* **openDatabase** *?filename?*

> Open the database using the given *filename* is given. 
  If not *filename* is given opens the open file dialog.

*pathName* **refreshDatabase**

> Refresh the treeview widget which shows the database structure. Useful if the database was updated.

*pathName* **showHistory** *toplevel*

> Displays the SQL statement history in the given toplevel path. Default: `.history`

*pathName* **tedit** *arguments*

> Expose the interface of the *dgw::seditor* text widget, so you can use all of its methods 
  and the methods of the standard text editor widget. For example: 

> `pathName tedit insert end "select * from students"`

## <a name='binding'>KEY BINDINGS</a>

#### Editor widget

In addition to the standard bindings of the Tk text editor widget, the SQL editor 
widget, *dgw::seditor*, in the upper right, provides the following key and mouse bindings:

- `mouse right click` : editor popup with cut, paste etc.
- `Ctrl-x 2`: split the window vertically
- `Ctrl-x 3`: split the window horizontally
- `Ctrl-x 1` undo the splitting
- `Shift-Return`: Send the widget text to the configured *-toolcommand*
- `Control-Return`: send the current line to configured *-toolcommand*
- `Control-Shift-Return`: send the current selection to the tool command

Please note, that the tool command accelerator keys can be changed to other keys 
by using the options of the *dgw::seditor* widget using the `tedit` sub command of the *dgw::sqlview* widget.

#### Tableview widget

The tableview widget at the bottom can be sorted by column if the user clicks on 
the column headers. It otherwise provides the standard bindings of the ttk::treeview widget to the developer and user.

#### Notebook tabs

The following shortcuts are only available if the users click on the notebook tab:

- Ctrl-Tab: after click on the notebook will open a new tab, Ctrl-Tab outside of the notebook widget will change the visible tab
- Ctrl-Shift-Left: Move tab to the left.
- Ctrl-Shift-Right: move tab to the right
- Ctrl-w: closes the tab if the users confirms the dialog box message.
- Right mouse click: change the tab name.

If you the notebook tab has not the focus you have the following bindings available:

- Ctrl-Tab: cycle the tabs and bring the next in the forground, also called tab traversal.

## <a name='example'>EXAMPLE</a>

In the example below we create a sample database and load the database and 
their information into the three sub widgets.


    package require dgw::sqlview
    set sqlv [::dgw::sqlview .sql -database test.sqlite3 -funcfile sqlfunc.tcl]
    # create a test database
    $sqlv dbSelect "drop table if exists students"
    $sqlv dbSelect "create table students (id INTEGER, firstname TEXT, lastname TEXT, city TEXT)"
    $sqlv dbSelect "insert into students (id,firstname, lastname, city) values (1234, 'Marc', 'Musterman', 'Mustercity')"
    $sqlv dbSelect "insert into students (id,firstname, lastname, city) values (1235, 'Marcella', 'Musterwoman', 'Berlin')"
    $sqlv refreshDatabase
    $sqlv tedit doHilights sql
    $sqlv tedit insert end " select * from students"
    $sqlv executeSQL
    pack $sqlv -side top -fill both -expand yes


## <a name='install'>INSTALLATION</a>

You can install and use the **dgw::sqlview** package if you have a working install of:

- Tcl/Tk installed together with the database extensions *tdbc*
- the snit package, which is  part of [tcllib](https://core.tcl-lang.org/tcllib)

If you have this, then download the latest *dgw* and *dgtools* package releases from: [dgw package release page](https://chiselapp.com/user/dgroth/repository/tclcode/wiki?name=releases).
For installation unzip the latest *dgw* and *dgtools* zip files and copy the complete *dgw* and *dgtools* folders into a path 
of your *auto_path* list of Tcl. Alternatively you can append the *auto_path* list with the parent directory of the *dgw* directory.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish sqlview.tcl --demo


The example code used for this demo can be seen in the terminal by using the following command line:


    $ tclsh sqlview.tcl --code

## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh sqlview.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh sqlview.tcl --html


If the tcllib Markdown package is installed, this will directly create a HTML page `sqlview.html` 
which contains the formatted documentation. 

Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh sqlview.tcl --man


The output of this command can be used to feed a Markdown processor for conversion into a 
html, docx or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../sqlview.tcl --man > sqlview.md
    pandoc -i sqlview.md -s -o sqlview.html
    pandoc -i sqlview.md -s -o sqlview.tex
    pdflatex sqlview.tex


## <a name='see'>SEE ALSO</a>

- [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various other useful widgets and tools to build Tcl/Tk applications.

 
## <a name='changes'>CHANGES</a>

* 2020-03-05 - version 0.6 started

## <a name='todo'>TODO</a>

* tests
* github url 

## <a name='authors'>AUTHORS</a>

The **dgw::sqlview** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>Copyright</a>

Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw::sqlview package, version 0.6.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



