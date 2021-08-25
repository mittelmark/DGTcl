##############################################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 07:48:52 2021
#  Last Modified : <210824.0754>
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


lappend auto_path /home/groth/workspace/delfgroth/mytcl/libs
package require rl_json
# pandoc -s -t json dgtools/test.md > dgtools/test.json
# tclsh dgtools/json-pretty.tcl < dgtools/test.json | less
# cat dgtools/test.json | tclsh dgtools/filter.tcl |  tclsh dgtools/json-pretty.tcl
# pandoc dgtools/test.md -s --metadata title="test run with tcl filter" -o dgtools.html --filter dgtools/filter.tcl
# read the JSON AST from stdin
set jsonData {}
while {[gets stdin line] > 0} {
   append jsonData $line
}

puts [rl_json::json pretty $jsonData]
