#!/bin/bash
function echo_info {
	echo -e "\033[1;39m* ${1}\033[0m"
}

function check_previous_status {
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo -e "\n\033[1;31mUh-oh! There is an error.\033[0m\n"
	fi
}

# Vars

flume_image=flume

# Build Flume image

echo_info "Build Flume image"
docker build -t ${flume_image} .

# (Re)start Flume container

echo_info "Stop previous Flume container (if necessary)"
docker stop flume > /dev/null

echo_info "Start Flume container"
docker run --rm --name=flume -v `pwd`/test/conf:/tmp/conf -v `pwd`/test/tmp:/tmp/flume-io ${flume_image} agent -n agent -c /etc/flume-ng/conf -f /tmp/conf/flume.properties &

# Add new logs in input file

echo "test1" >> `pwd`/test/tmp/flume-input.log
echo "test2" >> `pwd`/test/tmp/flume-input.log
sleep 10

# Check logs in output folder

cat `pwd`/test/tmp/flume-output/* | grep test1
check_previous_status

# Stop Flume container

echo_info "Stop Flume container"
docker stop flume

# Clean temporary files

rm `pwd`/test/tmp/flume-input.log
rm -rf `pwd`/test/tmp/flume-output
mkdir `pwd`/test/tmp/flume-output

exit $ret
