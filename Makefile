##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Dr. Detlef Groth
#  Created       : Sun Nov 14 08:13:42 2021
#  Last Modified : <211114.0815>
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
	echo default
check:
	echo Ok
build:
	echo build
build-test:
	echo "#!/bin/bash" > test.sh
	echo "echo this-is-test" >> test.sh
