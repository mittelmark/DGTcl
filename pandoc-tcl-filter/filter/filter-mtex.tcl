#' ---
#' title: "filter-mtex.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-12
#' dot:
#'     imagepath: nfigures
#'     ext: png
#' ---
# a simple pandoc filter using Tcl the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-mtex.tcl_ - Filter which can be used to display LaTeX equations 
#' within a Pandoc processed document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' Alternatively since version 0.4.0 the filter comes as well as a stand alone 
#' applicaion and can be used like this:
#' 
#' ```
#' pandoc-tcl-filter.tapp input.md output.html -s --css mini.css
#' ```
#' 
#' 
#' All arguments that pandoc accepts can be added after the output file.
#' 
#' The file `filter-mtex.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.mtex` marker are found, the contents in the code block is processed via one of the Graphviz tools.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be png, pdf, default: pdf
#'   - fig - should a figure be created, default: true
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#' 
#' The  options results, eval, fif should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default image output path to nfigures and the filename to pdf
#' 
#' ```
#'  ----
#'  title: "filter-mtex.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-12
#'  dot:
#'      imagepath: nfigures
#'      ext: pdf
#'  ----
#' ```
#'
#' ## Installation
#' 
#' The filter needs an existing LaTeX installation and the LaTeX packages standalone and preview.
#' 
#' ## Examples
#' 
#' ```{.mtex}
#' $ E=mc^2 $
#' ```
#' 
#' ```{.mtex}
#' \begin{equation*} \label{eu_eqn}
#' e^{\pi i} + 1 = 0
#' \end{equation*}
#' ```
#' 
#' The beautiful equation \ref{eu_eqn} is known as the Euler equation.
#'
#' Now an example for the align environment:
#' 
#' ```{.mtex}
#' \begin{align*} 
#' 2x - 5y &=  8 \\ 
#' 3x + 9y &=  -12
#' \end{align*}
#' ```
#' 
#' An here for the multiline environment:
#' 
#' ```{.mtex}
#' \begin{multline*}
#' p(x) = 3x^6 + 14x^5y + 590x^4y^2 + 19x^3y^3\\ 
#' - 12x^2y^4 - 12xy^5 + 2y^6 - a^3b^3
#' \end{multline*}
#' ```
#' 
#' Now using colors with the xolor package:
#' 
#' ```{.mtex}
#' \color{red}{
#' \begin{multline*}
#' p(x) = 3x^6 + 14x^5y + 590x^4y^2 + 19x^3y^3\\ 
#' - 12x^2y^4 - 12xy^5 + 2y^6 - a^3b^3
#' \end{multline*}
#' }
#' ```
#'
#' Large brackets:
#' 
#' ```{.mtex}
#' $$
#' \left[ \frac{ N } { \left( \frac{L}{p} \right)  - (m+n) }  \right]
#' $$
#' ```
#' 
#' And now a matrix:
#' 
#' ```{.mtex}
#' $$
#' \begin{bmatrix}
#' 1 & 2 & 3\\
#' a & b & c\\
#' d & e & f
#' \end{bmatrix}
#' $$
#' ```
#' 
#' And lastly let's look if errors are catched:
#' 
#' ```{.mtex}
#' $$
#' \begin{xmatrix}
#' 1 & 2 & 3\\
#' a & b & c\\
#' d & e & f
#' \end{xmatrix}
#' $$
#' ```

#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [EQN filter](filter-eqn.html)
#' 
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#
##############################################################################
proc filter-mtex {cnt dict} {
set codestart {
\documentclass[preview]{standalone}
\usepackage{amsmath}
\usepackage{xcolor}
% if you need the equation number, remove the asterix
\PreviewEnvironment{equation*}
\PreviewEnvironment{align*}
\PreviewEnvironment{multiline*}

% if you need paddings, adjust the following
\PreviewBorder=2pt


\begin{document}
\__FONTSIZE__
}
set codeend {
\end{document}
}
    global n
    incr n
    set def [dict create results hide eval true fig true width 400 height 400 \
             include true label null fontsize Large envir equation imagepath images]
    set dict [dict merge $def $dict]
    set codestart [regsub {__FONTSIZE__} $codestart [dict get $dict fontsize]]
    #set code [regsub {__CNT__} $cnt [dict get $dict fontsize]]    
    #set code [regsub {__envir__} $cnt [dict get $dict envir]]        
    set tdir [getTempDir]
    set tempfile [file join $tdir [file tempfile]]
    set out [open $tempfile.tex w 0600]
    puts $out $codestart
    puts $out $cnt
    puts $out $codeend
    close $out
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname mtex-$n
    } else {
        set fname [dict get $dict label]
    }
    # TODO: error catching
    set owd [pwd]
    cd $tdir
    #puts stderr ""
    #puts stderr [exec cat $tempfile.tex]
    #exec -ignorestderr latex "\\def\\formula{$cnt}\\input{$tempfile.tex}" > /dev/null
    set res ""
    if {[catch { set res [exec -ignorestderr latex $tempfile.tex]   } ]} {
        append res "\n$::errorInfo"
        return [list $res ""]
    } else {
        set res ""
    }
    exec -ignorestderr dvipng $tempfile.dvi -o $fname.png > /dev/null 2> /dev/null
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    file copy -force $fname.png [file join $owd [dict get $dict imagepath] $fname.png]
    cd $owd
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
            set img [file join $owd [dict get $dict imagepath] $fname.png]
        }
    }
    return [list $res $img]
}
