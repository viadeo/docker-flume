# Docker Flume

This docker instance make flume available for ECS stacks.
Docker flume containers run (one) on each ECS instance listening on 9999 (avro), 9997 (http) port for events.

You can contact your local flule instance from docker container by identifying your local host IP with metadata endpoint

  curl http://169.254.169.254/latest/meta-data/local-ipv4

it require Route53 record for local domain on "flume-collector" to address flume-collector ELB (avro endpoint)
