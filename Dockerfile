FROM debian:squeeze

# Install basics
RUN \
  apt-get -qq update && \
  apt-get -y install wget python-software-properties && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Java
RUN \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/webupd8team-java.list  && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get update && \
  echo "oracle-java6-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  apt-get install -y oracle-java6-installer && \
  rm -rf /var/lib/apt/lists/*

# Install HBase 0.92.1 of CDH 4.1.2
RUN \
  echo "deb http://archive.cloudera.com/cdh4/debian/squeeze/amd64/cdh squeeze-cdh4.1.2 contrib" > /etc/apt/sources.list.d/cloudera_repository.list && \
  wget -qO - http://archive.cloudera.com/cdh4/debian/squeeze/amd64/cdh/archive.key | apt-key add - && \
  apt-get update && \
  apt-get install -y flume-ng flume-ng-agent procps && \
  cp /etc/flume-ng/conf/flume-env.sh.template /etc/flume-ng/conf/flume-env.sh && \
  sed -i 's|#JAVA_HOME=.*|JAVA_HOME=/usr/lib/jvm/java-6-oracle|g' /etc/flume-ng/conf/flume-env.sh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "flume-ng"]

CMD [ "help" ]
