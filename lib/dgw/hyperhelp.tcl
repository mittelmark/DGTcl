#!/bin/sh
# The next line executes Tcl with the script \
exec tclsh "$0" "$@"
#' ---
#' title:  __PKGNAME__ __PKGVERSION__
#' author: Dr. Detlef Groth, Schwielowsee, Germany
#' documentclass: scrartcl
#' geometry:
#' - top=20mm
#' - right=20mm
#' - left=20mm
#' - bottom=30mm
#' ---
#' 
#'
#' ## NAME
#'
#' **dgw::hyperhelp**   help system with hypertext facilitites and table of contents outline
#' 
#' 
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [METHODS](#methods)
#'  - [EXAMPLE](#example)
#'  - [MARKUP LANGUAGE](#formatting)
#'  - [INSTALLATION](#install)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE AND COPYRIGHT](#license)
#' 
#' 
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' Usage as package:
#' 
#' ```
#' package require dgw::hyperhelp
#' dgw::hyperhelp pathName -helpfile filename ?-option value ...?
#' pathName help topic
#' ```
#' 
#' Usage as command line application:
#' 
#' ```
#' tclsh hyperhelp.tcl filename ?--commandsubst true?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The **dgw::hyperhelp** package is hypertext help system which can be easily embedded into Tk applications. It is based on code
#' of the Tclers Wiki mainly be Keith Vetter see the [Tclers-Wiki](https://wiki.tcl-lang.org/page/A+Hypertext+Help+System)
#' The difference of this package to the wiki code is, that it works on external files, provides some `subst` support for variables 
#' and commands as well as a browser like toolbar. It can be as well used as standalone applications for browsing the help files.
#' Markup syntax was modified towards Markdown to simplify writing help pages as this is a common documentation language. 
#' In practice you can create a document which is a valid Markdown document and at the same time an usable help file. 
#' The file [hyperhelp-markdown-sample.md](hyperhelp-markdown-sample.md) gives an example for such a file.


package require Tk
package require tile

#if {[catch {package require dgtools::shistory}]} {
#    tcl::tm::path add [file join [file dirname [info script]] .. libs]
#    lappend auto_path [file join [file dirname [info script]] .. libs]
#}
#interp alias {} ::button {} ::ttk::button
set haveTile078 1
package require dgtools::shistory

#proc thingy name {proc $name args "namespace eval $name \$args"}

#thingy hist

#' 
#' ## <a name='command'>COMMAND</a>
#' 
#' **dgw::hyperhelp** *pathName -helpfile fileName ?-option value ...?*
#' 
#' > creates a new *hyperhelp* widget using the given widget *pathName* and with the given *fileName*.
#'
#' ## <a name='options'>OPTIONS</a>
#' 
#' The **dgw::hyperhelp** snit widget supports the following options which 
#' should be set only at widget creation:

namespace eval dgw { 
    variable HyperMini
    set HyperMini {---
title: Hyperhelp template
author: Marc Musterman, Mustercity, Mustercountry
date: 2020-MM-DD
geometry:
- top=20mm
- bottom=20mm
- left=20mm
---

## <a name="toc">Table of Contents</a>

  * [Home](#home)
  * Markup samples
     * [Structure](#structure)
     * [Emphasis](#emph)
     * [Code](#code)
     * [Images and Links](#links)
     * [Substitutions](#subst)
  * [Table of Contents](#toc)
  
  Indent bullet lists and also the TOC list with 2 spaces for first level, 
  and with least 4-6 spaces for second level indentation.
  
* Unindented list do not work
* as can bee seen here  
  
-----

## <a name="home">Home</a>

This is a small starting template for the hyperhelp::package.

-----

## <a name="structure">Structure</a>

### Header level 3

horizontal row:

----

List examples:

  * list item 1
  * list item 2
  * list item 3
    * subitem 3.1
    * subitem 3.2
  * list item 4

  1. numbered item 1
  2. numbered item 2
  3. numbered item 3  
  4. numbered item 4  

Paragraph indentation:

> some text which can be continued without linebreak in the output
  here.

List indentation:

> * item 1
  * item 2
  * item 3
    
-----

## <a name="emph">Emphasis</a>

Let's write mixed **bold** and *italic* and `typewriter text` in one line.


-----

## <a name="code">Code</a>

Source code blocks are done using at least three whitespaces at the beginning
of the lines.

    if {$x == 1} {
       puts "x is 1"
    }


Show lines start with list symbols by preceeding them with a dot.

    .* first list item as source code
    .* second itemlist item as source code
      
-----

## <a name="images">Images and Links</a>

Image:

![](hyperhelp.png)
    
Link to [Table of Contents](#toc)


-----

## <a name="subst">Substitutions</a>

We use:
    * Tcl/Tk $::tcl_patchLevel
    * dgw::hyperhelp [[package present dgw::hyperhelp]]
}        
}

snit::widget ::dgw::hyperhelp {
    variable W                                  ;# Various widgets
    variable pages                              ;# All the help pages
    variable alias                              ;# Alias to help pages
    variable state
    variable font "Times New Roman"
    variable var
    variable sh
    variable npages 0
    variable ptitle ""
    variable fonts
    variable sentry 
    #' 
    #'   __-bottomnavigation__ _boolean_
    #' 
    #'  > Configures the hyperhelp widget if at the bottom of each help page a textual navigation line should be displayed. Default *false*.
    option -bottomnavigation false
    
    #' 
    #'   __-commandsubst__ _boolean_
    #' 
    #'  > Configures the hyperhelp widget to do substitutions using Tcl commands within the text.
    #'    This might give some security issues if you load help files from dubious sources, 
    #'  although for this most critical commands like file, exec and socket are disaable even if this option is set to true.
    #'  Default: false
    
    option -commandsubst false
    
    #' 
    #'   __-dismissbutton__ _boolean_
    #' 
    #'  > Configures the hyperhelp widget to display at the button a "Dismiss" button. Useful if the help page is direct parent in a toplevel to destroy this toplevel. Default: *false*.
    option -dismissbutton false
    
    #' 
    #'   __-font__ _fontname_
    #' 
    #'  > Configures the hyperhelp widget to use the given font. 
    #' Fontnames should be given as `[list fontname size]` such as for example 
    #' `\[list {Linux Libertine} 12\]`. If no fontname is given the hyperhelp widget 
    #' tries out a few standard font names on Linux and Windows System. 
    #' If none of those fonts is found, it falls back to "Times New Roman" which should be available on all platforms.
    option -font ""

    #' 
    #'   __-helpfile__ _fileName_
    #' 
    #'  > Configures the hyperhelp widget with the given helpfile 
    #'    option to be displayed within the widget.
    option -helpfile ""
    
    #' 
    #'   __-toctree__ _boolean_
    #' 
    #'  > Should the toc tree widget on the left be displayed. 
    #'    For simple help pages, consisting only of one, two, three pages the 
    #'    treeview widget might be overkill. Please note, that this widget is also 
    #'    not shown if there is no table of contents page, regardless of the _-toctree_ option.
    #'    Must be set at creation time currently.
    #'    Default: *true*
    option -toctree true
    
    #' 
    #'   __-toolbar__ _boolean_
    #' 
    #'  > Should the toolbar on top be displayed. For simple help pages, 
    #'    consisting only of one, two pages the toolbar might be overkill. 
    #'    Must be set at creation time currently.
    #'    Default: *true*
    option -toolbar true
    constructor {args} {
        $self configurelist $args
        #parray options
        set font ""
        if {$options(-font) eq ""} {
            set ff [font families] 
            set size 12
            foreach f [list {Linux Libertine} {Alegreya} {Constantia} {Georgia} {Palatino Linotype} {Times New Roman} {Cambria}] {
                set idx [lsearch -exact $ff $f]
                if { $idx > -1} {
                    set options(-font) [list [lindex $f $idx] 12]
                    set font $f ;#[list $f 12]
                    break
                }
            } 
            if {$font eq ""} {
                set options(-font) [list "Times New Roman" 12]
                set font "Times New Roman"
            } 
        } else {
            set font [lindex $options(-font) 0]
            set size [lindex $options(-font) 1]
        }
        set fonts(fixed) [font create -family "Courier" -size [expr {$size-1}]]
        set fonts(std)  [font create -family $font -size $size]
        set fonts(italic)  [font create -family $font -size $size -slant italic]
        set fonts(bold)  [font create -family $font -size $size -weight bold]
        set fonts(hdr)  [font create -family $font -size [expr {$size+4}]]
        set fonts(hdr3)  [font create -family $font -size [expr {$size+4}]]
        set font $fonts(std)
        array unset var
        array unset pages
        set pages(ERROR!) "page does not exists"
        array unset alias
        array unset state
        array set state {seen {} current {} all {} allTOC {} haveTOC 0}
        array set W {top .helpSystem main "" tree ""}
        array set alias {index Index previous Previous back Back forward Forward 
            search Search history History next Next}
        array set var [list]
        set sh [::dgtools::shistory %AUTO% -home ""]
        set W(top) $win
        $self ReadHelpFiles
        $self Help 
    }
    onconfigure -font value {
        #puts "configuring font"
        set f [lindex $value 0]
        foreach fnt [array names fonts] {
            font configure $fonts($fnt) -family $fnt
        }
        set options(-font) $value
    }
 
    ## BON HELP
    ##+##########################################################################
    #
    # Help Section
    #
    # Based on https://wiki.tcl-lang.org/1194
    #
    #  AddPage title aliases text  -- register a hypertext page
    #  Help ?title?                -- bring up a toplevel showing the specified page
    #                                 or a index of titles, if not specified
    #
    # Hypertext pages are in a subset of Wiki format:
    #   indented lines come in fixed font without evaluation;
    #   blank lines break paragraphs
    #   a line starting with "   * " gets a bullet
    #   a line starting with "   - " gets a dash
    #   a line starting with "   1 " will be a numbered list
    #    repeating the initial *,- or "1" will indent the list
    #   a line starting with "   | " will be an indented block paragraph (one level only)
    #
    #   text enclosed by '''<text>''' is embolden
    #   text enclosed by ''<text>'' is italics
    #   all lines without leading blanks are displayed without explicit
    #      linebreak (but possibly word-wrapped)
    #   a link is the title of another page in brackets (see examples at
    #      end). Links are displayed underlined and blue (or purple if they
    #      have been visited before), and change the cursor to a pointing
    #      hand. Clicking on a link of course brings up that page.
    #
    # In addition, you get "Index", "Search" (case-insensitive regexp in
    # titles and full text), "History", and "Back" links at the bottom of
    # pages.
 
 
    ##+##########################################################################
    #
    # Help -- initializes and creates the help dialog
    #
    #' 
    #' ## <a name='methods'>METHODS</a>
    #' 
    #' The *hyperhelp* widget provides the following methods:
    #' 
    
    #' *pathName* **help** *topic*
    #'
    #' > Displays the given topic within widget. If the page does not exists an error page is shown.
    
    method help {{title ""}} {
        $self DoDisplay 
        #raise $W(top)
        $self Show $title 
        set ptitle $title
    }
    method Help {{title ""}} {
        $self help $title
    }
    
    #'
    #' *pathName* **getTitle**
    #'
    #' > Returns the current topic shown in the hyperhelp browser.
    
    method getTitle {} {
        return $ptitle
    }
    
    #'
    #' *pathName* **getPages**
    #'
    #' > Returns the page names for the current help file.
    
    method getPages {} {
        return [array names pages]
    }


    ##+##########################################################################
    #
    # ReadHelpFiles -- reads "help.txt" in the packages directory
    # and creates all the help pages.
    #
    method ReadHelpFiles {} {
        set fname $options(-helpfile)
        #set fname [file join $dir help.txt]
        set fin [open $fname r]
        set data [read $fin] ; list
        close $fin
        # remove pandoc header
        regsub -- {^-{3,}\s*\ntitle:.+?\n---\n} $data "" data
        regsub -all -line {^-{5,}$} $data \x01 data
        regsub -all -line {^\#\s.*$\n} $data {} data
        regsub -all -line {^ {4,5}([-+*]) } $data "    \\1\\1 " data
        set t [clock seconds]
        set cmds [list file open exec send socket] 
        foreach cmd $cmds {
            rename ::$cmd ::${cmd}.orig$t
        }
        set x 0
        foreach section [split $data \x01] {
            set section [regsub -all {^(\s*)## +<a name=["']([^>]+)['"]>\s*([^<]+)\s*</a>} $section "title: \\3\nalias: \\2"]
            set n [regexp -line {^(title:|##)\s*(.*?) *$} $section => => title]
            if {! $n} {
                tk_messageBox -title "Error!" -icon error -message "Bad help section\n'[string range $section 0 400]'" -type ok
                continue
            }
            #puts "'${title}'"
            
            set n [regexp -line {^icon:\s*(.*?) *$} $section => icon]
            if {! $n} {
                set var("icon,$title") filenew16
            } else {
                set  var("icon,$title") $icon
            }
            if {[incr x] == 1} {
                set var(home) $title
                $sh configure -home $title
            }
            set npages $x
            set aliases {}
            foreach {. ali} [regexp -all -line -inline {^alias:\s*(.*?) *$} $section] {
                if {$ali eq "Home" || $ali eq "home"} {
                    set var(home) $ali
                }
                lappend aliases $ali
            }
            # make subst more save
            # did not got interp alias to work
            
            regsub -all -line {^(title:|alias:|icon:).*$\n} $section {} section
            regsub -all {\[\[} $section "````" section
            regsub -all {\]\]} $section "创创" section
            regsub -all {\[} $section "``" section
            regsub -all {\]} $section "创" section
            regsub -all {````} $section "\[" section
            regsub -all {创创} $section "\]" section
            #set i [interp create -safe]
            #interp eval $i package require tdbc
            # not available in save interpr
            #interp eval $i [list subst "$section"]
            set sect ""
            foreach line [split $section "\n"] {
                if {$options(-commandsubst)} {
                    catch { set line [subst $line] } 
                } else {
                    catch { set line [subst -nocommands $line] } 
                }
                set line [regsub -all {\[([^]]+)\]} $line "(Error: \\1)"]
                append sect "$line\n"
            }  
            set section $sect
            #interp eval $i set section $section
            #$i eval subst $section
            
            regsub -all {``} $section "\[" section
            regsub -all {创} $section "\]" section
            #puts "adding $title"
            $self AddPage $title $aliases $section
        }

        foreach cmd $cmds {
            rename ::${cmd}.orig$t ::$cmd 
        }
        if {$x > 1} {
            # todo catch nox existing display
            $self BuildTOC
        } 
        if {$x == 1} {
            #pack forget $win.status
        }
    }
    
    ##+##########################################################################
    #
    # AddPage -- Adds another page to the help system
    #
    method AddPage {title aliases body} {
        regsub -all {\n } $body "\n" body
        set title [string trim $title]
        set body [string trim $body "\n"]
        regsub -all {\\\n} $body {} body            ;# Remove escaped lines
        regsub -all {[ \t]+\n} $body "\n" body      ;# Remove trailing spaces
        regsub -all {([^\n])\n([^\s])} $body {\1 \2} body ;# Unwrap paragraphs
        
        set pages($title) $body
        
        lappend aliases [string tolower $title]
        foreach name $aliases { set alias([string tolower $name]) $title }
        
        if {[lsearch $state(all) $title] == -1} {
            set state(all) [lsort [lappend state(all) $title]]
        }
    }
    
    typeconstructor {
        image create photo acthelp16 -data {
            R0lGODlhEAAQAIMAAPwCBAQ6XAQCBCyCvARSjAQ+ZGSm1ARCbEyWzESOxIy6
            3ARalAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAQ/EEgQqhUz00GE
            Jx2WFUY3BZw5HYh4cu6mSkEy06B72LHkiYFST0NRLIaa4I0oQyZhTKInSq2e
            AlaaMAuYEv0RACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        
        image create photo bookmark -data {
            R0lGODlhEAAQAIQAAPwCBCwqLLSytLy+vERGRFRWVDQ2NKSmpAQCBKyurMTG
            xISChJyanHR2dIyKjGxubHRydGRmZIyOjFxeXHx6fAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVbICACwWie
            Y1CibCCsrBkMb0zchSEcNYskCtqBBzshFkOGQFk0IRqOxqPBODRHCMhCQKte
            Rc9FI/KQWGOIyFYgkDC+gPR4snCcfRGKOIKIgSMQE31+f4OEYCZ+IQAh/mhD
            cmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENv
            ciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3
            LmRldmVsY29yLmNvbQA7
        }
        image create photo bell -data {
            R0lGODlhDwAOAIIAAPwCBISCBPz+BIQCBMTCxISChPz+/AQCBCH5BAEAAAAA
            LAAAAAAPAA4AAAM+CLrR+zCIAWsgLVRGRBhOVQiG94WPVAbHaZHYAWqRYLbg
            e88RsbInGuBCEhRYrZYm4xk4nYdoKzKIbiKHawIAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }

        image create photo idea -data {
            R0lGODlhEAAQAIMAAPwCBAQCBPz+BPzerPz+xPyqXPz+/ISChFxaXKSipDQy
            NAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARMEEgZap14BjG6
            CJkmEMVQCF+4mQPBpthWtuYJxkJJGK6dbQRCgMBB3XCDzQamMhpDGlvuCFUy
            oQDLBUsJHBDUKuKQCKsUCIVZtc34IwAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lG
            IFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCBy
            aWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo reload-16 -data {
            R0lGODlhEAAQAIUAAPwCBCRaJBxWJBxOHBRGBCxeLLTatCSKFCymJBQ6BAwm
            BNzu3AQCBAQOBCRSJKzWrGy+ZDy+NBxSHFSmTBxWHLTWtCyaHCSSFCx6PETK
            NBQ+FBwaHCRKJMTixLy6vExOTKyqrFxaXDQyNDw+PBQSFHx6fCwuLJyenDQ2
            NISChLSytJSSlFxeXAwODCQmJBweHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaB
            QIBQGBAMBALCcCksGA4IQkJBUDIDC6gVwGhshY5HlMn9DiCRL1MyYE8iiapa
            SKlALBdMRiPckDkdeXt9HgxkGhWDXB4fH4ZMGnxcICEiI45kQiQkDCUmJZsk
            mUIiJyiPQgyoQwwpH35LqqgMKiEjq5obqh8rLCMtowAkLqovuH5BACH+aENy
            ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
            IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
            ZGV2ZWxjb3IuY29tADs=
        }

        image create photo klipper-16 -data {
            R0lGODlhEAAQAIYAAPwCBFQyDEwuFEQuDISGhFRSVEQqFEQuFPz+/PTy7Nze
            3PT29Ozu7DQyNJx6VIxuRIRiLEwuDIxSFHxSHKSipLSytGRiZGRCHDwmFOzm
            3HxOHIRWHOTazHRCFHxOFEwyFNTKvHROHFxeXJRqLIxWFFw6DFQ2DNTCrIRa
            JJxuPMSynHRKHIxqRMSqjGRGHMSifJxeFKyGXHxKFLyaXKyObGxGFEwyDKyO
            XIxeHKSOdFQ6FIx2THRKFFw+FKx6NKRmFKxuFLyCPLyOTLyabLSefLyijFw6
            FJRmJIxWHHRGFFQ2FAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAfFgAAAAQIDBAWIiAMGA4IABwgJCgUICwwKDQ4PEBGCEQsS
            EwUUFQQWDRepGJ4ZEggIDbENrxobAZ4cHa+7uxAeH4IGICEIIsbGFggjJCWC
            JicovLwpIcAAGCorCBbc3AoILB2rgy2u0q8OLrcAJS8wr8nJrzEy6yUz79si
            vDQ1jQA2buB4tU8eghw6xgnYwePcqxcdbAjq4eMHECA+ggiZMYRIESPjShyB
            gQPJBB48OsiokaTDOoACItgwYULJhw8BbIzzEwgAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }
        image create photo fileopen16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBOSmZPzSnPzChPzGhPyuZEwyHExOTFROTFxa
            VFRSTMSGTPT29Ozu7Nze3NTS1MzKzMTGxLy6vLS2tLSytDQyNOTm5OTi5Ly+
            vKyqrKSmpIyOjLR+RNTW1MzOzJyenGxqZBweHKSinJSWlExKTMTCxKyurGxu
            bBQSFAwKDJyanERCRERGRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaR
            QIBwGCgGhkhkEWA8HpNPojFJFU6ryitTiw0IBgRBkxsYFAiGtDodDZwPCERC
            EV8sEk0CI9FoOB4BEBESExQVFgEEBw8PFxcYEBIZGhscCEwdCxAPGA8eHxkU
            GyAhIkwHEREQqxEZExUjJCVWCBAZJhEmGRUnoygpQioZGxsnxsQrHByzQiJx
            z3EsLSwWpkJ+QQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9u
            IDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2
            ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo actreload16 -data {
            R0lGODlhEAAQAIUAAPwCBCRaJBxWJBxOHBRGBCxeLLTatCSKFCymJBQ6BAwm
            BNzu3AQCBAQOBCRSJKzWrGy+ZDy+NBxSHFSmTBxWHLTWtCyaHCSSFCx6PETK
            NBQ+FBwaHCRKJMTixLy6vExOTKyqrFxaXDQyNDw+PBQSFHx6fCwuLJyenDQ2
            NISChLSytJSSlFxeXAwODCQmJBweHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaB
            QIBQGBAMBALCcCksGA4IQkJBUDIDC6gVwGhshY5HlMn9DiCRL1MyYE8iiapa
            SKlALBdMRiPckDkdeXt9HgxkGhWDXB4fH4ZMGnxcICEiI45kQiQkDCUmJZsk
            mUIiJyiPQgyoQwwpH35LqqgMKiEjq5obqh8rLCMtowAkLqovuH5BACH+aENy
            ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
            IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
            ZGV2ZWxjb3IuY29tADs=
        }
        image create photo start-16 -data {
            R0lGODlhEAAQAIUAAPwCBBRSdBRObCQ2TAQCBBxObISevNzu/BRGZPz6/FzC
            3Pz+/HTS5ByyzJze7Mzq9ITC3AQWLAyWvBSavFyuxAwaLAQSHBRWfBSOrDzW
            5AyixCS61ETW3CzG1AQeLAweLAxefBSStEze7CSWtCyatBSCnAwmPBRWdByi
            xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZr
            QIBwSCwah4HjUTBQEogFw/M4BQgMh2pxijAkFAhBYJwUPq8LRsPxWDwgkSHh
            elA0JJIJnlKRWy4YGRoSGxwcHRsecgAfICEiGhMjJBglVVMRgBkgJp0El0MR
            JyhaRFqipUoAFqmqrapHfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8g
            dmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRz
            IHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo navback16 -data {
            R0lGODlhEAAQAIUAAPwCBBRSdBRObCQ2TBxObISevAQCBNzu/BRGZPz6/FzC
            3Pz+/HTS5ByyzJze7Mzq9ITC3AQWLAyWvBSavFyuxAwaLAwSHBRafBSOrDzW
            5AyixCS61ETW3CzG1AQeLAweLAxefBSStEze7CSWtCyatBSCnBRWfAwmPBRW
            dByixAQSHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZi
            QIBwSCwah4HjUTBQFgkFg3MoKBykU0QhoUAIAuAksbpgNByPxQMSGVsVDYlk
            IqdUiJYLJqORbDgcHRseRR8gISIaEyMkGCVYRBEmeyAnlgaQkSgpmU4RAZ1O
            KqFOpFNGfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAy
            LjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVk
            Lg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo finish-16 -data {
            R0lGODlhEAAQAIUAAPwCBAwyTBRObAw2VDR+nAQCBCRKZOzy/KTe7Pz+/KTK
            3Nzu/Lze7FS+1AyexAyuzBSavAyOtBSmzOTy/BRqjNTm9IzO5ETS3ETa5By6
            1AyixByixBRmjAQGDBxCXGSivCySrCSWtBTC3AQOHAQWHAxWdEze7AQKFBRC
            XAwqPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZt
            QIBwSCwahYGjUjBQGgWE5LCgNBwITSFVKOgKDAZEIqodChSLw4HRcIyTW4Dg
            0HhAIhGIZEIJxA0VFhcYGRAaGBscHXEeHyAhIQ4iiBwjAHEBJCMjJCUmiSdl
            RyigU0oolURxRSmrTpevsUN+QQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBy
            byB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdo
            dHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo navforward16 -data {
            R0lGODlhEAAQAIUAAPwCBAwyTBRObAw2VDR+nCRKZOzy/KTe7Pz+/KTK3Nzu
            /Lze7FS+1AyexAyuzBSavAyOtBSmzOTy/BRqjNTm9IzO5ETS3ETa5By61Ayi
            xByixBRmjAQGDBxCXGSivCySrCSWtBTC3AQOHAQWHAxWdEze7AQKFBRCXAwq
            PAQCBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZj
            QIBwSCwahYGjUjBQGgWEpHNYMBCaT4G2UDggos+EwmBYMBpf6VBgYDgeEMgj
            IpmoAQVKxXLBPDIXGhscRB0eHyAgDSGBGyJFASMiIiMkJYImUwAnmJqbjp4A
            KCmhAKSlTn5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo navhome16 -data {
            R0lGODlhEAAQAIUAAPwCBDw6PBQWFCQiJAQCBFxeXMTCxJyanDwyLDQqLFRS
            VLSytJSSlISChCQmJERGRFRWVGxubKSmpJyenGRmZLy+vOzq7OTi5Ly6vGRi
            ZPTy9Pz6/OTm5ExOTPT29BwaHNza3NS6tJRqRGQqBNy6pIyKjDwGBPTe1JSW
            lDQyNOTGrNRiBGwmBIRaLNymdLxWBHxGFNySXCwqLKyqrNR6LKxGBNTS1NTW
            1Jw+BEweDDQ2NAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAao
            QIBwCAgIiEjAgAAoGA6I5DBBUBgWjIZDqnwYGgVIoTGQQgyRiGRCgZCR1nTF
            csFkHm9hBp2paDYbHAsZHW9eERkYGh4eGx4ag3gfSgMTIBshIiMkGyAlCCZT
            EpciJyQjGxcoKUQBEhcbIiorLB4XEltDrhcaLS4vtbcJra8bMDHAGrcyrTMX
            HjA0NSypEsO6EzY3IzU4OdoTzK0BCAkDMgkIOjJlAH5BACH+aENyZWF0ZWQg
            YnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcs
            MTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxj
            b3IuY29tADs=
        }
        image create photo nav1leftarrow16 -data {
            R0lGODlhEAAQAIAAAP///wAAACH5BAEAAAAALAAAAAAQABAAAAIdhI+pyxqd
            woNGTmgvy9px/IEWBWRkKZ2oWrKu4hcAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo nav1rightarrow16 -data {
            R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIdhI+pyxCt
            woNHTmpvy3rxnnwQh1mUI52o6rCu6hcAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }

        image create photo playend16 -data {
            R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIjhI+py8Eb
            3ENRggrxjRnrVIWcIoYd91FaenysMU6wTNeLXwAAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }
        image create photo playstart16 -data {
            R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIjhI+pyxud
            wlNyguqkqRZh3h0gl43hpoElqlHt9UKw7NG27BcAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }
        image create photo history -data {
            R0lGODlhEAAQAIUAAPwCBEQ2LEw6POTSrOzWtNS2lAQCBOzatPTm3PTq3Myy
            jEw+NOzm1Pz29Pz+/Pz6/Pz27FRGPFxKRPTu3Pzy7Pz69Pz67KSGbPzy3Pzu
            3PTizPzu1Pzq1PTmzOzaxPTixPTmxOzWvOTOtKyWdOTGpOTStNS+nIRmVLym
            hNzCnOzavLyefAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaH
            QIBwGCgOj0jBgFAwGJDJAyJBUDihwgWj4XhAqhEJNDKhVLwUSUDyPJIrlgYl
            LSG0hYELhgLJTBJOd1kaGxgYHB0egkQfHBwgHyEigkUBIwMkBwcEJSZ3ARYW
            JCcnKCYpJJ5HAQUqFhSjJysoKItOCgehJBISI4tCtyERa79HTrx2WEiBUH5B
            ACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERl
            dmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6
            Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }

        image create photo help -data {
            R0lGODlhEAAQAIEAAPwCBAQChAQCBAAAACH5BAEAAAAALAAAAAAQABAAAAIz
            hH+hIeiwVmtOUcjENaxqjVjhByaBSZZVl24Y1V6iEVMzkD4bqD700bshgh1f
            zwd0IfwFACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41
            DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4N
            Cmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo hinfo -data {
            R0lGODlhEAAQAIYAAPwCBBQ+XBRCZAw+XAw6XBRCXCRObCxihCxqjCRijBRS
            fAwyVCxehDx6nER+pPz+/BxKZAwmPFyWtGyevCRSbBxWfAxGbHSqxGSatCxu
            lBxahBRKbAQiNEyKrBRKdAw6ZAwiNESSLCyCDBxWBDRulBwyRHS6ZDSWHCyK
            FDQyNCxqlAQmRAwiPMzalPyCBMQCBCx+DAwuRBQqPITCdFxaXCyOFAQeNAwm
            RAxKdPz6/GyyVMTCxKSirAQCBGzKZAwqTAweNFyuRDyeJFzCTITOdAQiPAQa
            NHzCbES6NEy6PESyNDyqLDymJPz+xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAfBgACCAAECAwSDiYMFBgcICQoLC4qCBQwNDg8PEJERlAYN
            EhOaFBUWnokBBw4SFxgOGRobCxyJBQkNHZoPpR4fICEiIiMBCSSYmgoKFgsl
            JicoKQQKCSoZmgW+KywtLi8pMDEbFRqaAcwyMyc0NSkiNjc4ObsrKyU6Ozw9
            7j4lNhGSfsgAEkQIDxr7YAwh0qKIDSM2jgRpgbDHPhFIMiZRsoTJkhMgobUD
            MKKkySYjUKockYJSypcrWypKQbOmTT+BAAAh/mhDcmVhdGVkIGJ5IEJNUFRv
            R0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFs
            bCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo sheet -data {
            R0lGODlhEAAQAIIAAPwCBAQCBAT+/Pz+/KSipPz+BAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAANFCBDc7iqIKUW98WkWpx1DAIphR41ouWya+YVpoBAaCKtM
            oRfsyue8WGC3YxBii5+RtiEWmASFdDVs6GRTKfCa7UK6AH8CACH+aENyZWF0
            ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5
            OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2
            ZWxjb3IuY29tADs=
        }

        image create photo folder -data {
            R0lGODlhEAAQAIYAAPwCBAQCBExKTBwWHMzKzOzq7ERCRExGTCwqLARqnAQ+
            ZHR2dKyqrNTOzHx2fCQiJMTi9NTu9HzC3AxmnAQ+XPTm7Dy67DymzITC3IzG
            5AxypHRydKymrMzOzOzu7BweHByy9AyGtFyy1IzG3NTu/ARupFRSVByazBR6
            rAyGvFyuzJTK3MTm9BR+tAxWhHS61MTi7Pz+/IymvCxulBRelAx2rHS63Pz6
            /PTy9PTu9Nza3ISitBRupFSixNTS1CxqnDQyNMzGzOTi5MTCxMTGxGxubGxq
            bLy2vLSutGRiZLy6vLSytKyurDQuNFxaXKSipDw6PAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAfDgACCAAECg4eIAAMEBQYHCImDBgkKCwwNBQIBBw4Bhw8Q
            ERITFJYEFQUFnoIPFhcYoRkaFBscHR4Ggh8gIRciEiMQJBkltCa6JyUoKSkX
            KhIrLCQYuQAPLS4TEyUhKb0qLzDVAjEFMjMuNBMoNcw21QY3ODkFOjs82RM1
            PfDzFRU3fOggcM7Fj2pAgggRokOHDx9DhhAZUqQaISBGhjwMEvEIkiIHEgUA
            kgSJkiNLmFSMJChAEydPGBSBwvJQgAc0/QQCACH+aENyZWF0ZWQgYnkgQk1Q
            VG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4g
            QWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29t
            ADs=
        }
        image create photo book -data {
            R0lGODlhEAAQAIQAAPwCBAQCBDyKhDSChGSinFSWlEySjCx+fHSqrGSipESO
            jCR6dKTGxISytIy6vFSalBxydAQeHHyurAxubARmZCR+fBx2dDyKjPz+/MzK
            zLTS1IyOjAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVkICCOZGmK
            QXCWqTCoa0oUxnDAZIrsSaEMCxwgwGggHI3E47eA4AKRogQxcy0mFFhgEW3M
            CoOKBZsdUrhFxSUMyT7P3bAlhcnk4BoHvb4RBuABGHwpJn+BGX1CLAGJKzmK
            jpF+IQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
            qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
            dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7}
        image create photo bookopen -data {
            R0lGODlhEAAQAIUAAPwCBAQCBExCNGSenHRmVCwqJPTq1GxeTHRqXPz+/Dwy
            JPTq3Ny+lOzexPzy5HRuVFSWlNzClPTexIR2ZOzevPz29AxqbPz6/IR+ZDyK
            jPTy5IyCZPz27ESOjJySfDSGhPTm1PTizJSKdDSChNzWxMS2nIR6ZKyijNzO
            rOzWtIx+bLSifNTGrMy6lIx+ZCRWRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAae
            QEAAQCwWBYJiYEAoGAFIw0E5QCScAIVikUgQqNargtFwdB9KSDhxiEjMiUlg
            HlB3E48IpdKdLCxzEAQJFxUTblwJGH9zGQgVGhUbbhxdG4wBHQQaCwaTb10e
            mB8EBiAhInp8CSKYIw8kDRSfDiUmJ4xCIxMoKSoRJRMrJyy5uhMtLisTLCQk
            C8bHGBMj1daARgEjLyN03kPZc09FfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo filenew16 -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJyanPz+/Ozq7GxqbPz6/GxubNTK
            xDQyNIyKhHRydERCROTi3PT29Pz29Pzy7PTq3My2pPzu5PTi1NS+rPTq5PTe
            zMyynPTm1Pz69OzWvMyqjPTu5PTm3OzOtOzGrMSehNTCtNS+tAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ/
            QAAgQCwWhUhhQMBkDgKEQFIpKFgLhgMiOl1eC4iEYrtIer+MxsFRRgYe3wLk
            MWC0qXE5/T6sfiMSExR8Z1YRFRMWF4RwYIcYFhkahH6AGBuRk2YCCBwSFZgd
            HR6UgB8gkR0hpJsSGCAZoiEiI4QKtyQlFBQeHrVmC8HCw21+QQAh/mhDcmVh
            dGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAx
            OTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRl
            dmVsY29yLmNvbQA7
        }
        image create photo textfile -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJSWjPz+/Ozq7GxqbJyanPT29HRy
            dMzOzDQyNIyKjERCROTi3Pz69PTy7Pzy7PTu5Ozm3LyqlJyWlJSSjJSOhOzi
            1LyulPz27PTq3PTm1OzezLyqjIyKhJSKfOzaxPz29OzizLyidIyGdIyCdOTO
            pLymhOzavOTStMTCtMS+rMS6pMSynMSulLyedAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaQ
            QIAQECgajcNkQMBkDgKEQFK4LFgLhkMBIVUKroWEYlEgMLxbBKLQUBwc52Hg
            AQ4LBo049atWQyIPA3pEdFcQEhMUFYNVagQWFxgZGoxfYRsTHB0eH5UJCJAY
            ICEinUoPIxIcHCQkIiIllQYEGCEhJicoKYwPmiQeKisrKLFKLCwtLi8wHyUl
            MYwM0tPUDH5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }


    }
    ##+##########################################################################
    #
    # DoDisplay -- Creates our help display. If we have tile 0.7.8 then
    # we will also have a TOC pane.
    #
    method DoDisplay {} {
        set W(top) $win
        set TOP $win
        #wm title $TOP "Help"
        #wm transient $TOP .
        if {[winfo exists $TOP.status]} {
            return
        }
        frame $TOP.status
        if {$options(-toolbar) && $npages > 1} {
            pack $TOP.status -side top -expand false -anchor n
        }
        pack [button $TOP.status.refresh -image reload-16  -relief groove -borderwidth 2\
              -command [mymethod Refresh]] -padx 3 -pady 4 -side left -ipadx 2 -ipady 2
        pack [button $TOP.status.home -image navhome16  -relief groove -borderwidth 2\
              -command [mymethod Show]] -padx 3 -pady 4 -side left -ipadx 2 -ipady 2
        pack [button $TOP.status.index -image klipper-16  -relief groove -borderwidth 2 \
              -command [mymethod Show index]] -padx 3 -pady 4 -side left -ipadx 2 -ipady 2    
        #pack [button $TOP.status.first -image start-16  -relief groove -borderwidth 2 -state disabled] -padx 3 -pady 4 -side left -ipadx 2 -ipady 2
        pack [button $TOP.status.backward -image navback16  -relief groove -borderwidth 2 \
              -command [mymethod Show Back] -state disabled] -padx 3 -pady 4 -side left -ipadx 2 -ipady 2
        set W(backward) $TOP.status.backward 
        
        pack [button $TOP.status.forward -image navforward16  -relief groove -borderwidth 2 -state disabled \
              -command [mymethod Show Forward]]  -padx 3 -pady 4 -side left     -ipadx 2 -ipady 2
        set W(forward) $TOP.status.forward 
        
        #    pack [button $TOP.status.last -image finish-16  -relief groove -borderwidth 2 -state disabled]  -padx 3 -pady 4 -side left     -ipadx 2 -ipady 2
        pack [ttk::separator $TOP.status.sep -orient vertical] -side left -expand false -padx 5 -fill y -pady 3
        #   pack [button $TOP.status.bl -image playstart16 -command { puts First } -relief groove -borderwidth 2] -side left -padx 2
        pack [button $TOP.status.bb -image nav1leftarrow16 -command [mymethod Show Previous] -relief groove -borderwidth 2] -side left -padx 2
        pack [button $TOP.status.bf -image nav1rightarrow16 -command  [mymethod Show Next] -relief groove -borderwidth 2] -side left -padx 2
        #pack [button $TOP.status.b1 -image playend16 -command { puts Last } -relief groove -borderwidth 2] -side left -padx 2
        pack [entry  $TOP.status.e -textvar [myvar state(search)]] -side left -padx 5 
        set sentry $TOP.status.e
        bind $TOP.status.e <Return> [mymethod DoToolSearch]
        pack [button $TOP.status.be -text Search! -command [mymethod DoToolSearch]] -side left -padx 5
        frame $TOP.bottom -bd 2 -relief ridge
        
        button $TOP.b -text "Dismiss" -command [list destroy [winfo parent $TOP]]
        if {$options(-dismissbutton)} {
            pack $TOP.bottom -side bottom -fill both
            pack $TOP.b -side bottom -expand 1 -pady 10 -in $TOP.bottom
        }
        
        set P $TOP.p
        if {$::haveTile078} {                       ;# Need tags on treeview
            set state(haveTOC) 1
            ::ttk::panedwindow $P -orient horizontal
            
            pack $P -side top -fill both -expand 1
            frame $P.toc -relief ridge
            frame $P.help -bd 2 -relief ridge
            $self CreateTOC $P.toc
            $self CreateHelp $P.help
            if {$options(-toctree) && $npages > 1 && [llength [$W(tree) children ""]] > 0} {
                $P add $P.toc
            }
            $P add $P.help
        } else {
            set state(haveTOC) 0
            frame $P
            pack $P -side top -fill both -expand 1
            $self CreateHelp $P
        }

        #bind $TOP <Map> [list apply { TOP {
        #    bind $TOP <Map> {}
        #    CenterWindow $TOP 
        #}} $TOP]
        #pack $fr -side top -fill both -expand true
 
    }
    ##+##########################################################################
    #
    # CreateTOC -- Creates a TOC display from tile's treeview widget
    #
    method CreateTOC {TOC} {
        set W(tree) $TOC.tree
        ttk::scrollbar $TOC.sby -orient vert -command "$W(tree) yview"
        #scrollbar $TOC.sbx -orient hori -command "$W(tree) xview"
        
        ::ttk::treeview $W(tree) -padding {2 2 2 2} -selectmode browse \
              -yscrollcommand "$TOC.sby set" ;#$ -xscrollcommand "$TOC.sbx set"
        # todo: must be recalled after font changes !! (Done)
        ttk::style configure Treeview \
              -rowheight [expr {[font metrics $font -linespace] + 5}]
        ttk::style configure Treeview.Item \
              -padding {2 3 2 2}
        #$W(tree) configure -rowheight 20
        grid $W(tree) $TOC.sby -sticky news
        #grid $TOC.sbx -sticky ew
        grid rowconfigure $TOC 0 -weight 1
        grid columnconfigure $TOC 0 -weight 1
        
        $W(tree) heading #0 -text "Table of Contents"
        $W(tree) tag configure link -foreground blue
        # NB. binding to buttonpress sometimes "misses" clicks
        $W(tree) tag bind link <Key-Return> [mymethod ButtonPress]
        $W(tree) tag bind link <Button-1> [mymethod ButtonPress]
        $W(tree) tag bind link <<TreeviewSelect>> [mymethod ButtonPress]
        bind $W(tree) <<TreeviewOpen>> [mymethod TreeviewUpdateImages true]
        bind $W(tree) <<TreeviewClose>> [mymethod TreeviewUpdateImages false]
        $self BuildTOC
    }
    ##+##########################################################################
    #
    # CreateHelp -- Creates our main help widget
    #
    method CreateHelp {w} {
 
        set W(main) $w.t ;# normal
        text $w.t -border 5 -relief flat -wrap word -state disabled -width 60 \
              -yscrollcommand "$w.s set" -padx 5 -font $fonts(std)
        $W(tree) tag configure std -font [$W(main) cget -font]
        
        ttk::scrollbar $w.s -orient vert -command "$w.t yview"
        pack $w.s -fill y -side right
        pack $w.t -fill both -expand 1 -side left
        
        $w.t tag config link -foreground blue -underline 1
        $w.t tag config seen -foreground purple4 -underline 1
        $w.t tag bind link <Enter> "$w.t config -cursor hand2"
        $w.t tag bind link <Leave> "$w.t config -cursor {}"
        $w.t tag bind link <1> [mymethod Click $w.t %x %y]
        $w.t tag config hdr -font $fonts(hdr)
        $w.t tag config hdr3 -font $fonts(hdr3)
        $w.t tag config hr -justify center
        $w.t tag config fix -font $fonts(fixed)
        $w.t tag config bold -font $fonts(bold)
        $w.t tag config italic -font $fonts(italic)
        set l1 [font measure $font "   "]
        set l2 [font measure $font "   \u2022   "]
        set l3 [font measure $font "       \u2013   "]
        set l3 [expr {$l2 + ($l2 - $l1)}]
        $w.t tag config bullet -lmargin1 $l1 -lmargin2 $l2
        $w.t tag config number -lmargin1 $l1 -lmargin2 $l2
        $w.t tag config dash -lmargin1 $l1 -lmargin2 $l2
        $w.t tag config bar -lmargin1 $l2 -lmargin2 $l2
        
        # this should not work as the widget is disabled
        #        bind $w.t <n> [list ::Help::Next $w.t 1]
        #        bind $w.t <p> [list ::Help::Next $w.t -1]
        #        bind $w.t <b> [list ::Help::Back $w.t]
        #        bind $w.t <Key-space> [bind Text <Key-Next>]
        
        # Create the bitmap for our bullet
        if {0 && [lsearch [image names] bullet] == -1} {
            image create bitmap bullet -data {
                #define bullet_width  11
                #define bullet_height 9
                static char bullet_bits[] = {
                    0x00,0x00, 0x00,0x00, 0x70,0x00, 0xf8,0x00, 0xf8,0x00,
                    0xf8,0x00, 0x70,0x00, 0x00,0x00, 0x00,0x00
                };
            }
        }
        # bindings
        #    foreach tag [$w.t tag names] {
        #        puts $tag
        #        $w.t tag bind $tag <KeyPress> { puts %K }
        #    }
        #bind $w.t <KeyPress> {
        #    puts %K
        #}
        # but this should work as is bind on the toplevel
        # some keys are reserved for navigation of the toc widget 
        # such us Left, Right, Up, Down
        if {[info exists W(top)] && [winfo exists $W(top)]} {
            bind $w.t <Enter> [mymethod Bindings %W true]
            bind $w.t <Leave> [mymethod Bindings %W false]
            wm protocol [winfo toplevel $w.t] WM_DELETE_WINDOW [mymethod DestroyToplevel]
        }
        
    }
    method DestroyToplevel {} {
        $self Bindings $W(main) false
        destroy [winfo toplevel $W(top)]
    }
    method Bindings {w on} {
        if {$on} {
            bind all <Key-space> [list tk::TextScrollPages $w +1 ]
            bind all <Key-BackSpace> [list tk::TextScrollPages $w -1 ]
            bind all <Key-Next> [list tk::TextScrollPages $w +1 ]
            bind all <Key-Prior> [list tk::TextScrollPages $w -1 ]
            bind all <Control-k> [list tk::TextScrollPages $w -1 ]
            bind all <Control-j> [list tk::TextScrollPages $w +1 ]
            bind all <Control-b> [list tk::TextScrollPages $w -1 ]
            bind all <Control-space> [list tk::TextScrollPages $w +1 ]
            bind all <Control-h> [mymethod Show Back]
            bind all <Alt-Left> [mymethod Show Back]
            bind all <Control-l> [mymethod Show Forward]
            bind all <Alt-Right> [mymethod Show Forward]
            bind all <n> [mymethod Next $w 1]
            bind all <p> [mymethod Next $w -1]
            bind all <b> [mymethod Back $w]
            bind all <Control-plus> [mymethod changeFontSize +2]
            bind all <Control-minus> [mymethod changeFontSize -2]

        } else {
            bind all <Key-space>     {}
            bind all <Key-BackSpace> {}
            bind all <Key-Next>      {}
            bind all <Key-Prior>     {}
            bind all <Control-k> {}
            bind all <Control-j> {}
            bind all <Control-b> {}
            bind all <Control-space> {}
            bind all) <Control-h> {}
            bind all <Alt-Left> {}
            bind all <Control-l> {}
            bind all <Alt-Right> {}
            bind all <n> {}
            bind all <p> {}
            bind all <b> {}
            bind all <Control-plus> {}
            bind all <Control-minus> {}

            
        }
    }
    method changeFontSize {i} {
        #set size [font configure $font -size]
        #if {$size < 0} {
        #    # pixel
        #    incr size [expr {$i*-1}]
        #} else {
        #    incr size $i
        #}
        #font configure $font -size $size
        foreach fnt [array names fonts] {
            font configure $fonts($fnt) -size [expr {[font configure $fonts($fnt) -size] + $i}]
        }
        #set font 
        #$W(tree) tag configure std -font $font
        ttk::style configure Treeview \
              -rowheight [expr {[ttk::style configure Treeview -rowheight] + $i}]
    }

    ##+##########################################################################
    #
    # Click -- Handles clicking a link on the help page
    #
    method Click {w x y} {
        set range [$w tag prevrange link "[$w index @$x,$y] + 1 char"]
        if {[llength $range]} { $self Show [eval $w get $range]}
    }
    ##+##########################################################################
    #
    # Back -- Goes back in help history
    #
    method Back {w} {
        if {[$sh canBackward]} {
            set back [$sh back]
            $self Show $back
        }
    }
    #
    # Forward -- Goes forward in help history
    method Forward {w} {
        if {[$sh canForward]} {
            set forw [$sh forward]
            $self Show $forw
        }
    }
    ##+##########################################################################
    #
    # Next -- Goes to next help page
    #
    method Next {w dir} {
        set what $state(all)
        if {$state(allTOC) ne {}} {set what $state(allTOC)} ;# TOC order if we can
        
        set n [lsearch -exact $what $state(current)]
        set n [expr {($n + $dir) % [llength $what]}]
        set next [lindex $what $n]
        $self Show $next
    }
    ##+##########################################################################
    #
    # ::Help::Listpage -- Puts up a help page with a bunch of links (all or history)
    #
    method Listpage {w llist} {
        foreach i $llist {$w insert end \n; $self Showlink $w $i}
    }
    ##+##########################################################################
    #
    # Search -- Creates search help page
    #
    method Search {w} {
        if {$options(-toolbar)} {
            focus $sentry
        } else {
            $w insert end "\nSearch phrase:      "
            entry $w.e -textvar [myvar state(search)]
            $w window create end -window $w.e
            focus $w.e
            #$w.e select range 0 end
            $w.e icursor end
            bind $w.e <Return> [mymethod DoToolSearch]
            button $w.b -text Search! -command [mymethod DoToolSearch]
            $w insert end " "
            $w window create end -window $w.b
        }
    }
    ##+##########################################################################
    #
    # DoSearch -- Does actual help search
    #
    method DoToolSearch {} {
        $W(main) config -state normal
        $W(main) delete 1.0 end
        $self Search $W(main)
        $self DoSearch $W(main)
        $W(main) config -state disabled

    }
    method DoSearch {w} {
        $w config -state normal
        $w insert end "\n\nSearch results for '$state(search)':\n"
        foreach i $state(all) {
            if {[regexp -nocase $state(search) $i]} { ;# Found in title
                $w insert end \n
                $self Showlink $w $i
            } elseif {[regexp -nocase -indices -- $state(search) $pages($i) pos]} {
                set p1 [expr {[lindex $pos 0]-20}]
                set p2 [expr {[lindex $pos 1]+20}]
                regsub -all \n [string range $pages($i) $p1 $p2] " " context
                $w insert end \n
                $self Showlink $w $i
                $w insert end " - ...$context..."
            }
        }
        $w config -state disabled ;#normal
    }
    ##+##########################################################################
    #
    # Showlink -- Displays link specially
    #
    method Showlink {w link {tag {}}} {
        if {[regexp {(\.png|\.gif)$} $link]} {
            set imgName [file tail [file rootname $link]]
            set imgFile [file join [file dirname $options(-helpfile)] $link]
            if {[file exists $imgFile]} {
                image create photo $imgName -file $imgFile
                #puts "Image:'$link'"
                $w image create end -image $imgName
            } else {
                $w insert end "(Error: file $link does not exists)"
            }
        } else {
            set tag [concat $tag link]
            set title [$self FindPage $link]
            if {[lsearch -exact $state(seen) $title] > -1} {
                lappend tag seen
            }
            $w insert end $link $tag
        }
    }
    ##+##########################################################################
    #
    # FindPage -- Finds actual pages given a possible alias
    #
    method FindPage {title} {
        if {[info exists pages($title)]} { return $title }
        set title2 [string tolower $title]
        if {[info exists alias($title2)]} { return $alias($title2) }
        return "ERROR!"
    }
    ##+##########################################################################
    #
    # Show -- Shows help or meta-help page
    #
    method Show {{title ""}} {
        set title [string trim $title]
        if {$title eq ""} {
            set title $var(home)
        }
        
        set w $W(main)
        set title [$self FindPage $title]
        
        if {[lsearch -exact $state(seen) $title] == -1} {lappend state(seen) $title}
        $w config -state normal
        $w delete 1.0 end
        $w insert end $title hdr "\n"
        set next 0                                  ;# Some pages have no next page
        switch -- $title {
            Back     { $self Back $w; return}
            Forward  { $self Forward $w; return}        
            History  { $self Listpage $w [$sh getHistory]}
            Next     { $self Next $w 1; return}
            Previous { $self Next $w -1; return}
            Index    { $self Listpage $w $state(all)}
            Search   { $self Search $w}
            default  { $self ShowPage $w $title ; set next 1 }
        }
        
        # Add bottom of the page links
        if {$options(-bottomnavigation)} {
            $w insert end \n------\n {}
            if {! $state(haveTOC) && [info exists alias(toc)]} {
                $w insert end TOC link " - " {}
            }
            $w insert end Index link " - " {} Search link
            if {$next} {
                $w insert end " - " {} Previous link " - " {} Next link
            }
            if {[llength [$sh getHistory]]} {
                $w insert end " - " {} History link " - " {} Back link
            }
            
            $w insert end \n
        }
        $sh insert $title
        if {[$sh canBackward]} {
            $W(backward) configure -state active
        } else {
            $W(backward) configure -state disabled
        }
        if {[$sh canForward]} {
            $W(forward) configure -state active
            
        } else {
            $W(forward) configure -state disabled
        }
        
        
        $w config -state disabled ;#disabled
        set state(current) $title
    }
    ##+##########################################################################
    #
    # ShowPage -- Shows a text help page, doing wiki type transforms
    #
    method ShowPage {w title} {
        set endash \u2013
        set emdash \u2014
        set bullet \u2022
        
        $w insert end \n                            ;# Space down from the title
        if {! [info exists pages($title)]} {
            set lines [list "This help page is missing." "" "See \[Index\] for a list of existing pages!"]
        } else {
            # image fix
            set txt [regsub -all {([^ ]{3}!)\[.*?\]\((.+?)\)} $pages($title) "\\1\[\\2\]"]
            # link fix
            set txt [regsub -all {([^!])\[(.*?)\]\((.+?)\)} $txt "\\1\[\\2\]"]
            set txt [regsub -all {\n!} $txt "\n"]
            set lines [split $txt \n]
        }
        
        set ind ""
        foreach line $lines {
            set tag {}
            set op1 ""
            if {[regexp -line {^[-_]{3,4}\s*$} $line]} {
                $w insert end "[string repeat _ 30]\n" hr
                continue
            } elseif {[regexp -line {^[#]{3,5}\s(.+)} $line -> txt]} {
                $w insert end "$txt\n" hdr3
                continue
            } elseif {[regexp -line {^>\s*$} $line]} {
                set ind "   | "
                $w insert end "\n"
                continue
            } elseif {[regexp -line {^>(\s+[-*].+)} $line -> rest]} {

                set  ind "   |"
                set line $rest
                #puts $line
                #continue
            } elseif {[regexp -line {^>\s([A-Z0-9a-z].+)} $line -> rest]} {
                #puts  $line
                set  ind "   | "
                set line $rest
                #continue
            } elseif {[regexp {^\s*$} $line]} {
                set ind ""
            }
            set line "$ind$line"
            if {[regexp -line {^ +\|*\s*([-1*|]+)\s+(.*)} $line -> op txt]} {
                set ind2 ""
                if {[regexp -line {^ +\|} $line ]} {
                    set ind2 "         "
                } 
                set op1 [string index $op 0]
                set lvl [expr {[string length $op] - 1}]
                set indent $ind2[string repeat "     " $lvl]
                if {$op1 eq "1"} {                  ;# Number
                    if {! [info exists number($lvl)]} { set number($lvl) 0 }
                    set tag number
                    incr number($lvl)
                    $w insert end "$indent $number($lvl). " $tag
                } elseif {$op1 eq "*"} {            ;# Bullet
                    set tag bullet
                    $w insert end "$indent $bullet " $tag
                } elseif {$op1 eq "-"} {            ;# Dash
                    set tag dash
                    $w insert end "$indent $endash " $tag
                } elseif {$op1 eq "|"} {            ;# Bar
                    set tag bar
                }
                set line $txt
            } elseif {[string match "  *" $line]} {  ;# Line beginning w/ a space
                $w insert end "$line\n" fix
                unset -nocomplain number
                continue
            }
            if {$op1 ne "1"} {unset -nocomplain number}
            
            while {1} {                             ;# Look for markups
                set link0 [set bold0 [set ital0 $line]]
                set n1 [regexp {^(.*?)[[](.*?)[]](.*$)} $line -> link0 link link1]
                set n2 [regexp {^(.*?)('{3}|[*]{2})(.*?)('{3}|[*]{2})(\s*.*$)} $line -> bold0 x bold y bold1]
                set n3 [regexp {^(.*?)('{2}|[*]{1})([^\s].*?)('{2}|[*]{1})(\s*.*$)} $line -> ital0 x ital y ital1]
                set n4 [regexp {^(.*?)`(.*?)`(\s*.*$)} $line -> tt0 tt tt1]
                if {$n4} {
                    set len4 [expr {$n4 ? [string length $tt0] : 9999}]
                }

                if {$n1 == 0 && $n2 == 0 && $n3 == 0 && $n4 == 0} break
                
                set len1 [expr {$n1 ? [string length $link0] : 9999}]
                set len2 [expr {$n2 ? [string length $bold0] : 9999}]
                set len3 [expr {$n3 ? [string length $ital0] : 9999}]
                set len4 [expr {$n4 ? [string length $tt0] : 9999}]
                set l1 [lindex [lsort -integer [list $len1 $len2 $len3 $len4]] 0]
                if {false} {
                    if {$len1 < $len3} {
                        $w insert end $link0 $tag
                        $self Showlink $w $link $tag
                        set line $link1
                    } elseif {$len2 <= $len3} {
                        $w insert end $bold0 $tag $bold [concat $tag bold]
                        set line $bold1
                    } else  {
                        $w insert end $ital0 $tag $ital [concat $tag italic]
                        set line $ital1
                    }
                }
                if {$len1 == $l1} {
                    $w insert end $link0 $tag
                    $self Showlink $w $link $tag
                    set line $link1
                } elseif {$len2 == $l1} {
                    $w insert end $bold0 $tag $bold [concat $tag bold]
                    set line $bold1
                } elseif {$len3 == $l1}  {
                    $w insert end $ital0 $tag $ital [concat $tag italic]
                    set line $ital1
                } else {
                    $w insert end $tt0 $tag $tt [concat $tag fix]
                    set line $tt1
                }
                #$w insert end $ital0 $tag $ital [concat $tag italic]
                    #set line $ital1
                # else 
                #    $w insert end $tt0 $tag $tt1 [concat $tag fix]
                #    set line $tt1
                #
            }
            $w insert end "$line\n" $tag
        }
    }
    ##+##########################################################################
    #
    # BuildTOC -- Fills in our TOC widget based on a TOC page
    #
    method BuildTOC {} {
        set state(allTOC) {}                        ;# All pages in TOC ordering
        if {! [winfo exists $W(tree)]} return
        set tocData $pages([$self FindPage toc])
        $W(tree) delete [$W(tree) child {}]
        #$W(tree) configure -padding {50 10 2 2}
        unset -nocomplain parent
        set parent() {}
        
        regsub -all {'{2,}} $tocData {} tocData
        regsub -all {\(#.+?\)} $tocData "" tocData
        regsub -all { {4,5}([-*+]) }   $tocData  "    \\1\\1 " tocData
        #puts $tocData
        foreach line [split $tocData \n] {
            
            set n [regexp {^\s{1,}([-*]+)\s*(.*)} $line => dashes txt]
            if {! $n} continue
            
            set isLink [regexp {^\[(.*)\]$} $txt => txt]
            set pDashes [string range $dashes 1 end]
            if {[info exists var("icon,$txt")]} {
                set icon $var("icon,$txt")
            } else {
                set icon filenew16
            }
            set parent($dashes) [$W(tree) insert $parent($pDashes) end -text " $txt" -tag std -image $icon]
            if {$parent($pDashes) ne ""} {
                $W(tree) item $parent($pDashes) -image book
            }
            if {$isLink} {
                $W(tree) item $parent($dashes) -tag [list link std]
                
                set ptitle [$self FindPage $txt]
                if {[lsearch $state(allTOC) $ptitle] == -1} {
                    lappend state(allTOC) $ptitle
                }
            }
        }
    }
    ##+##########################################################################
    #
    # ButtonPress -- Handles clicking on a TOC link
    # !!! Sometimes misses clicks, so we're using TreeviewSelection instead
    #
    method ButtonPress {} {
        set id [$W(tree) selection]
        set title [$W(tree) item $id -text]
        $self Show $title
    }
    ##+##########################################################################
    #
    # TreeviewSelection -- Handles clicking on any item in the TOC
    #
    method TreeviewSelection {} {
 
        set id [$W(tree) selection]
        set title [$W(tree) item $id -text]
        set tag [$W(tree) item $id -tag]
        if {$tag eq "link"} {
            $self Show $title
        } else {                                    ;# Make all children visible
            set last [lindex [$W(tree) children $id] end]
            if {$last ne {} && [$W(tree) item $id -open]} {
                $W(tree) see $last
            }
        }
    }
    ##+###########################################################################
    #
    # TreeviewUpdateImages -- check if children are visible and update icon
    # 
    method TreeviewUpdateImages {open} {
        # event fires before 
        # the children are indeed displayed or hided
        set item [$W(tree) focus]
        if {$open} {
            if {[llength [$W(tree) children $item]] > 0} {
                $W(tree) item $item -image bookopen
            }
        } else {
            if {[llength [$W(tree) children $item]] > 0} {
                $W(tree) item $item -image book
            }
        }
    }
    method CenterWindow {w} {
        wm withdraw $w
        set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
               - [winfo vrootx [winfo parent $w]]]
        set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
               - [winfo vrooty [winfo parent $w]]]
        wm geom $w +$x+$y
        wm deiconify $w
    }
    ##+##########################################################################
    #
    # Refresh -- resets all help info and updates widget
    #
    method Refresh {} {
        set current $state(current)
        array unset pages
        set pages(ERROR!) "page does not exists"
        array unset state
        array set state {seen {} current {} all {} allTOC {} haveTOC 0}
        array unset alias
        
        foreach title {Back History Next Previous Index Search} {
            set alias([string tolower $title]) $title
        }
        $sh resetHistory
        $self ReadHelpFiles 
        $self Show $current
    }
    ##+##########################################################################
    #
    # Sanity -- Checks for missing help links
    #
    method Sanity {} {
        set missing {}
        foreach page $state(all) {
            set m [$self CheckLinks $page]
            if {$m ne {}} {
                set missing [concat $missing $m]
            }
        }
        return $missing
    }
    ##+##########################################################################
    #
    # CheckLinks -- Checks one page for missing help links
    #
    method CheckLinks {title} {
        set missing {}
        set title [$self FindPage $title]
        foreach {. link} [regexp -all -inline {\[(.*?)\]} $pages($title)] {
            if {! [info exists alias([string tolower $link])]} {
                lappend missing $link
            }
        }
        return $missing
    }

    method WIKIFIX {txt} {
        regsub -all {\n } $txt "\n" txt
        return $txt
        
    }
}
## EON HELP
package provide dgw::hyperhelp 0.8.2
#' 
#' ## <a name='example'>EXAMPLE</a>
#' 
#' ```
#' package require dgw::hyperhelp
#' set helpfile [file join [file dirname [info script]] hyperhelp-docu.txt]
#' set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
#' pack $hhelp -side top -fill both -expand true
#' $hhelp help overview
#' ```

#' 
#' ## <a name='formatting'>MARKUP LANGUAGE</a>
#'
#' The Markup language of the hyperhelp widget is similar to Tclers Wiki and Markdown markup.
#' Here are the most important markup commands. For a detailed description have a look at the 
#' file `hyperhelp-docu.txt` which contains the hyperhelp documentation with detailed markup rules.
#'
#' *Page structure:*
#' 
#' A help page in the help file is basically started with the title tag at the beginning of a line and adds with 6 dashes. See here an example for three help pages. 
#' To shorten links in the document later as well an `alias` can be given afterwards. There is also support for Markdown headers as the last page shows.
#'
#' 
#'     title: Hyperhelp Title Page
#'     alias: main
#'
#'     Free text can be written here with standard *Markdown* 
#'     or ''Wiki'' syntax markup.
#'
#'     ------
#'     title: Other Page title
#'     alias: other
#'     icon: acthelp16
#'
#'     Follows more text for the second help page. You can link
#'     to the [main] page here also.
#'     ------
#' 
#'     ## <a name="aliasname">Page title</a>
#'     
#'     Text for the next page after this Markdown like header, the anchor is now an alis 
#'     which can be used for links like here [aliasname], the link [Page title] points to the same page.
#'
#' For the second page an other icon than the standard file icon was given for the help page. This icon is
#' used for the treeview widget on the left displayed left of the page title.
#' The following icons are currently available: acthelp16, bookmark, idea, navhome16, help, sheet, folder, textfile.
#' 
#' *"Table of Contents" page:*
#' 
#' There is a special page called "Table of Contents". The unnumbered list, probably nested, of this page will be used
#' for the navigation outline tree on the left. Below is the example for the contents page which
#' comes with the hyperhelp help file "hyperhelp-docu.txt". The "Table of Contents" page should be the first page
#' in your documentation. Please indent only with standard Markdown syntax compatible, so two spaces 
#' for first level and four spaces for second level.
#' 
#'     title: Table of Contents 
#'     alias: TOC
#'       - [Welcome to the Help System]
#'       - [What's New]
#'       - Formatting
#'         - [Basic Formatting]
#'         - [Aliases]
#'         - [Lists]
#'         - [Substitutions]
#'         - [Images]
#'         - [Code Blocks]
#'         - [Indentation]
#'       - [Creating the TOC]
#'       - [Key Bindings]
#'       - [To Do]
#'     
#'     -------
#
#'
#' *Font styles:*
#' 
#' > - '''bold''' - **bold** (Wiki syntax), \*\*bold\*\* - **bold** (Markdown syntax)
#'   - ''italic'' - *italic* (Wiki syntax), \*italic\* - *italic* (Markdown syntax)
#'   - \`code\`  - `code`
#' 
#' *Links:*
#' 
#' > - hyperlinks to other help pages within the same document are created using brackets: `[overview]` -> [overview](#overview)
#'   - image links, where images will be embedded and shown `[image.png]`
#'   - also image display and hyperlinks in Markdown format are supported. Therefore `![](image.png)` displays an image and 
#'     `[Page title](#alias)`  creates a link to the page "Page title"
#' 
#' *Code blocks:*
#' 
#' > - code blocks are started by indenting a line with three spaces
#'   - the block continues until less than three leading whitespace character are found on the text
#'
#' *Indentation:*
#'
#' > - indented blocks are done by using the pipe symbol `|` or the greater symbol  as in Markdown syntax
#'   - indenting ends on lines without whitespaces as can be seen the following example
#'
#' 
#'      > * indented one with `code text`
#'        * indented two with **bold text**
#'        * indented three with *italic text*
#' 
#'      this text is again unindented
#' 
#' 
#' *Substitutions:*
#'
#' > - you can substitute variables and commands within the help page
#'   - command substition is done using double brackets like in `[[package require dgw::hyperhelp]]` would embed the package version of the hyperhelp package
#'   - variable substitution is done using the Dollar variable prefix, for instance `$::tcl_patchLevel` would embed the actual Tcl version
#'   - caution: be sure to not load files from unknown sources, command substitution should not work with commands like `file`, `exec` or `socket`. 
#'     But anyway only use your own help files
#'
#' *Lists:*
#' 
#' > - support for list and nested lists using the standard `* item` and `** subitem`` syntax
#'   - numbered lists can be done with starting a line with `1. ` followed by a white space such as in ` 1. item` and ` 11. subitem`
#'   - dashed lists can be done with single and double dashes 
#'
#' *Key bindings:*
#' 
#' > The  hyperhelp  window  provides  some  standard  key bindings to navigate the content:
#' 
#' > * space, next: scroll down
#' * backspace, prior: scroll up
#' * Ctrl-k, Ctrl-j: scroll in half page steps up and down
#' * Ctrl-space, Ctrl-b: scroll down or up
#' * Ctrl-h, Alt-Left, b: browse back history if possible
#' * Ctrl-l, Alt-Right: browse forward in history if possible
#' * n, p: browse forward or backward in page order
#' * Control-Plus, Control-Minus changes in font-size
#' * Up, Down, Left, Right etc are used for navigation in the treeview widget
#'
#'  
#' ## <a name='install'>INSTALLATION</a>
#' 
#' Installation is easy you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' - the dgtools::shistory package which can be found at the same side as the dgw::hyperhelp package
#' 
#' For installation you copy the complete *dgw* and the *dgtools* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose. Please note, that in the latter case you must redo this 
#' for the `dgtools::shistory` package.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --code
#' ```
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. 
#' To extract the documentation you need that the dgwutils.tcl file is in 
#' the same directory with the file `__BASENAME__.tcl`. 
#' Then you can use the following command lines:
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
#' - [dgw - package](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#' - [shtmlview - package](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#'
#' ## <a name='todo'>TODO</a>
#'
#' * some more template files (done)
#' * tests (done, could be more)
#' * github url
#' * fix for broken TOC with four indents needed (done (?))
#'
#' ## <a name='changes'>CHANGES</a>
#' 
#' - 2020-02-01 Release 0.5 - first published version
#' - 2020-02-05 Release 0.6 - catching errors for missing images and wrong Tcl code inside substitutions
#' - 2020-02-07 Release 0.7 
#'     - options _-toolbar_, _-toctree_ for switchable display
#'     - single page, automatic hiding of toctree and toolbar
#'     - outline widget only shown if TOC exists
#'     - adding Control-Plus, Control-Minus for font changes
#'     - fix indentation and italic within indentation is now possible
#'     - basic Markdown support 
#' - 2020-02-16 Release 0.8.0
#'     - fix for Ctrl.j, Ctrk-k keys
#'     - disabled default command substitutions
#' - 2020-02-19 Release 0.8.1
#'     - removed bug in the within page search
#'     - insertion cursors for search remains in the widget
#'     - fixed bug in help page 
#' - 2020-03-02
#'     - adding hyperhelp-minimal example to the code
#'     - adding --sample option to print this to the terminal
#'
#' ## <a name='authors'>AUTHOR(s)</a>
#' 
#' The *__PKGNAME__* package was written by Dr. Detlef Groth, Schwielowsee, Germany using Keith Vetters code from the Tclers Wiki as starting point.
#' 
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#' 
#' The __PKGNAME__ package version __PKGVERSION__
#' 
#' Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#'
if {[info exists argv0] && $argv0 eq [info script] && [regexp hyperhelp $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    package require dgw::dgwutils
    #source [file join [file dirname [info script]] dgwutils.tcl]
    if {[llength $argv] >= 1 && [file exists [lindex $argv 0]]} {    
        set sub false
        # todo deal with --option and topic
        if {[llength $argv] > 1 && [lindex $argv 1] eq "--commandsubst"} {
            set sub true
        }
        set hhelp [dgw::hyperhelp .win -helpfile [lindex $argv 0] -commandsubst $sub] ;#-font [{Alegreya 12}]
        if {[llength $argv] == 2 && !$sub} {
            $hhelp Help [lindex $argv 1]
        } elseif {[llength $argv] == 3} {
            $hhelp Help [lindex $argv 2]
        }

        pack .win -side top -fill both -expand true
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
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
        tcltest::test gui-2.1 {
            starting hyperhelp
        } -body {
            package require dgw::hyperhelp
            set helpfile [file join [file dirname [info script]] hyperhelp-docu.txt]
            set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
            pack $hhelp -side top -fill both -expand true
            $hhelp help "What's New"
            $hhelp help "overview"            
            $hhelp help "toc"       
            $hhelp help "What's New"
            set result [$hhelp getTitle]
            $hhelp help "What's New"
            set pages [$hhelp getPages]
            foreach page $pages {
                $hhelp help $page
                update idletasks
                after 500
            }
            $hhelp help "What's New"
            destroy .help
            set result
        } -result {What's New}
        tcltest::test gui-2.2 {
            simple on page side
        } -body {
            package require dgw::hyperhelp
            set helpfile [file join [file dirname [info script]] hyperhelp-onepage-sample.txt]
            set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
            pack $hhelp -side top -fill both -expand true
            set result [$hhelp getTitle]
            set pages [$hhelp getPages]
            foreach page $pages {
                $hhelp help $page
                update idletasks
                after 500
            }
            destroy .help
            set result 1
        } -result {1}
        tcltest::test gui-2.3 {
            notoc test with several pages
        } -body {
            package require dgw::hyperhelp
            set helpfile [file join [file dirname [info script]] hyperhelp-notoc-sample.txt]
            set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
            pack $hhelp -side top -fill both -expand true
            set result [$hhelp getTitle]
            set pages [$hhelp getPages]
            foreach page $pages {
                $hhelp help $page
                update idletasks
                after 500
            }
            destroy .help
            set result 1
        } -result {1}
        tcltest::test gui-2.4 {
            markdown test
        } -body {
            package require dgw::hyperhelp
            set helpfile [file join [file dirname [info script]] hyperhelp-markdown-sample.md]
            set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
            pack $hhelp -side top -fill both -expand true
            set result [$hhelp getTitle]
            set pages [$hhelp getPages]
            foreach page $pages {
                $hhelp help $page
                update idletasks
                after 500
            }
            destroy .help
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--sample"} {
        puts $::dgw::HyperMini
        destroy .
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a help viewer widget with hyperhelp"
        puts "text facilities and a browser like toolbar"
        puts ""
        puts "Usage: [info nameofexe] [info script] option|filename\n"
        puts "    filename is a help file with hyperhelp markup"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --sample  : print a sample help file to the terminal to be piped into new help file"
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
    if {[lindex $argv 0] eq "demo"} {
        panedwindow .pw
        set hfile [file join [file dirname [info script]] help.txt]
        set hhelp [hyperhelp::hyperhelp .pw.win -helpfile $hfile]
        $hhelp Help overview
        set hhelp2 [hyperhelp::hyperhelp .pw.win2 -helpfile $hfile]
        $hhelp2 Help overview
        pack .pw -side left -fill both -expand yes
        .pw add $hhelp $hhelp2
        
    }
}


