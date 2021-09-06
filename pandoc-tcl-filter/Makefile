##-*- makefile -*-############################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 08:52:58 2021
#  Last Modified : <210906.0906>
#
#  Description	 - Makefile for pandoc-tcl-filter
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################

FILES=Makefile Readme.html Readme.md pandoc-tcl-filter.tcl mini.css LICENSE json-pretty.tcl \
	pandoc-tcl-filter.md pandoc-tcl-filter.html filter/filter-dot.tcl \
	filter/filter-mtex.tcl filter/smallcaps.lua \
	filter/filter-tsvg.tcl lib/tsvg/tsvg.tcl lib/tsvg/pkgIndex.tcl lib/tsvg/tsvg.html lib/tsvg/tsvg.md \
	lib/tdot/tdot.tcl lib/tdot/pkgIndex.tcl lib/tdot/tdot.html lib/tdot/tdot.md \
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
		--filter pandoc-tcl-filter.tcl --toc --lua-filter=filter/smallcaps.lua
	htmlark -o Readme-ark.html Readme.html
	mv Readme-ark.html Readme.html

pandoc-tcl-filter.html: pandoc-tcl-filter.tcl
	perl -ne "s/^#' ?(.*)/\$$1/ and print " pandoc-tcl-filter.tcl > pandoc-tcl-filter.md
	pandoc pandoc-tcl-filter.md -s  \
	    --metadata title="pandoc-tcl-filter.tcl documentation"  \
	    -o pandoc-tcl-filter.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css
filter/filter-dot.html: filter/filter-dot.tcl
	perl -ne "s/^#' ?(.*)/\$$1/ and print " filter/filter-dot.tcl > filter/filter-dot.md
	pandoc filter/filter-dot.md -s  \
	    --metadata title="filter-dot.tcl documentation"  \
	    -o filter/filter-dot.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css -M date="`date "+%B %e, %Y %H:%M"`"
github:
	for file in $(FILES) ; do cp -u $${file} ~/workspace/DGTcl/pandoc-tcl-filter/$${file} ; done

tsvg-test:
	tclsh lib/tsvg/tsvg.tcl
tsvg-docu: 	
	perl -ne "s/^#' ?(.*)/\$$1/ and print " lib/tsvg/tsvg.tcl > tsvg.md
	pandoc tsvg.md -s  \
	    --metadata title="tsvg package documentation"  \
	    -o tsvg.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css --toc
	htmlark -o lib/tsvg/tsvg.html tsvg.html
	cp tsvg.md lib/tsvg/

tdot-docu: 	
	perl -ne "s/^#' ?(.*)/\$$1/ and print " lib/tdot/tdot.tcl > tdot.md
	pandoc tdot.md -s  \
	    --metadata title="tdot package documentation"  \
	    -o tdot.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css --toc
	htmlark -o lib/tdot/tdot.html tdot.html
	cp tdot.md lib/tdot/
