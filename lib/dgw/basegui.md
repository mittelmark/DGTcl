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

# dgw::basegui 0.2
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20


## NAME

> **dgw::basegui** - starting point framework for writing Tk applications

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [TYPE OPTIONS](#options)
 - [TYPE COMMANDS](#commands)
 - [EXAMPLE](#example)
 - [INHERITANCE](#inheritance)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE ALSO](#see)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::basegui
    dgw::basegui cmdName
    cmdName addStatusBar
    cmdName autoscroll pathname
    cmdName balloon pathname message
    cmdName cballon canvasname tag message
    cmdName center window
    cmdName console ?pathname?
    cmdName dlabel pathname
    cmdName getFrame
    cmdName getMenu
    cmdName labentry pathname
    cmdName message msg
    cmdName notebook pathname
    cmdName progress value
    cmdName rotext pathname
    cmdName splash imgfile ?-delay milliseconds -message textmessage?
    cmdName status msg ?value?
    cmdName subwidget widgetName
    cmdName timer mode
    cmdName treeview pathname

## <a name='description'>DESCRIPTION</a>

The **dgw::basegui** application framework serves as building block for writing  Tk applications. 
It can be used for new applications as starting point providing useful widgets such as a ready to use menubar, a mainframe and
a statusbar etc and various utility methods, for instance to add scrollbars, centering a window on the screen. It can be however as well added to existing applications as it provides a few 
useful small widgets required in standard applications, such as a tooltip/balloon, a sortable table widget (based on ttk::treeview), 
a splash toplevel, a notebook with reorganizing facilities and popumenu for renaming tabs, a labentry and so on. 
Those widgets in many cases just add small functionalities with one or two new methods or options to existing widgets, 
not worth to put them into extra widget manual pages or even packages. These widgets are therefore documented in this manual page.

## <a name='command'>COMMAND</a>

**dgw::basegui** *cmdName ?options?*

> Creates and configures a new dgw::basegui application  using the main Tk window id _._ and the given *options*. 
  If the functionalties in this package should be added to existing applications the option *-start* should be set to *false*. See the _start_ option below for a more detailed explanation.
 
## <a name='options'>TYPE OPTIONS</a>

The **dgw::basegui** snit type supports the following options:

  __-start__ _boolean_ 

 > Should the application in the toplevel be started automatically. Default to *true*. 
In cases where you like to add just a few of the small widgets or utility methods of the *dgw::basegui* package such as 
*balloon*, *notebook*, *rotext*, *labentry* or some others to an existing application you should set 
this as *false* at object creation.

> The following methods can be used inside existing applications if the option *-start* was set to false:

>  - [autoscroll](#autoscroll)
   - [balloon](#balloon)
   - [cballoon](#cballoon)
   - [center](#center)
   - [console](#console)
   - [dlabel](#dlabel)
   - [notebook](#notebook)
   - [rotext](#rotext)
   - [splash](#splash)
   - [timer](#timer)
   - [treeview](#treeview)


  __-style__ _styleName_ 

 > Configures the ttk style for all widgets within the application. 'clam' and 'default# should be supported on all platforms. 
   Use `ttk::style theme names` within an interactive wish session to find out which themes are available on your machine.

## <a name='commands'>TYPE COMMANDS</a>

Each **dgw::basegui** command supports the following public methods to be used within inheriting applications to extend the basic application.
Alternatively widgets can be added to existing applications as well.

*cmdName* **addStatusBar** 

> Packs and displays the statusbar widget at the bottom of the application. 
If not called the statusbar will be invisible.

<a name="autoscroll">*cmdName* **autoscroll**  *pathname*</a>

> For the widget belonging to *pathname* add horizontal and vertical scrollbars, shown only when needed.
  Please note, that the widget in *pathname* must be the only child of a `tk::frame` or a `ttk::frame` widget created already.
   The widget *pathname* is then managed by grid, don't pack or grid the widget in *pathname* yourself. Handle it's geometry
  via its parent frame. See the following example:

> ```
package require dgw::basegui
::dgw::basegui app -style clam
set f [app getFrame]
set tf [ttk::frame $f.tframe]
set t [text $tf.text -wrap none]
app autoscroll $t
for {set i 0} {$i < 30} {incr i} {
    $t insert end "Lorem ipsum dolor sit amet, ....\n\n"
}
pack $tf -side top -fill both -expand yes
> ```


<a name="balloon">*cmdName* **balloon**  *pathname message ?display?* </a>

> For the widget belonging to *pathname* displays for around three seconds a small tooltip 
  using the given *message*. The boolean variable *display* can be used to unregister the tooltip 
  at a later point. See as well [cballoon](#cballoon) for tooltip on canvas tags.

<a name="cballoon">*cmdName* **cballoon**  *pathname tag message*</a>

> For the widget belonging to *pathname* display for the canvas items labeled with *tag* the 
  given message. See as well [balloon](#balloon) for standard tooltips for widgets.

<a name="center">*cmdName* **center** *window*</a>

> Centers a toplevel window on the screen.

<a name="console">*cmdName* **console** *?pathname?*</a>

> Displays a simple console in a toplevel if the target *pathname* is not given, or within the application if the given *pathname*
 is a valid widget path within an existing toplevel. This console can be used to debug applications and
  to inspect variables, commands etc. Based on wiki code in [A minimal console](https://wiki.tcl-lang.org/page/A+minimal+console). The *puts* commands entered within the *console* widget are displayed within the widget.

<a name="dlabel">*cmdName* **dlabel** *window*</a>

> Creates a ttk::label where the font size is dynamically adjusted to the widget size. Here an example:

> ```
dgw::basegui app -start false
font create title -family Helvetica -size 10
toplevel .test
set txt " Some Title "
app dlabel .test.l -text $txt -font title
pack  .test.l -expand 1 -fill both
wm geometry .test 400x300+0+0
> ```


*cmdName* **getFrame**  

> Returns the mainframe of the application.
  This function allows adding more widgets to the interior of the application in inheriting applications or at a later point.

*cmdName* **getMenu** *menuName ?option value ...?*  

> Returns the menu entry belonging to the given *menuName* or creates a new cascade with this *menuName* 
  in the application menubar. 
  This function allows adding more menu points in inheriting applications or at a later point to the application.
  At creation time or therafter additional configuration options can be given such as *-underline 0* for instance. Here an example for inserting new menu points  

> ```
::dgw::basegui app -style clam
set fmenu [app getMenu "File"]
$fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
> ```
 

<a name="labentry">*cmdName* **labentry**  *pathname ?-option value ...?*</a>

> Creates a simple *labentry* widget where the main widget is the entry widget. 
The label is set with the *-label* option. All other options and methods are delegated to the entry widget. 
The widget provides two additional methods:

> - *pathname entry* to access directly the internal entry widget
  - *pathname label* to access directly the internal label widget

*cmdName* **message**  *msg*

> Displays the text of *msg* in the statusbar. 
   Only useful if statusbar is displayed using the *addStatusBar* command.

<a name="notebook">*cmdName* **notebook**  *pathname ?-option value?*</a>

> Creates a standard *ttk::notebook* with some additional features, like right click popup for adding new tabs, rename existing tabs and changing tab order. There is further one additional option available:

> - *-createcmd command* invokes the given *command* if a new page is created. The *pathname* of the notebook and the page *index* are added as arguments to the script call.

> The widget further adds the following bindings to the standard *ttk::notebook* widget:

> - *F2* - popup for moving and renaming tabs
  - *Button-3* - popup for moving and renaming tabs
  - *Ctrl-Shift-Left* - move current tab to the left
  - *Ctrl-Shift-Right* - move current tab to the right
  - *Ctrl-w* - close current tab
  - *Ctrl-t* - create new tab

*cmdName* **progress**  *value* 

> Displays the given *value* within the progressbar in the statusbar widget. 
   Only useful if statusbar is displayed using the *addStatusBar* command.

<a name="rotext">*cmdName* **rotext**  *pathname* *?-option value ...?*</a>

> Creates a readonly *text* widget. All options are delegated to the standard textwidget, except for *-insertwidth*.
  The standard commands for the text widget work but not *insert* and *delete*. They are replaced with the *ins* and *del* subcommands. Useful fot displaying text to the user which should not be changed. See the following example on how to handle inserts into the *rotext* widget:

> ```
package require dgw::basegui
dgw::basegui app
# main application frame
set f [app getFrame]
# it is best to place it in a single frame if you need scrollbars
set roframe [ttk::frame $f.rf]
set rotext [app rotext $roframe.rotext -background salmon]
app autoscroll $rotext
# scrollbar free rotext can be placed directly into the main frame
set rotext2 [app rotext $f.rotext -autoscroll false]
for {set i 0} {$i < 100} {incr i 1} {
   $rotext ins end "Sample text line $i\n"
   $rotext2 ins end "Sample text line $i\n"
}
pack $roframe -side top -fill both -expand true
pack $rotext2 -side top -fill both -expand true
> ```

<a name="splash">*cmdName* **splash**  *imgfile ?-delay milliseconds -message textmessage?* </a>

> Hides the main application and shows the given image in *imgfile* as well as some 
  textmessage given with the option -message. The splash screen destroys itself after the given delay, default 2500. 
  If delay is given as zero (0), the splash widget is not destroyed. If the *imgfile* variable is given as `update` 
  then additional messages can be given to the splash widget. To destroy the splash method should be called with the
  imgfile argument `destroy`. See below for an example. 
  The pathname of the splash toplevel is `.splash`.

> Example with a simple single message splash:

> ```
app splash splash.png -delay 2000 -message "Loading editor application ..."
> ```

> Example with multiple messages:

> ```
app splash splash.png -delay 0 -message "Loading editor application ..."
after 2000 { app splash update -message "Loading data for editor application ..." }
after 4000 { app splash destroy }
> ```

*cmdName* **status**  *msg ?value?* 

> Displays the text of *msg* as message and the optional value within the progressbar in the statusbar widget. 
   Only useful if statusbar is displayed using the *addStatusBar* command.

*cmdName* **subwidget**  *widgetName* 

> Returns the widget belonging to the given *widgetName*.
  *widgetName* can be either *statusbar* or *frame*. This function allows access to internal widgets at a later point.

<a name="timer">*cmdName* **timer**  *mode*</a>

> Simple timer procedure to measure execution time in the GUI. 
The two modes are *reset* and *time*, the first measured time is initialized at *dgw::basegui* initialization:

> - *reset* - resets the time to the current time
  - *time*  - gets the execution time after the last reset, this is the default.

> ```
  dgw::basegui app
  puts "Startup in [app timer time] seconds!"
  app timer reset
  after 1500
  puts "After time [app timer time] seconds!"
> ```

<a name="treeview">*cmdName* **treeview**  *pathname ?-option value ...?* </a>

> Creates a standard *ttk::treeview* widget with additional sorting feature for the columns and banding stripes for the rows.
  It has as well a *loadData* method to load nested lists. See the following example.

> ```
  dgw::basegui app
  set f [app getFrame]
  set tv [app treeview $f.tv]
  set headers {country capital currency unit}
  set data {
   {Argentina          "Buenos Aires"          ARS 0.12}
   {Australia          Canberra                AUD 0.11}
   {Brazil             Brazilia                BRL 0.33}
   {Canada             Ottawa                  CAD 0.56}
   {China              Beijing                 CNY 0.88}
   {France             Paris                   EUR 1.23}
   {Germany            Berlin                  EUR 0.124}
   {India              "New Delhi"             INR 0.12345}
   {Italy              Rome                    EUR 1.2345}
 }
 pack $tv  -side left -expand yes -fill both
 $tv loadData $headers $data
> ```

## <a name='example'>EXAMPLE</a>

The following example demonstrates a few features for creating new standalone applications using the faciltities of 
of the *dgw::basegui* snit type. The code can be executed directly using the *--demo* commandline switch.


    ::dgw::basegui app -style clam
    puts "Startup in [app timer time] seconds!"
    app timer reset
    after 1500
    puts "After time [app timer time] seconds!"
    set fmenu [app getMenu "File"]
    $fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
    app addStatusBar
    set stb [app subwidget statusbar]
    $stb progress 100
    $stb set "starting ..."
    after 100
    app status progressing... 50
    after 1000
    app status finished 100
    set f [app getFrame]
    set btn [ttk::button $f.btn -text "Hover me!"]
    app balloon $btn "This is the hover message!\nNice ?"
    pack $btn -side top
    set tf [ttk::frame $f.tframe]
    set t [text $tf.text -wrap none]
    app autoscroll $t
    for {set i 0} {$i < 30} {incr i} {
        $t insert end "Lorem ipsum dolor sit amet, consectetur adipiscing elit, 
      sed do eiusmod tempor 
         incididunt ut labore et dolore magna aliqua. 
       Ut enim ad minim veniam, quis nostrud exercitation 
         ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n"
    }
    pack $tf -side top -fill both -expand yes
    pack [canvas $f.c] -side top -fill both -expand true
    set id [$f.c create oval 10 10 110 110 -fill red]
    app cballoon $f.c $id "This is a red oval"
    $f.c create rect 130 30 190 90 -fill blue -tag rect
    app cballoon $f.c rect "This is\na blue square"
    set nb [app notebook $f.nb]
    set bframe [ttk::frame $nb.bf]
    $nb add $bframe -text "rotext"
    set rotext [app rotext $bframe.rotext]
    app autoscroll $rotext
    for {set i 0} {$i < 50} {incr i 1} {
       $rotext ins end "Hello rotext ...\n"
    }
    set evar "entries text"
    app labentry $nb.len -label "The label" -textvariable evar
    $nb add $nb.len -text "labentry"
    pack $nb -side top -fill both -expand true


## <a name='inheritance'>INHERITANCE</a>

This snit type can be used to build up other more specialized applications. Here is an example, 
where we create a generic Editor class which adds additional menu points and embeds 
a scrolled text widget.

The most basic inheritance example would be just copying the functionality without the text widget.


    package require dgw::basegui
    snit::type EditorApp {
       component basegui
       # inheritance
       delegate method * to basegui
       delegate option * to basegui
       # variable addon to extend basegui
       variable textw
       constructor {args} {
            install basegui using dgw::basegui %AUTO%
            $self configurelist $args    
            # added functionality
            set f [$basegui getFrame]
            set textw [text $f.t -wrap none]
            $self autoscroll $textw
       }
       # added functionality
       # access functionality of the text widget
       # like: % app text insert end "hello basegui world"
       method text {args} {
          $textw {*}$args
       }
    }
    if {[info exists argv0] && $argv0 eq [info script]} {
       #start editor
       EditorApp app
       app text insert end "Hello EditorApp!!"
    }


This simple example should show how to extend the functionality of the basegui toplevel.
Before you start to write specialized applications you should create a simple proxy class which 
does nothing more than inheriting from `dgw::basegui` first. This is the code above without the text widget parts. 
You can then extend this base class and your specialized applications inherit from your baseclass. 
This allows you to extend all your specialized classes using your baseclass. So your setup should be:


    
                                     -- your::editor
    dgw::basegui -- your::basegui ---+
                                     -- your::databasebrowser
    
    


This is in the long term better than inheriting from `dgw::basegui` directly. You don't like to change the code of 
this class, but you can change `your::basegui` for instance to give better help facilities in the Help menu, or other features you need in your applications most of the time.
If you do this both application `your::editor` and `your::databasebrowser` will have this functionality at the same time 
after implementing it in `your::basegui` type. If you follow this approach you can easily update the *dgw::basegui* package without loosing your new functionalities.

## <a name='install'>INSTALLATION</a>

Installation is easy you can easily install and use this ** dgw::basegui** package if you have a working install of:

- the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file `dgw/basegui-0.2.tm` in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of basegui.tcl. 
Try "tclsh basegui.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish basegui.tcl --demo


The example code used for this demo can be seen in the terminal by using the following command line:


    $ tclsh basegui.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh basegui.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. 
You can as well use this markdown output directly to create html pages for 
the documentation by using the *--html* flag if the Markdown library of 
tcllib is installed on your machine.


    $ tclsh basegui.tcl --html


This will directly create a HTML page `basegui.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh basegui.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../basegui.tcl --man > basegui.md
    pandoc -i basegui.md -s -o basegui.html
    pandoc -i basegui.md -s -o basegui.tex
    pdflatex basegui.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: https://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODOS</a>

* socket check for starting the application twice
* tooltip embedded (done)
* auto scrolled command embedded for x and y scrollbars (done)

## <a name='authors'>AUTHOR</a>

The **basegui** command was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

 dgw::basegui command, version 0.2.

Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



