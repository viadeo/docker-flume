#!/bin/bash

# start Flume container
docker run --rm --name=flume -v test/conf:/tmp/conf -v test/tmp:/tmp/flume-io viadeo/docker_flume:${CIRCLE_SHA1} agent -n agent -c /etc/flume-ng/conf -f /tmp/conf/flume.properties &

# Add new logs in input file
echo "test1" >> test/tmp/flume-input.log
echo "test2" >> test/tmp/flume-input.log
sleep 10

# Check logs in output folder
cat test/tmp/flume-output/* | grep test1
ret=$?

# Stop Flume container
docker stop flume

exit $ret
