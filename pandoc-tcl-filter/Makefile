##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 08:52:58 2021
#  Last Modified : <210825.0541>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
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


default:
	pandoc test.md -s --metadata title="test run with tcl filter" -M date="`date "+%B %e, %Y %H:%M"`" \
		-o test.html --filter pandoc-tcl-filter.tcl --css mini.css

debug:
	pandoc -s -t json test.md > test.json 	
devel:	
	pandoc -s -t json test.md > test.json 	
	cat test.json | tclsh pandoc-tcl-filter.tcl | tclsh json-pretty.tcl
Readme.html : Readme.md mini.css
	pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
		-M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html \
		--filter pandoc-tcl-filter.tcl --css mini.css

