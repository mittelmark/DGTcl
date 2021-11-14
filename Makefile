
default:
	echo default
check:
	echo Ok
build:
	echo build
build-test:
	echo "#!/bin/bash" > test.sh
	ls >> test.sh
	echo "echo this-is-test" >> test.sh
