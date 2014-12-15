# RUNAS docker run -it -d --name jenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home deege/jenkins

FROM t0nyhays/java8base

MAINTAINER DJ Spiess (http://www.deege.com, dj@deege.com)

RUN apt-get update && apt-get install -y wget git curl zip && rm -rf /var/lib/apt/lists/*

# Set versions
ENV MAVEN_VERSION 3.2.3
ENV GROOVY_VERSION 2.3.8
ENV JENKINS_VERSION latest

# Install Maven
RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV PATH $MAVEN_HOME/bin:$PATH

# install git
RUN apt-get install -y git

# Install Groovy 
RUN mkdir /opt/groovy/
WORKDIR /opt
RUN cd /opt 
RUN wget http://dl.bintray.com/groovy/maven/groovy-binary-$GROOVY_VERSION.zip 
RUN unzip groovy-binary-$GROOVY_VERSION.zip && mv groovy-$GROOVY_VERSION /groovy
RUN ln -s /groovy/bin/{grape,groovy,groovyConsole,groovyc,groovydoc,groovysh,java2groovy,startGroovy} /usr/local/bin/
ENV GROOVY_HOME /opt/groovy/
ENV PATH $GROOVY_HOME/bin:$PATH

# install Jenkins
RUN useradd -d /home/jenkins -m -s /bin/bash jenkins
ADD http://mirrors.jenkins-ci.org/war/${JENKINS_VERSION}/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins
VOLUME /var/jenkins_home

# for main web interface:
EXPOSE 8080
# will be used by attached slave agents:
EXPOSE 50000

ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
