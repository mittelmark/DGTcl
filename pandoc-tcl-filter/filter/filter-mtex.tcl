##############################################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Aug 30 19:07:46 2021
#  Last Modified : <210830.2057>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from Dr. Detlef Groth.
#
##############################################################################
proc filter-mtex {cnt dict} {
set code {
\ifdefined\formula
\else
    \def\formula{E = m x c^2}
\fi
\documentclass[16pt,border=2pt]{standalone}
\usepackage{amsmath}
\usepackage{varwidth}
\begin{document}
\__FONTSIZE__
\begin{varwidth}{\linewidth}
\[ \formula \]
\end{varwidth}
\end{document}
}
    global n
    incr n
    set def [dict create results hide eval true fig true width 400 height 400 \
             include true label null fontsize Large envir equation]
    set dict [dict merge $def $dict]
    set code [regsub {__FONTSIZE__} $code [dict get $dict fontsize]]
    #set code [regsub {__CNT__} $cnt [dict get $dict fontsize]]    
    #set code [regsub {__envir__} $cnt [dict get $dict envir]]        
    set tempfile [file join /tmp [file tempfile]]
    set out [open $tempfile.tex w 0600]
    puts $out $code
    close $out
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname mtex-$n
    } else {
        set fname [dict get $dict label]
    }
    # TODO: error catching
    set owd [pwd]
    cd /tmp
    #puts stderr ""
    exec -ignorestderr latex "\\def\\formula{$cnt}\\input{$tempfile.tex}" > /dev/null
    puts stderr "exec dvipng $tempfile.dvi $fname.png > /dev/null 2> /dev/null    "
    exec -ignorestderr dvipng $tempfile.dvi -o $fname.png > /dev/null 2> /dev/null
    file copy -force $fname.png [file join $owd $fname.png]
    cd $owd
    set res ""
    #set res [exec dot -Tsvg $fname.dot -o $fname.svg]
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.png
        }
    }
    return [list $res $img]
}
