##############################################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Jan 17 05:48:00 2017
#  Last Modified : <200227.1431>
#
#  Description	 : Snit type as a base class to build Tk applications
#
#  Notes         : 
#
#  History       : 2020-01-18 - Release 0.1
#                  2020-01-19 - Version 0.2
#                               - rotext command added   
#                               - center command added
#                               - notebook command added
#                               - labentry command added
#                               - timer command added
#                               - start option to allow using commands in existing applications
#                               - treeview widget with sorting facilities
#	
##############################################################################
#
#  Copyright (c) 2017-2020 Dr. Detlef Groth.
# 
#' ---
#' documentclass: scrartcl
#' title: dgw::basegui __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' ---
#' 
#' ## NAME
#'
#' > **dgw::basegui** - starting point framework for writing Tk applications
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [TYPE OPTIONS](#options)
#'  - [TYPE COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [INHERITANCE](#inheritance)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgw::basegui
#' dgw::basegui cmdName
#' cmdName addStatusBar
#' cmdName autoscroll pathname
#' cmdName balloon pathname message
#' cmdName cballon canvasname tag message
#' cmdName center window
#' cmdName console ?pathname?
#' cmdName dlabel pathname
#' cmdName getFrame
#' cmdName getMenu
#' cmdName labentry pathname
#' cmdName message msg
#' cmdName notebook pathname
#' cmdName progress value
#' cmdName rotext pathname
#' cmdName splash imgfile ?-delay milliseconds -message textmessage?
#' cmdName status msg ?value?
#' cmdName subwidget widgetName
#' cmdName timer mode
#' cmdName treeview pathname
#' ```


package require Tk
package require dgw::statusbar
package require dgw::dgwutils
package provide dgw::basegui 0.2

#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **dgw::basegui** application framework serves as building block for writing  Tk applications. 
#' It can be used for new applications as starting point providing useful widgets such as a ready to use menubar, a mainframe and
#' a statusbar etc and various utility methods, for instance to add scrollbars, centering a window on the screen. It can be however as well added to existing applications as it provides a few 
#' useful small widgets required in standard applications, such as a tooltip/balloon, a sortable table widget (based on ttk::treeview), 
#' a splash toplevel, a notebook with reorganizing facilities and popumenu for renaming tabs, a labentry and so on. 
#' Those widgets in many cases just add small functionalities with one or two new methods or options to existing widgets, 
#' not worth to put them into extra widget manual pages or even packages. These widgets are therefore documented in this manual page.
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::basegui** *cmdName ?options?*
#' 
#' > Creates and configures a new dgw::basegui application  using the main Tk window id _._ and the given *options*. 
#'   If the functionalties in this package should be added to existing applications the option *-start* should be set to *false*. See the _start_ option below for a more detailed explanation.
#'  
#' ## <a name='options'>TYPE OPTIONS</a>
#' 
#' The **dgw::basegui** snit type supports the following options:

namespace eval dgw {}

# read only text widget from the snitfaq page: 
# https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/snit/snitfaq.md
::snit::widgetadaptor dgw::rotext {
    # ignored, should be silently taken and ignored
    option -autoscroll ""
    constructor {args} {
        # Create the text widget; turn off its insert cursor
        installhull using text -insertwidth 0 -border 5 -relief flat

        # Apply any options passed at creation time.
        $self configurelist $args
    }

    # Disable the text widget's insert and delete methods, to
    # make this readonly.
    method insert {args} {}
    method delete {args} {}

    # Enable ins and del as synonyms, so the program can insert and
    # delete.
    delegate method ins to hull as insert
    delegate method del to hull as delete

    # Pass all other methods and options to the real text widget, so
    # that the remaining behavior is as expected.
    delegate method * to hull
    delegate option * to hull
}
snit::widget ::dgw::labentry {
    option -dummy ""
    component entry
    component label
    delegate option * to entry except -label
    delegate option -label to label as -text
    delegate method * to entry
    constructor {args} {
        install label using ttk::label $win.lbl
        install entry using ttk::entry $win.entry ;# -textvariable [myvar EntryText]
        $self configurelist $args
        pack $win.lbl -side left -fill x -expand false -padx 5 -pady 5
        pack $win.entry -side left -fill x -expand false -padx 5 -pady 5
        
    }
    # not required
    method bind {evt script} {
        bind $entry $evt $script
    }
    # access to internal widgets
    method entry {} {
        return $entry
    }
    method label {} {
        return $label
    }
}
snit::widget dgw::snotebook {
    option -createcmd ""
    option -raisecmd ""
    option -closecmd ""
    option -renamecmd ""
    option -movecmd ""    
    variable nb
    variable nbtext
    variable child
    delegate option * to nb
    delegate method * to nb except [list add bind]
    constructor {args} {
        $self configurelist $args
        install nb using ttk::notebook $win.nb ;#-side top -width 150 -height 50        
        pack $nb -fill both -expand yes -side top
        bind $nb <KeyPress-F2> [mymethod tabRename %x %y]
        bind $nb <Button-3> [mymethod tabRename %x %y]        
        bind $nb <Control-Shift-Left> [mymethod tabMove left %W]
        bind $nb <Control-Shift-Right> [mymethod tabMove right %W]
        bind $nb <Control-w> [mymethod tabClose %W]   
        bind $nb <Control-t> [mymethod new %W]        
        bind $nb <Enter> [list focus -force $nb]
        if {$options(-raisecmd) ne ""} {
            bind $nb <<NotebookTabChanged>>  [mymethod raise %W]
        }

    }
    method add {page args} {
        $nb add $page {*}$args
        if {$options(-createcmd) ne ""} {
            eval $options(-createcmd) $nb $page
        }

    }
    method raise {w} {
        eval $options(-raisecmd) $w [$w index current]
    }
    method new {w} {
        frame $nb.f[llength [$nb tabs]]
        $self add $nb.f[llength [$nb tabs]] -text "Tab [expr {[llength [$nb tabs]] + 1}]"
    }
    method bind {ev script} {
        bind $nb $ev $script
    }
    method tabClose {w} {
        set child [$w select]
        set answer [tk_messageBox -title "Question!" -message "Really close tab [$w tab $child -text] ?" -type yesno -icon question]
        if { $answer } {
            $w forget $child
            destroy $child
        } 
    }
    method tabRename {x y} {
        set nbtext ""
        if {![info exists .rename]} {
            toplevel .rename
            wm overrideredirect .rename true
            #wm title .rename "DGApp" ;# for floating on i3
            set x [winfo pointerx .]
            set y [winfo pointery .]
            entry .rename.ent -textvariable [myvar nbtext]
            pack .rename.ent -padx 5 -pady 5
        }
        wm geometry .rename "180x40+$x+$y"
        set tab [$nb select]
        set nbtext [$nb tab $tab -text]
        focus -force .rename.ent
        bind .rename.ent <Return> [mymethod doTabRename %W]
        bind .rename.ent <Escape> [list destroy .rename]
        
    }
    method doTabRename {w} {
        set tab [$nb select]
        $nb tab $tab -text $nbtext
        if {$options(-renamecmd) ne ""} {
            eval $options(-renamecmd) $nb $tab
        }

        destroy .rename
    }
    method tabMove {dir w} {
        #puts move$dir
        set idx [lsearch [$nb tabs] [$nb select]]
        #puts $idx
        set current [$nb select]
        if {$dir eq "left"} {
            if {$idx > 0} {
                $nb insert [expr {$idx - 1}]  $current
            }
        } else {
            if {$idx < [expr {[llength [$nb tabs]] -1}]} {
                $nb insert [expr {$idx + 1}] $current
            }
        }
        if {$options(-movecmd) ne ""} {
            eval $options(-movecmd) $nb $current $dir
        }

        # how to break automatic switch??
        after 100 [list $nb select $current]
    }
}
# dynamic font size label
snit::widget  dgw::dlabel {
    component label
    option -text "Default"
    delegate method * to label
    delegate option * to label
    option -font ""
    constructor {args} {
        install label using ttk::label $win.lbl {*}$args
        $self configurelist $args
        if {$options(-font) eq ""} {
            set mfont [font create {*}[font configure TkDefaultFont]]
            $label configure -font $mfont
            set options(-font) $mfont
        }
        pack $label -side top -fill both -expand yes -padx 10 -pady 10
        bind  $label <Configure> [mymethod configureBinding %W %w %h] 
    }
    method adjustFont {width height} {
        set cw [font measure $options(-font) $options(-text)]
        set ch [font metrics $options(-font)]
        set size [font configure $options(-font) -size]
        # shrink
        set shrink false
        while {true} {
            set cw [font measure $options(-font) $options(-text)]
            set ch [font metrics $options(-font)]
            set size [font configure $options(-font) -size]

            if {$cw < $width && $ch < $height} {
                break
            }
            incr size -2
            font configure $options(-font) -size $size
            set shrink true
        }
        # grow
        while {!$shrink} {
            set cw [font measure $options(-font) $options(-text)]
            set ch [font metrics $options(-font)]
            set size [font configure $options(-font) -size]
            if {$cw > $width || $ch > $height} {
                incr size -2 ;#set back
                font configure $options(-font) -size $size
                break
            }
            incr size 2
            font configure $options(-font) -size $size
        }
    }
    
    method configureBinding {mwin width height} {
        bind $mwin <Configure> {}
        $self adjustFont $width $height
        after idle [list bind $mwin <Configure> [mymethod configureBinding %W %w %h]]
    }
}

# standard ttk::treeview with sort facilities if in table mode
snit::widget dgw::treeview {
    component treeview
    variable lnum ;# keeps the number of items
    variable _DATA
    delegate option * to treeview 
    delegate method * to treeview
    constructor {args} {
        $self configurelist $args
        install treeview using ::ttk::treeview $win.tv -show headings 
        pack $treeview -side top -fill both -expand yes 
    }
    typeconstructor {
        image create photo arrow(1) -data {
            R0lGODlhEAAQAIIAAAT+BPwCBAQCBAQC/FxaXAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAM5CBDM+uKp8KiMsmaAs82dtnGeCHnNp4TjNQ4jq8CbDNOr
            oIe3ROyEx2A4vOgkOBzgFxQ6Xa0owJ8AACH+aENyZWF0ZWQgYnkgQk1QVG9H
            SUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxs
            IHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo arrow(0) -data {
            R0lGODlhEAAQAIIAAAT+BAQC/AQCBPwCBFxaXAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAM4CAqxLm61CGBs81FMrQxgpnhKJlaXFJHUGg0w7DrDUmvt
            PQo8qyuEHoHW6hEVv+DQFvuhWtCFPwEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }

        image create bitmap arrow(2) -data {
            #define arrowUp_width 7
            #define arrowUp_height 4
            static char arrowUp_bits[] = {
                0x08, 0x1c, 0x3e, 0x7f
            };
        }
        image create bitmap arrow(3) -data {
            #define arrowDown_width 7
            #define arrowDown_height 4
            static char arrowDown_bits[] = {
                0x7f, 0x3e, 0x1c, 0x08
            };
        }
        image create bitmap arrowBlank -data {
            #define arrowBlank_width 7
            #define arrowBlank_height 4
            static char arrowBlank_bits[] = {
                0x00, 0x00, 0x00, 0x00
            };
        }   
    }
    method loadData {headers data} {
        #puts "beginn: [$mtimer seconds]"
        set font [::ttk::style lookup [$treeview cget -style] -font]
        set x 0
        $treeview delete {}
        $treeview configure -columns $headers -show headings
        $treeview column #0 -width -1
        foreach col $headers {
            set idx #[incr x]
            $treeview heading $idx -text "$col " -image arrowBlank \
                  -command [mymethod SortBy $col 0] 
            $treeview column $idx -width 140 -stretch true
        }
        set lnum 0
        set max [llength $data]
        foreach dat [lreverse $data] {
            $treeview insert {} 0 -values $dat -tag "tag[incr lnum]"
            if {[expr {$lnum % 100000}] == 0} {
                update idletasks
            }
        }
        $self BandTable
        $self correctColumnWidths
        set _DATA $data
                
    }
    method correctColumnWidths {} {
        set width [winfo width $treeview]
        set ncol [llength [$treeview cget -columns]]
        set cwidth [expr {round((($width-15)/$ncol))}]
        set idx -1
        foreach ccol [$treeview cget -columns] {
            incr idx
            $treeview column $idx -width $cwidth -minwidth 60
        }

    }
    method SortBy {col direction} {
        #set mtimer [Timer %AUTO%]
        set ncol [lsearch -exact [$treeview cget -columns] $col]
        # Build something we can sort
        $treeview delete [$treeview children ""]
        set dir [expr {$direction ? "-decreasing" : "-increasing"}]
        set stype dictionary
        if {[string is double [lindex [lindex $_DATA 0] $ncol]]} {
            set stype real
        }  elseif {[string is integer [lindex [lindex $_DATA 0] $ncol]]} {
            set stype integer
        }
        set data [lsort -$stype -index $ncol $dir $_DATA]
        $self loadData [$treeview cget -columns] $data
        #        set width [winfo width $treeview]
        #        set ncol [llength [$treeview cget -columns]]
        #        set cwidth [expr {round((($width-15)/$ncol))}]
         set idx -1
        foreach ccol [$treeview cget -columns] {
            incr idx
            set img arrowBlank
            if {$ccol == $col} {
                set img arrow($direction)
            }
            $treeview heading $idx -image $img
            #$treeview column $idx -width $cwidth
        }
        set cmd [mymethod SortBy $col [expr {!$direction}]]

        $treeview heading $col -command $cmd
    }
    method BandTable {} {
        array set colors {0 #FFFFFF 1 #DDDDFF}
        set id 1
        foreach row [$treeview children {}] {
            set id [expr {! $id}]
            set tag [$treeview item $row -tag]
            $treeview tag configure $tag -background $colors($id)
        }
    }

}

# styles
ttk::style layout ToolButton [ttk::style layout TButton]
ttk::style configure ToolButton [ttk::style configure TButton]
ttk::style configure ToolButton -relief groove
ttk::style configure ToolButton -borderwidth 2
ttk::style configure ToolButton -padding {2 2 2 2} 

ttk::style configure Treeview -background white
option add *Text.background    white

# fix for treeview in 8.6.9
if {$::tcl_patchLevel eq "8.6.9"} {
    # https://core.tcl.tk/tk/info/509cafafae
    # bug with tag preferences, 
    # let stripes work again
    apply {name {
            set newmap {}
            foreach {opt lst} [ttk::style map $name] {
                if {($opt eq "-foreground") || ($opt eq "-background")} {
                    set newlst {}
                    foreach {st val} $lst {
                        if {($st eq "disabled") || ($st eq "selected")} {
                            lappend newlst $st $val
                        }
                    }
                    if {$newlst ne {}} {
                        lappend newmap $opt $newlst
                    }
                } else {
                    lappend newmap $opt $lst
                }
            }
            ttk::style map $name {*}$newmap
    }} Treeview
}
# simple timer
snit::type dgw::Timer {
    variable time
    constructor {} {
        set time [clock seconds]
    }
    method seconds {} {
        set now [clock seconds]
        return [expr {$now-$time}]
    }
    method reset {} {
        set time [clock seconds]
    }
}


snit::type ::dgw::basegui {
    #hulltype toplevel
    
    #' 
    #'   __-style__ _styleName_ 
    #' 
    #'  > Configures the ttk style for all widgets within the application. 'clam' and 'default# should be supported on all platforms. 
    #'    Use `ttk::style theme names` within an interactive wish session to find out which themes are available on your machine.
    option -style ""
    
    #' 
    #'   __-start__ _boolean_ 
    #' 
    #'  > Should the application in the toplevel be started automatically. Default to *true*. 
    #' In cases where you like to add just a few of the small widgets or utility methods of the *dgw::basegui* package such as 
    #' *balloon*, *notebook*, *rotext*, *labentry* or some others to an existing application you should set 
    #' this as *false* at object creation.
    #'
    #' > The following methods can be used inside existing applications if the option *-start* was set to false:
    #' 
    #' >  - [autoscroll](#autoscroll)
    #'    - [balloon](#balloon)
    #'    - [cballoon](#cballoon)
    #'    - [center](#center)
    #'    - [console](#console)
    #'    - [dlabel](#dlabel)
    #'    - [notebook](#notebook)
    #'    - [rotext](#rotext)
    #'    - [splash](#splash)
    #'    - [timer](#timer)
    #'    - [treeview](#treeview)
    #' 
    option -start true

    variable var
    variable gui
    variable x
    variable top
    variable console 
    variable timer
    constructor {args} { 
        #installhull using $win
        $self configurelist $args
        set timer [Timer %AUTO%]
        if {$options(-start)} {
            set path .
            set top $path ;# $path
            #installhull using toplevel $top
            $self init
            $self gui
        }
    }
    onconfigure -style value {
        if {$value ne ""} {
            ttk::style theme use $value
        }
        set options(-style) $value
    }
    method init {} {
        #my variable var
        set var(appname) DGBaseGuiApp
        set var(author) "Dr. Detlef Groth"
        set var(revision) 0.1
        set var(year) 2020
        if {[info exists ::starkit::topdir]} {
            set var(helpfile) [file join $::starkit::topdir lib app-$var(appname) html-$var(appname) index.html]
            set var(iconfile) [file join $::starkit::topdir lib app-$var(appname) $var(appname).ico]
        } else {
            set var(helpfile) [file join [file dirname [info script]] html-$var(appname) index.html]
            set var(iconfile) [file join [file dirname [info script]] $var(appname).ico]
        }
    }
    method exit {{ask true}} {
        if {$ask} {
            set answer [tk_messageBox -title "Question!" -message "Really quit application ?" -type yesno -icon question]
            if { $answer } {
                exit 0
            } 
        }

    }
    method about {} {
        tk_messageBox -title "Info!" -icon info -message \
              "$var(appname)\n@$var(author)\n$var(year)" -type ok
    }
    # todo
    method setAppname {appname revision author year} {
        set var(appname) $appname
        set var(revision) $revision
        set var(author) $author
        set var(year) $year
        wm title $top "$var(appname), $var(revision), by @ $var(author), $var(year)"
    }
    method Exit { } {
        puts "privat Exit"
        exit 0
    }
    method gui {} {
        wm protocol $top WM_DELETE_WINDOW  [mymethod  exit]
        wm title $top "$var(appname), $var(revision), by @ $var(author), $var(year)"
        if {$top eq "."} {
            set t ""
        } else {
            set t $top
        }
        menu $t.mbar
        $top configure -menu $t.mbar
        menu $t.mbar.fl -tearoff 0
        menu $t.mbar.hlp -tearoff 0
        $t.mbar add cascade -menu $t.mbar.fl -label File  -underline 0
        $t.mbar add cascade -menu $t.mbar.hlp -label Help  -underline 0

        $t.mbar.fl add separator
        $t.mbar.fl add command -label Exit -command [mymethod exit] -underline 1
        
        $t.mbar.hlp add command -label About -command [mymethod about] -underline 0
        set var(menu,file) $t.mbar.fl
        set var(menu,help) $t.mbar.hlp
        set gui(frame) [ttk::frame $t.frame]
        pack $gui(frame) -side top -fill both -expand yes
        set gui(sep) [ttk::separator $t.sep -orient horizontal]
        set gui(statusbar) [::dgw::statusbar $t.stb]
        #wm iconbitmap $top $var(iconfile)
        #my Exit
    }
    #'
    #' ## <a name='commands'>TYPE COMMANDS</a>
    #' 
    #' Each **dgw::basegui** command supports the following public methods to be used within inheriting applications to extend the basic application.
    #' Alternatively widgets can be added to existing applications as well.
    #' 
    #' *cmdName* **addStatusBar** 
    #' 
    #' > Packs and displays the statusbar widget at the bottom of the application. 
    #' If not called the statusbar will be invisible.

    method addStatusBar {} {
        pack $gui(sep) -side top -expand false -fill x
        pack $gui(statusbar) -side top -expand false -fill x
    }
    #-- A autoscrollbar  which appears only when needed, removes requirement of autoscroll
    #'
    #' <a name="autoscroll">*cmdName* **autoscroll**  *pathname*</a>
    #' 
    #' > For the widget belonging to *pathname* add horizontal and vertical scrollbars, shown only when needed.
    #'   Please note, that the widget in *pathname* must be the only child of a `tk::frame` or a `ttk::frame` widget created already.
    #'    The widget *pathname* is then managed by grid, don't pack or grid the widget in *pathname* yourself. Handle it's geometry
    #'   via its parent frame. See the following example:
    #'
    #' > ```
    #' package require dgw::basegui
    #' ::dgw::basegui app -style clam
    #' set f [app getFrame]
    #' set tf [ttk::frame $f.tframe]
    #' set t [text $tf.text -wrap none]
    #' app autoscroll $t
    #' for {set i 0} {$i < 30} {incr i} {
    #'     $t insert end "Lorem ipsum dolor sit amet, ....\n\n"
    #' }
    #' pack $tf -side top -fill both -expand yes
    #' > ```
    #'
    method autoscroll {w} {
        set frame [winfo parent $w]
        grid $w -in $frame -row 0 -column 0 -sticky nsew
        grid rowconfigure $frame $w -weight 1
        grid columnconfigure $frame $w -weight 1
        ttk::scrollbar $frame.vsb -command "$w yview"       
        grid $frame.vsb -row 0 -column 1 -sticky ns
        ttk::scrollbar $frame.hsb -orient horizontal -command "$w xview"       
        grid $frame.hsb -row 1 -column 0 -sticky ew 
        $w configure -yscrollcommand [mymethod scrollSet $frame.vsb] \
              -xscrollcommand [mymethod scrollSet $frame.hsb]
        grid propagate $w true
    }
    # private method
    method scrollSet {w lo hi} {
        if {$lo <= 0.0 && $hi >= 1.0} {
            grid remove $w
        } else {
            grid $w
        }
        $w set $lo $hi
    }
    #-- A simple balloon, modified from Bag of Tk algorithms:  
    #'
    #' <a name="balloon">*cmdName* **balloon**  *pathname message ?display?* </a>
    #' 
    #' > For the widget belonging to *pathname* displays for around three seconds a small tooltip 
    #'   using the given *message*. The boolean variable *display* can be used to unregister the tooltip 
    #'   at a later point. See as well [cballoon](#cballoon) for tooltip on canvas tags.
    
    method balloon {w msg {display false}} {
        if {$display} {
            set top .balloon
            catch {destroy $top}
            toplevel $top -bd 1
            wm overrideredirect $top 1
            wm geometry $top +[expr {[winfo pointerx $w]+5}]+[expr {[winfo pointery $w]+5}]
            pack [message $top.txt -aspect 10000 -bg lightyellow \
                  -borderwidth 0 -text $msg -font {Helvetica 9}]
            bind  $top <1> [list destroy $top]
            raise $top
            after 3000 destroy $top
        } else {
            bind $w <Enter> [mymethod balloon $w $msg true]
            bind $w <Leave> { catch destroy .balloon }
        }
    }
    
    #-- A simple balloon for canvas items, https://wiki.tcl-lang.org/image/WikiDbImage+cballoon
    #-- https://wiki.tcl-lang.org/page/Canvas+balloon+help?R=0
    #'
    #' <a name="cballoon">*cmdName* **cballoon**  *pathname tag message*</a>
    #' 
    #' > For the widget belonging to *pathname* display for the canvas items labeled with *tag* the 
    #'   given message. See as well [balloon](#balloon) for standard tooltips for widgets.

    method cballoon {w tag text} {
        $w bind $tag <Enter> [mymethod cballoonMake $w $text]
        $w bind all  <Leave> [list after 1 $w delete cballoon]
    }
    
    method cballoonMake {w text} {
        foreach {- - x y} [$w bbox current] break
        if [info exists y] {
            set id [$w create text $x $y -text $text -tag cballoon]
            foreach {x0 y0 x1 y1} [$w bbox $id] break
            $w create rect $x0 $y0 $x1 $y1 -fill lightyellow -tag cballoon
            $w raise $id
            after 3000 [list $w delete cballoon]
        }
    }
    #'
    #' <a name="center">*cmdName* **center** *window*</a>
    #' 
    #' > Centers a toplevel window on the screen.

    method center {w} {
        wm withdraw $w
        set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
               - [winfo vrootx [winfo parent $w]]]
        set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
               - [winfo vrooty [winfo parent $w]]]
        wm geom $w +$x+$y
        wm deiconify $w
    }

    #-------    
    #-- A simple console, modified from https://wiki.tcl-lang.org/page/A+minimal+console
    #'
    #' <a name="console">*cmdName* **console** *?pathname?*</a>
    #' 
    #' > Displays a simple console in a toplevel if the target *pathname* is not given, or within the application if the given *pathname*
    #'  is a valid widget path within an existing toplevel. This console can be used to debug applications and
    #'   to inspect variables, commands etc. Based on wiki code in [A minimal console](https://wiki.tcl-lang.org/page/A+minimal+console). The *puts* commands entered within the *console* widget are displayed within the widget.
    
    method console {{target ".console"}} {
        if {$target eq ".console"} {
            catch {
                destroy $target
            }
            toplevel .console
        } 
        frame $target.fr
        text $target.fr.cmd -wrap word
        set console $target.fr.cmd
        $self autoscroll $console
        bind $console <Return> [mymethod evalConsoleCmd]
        bind $console <Return> +break
        $console tag configure success -foreground \#008800
        $console tag configure failure -foreground red
        $console tag configure terminal -foreground blue
        $console insert end "% " terminal 
        pack $target.fr -side top -fill both -expand true
        
    }
    # private method
    method evalConsoleCmd {} {
        set c $console
        if {[$c compare {insert + 1 lines} < end]} then {
            set l [$c get {insert linestart} {insert lineend}]
            $c insert {end - 1 chars} \n[string trimright $l]
            $c mark set insert end
            $c see insert
        } else {
            set code [$c get end-1lines+2chars end-1chars]
            # direct puts to terminal
            set start [string range $code 0 4]
            if {$start eq "puts "} {
                set code "set temphjkil [string range $code 5 end]"
                if {[catch {
                     set result [uplevel #0 "$code"]
                } err]} then {
                     $c insert end \n {"} $err failure \n
                } else {
                    $c insert end \n {} $result success \n
                }
            } else {
                if {[catch {
                     set result [uplevel #0 [$c get end-1lines+2chars end-1chars]]
                } err]} then {
                     $c insert end \n {"} $err failure \n
                } else {
                    $c insert end \n {} $result success \n
                }
            }
            $c insert end "% " terminal 
        }
    }
    #'
    #' <a name="dlabel">*cmdName* **dlabel** *window*</a>
    #' 
    #' > Creates a ttk::label where the font size is dynamically adjusted to the widget size. Here an example:
    #'
    #' > ```
    #' dgw::basegui app -start false
    #' font create title -family Helvetica -size 10
    #' toplevel .test
    #' set txt " Some Title "
    #' app dlabel .test.l -text $txt -font title
    #' pack  .test.l -expand 1 -fill both
    #' wm geometry .test 400x300+0+0
    #' > ```
    #' 
    method dlabel {w args} {
         dgw::dlabel $w {*}$args
   
    }
    #'
    #' *cmdName* **getFrame**  
    #' 
    #' > Returns the mainframe of the application.
    #'   This function allows adding more widgets to the interior of the application in inheriting applications or at a later point.

    method getFrame {} {
        return $gui(frame)
    }
    #'
    #' *cmdName* **getMenu** *menuName ?option value ...?*  
    #' 
    #' > Returns the menu entry belonging to the given *menuName* or creates a new cascade with this *menuName* 
    #'   in the application menubar. 
    #'   This function allows adding more menu points in inheriting applications or at a later point to the application.
    #'   At creation time or therafter additional configuration options can be given such as *-underline 0* for instance. Here an example for inserting new menu points  
    #'
    #' > ```
    #' ::dgw::basegui app -style clam
    #' set fmenu [app getMenu "File"]
    #' $fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
    #' > ```
    #'  

    method getMenu {name args} {
        set wpath [string tolower [regsub -all { } $name ""]]
        if {$top eq "."} {
            set t ""
        } else {
            set t $top
        }
        if {[info exists var(menu,$wpath)]} {
            if {[llength $args] > 0} {
                if {$wpath eq "file"} {
                    set idx 1
                } elseif {$wpath eq "help"} {
                    set idx end
                } else {
                    set idx $var(menuidx,$wpath)
                }
                $t.mbar entryconfigure $idx {*}$args
            }
            return $var(menu,$wpath)
        } else {
            set idx [$t.mbar index end]
            menu $t.mbar.$wpath -tearoff 0
            $t.mbar insert $idx cascade -menu  $t.mbar.$wpath -label $name
            set var(menu,$wpath) $t.mbar.$wpath
            set var(menuidx,$wpath) $idx
            if {[llength $args] > 0} {
                $t.mbar entryconfigure $idx {*}$args
            }
            return $var(menu,$wpath)
        }
    }
    
    #'
    #' <a name="labentry">*cmdName* **labentry**  *pathname ?-option value ...?*</a>
    #' 
    #' > Creates a simple *labentry* widget where the main widget is the entry widget. 
    #' The label is set with the *-label* option. All other options and methods are delegated to the entry widget. 
    #' The widget provides two additional methods:
    #'
    #' > - *pathname entry* to access directly the internal entry widget
    #'   - *pathname label* to access directly the internal label widget
    method labentry {w args} {
        dgw::labentry $w {*}$args
    }
    #'
    #' *cmdName* **message**  *msg*
    #' 
    #' > Displays the text of *msg* in the statusbar. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    
    method message {msg} {
        $gui(statusbar) set $msg
    }
    #'
    #' <a name="notebook">*cmdName* **notebook**  *pathname ?-option value?*</a>
    #' 
    #' > Creates a standard *ttk::notebook* with some additional features, like right click popup for adding new tabs, rename existing tabs and changing tab order. There is further one additional option available:
    #'
    #' > - *-createcmd command* invokes the given *command* if a new page is created. The *pathname* of the notebook and the page *index* are added as arguments to the script call.
    #'
    #' > The widget further adds the following bindings to the standard *ttk::notebook* widget:
    #'
    #' > - *F2* - popup for moving and renaming tabs
    #'   - *Button-3* - popup for moving and renaming tabs
    #'   - *Ctrl-Shift-Left* - move current tab to the left
    #'   - *Ctrl-Shift-Right* - move current tab to the right
    #'   - *Ctrl-w* - close current tab
    #'   - *Ctrl-t* - create new tab
    
    method notebook {w args} {
        dgw::snotebook $w {*}$args
    }
    
    #'
    #' *cmdName* **progress**  *value* 
    #' 
    #' > Displays the given *value* within the progressbar in the statusbar widget. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    method progress {value} {
        $gui(statusbar) progress $value
    }
    #'
    #' <a name="rotext">*cmdName* **rotext**  *pathname* *?-option value ...?*</a>
    #' 
    #' > Creates a readonly *text* widget. All options are delegated to the standard textwidget, except for *-insertwidth*.
    #'   The standard commands for the text widget work but not *insert* and *delete*. They are replaced with the *ins* and *del* subcommands. Useful fot displaying text to the user which should not be changed. See the following example on how to handle inserts into the *rotext* widget:
    #'
    #' > ```
    #' package require dgw::basegui
    #' dgw::basegui app
    #' # main application frame
    #' set f [app getFrame]
    #' # it is best to place it in a single frame if you need scrollbars
    #' set roframe [ttk::frame $f.rf]
    #' set rotext [app rotext $roframe.rotext -background salmon]
    #' app autoscroll $rotext
    #' # scrollbar free rotext can be placed directly into the main frame
    #' set rotext2 [app rotext $f.rotext -autoscroll false]
    #' for {set i 0} {$i < 100} {incr i 1} {
    #'    $rotext ins end "Sample text line $i\n"
    #'    $rotext2 ins end "Sample text line $i\n"
    #' }
    #' pack $roframe -side top -fill both -expand true
    #' pack $rotext2 -side top -fill both -expand true
    #' > ```
    
    method rotext {pathname args} {
        set rotext [dgw::rotext $pathname {*}$args]
        return $rotext
    }
    #'
    #' <a name="splash">*cmdName* **splash**  *imgfile ?-delay milliseconds -message textmessage?* </a>
    #' 
    #' > Hides the main application and shows the given image in *imgfile* as well as some 
    #'   textmessage given with the option -message. The splash screen destroys itself after the given delay, default 2500. 
    #'   If delay is given as zero (0), the splash widget is not destroyed. If the *imgfile* variable is given as `update` 
    #'   then additional messages can be given to the splash widget. To destroy the splash method should be called with the
    #'   imgfile argument `destroy`. See below for an example. 
    #'   The pathname of the splash toplevel is `.splash`.
    #'
    #' > Example with a simple single message splash:
    #' 
    #' > ```
    #' app splash splash.png -delay 2000 -message "Loading editor application ..."
    #' > ```
    #' 
    #' > Example with multiple messages:
    #' 
    #' > ```
    #' app splash splash.png -delay 0 -message "Loading editor application ..."
    #' after 2000 { app splash update -message "Loading data for editor application ..." }
    #' after 4000 { app splash destroy }
    #' > ```
    method splash {imgfile args} {
        array set arg [list -delay 0 -message "Loading application ..."]
        array set arg $args
        if {$imgfile eq "destroy"} {
            destroy .splash
             wm deiconify .
        } elseif {$imgfile ne "update"} {
            if {[catch {image create photo splash -file $imgfile}]} {
                error "image $imgfile not found"
            }
            wm withdraw .
            toplevel .splash
            wm overrideredirect .splash 1
            canvas .splash.c -highlightt 0 -border 0
            
            .splash.c create image 0 0 -anchor nw -image splash
            foreach {- - width height} [.splash.c bbox all] break
            .splash.c config -width $width -height $height
            pack .splash.c
            pack [ttk::label .splash.label -text $arg(-message) -font 16] -padx 20 -pady 10 -side top
            pack [ttk::progressbar .splash.pb -mode indeterminate]  -padx 10 -pady 20 -side top
            set wscreen [winfo screenwidth .splash]
            set hscreen [winfo screenheight .splash]
            set x [expr {($wscreen - $width) / 2}]
            set y [expr {($hscreen - $height) / 2}]
            
            wm geometry .splash +$x+$y
            raise .splash
            .splash.pb start
            update idletasks
        } else {
            puts update
            .splash.label configure -text $arg(-message)
            update
        }
        if {$arg(-delay) > 0} {
            update
            after $arg(-delay) {destroy .splash; wm deiconify .}
        }
    }    
    #'
    #' *cmdName* **status**  *msg ?value?* 
    #' 
    #' > Displays the text of *msg* as message and the optional value within the progressbar in the statusbar widget. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    
    method status {msg {value 0}} {
        $gui(statusbar) set $msg $value
    }
    #'
    #' *cmdName* **subwidget**  *widgetName* 
    #' 
    #' > Returns the widget belonging to the given *widgetName*.
    #'   *widgetName* can be either *statusbar* or *frame*. This function allows access to internal widgets at a later point.

    method subwidget {widgetname} {
        if {$widgetname eq "frame"} {
            return [$self getFrame]
        } elseif {$widgetname eq "statusbar"} {
            return $gui(statusbar)
        }
    }
    #'
    #' <a name="timer">*cmdName* **timer**  *mode*</a>
    #' 
    #' > Simple timer procedure to measure execution time in the GUI. 
    #' The two modes are *reset* and *time*, the first measured time is initialized at *dgw::basegui* initialization:
    #'
    #' > - *reset* - resets the time to the current time
    #'   - *time*  - gets the execution time after the last reset, this is the default.
    #'
    #' > ```
    #'   dgw::basegui app
    #'   puts "Startup in [app timer time] seconds!"
    #'   app timer reset
    #'   after 1500
    #'   puts "After time [app timer time] seconds!"
    #' > ```
    method timer {{mode time}} {
        if {$mode eq "time"} {
            return [$timer seconds]
        } elseif {$mode eq "reset"} {
            $timer reset
        }
    }
    #'
    #' <a name="treeview">*cmdName* **treeview**  *pathname ?-option value ...?* </a>
    #' 
    #' > Creates a standard *ttk::treeview* widget with additional sorting feature for the columns and banding stripes for the rows.
    #'   It has as well a *loadData* method to load nested lists. See the following example.
    #'
    #' > ```
    #'   dgw::basegui app
    #'   set f [app getFrame]
    #'   set tv [app treeview $f.tv]
    #'   set headers {country capital currency unit}
    #'   set data {
    #'    {Argentina          "Buenos Aires"          ARS 0.12}
    #'    {Australia          Canberra                AUD 0.11}
    #'    {Brazil             Brazilia                BRL 0.33}
    #'    {Canada             Ottawa                  CAD 0.56}
    #'    {China              Beijing                 CNY 0.88}
    #'    {France             Paris                   EUR 1.23}
    #'    {Germany            Berlin                  EUR 0.124}
    #'    {India              "New Delhi"             INR 0.12345}
    #'    {Italy              Rome                    EUR 1.2345}
    #'  }
    #'  pack $tv  -side left -expand yes -fill both
    #'  $tv loadData $headers $data
    #' > ```
    method treeview {w args} {
        dgw::treeview $w {*}$args
    }
    method hello { } {
        incr x
        puts "Hello Worleded $x times!"
    }
    
}
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' The following example demonstrates a few features for creating new standalone applications using the faciltities of 
#' of the *dgw::basegui* snit type. The code can be executed directly using the *--demo* commandline switch.
#' 
#' ```
#' ::dgw::basegui app -style clam
#' puts "Startup in [app timer time] seconds!"
#' app timer reset
#' after 1500
#' puts "After time [app timer time] seconds!"
#' set fmenu [app getMenu "File"]
#' $fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
#' app addStatusBar
#' set stb [app subwidget statusbar]
#' $stb progress 100
#' $stb set "starting ..."
#' after 100
#' app status progressing... 50
#' after 1000
#' app status finished 100
#' set f [app getFrame]
#' set btn [ttk::button $f.btn -text "Hover me!"]
#' app balloon $btn "This is the hover message!\nNice ?"
#' pack $btn -side top
#' set tf [ttk::frame $f.tframe]
#' set t [text $tf.text -wrap none]
#' app autoscroll $t
#' for {set i 0} {$i < 30} {incr i} {
#'     $t insert end "Lorem ipsum dolor sit amet, consectetur adipiscing elit, 
#'   sed do eiusmod tempor 
#'      incididunt ut labore et dolore magna aliqua. 
#'    Ut enim ad minim veniam, quis nostrud exercitation 
#'      ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n"
#' }
#' pack $tf -side top -fill both -expand yes
#' pack [canvas $f.c] -side top -fill both -expand true
#' set id [$f.c create oval 10 10 110 110 -fill red]
#' app cballoon $f.c $id "This is a red oval"
#' $f.c create rect 130 30 190 90 -fill blue -tag rect
#' app cballoon $f.c rect "This is\na blue square"
#' set nb [app notebook $f.nb]
#' set bframe [ttk::frame $nb.bf]
#' $nb add $bframe -text "rotext"
#' set rotext [app rotext $bframe.rotext]
#' app autoscroll $rotext
#' for {set i 0} {$i < 50} {incr i 1} {
#'    $rotext ins end "Hello rotext ...\n"
#' }
#' set evar "entries text"
#' app labentry $nb.len -label "The label" -textvariable evar
#' $nb add $nb.len -text "labentry"
#' pack $nb -side top -fill both -expand true
#' ```
#'
#' ## <a name='inheritance'>INHERITANCE</a>
#' 
#' This snit type can be used to build up other more specialized applications. Here is an example, 
#' where we create a generic Editor class which adds additional menu points and embeds 
#' a scrolled text widget.
#'
#' The most basic inheritance example would be just copying the functionality without the text widget.
#'
#' ```
#' package require dgw::basegui
#' snit::type EditorApp {
#'    component basegui
#'    # inheritance
#'    delegate method * to basegui
#'    delegate option * to basegui
#'    # variable addon to extend basegui
#'    variable textw
#'    constructor {args} {
#'         install basegui using dgw::basegui %AUTO%
#'         $self configurelist $args    
#'         # added functionality
#'         set f [$basegui getFrame]
#'         set textw [text $f.t -wrap none]
#'         $self autoscroll $textw
#'    }
#'    # added functionality
#'    # access functionality of the text widget
#'    # like: % app text insert end "hello basegui world"
#'    method text {args} {
#'       $textw {*}$args
#'    }
#' }
#' if {[info exists argv0] && $argv0 eq [info script]} {
#'    #start editor
#'    EditorApp app
#'    app text insert end "Hello EditorApp!!"
#' }
#' ``` 
#'
#' This simple example should show how to extend the functionality of the basegui toplevel.
#' Before you start to write specialized applications you should create a simple proxy class which 
#' does nothing more than inheriting from `dgw::basegui` first. This is the code above without the text widget parts. 
#' You can then extend this base class and your specialized applications inherit from your baseclass. 
#' This allows you to extend all your specialized classes using your baseclass. So your setup should be:
#'
#' ```
#'
#'                                  -- your::editor
#' dgw::basegui -- your::basegui ---+
#'                                  -- your::databasebrowser
#'
#'
#' ```
#' 
#' This is in the long term better than inheriting from `dgw::basegui` directly. You don't like to change the code of 
#' this class, but you can change `your::basegui` for instance to give better help facilities in the Help menu, or other features you need in your applications most of the time.
#' If you do this both application `your::editor` and `your::databasebrowser` will have this functionality at the same time 
#' after implementing it in `your::basegui` type. If you follow this approach you can easily update the *dgw::basegui* package without loosing your new functionalities.
#' 
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can easily install and use this ** __PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file `dgw/__BASENAME__-__PKGVERSION__.tm` in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose.
#'
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
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
#' This will extract the embedded manual pages in standard Markdown format. 
#' You can as well use this markdown output directly to create html pages for 
#' the documentation by using the *--html* flag if the Markdown library of 
#' tcllib is installed on your machine.
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --html
#' ```
#' 
#' This will directly create a HTML page `__BASENAME__.html` which contains the formatted documentation. 
#' Github-Markdown can be extracted by using the *--man* switch:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --man
#' ```
#'
#' The output of this command can be used to feed a markdown processor for conversion into a 
#' html or pdf document. If you have pandoc installed for instance, you could execute the following commands:
#'
#' ```
#' tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw - package homepage: https://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#'
#' ## <a name='todo'>TODOS</a>
#'
#' * socket check for starting the application twice
#' * tooltip embedded (done)
#' * auto scrolled command embedded for x and y scrollbars (done)
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** command was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#'  __PKGNAME__ command, version __PKGVERSION__.
#'
#' Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
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

# test
if {false} {
    package require Tk
    snit::widget Toplevel {
        hulltype toplevel
        constructor {args} {
            #toplevel $win
            #$self configurelist $args
            wm withdraw .
            pack [text $win.t]
        }
        
    }

    Toplevel .t
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp basegui $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        dgw::runExample [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a basic application framework for"
        puts "                       building Tk applications."
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
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
    }
}


