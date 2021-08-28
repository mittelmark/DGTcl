##-*- makefile -*-############################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 08:52:58 2021
#  Last Modified : <210828.1354>
#
#  Description	 - Makefile for pandoc-tcl-filter
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################

FILES=Makefile Readme.html Readme.md pandoc-tcl-filter.tcl mini.css LICENSE json-pretty.tcl \
	pandoc-tcl-filter.md pandoc-tcl-filter.html filter-dot.tcl \
	filter-tsvg.tcl lib/tsvg/tsvg.tcl lib/tsvg/pkgIndex.tcl lib/tsvg/tsvg.html lib/tsvg/tsvg.md \
	lib/rl_json/pkgIndex.tcl lib/rl_json/json.html lib/rl_json/librl_json0.11.0.so \
	lib/rl_json/json.n lib/rl_json/mini.css


default:
	pandoc test.md -s --metadata title="test run with tcl filter" \
		-M date="`date "+%B %e, %Y %H:%M"`" \
		-o test.html --filter pandoc-tcl-filter.tcl --css mini.css

debug:
	pandoc -s -t json test.md > test.json 	
devel:	
	pandoc -s -t json test.md > test.json 	
	cat test.json | tclsh pandoc-tcl-filter.tcl | tclsh json-pretty.tcl
Readme.html : Readme.md mini.css
	pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
		-M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html \
		--filter pandoc-tcl-filter.tcl --css mini.css --toc

pandoc-tcl-filter.html: pandoc-tcl-filter.tcl
	perl -ne "s/^#' ?(.*)/\$$1/ and print " pandoc-tcl-filter.tcl > pandoc-tcl-filter.md
	pandoc pandoc-tcl-filter.md -s  \
	    --metadata title="pandoc-tcl-filter.tcl documentation"  \
	    -o pandoc-tcl-filter.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css
github:
	for file in $(FILES) ; do cp -u $${file} ~/workspace/DGTcl/pandoc-tcl-filter/$${file} ; done

tsvg-test:
	tclsh lib/tsvg/tsvg.tcl
tsvg-docu: 	
	perl -ne "s/^#' ?(.*)/\$$1/ and print " lib/tsvg/tsvg.tcl > tsvg.md
	pandoc tsvg.md -s  \
	    --metadata title="tsvg package documentation"  \
	    -o tsvg.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css
	htmlark -o lib/tsvg/tsvg.html tsvg.html
	cp tsvg.md lib/tsvg/
