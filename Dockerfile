FROM centos:centos6

# update
RUN yum install -y epel-release && yum update -y && yum clean all -y && \
    yum install -y docker-io unzip wget tar which man git openssh-server

# setup sshd/ssh
RUN /sbin/chkconfig sshd on && service sshd start && \
    ssh-keygen -qf /root/.ssh/id_rsa -N "" && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    ssh-keyscan -H localhost >> /root/.ssh/known_hosts && \
    ssh-keyscan -H 0.0.0.0 >> /root/.ssh/known_hosts && \
    ssh-keyscan -H 127.0.0.1 >> /root/.ssh/known_hosts

# setup Oracle Java
ENV JAVA_VER 1.8.0_77
ENV JAVA_DWL_VER 8u77
ENV JAVA_DWL_BVER b03
ENV JAVA_HOME /usr/java64/current
ENV JDK_HOME ${JAVA_HOME}
ENV PATH ${JAVA_HOME}/bin:${PATH}
RUN mkdir /usr/java64 ; cd /usr/java64/ ; \
     wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_DWL_VER}-${JAVA_DWL_BVER}/jdk-${JAVA_DWL_VER}-linux-x64.tar.gz && \
     cd /usr/java64/ && tar -xzf jdk-${JAVA_DWL_VER}-linux-x64.tar.gz && rm jdk-${JAVA_DWL_VER}-linux-x64.tar.gz && \
     cd /usr/java64/ && ln -s jdk${JAVA_VER} current && \
     chown -R root:root /usr/java64 && \
     chmod -R a+rwX /usr/java64 && \
     echo "export JAVA_HOME=${JAVA_HOME}" >> /root/.bashrc && \
     echo "PATH=\${JAVA_HOME}/bin:\${PATH}" >> /root/.bashrc

# setup Maven
ENV MAVEN_VERSION 3.2.5
ENV MAVEN_OPTS -Xms512M -Xmx1024M -Xss1M -XX:MaxPermSize=128M -Djava.awt.headless=true
ENV PATH /usr/share/apache-maven-${MAVEN_VERSION}/bin:${PATH}
RUN curl http://mirrors.ibiblio.org/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz > /usr/share/maven.tar.gz && \
    cd /usr/share && \
    tar xvzf maven.tar.gz && \
    rm -f maven.tar.gz && \
    mkdir /root/.m2 && \
    echo "export MAVEN_VERSION=${MAVEN_VERSION}" >> /root/.bashrc && \
    echo "export MAVEN_OPTS='${MAVEN_OPTS}'" >> /root/.bashrc && \
    echo "export MAVEN_HOME=/usr/share/apache-maven-\${MAVEN_VERSION}" >> /root/.bashrc && \
    echo "PATH=\${MAVEN_HOME}/bin:\${PATH}" >> /root/.bashrc

# setup fluo-dev & download dependencies
RUN cd /root && \
     git clone https://github.com/fluo-dev/fluo-dev.git && \
     cd fluo-dev/conf && cp env.sh.example env.sh && \
     perl -pi -e 's/SETUP_METRICS=false/SETUP_METRICS=true/' env.sh && \
     perl -pi -e 's(APACHE_MIRROR=.*$)(APACHE_MIRROR=http://apache.arvixe.com/)' env.sh && \
     grep 'export FLUO_VERSION' env.sh >> /root/.bashrc && \
     echo 'export FLUO_HOME=/root/fluo-dev/install/fluo-\${FLUO_VERSION}' >> /root/.bashrc && \
     echo 'PATH=\${FLUO_HOME}/bin:\${PATH}' >> /root/.bashrc && \
     cd ../bin/ && ./fluo-dev download ; exit 0

EXPOSE 50070 8088 50095 18080 3000 8083 22

CMD /bin/bash
