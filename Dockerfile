FROM openjdk:8u212-b04-jdk-stretch

ENV SCALA_VERSION 2.12.8
ENV SBT_VERSION 1.2.8

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt

 # Add and use user conseil
RUN groupadd --gid 1001 conseil && useradd --gid 1001 --uid 1001 conseil --shell /bin/bash
RUN chown -R conseil:conseil /opt
RUN mkdir /home/conseil && mkdir /etc/conseil && chown -R conseil:conseil /home/conseil && chown -R conseil:conseil /etc/conseil
RUN mkdir /logs && chown -R conseil:conseil /logs

USER conseil

# Define working directory
WORKDIR /home/conseil

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /home/conseil/ && \
  echo >> /home/conseil/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /home/conseil/.bashrc

# Prepare sbt
RUN \
  sbt sbtVersion && \
  mkdir -p project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

RUN git clone https://github.com/Cryptonomic/Conseil.git

RUN cd Conseil && sbt 'set logLevel in compile := Level.Error' compile -J-Xss32m && sbt "set test in assembly := {}" clean assembly -J-Xss32m

CMD env SBT_OPTS="-Dconfig.file=/etc/conseil/conseil.conf" && sbt -J-Xss32m "runConseil" && sbt -J-Xss32m "runLorre alphanet"