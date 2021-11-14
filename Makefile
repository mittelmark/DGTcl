
default:
	echo default
check:
	echo Ok
build:
	echo build
build-test:
	echo "#!/bin/bash" > test.sh
	ls >> test.sh
	echo "Operating System" >> test.sh
	echo "parray tcl_platform" | tclsh >> test.sh
	echo "Tcl Version" >> test.sh
	echo "set tcl_patchLevel" | tclsh >> test.sh
	echo "tpack version" >> test.sh
	tclsh bin/tpack.tcl --version >> test.sh
	echo "echo this-is-test" >> test.sh
