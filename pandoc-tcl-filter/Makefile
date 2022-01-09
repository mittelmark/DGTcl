##-*- makefile -*-############################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 08:52:58 2021
#  Last Modified : <220109.1949>
#
#  Description	 - Makefile for pandoc-tcl-filter
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################

Readme.html : Readme.md mini.css header.md
	pandoc -o header.html header.md
	pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
		-M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html -B header.html  \
		--filter ./pandoc-tcl-filter.tcl --toc --lua-filter=filter/smallcaps.lua
	htmlark -o Readme-ark.html Readme.html
	mv Readme-ark.html Readme.html

pandoc-tcl-filter.html: pandoc-tcl-filter.tcl
	chmod 755 ./pandoc-tcl-filter.tcl
	./pandoc-tcl-filter.tcl pandoc-tcl-filter.tcl pandoc-tcl-filter-out.html --css mini.css -s
	htmlark -o pandoc-tcl-filter.html pandoc-tcl-filter-out.html
filter/filter-dot.html: filter/filter-dot.tcl
	perl -ne "s/^#' ?(.*)/\$$1/ and print " filter/filter-dot.tcl > filter/filter-dot.md
	pandoc filter/filter-dot.md -s  \
	    --metadata title="filter-dot.tcl documentation"  \
	    -o filter/filter-dot.html  --filter pandoc-tcl-filter.tcl \
	    --css mini.css -M date="`date "+%B %e, %Y %H:%M"`"
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
tcl-filter.tapp:
	if [ ! -d pandoc-tapp ] ;  then mkdir pandoc-tapp ; fi
	cp pandoc-tcl-filter.tcl pandoc-tapp/
	if [ ! -d  pandoc-tapp/pandoc-tcl-filter.vfs ] ;  then mkdir  pandoc-tapp/pandoc-tcl-filter.vfs ; fi
	echo "lappend auto_path [file normalize [file join [file dirname [info script]] lib]]" > pandoc-tapp/pandoc-tcl-filter.vfs/main.tcl
	cp -r lib pandoc-tapp/pandoc-tcl-filter.vfs/
	-rm -rf pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters
	cp  -r filter pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*~
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*md
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*lua
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*.n	
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*.dot	
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*html
	-rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*png	
	-rm -rf pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters/figures
	-rm -rf pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters/images
	-rm -rf pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters/nfigures
	cd pandoc-tapp && tclsh ../../bin/tpack.tcl wrap pandoc-tcl-filter.tapp
	cd pandoc-tapp && cp pandoc-tcl-filter.tapp ..
tests-folder:
	tclsh pandoc-tcl-filter.tcl tests/table.md tests/table.html -s --css mini.css
	htmlark tests/table.html -o tests/table-out.html
	cp tests/table-out.html tests/table.html

	
