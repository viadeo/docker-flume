FROM debian:jessie-slim

# Install basics
RUN \
  mkdir -p /usr/share/man/man1 && \
  apt-get -qq update && \
  apt-get -y install wget python-software-properties openjdk-7-jre-headless && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install HBase 0.92.1 of CDH 4.1.2
RUN \
  echo "deb http://archive.cloudera.com/cdh5/debian/jessie/amd64/cdh jessie-cdh5 contrib" > /etc/apt/sources.list.d/cloudera_repository.list && \
  wget -qO - "http://archive.cloudera.com/cdh5/debian/jessie/amd64/cdh/archive.key" | apt-key add - && \
  apt-get update && \
  apt-get install -y flume-ng flume-ng-agent procps && \
  cp /etc/flume-ng/conf/flume-env.sh.template /etc/flume-ng/conf/flume-env.sh && \
  sed -i 's|#JAVA_HOME=.*|JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/|g' /etc/flume-ng/conf/flume-env.sh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /data/flumeng && chown -R flume /data/flumeng  

EXPOSE 9009 9997 9999 41414 
COPY conf/ /etc/flume-ng/conf/
USER flume

ENTRYPOINT [ "flume-ng" ]
CMD ["agent", "-n", "agent", "-c", "/etc/flume-ng/conf", "-f", "/etc/flume-ng/conf/flume.conf"]
