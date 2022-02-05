#' ---
#' title: "filter-mtex.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2022-0122
#' mtex:
#'     imagepath: images
#'     ext: png
#' ---
# a simple pandoc filter using Tcl the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-mtex.tcl_ - Filter which can be used to display LaTeX equations and LaTeX generated figures
#' within a Pandoc processed document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tapp -s -o output.html
#' ```
#' 
#' Alternatively since version 0.4.0 the filter comes as well as a stand alone 
#' application and can be used like this:
#' 
#' ```
#' pandoc-tcl-filter.tapp input.md output.html -s --css mini.css
#' ```
#' 
#' This can be used as well do extract Markdown code behind `#'' comments like in the source of this
#' file - filter-mtex.tcl itself. The document can be processed like this:
#' 
#' ```
#' pandoc-tcl-filter.tapp filter-mtex.tcl filter-mtex.html -s --css mini.css
#' ```
#'
#' All arguments that pandoc accepts can be added after the output file.
#' 
#' The file `filter-mtex.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `{.mtex}` marker are found, the contents 
#' in the code block is processed via latex or if other latex engines are given, for instance xelatex using this
#' latex engine. For pstricks related packages the option
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg (needs texlive-dvisvgm - [https://dvisvgm.de/](https://dvisvgm.de/) or pdf2svg - [https://github.com/dawbarton/pdf2svg](https://github.com/dawbarton/pdf2svg)), png, pdf, default: png
#'   - fig - should a figure be created, default: true
#'   - header - file with LaTeX code to be included in the document preamble, useful for embed more extensive package configurations and macros, default: null
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - latex - which latex engine should be used, latex (using dbipng, divisvgm or dvipdfm), xelatex (convert, pdf2svg) and and dvips (latex, dvips, ps2pdf, pdf2svg or convert) default: latex
#'   - packages - space separated list of packages which should be included in the LaTeX preamble if null, 
#'     just amsmath and xcolor will be loaded, default: null
#'   - resize - if latex engine pdflatex or latex the percent to resize the final png image, default: 100%
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#' 
#' The  options *results* and *eval* should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#'
#' To change the code chunk defaults for a complete document, 
#' the YAML header can be used. Here an example to change the 
#' default image output path to *nfigures* and the filename extension
#' to *pdf* and to use the *chemformula* LaTeX package:
#' 
#' ```
#'  ----
#'  title: "filter-mtex.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2022-01-22
#'  mtex:
#'      imagepath: nfigures
#'      packages: chemformula
#'      latex:    pdflatex
#'      ext: pdf
#'  ----
#' ```
#'
#' ## Installation / Requirements
#' 
#' The filter needs an existing LaTeX installation and the LaTeX packages *standalone* and *preview*.
#' 
#' In the background quite a set of different tools is used such as convert (conversion to png if first output is pdf), `pdf2svg` or if LaTeX engine is latex `dvi2svgm` for conversion into svg. Here a table with the require tools:
#' 
#' > | latex         | png           | pdf     | svg     |
#' > | ------------- | ------------- | ------- | ------- |
#' > | latex         | dvipng        | dvipdfm | dvisvgm |
#' > | dvips         | convert       | ps2pdf  | pdf2svg |
#' > | xelatex/pdflatex | convert    | -       | pdf2svg |
#' 
#' ## Examples
#' 
#' LaTeX Math
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
#' Now using colors with the xcolor package:
#' 
#' ```{.mtex packages="xcolor"}
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
#' Let's look if errors are catched:
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
#'
#' ### Chemical formulas
#' 
#' It is as well possible to use other LaTeX packages, here an example to use the
#' *chemformula* package for displaying chemical equations.
#' 
#' ```{.mtex packages="chemformula" latex="pdflatex" fontsize="Huge"}
#' \begin{align*}
#' \ch{
#'   RNO2      &<=>[ + e- ] RNO2^{-.} \\
#'   RNO2^{-.} &<=>[ + e- ] RNO2^2-
#' }
#' \end{align*}
#' ```
#' 
#' ### Games and Hobby
#' 
#' Now demonstration of some game packages.
#'
#' Here the display of a chessboard (`{.mtex packages="skak"}`):
#' 
#' ```{.mtex packages="skak"}
#' \largeboard
#' \newgame
#' \fenboard{r5k1/1b1p1ppp/p7/1p1Q4/2p1r3/PP4Pq/BBP2b1P/R4R1K w - - 0 20}
#' \showboard
#' ```
#' 
#' Here the display of a GO game (`{.mtex packages="psgo" latex="dvips"}`):
#' 
#' ```{.mtex packages="psgo" latex="dvips"}
#' \begin{psgoboard*}[9]
#' \move*{c}{3} 
#' \move*{g}{7}
#' \move*{g}{4}
#' \move*{c}{7}
#' \move*{e}{7}
#' \move{f}{6} 
#' \move{e}{6}
#' \move{c}{5}
#' \end{psgoboard*}
#' ```
#' 
#' The *psg* package us using the *pstricks* package and so needs a special conversion via *dvips* so that's why the LaTeX engine must be set to *dvips*.
#' 
#' Next we display a sudoku (`{.mtex packages="sudoku"}`):
#' 
#' ```{.mtex packages="sudoku"}
#' \begin{sudoku}
#' |2|5| | |3| |9| |1|.
#' | |1| | | |4| | | |.
#' |4| |7| | | |2| |8|.
#' | | |5|2| | | | | |.
#' | | | | |9|8|1| | |.
#' | |4| | | |3| | | |.
#' | | | |3|6| | |7|2|.
#' | |7| | | | | | |3|.
#' |9| |3| | | |6| |4|.
#' \end{sudoku}
#' ```
#' 
#' ### Tikz package code
#' 
#' Let's now finally add examples using the famous *tikz* package or packages build on top of the *tkiz*
#' package.
#' 
#' At first a flowchart (`{.mtex packages="tikz" latex="pdflatex"}`):
#' 
#' ```{.mtex packages="tikz" latex="pdflatex"}
#' \begin{tikzpicture}[ultra thick,scale=1.5, every node/.style={scale=1.5}]
#' \node (A) at (0,0) [circle,shade,draw] {$\sin(x)$};
#' \node (B) at (3,0) {$\cos(x)$};
#' \node (C) at (6,0) [fill=red!50] {$-\sin(x)$};
#' \draw[->, blue!50, ultra thick] (A) to[bend right=20]
#' node[above] {$\frac{\partial}{\partial x}$} (B);
#' \draw[->, blue!50, ultra thick] (B) to (C);
#' \draw[<->, ultra thick] (A) to[out=45, in=135] (C);
#' \end{tikzpicture}
#' ```
#' 
#' And here a plot using the *pgfplot* package `{.mtex packages="pgfplots" latex="pdflatex"}`.
#' 
#' ```{.mtex packages="pgfplots" latex="pdflatex"}
#' \begin{tikzpicture}
#'     \begin{axis}[domain=0:1,legend pos=outer north east]
#'     \addplot {sin(deg(x))}; 
#'     \addplot {cos(deg(x))}; 
#'     \addplot {x^2};
#'     \legend{$\sin(x)$,$\cos(x)$,$x^2$}
#'     \end{axis}
#' \end{tikzpicture}
#' ```
#' 
#' Here an example for the *smartdiagram* LaTeX package: `{.mtex packages="smartdiagram" latex="pdflatex"}`
#' 
#' ```{.mtex packages="smartdiagram" latex="pdflatex"}
#' \scalebox{1.5}{ % enlarge the size
#' \smartdiagram[circular diagram:clockwise]{Edit,
#'   pdf\LaTeX, Bib\TeX/ biber, make\-index, pdf\LaTeX}
#' }
#' ```
#' 
#' For more examples for the smartdiagram package see the documentation:
#' #' [https://texdoc.org/serve/smartdiagram/0](https://texdoc.org/serve/smartdiagram/0)
#' 
#' Sometimes you need more code to be added to the document header not only a few usepackage commands. 
#' To include more lines of LaTeX code before the acutal document section you can use the *header* 
#' code chunk option like shown here (`{.mtex packages="tikz" header="tikz-tree.tex" latex="pdflatex" ext="svg" resize="150%"}`). WE further set the output format to *svg* to improve the display quality:
#' 
#' ```{.mtex packages="tikz" header="tikz-tree.tex" latex="pdflatex" ext="svg" resize="150%"}
#' \scalebox{1.1}{
#' \begin{tikzpicture}
#'   [
#'     grow                    = right,
#'     sibling distance        = 5em,
#'     level distance          = 6em,
#'     edge from parent/.style = {draw, -latex},
#'     every node/.style       = {font=\small},
#'     sloped
#'   ]
#'   \node [root] {Formula}
#'     child { node [env] {equation}
#'       edge from parent node [below] {single-line?} }
#'     child { node [dummy] {}
#'       child { node [dummy] {}
#'         child { node [env] {align\\flalign}
#'           edge from parent node [below] {at relation sign?} }
#'         child { node [env] {alignat}
#'           edge from parent node [above] {at several}
#'                            node [below] {places?} }
#'         child { node [env] {gather}
#'                 edge from parent node [above] {centered?} }
#'         edge from parent node [below] {aligned?} }
#'       child { node [env] {multline}
#'               edge from parent node [above, align=center]
#'                 {first left,\\centered,}
#'               node [below] {last right}}
#'               edge from parent node [above] {multi-line?} };
#' \end{tikzpicture}
#' }
#' ```
#' 
#' Here the content of the file *tikz-tree.tex* which will be included in the LaTeX code in the 
#' document preamble before compiling the document:
#' 
#' ```{.tcl echo=false}
#' include tikz-tree.tex
#' ```
#' 
#' And now as well a *tikz* based calendar (`{.mtex packages="[calendar]tikz" latex="pdflatex"}`):
#' 
#' ```{.mtex packages="[calendar]tikz" latex="pdflatex"}
#' \tikz 
#' \calendar
#'     [dates=2022-01-01 to 2022-02-last,week list,
#'      month label above centered]
#'     if (Sunday) [red]
#'     if (Saturday) [red]
#'     if (equals=2022-02-14) [blue];
#' ```
#' 
#' The *tikz* library supports as well programming with LaTeX code `({.mtex packages="tikz" latex="pdflatex"}`):
#' 
#' ```{.mtex packages="tikz" latex="pdflatex"}
#' \scalebox{1.5}{
#' \begin{tikzpicture}
#' \foreach \x in {0,1,2,3}
#'    \foreach \y in {0,1,2,3}
#'      {
#'        \draw (\x,\y) circle (0.2cm);
#'        \fill (\x,\y) circle (0.1cm);
#'      }
#' \end{tikzpicture}}
#' ```
#' 
#' And here a mindmap example (`{.mtex packages="[mindmap]tikz" latex="pdflatex" ext="svg"}`):
#' 
#' ```{.mtex packages="[mindmap]tikz" latex="pdflatex" ext="svg"}
#' \tikz
#' [root concept/.append style={concept color=red!30},
#'    level 1 concept/.append style={concept color=red!20},
#'    level 2 concept/.append style={concept color=red!10},
#'    mindmap]
#' \node [concept] {Root concept}
#'    child[grow=30] {node[concept] {child 2}}
#'    child[grow=0 ] {node[concept] {child 3} 
#'        child[grow=0] { node[concept] {grandchild}}}
#'    child[grow=60] {node[concept] {child 1}};
#' ```
#' 
#' There is as well the possibilty to create handwrite-like charts. Here an example (`{.mtex latex="xelatex" ext="svg" header="xkcd.tex"}`):
#' 
#' ```{.mtex latex="xelatex" ext="svg" header="xkcd.tex"}
#'   \begin{tikzpicture}[xscale=4, yscale=0.05]
#'     \node at (-0.65,100) {100};
#'     \node at (-0.65, 50) { 50};
#'     \node at (-0.65,  0) {  0};
#'     \node at (0.5,115) {\large Claims of supernatural powers};
#'     \begin{scope}[very thick, every path/.style={xkcd}]
#'       \fill[fill=pltblue] (0.875,1) -- ++(0,99) -- ++(0.25,0) -- +(0,-99) -- cycle;
#'       \draw (0.875,1) -- ++(0,99) -- ++(0.25,0) -- +(0,-99);
#'       \draw[ultra thick] (0,3) -- (0,0) node[below, text width=3.4cm, align=center] {confirmed by\\ experiment};
#'       \draw[ultra thick] (1,3) -- (1,0) node[below, text width=3cm, align=center] {refuted by\\ experiment};
#'       \draw (-0.54,0) -- (1.5,0);
#'       \draw (-0.5,0) -- (-0.5,110);
#'       \draw (-0.54,100) -- (-0.46,100);
#'       \draw (-0.54,50)  -- (-0.46,50);
#'     \end{scope}
#'   \end{tikzpicture}
#' ```
#' 
#' For more possibilities to use tikz graphics you should have a look at 
#' the *tikz* and at the *pgf* manual.
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [EQN filter](filter-eqn.html)
#' 
#' ## LaTeX links
#' 
#' * LaTeX cookbook: [https://latex-cookbook.net/](https://latex-cookbook.net/)
#' * Package documentation (see [https://texdoc.org/](https://texdoc.org):
#'     * [https://texdoc.org/serve/tikz/0](https://texdoc.org/serve/tikz/0)
#'     * [https://texdoc.org/serve/pgf/0](https://texdoc.org/serve/pgf/0)
#'     * [https://texdoc.org/serve/pgfplots/0](https://texdoc.org/serve/tikz/0)
#'     * [https://texdoc.org/serve/smartdiagram/0](https://texdoc.org/serve/tikz/0)
#' 
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
#
##############################################################################
proc filter-mtex {cnt dict} {
set codestart {
\documentclass[preview]{standalone}
\usepackage{amsmath}
__PACKAGES__
__HEADER__
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
    set def [dict create results hide eval true ext png fig true width 400 height 400 \
             include true label null fontsize Large envir equation imagepath images \
             density 144 packages null latex latex header null resize 100%]
    set dict [dict merge $def $dict]
    set codestart [regsub {__FONTSIZE__} $codestart [dict get $dict fontsize]]
    if {[dict get $dict packages] eq "null"} {
        set codestart [regsub {__PACKAGES__} $codestart ""]
    } else {
        set packages [regsub -all { +} [dict get $dict packages] " "]
        set pkgs ""
        foreach pkg [split $packages " "] {
            if {[regexp {\[(.+)\](.+)} $pkg -> opt p]} {
                if {$p eq "tikz"} {
                    append pkgs "\\usepackage{$p}\n"
                    append pkgs "\\usetikzlibrary{$opt}\n"
                } else {
                    append pkgs "\\usepackage\[$opt\]{$p}\n"
                }
            } else {
                append pkgs "\\usepackage{$pkg}\n"
            }
        }
        set codestart [regsub {__PACKAGES__} $codestart $pkgs]
    }
    if {[dict get $dict header] eq "null"} {
        set codestart [regsub {__HEADER__} $codestart ""]
    } else {
        set filename [regsub {"} [dict get $dict header] ""] ;# "
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            set filedata [read $infh]
            set codestart [regsub {__HEADER__} $codestart "$filedata\n"]
        }
    }
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
    if {[dict get $dict latex] eq "latex"} {
        if {[catch { set res [exec -ignorestderr latex -halt-on-error $tempfile.tex]   } ]} {
            append res "\n$::errorInfo"
            cd $owd
            return [list $res ""]
        } else {
            set res ""
        }
        if {[dict get $dict ext] eq "png"} {
            exec -ignorestderr dvipng $tempfile.dvi -o $fname.png > /dev/null 2> /dev/null
        } elseif {[dict get $dict ext] eq "svg"} {
            if {[auto_execok dvisvgm] eq ""} {
                set res "Error: install texlive-dvisvgm"
            } else {
                exec -ignorestderr dvisvgm $tempfile.dvi -o $fname.svg > /dev/null 2> /dev/null
            }
        } else {
            exec -ignorestderr dvipdfm $tempfile.dvi -o $fname.pdf > /dev/null 2> /dev/null
        }
    } elseif {[dict get $dict latex] eq "dvips"} {
        if {[catch { set res [exec -ignorestderr latex -halt-on-error $tempfile.tex]   } ]} {
            append res "\n$::errorInfo"
            cd $owd
            return [list $res ""]
        } else {
            set res ""
        }
        if {[catch { 
             exec -ignorestderr dvips -q $tempfile.dvi -o $tempfile.ps > /dev/null 2> /dev/null
             exec -ignorestderr ps2pdf  -dALLOWPSTRANSPARENCY $tempfile.ps $tempfile.pdf > /dev/null 2> /dev/null        
             }]} {
                append res "\n$::errorInfo"
                cd $owd
                return [list $res ""]
        } else {
            set res ""
        }
        if {[dict get $dict ext] eq "png"} {
            exec -ignorestderr convert $tempfile.pdf -trim -colorspace RGB -density [dict get $dict density] -resize [dict get $dict resize] $fname.png  > /dev/null 2> /dev/null
        } elseif {[dict get $dict ext] eq "svg"} {
            if {[auto_execok pdf2svg] eq ""} {
                set res "Error: install pdf2svg"
            } else {
                exec -ignorestderr pdf2svg $tempfile.pdf $fname.svg
            } 
        } else {
            file copy $tempfile.pdf $fname.pdf
        }
        
    } else {
        if {[catch { set res [exec -ignorestderr [dict get $dict latex] -halt-on-error $tempfile.tex]   } ]} {
            append res "\n$::errorInfo"
            cd $owd
            return [list $res ""]
        } else {
            set res ""
        }
        if {[dict get $dict ext] eq "png"} {
            exec -ignorestderr convert $tempfile.pdf -colorspace RGB -density [dict get $dict density] -resize [dict get $dict resize] $fname.png > /dev/null 2> /dev/null
        } elseif {[dict get $dict ext] eq "svg"} {
            if {[auto_execok pdf2svg] eq ""} {
                set res "Error: install pdf2svg"
            } else {
                exec pdf2svg $tempfile.pdf $fname.svg
            } 
        } else {
            file copy $tempfile.pdf $fname.pdf
        }
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    file copy -force $fname.[dict get $dict ext] [file join $owd [dict get $dict imagepath] $fname.[dict get $dict ext]]
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
            set img [file join $owd [dict get $dict imagepath] $fname.[dict get $dict ext]]
        }
    }
    return [list $res $img]
}
