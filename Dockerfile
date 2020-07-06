#
#  Dockerfile for JSPWiki running in a tomcat 9 on top of OpenJDK11 
#
FROM alpine:3.12
MAINTAINER Harry Metske <metskem@apache.org>, Surj Bains <surj@polarpoint.io>

# Environment variables
ENV APACHE_TOMCAT_VERSION="9.0.36"
ENV JSP_WIKI_VERSION=2.11.0.M7
ENV JSPWIKI_WIKIPAGES_LANGUAGE=en


# add user and group 
ARG user=tomcat
ARG group=tomcat
ARG uid=1000
ARG gid=1000

RUN apk add --no-cache  openjdk11-jre curl ca-certificates
#-------------------------------------------------------------
#  Install Tomcat
#-------------------------------------------------------------
RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat


# download apache tomcat version
RUN  curl -O https://www.mirrorservice.org/sites/ftp.apache.org/tomcat/tomcat-9/v${APACHE_TOMCAT_VERSION}/bin/apache-tomcat-${APACHE_TOMCAT_VERSION}.tar.gz && tar -xvzf  apache-tomcat-${APACHE_TOMCAT_VERSION}.tar.gz \
      &&  mv apache-tomcat-${APACHE_TOMCAT_VERSION}/* /opt/tomcat/. && rm -rf apache-tomcat-${APACHE_TOMCAT_VERSION}.tar.gz


ENV TOMCAT_HOME /opt/${user}
RUN addgroup -g ${gid} ${group}
RUN adduser -h $TOMCAT_HOME -u ${uid} -G ${group} -D ${user}


# remove stuff we don't need
RUN    rm -rf /opt/tomcat/bin/*.bat && \
# provide access to tomcat manager application with user/pw = admin/admin :
    echo -e '<?xml version="1.0" encoding="utf-8"?>\n<tomcat-users>\n<role rolename="manager-gui"/>\n<role rolename="manager-script"/>\n<role rolename="manager-jmx"/>\n<role rolename="manager-status"/>\n<role rolename="admin"/>\n<user username="admin" password="admin" roles="manager,manager-gui,manager-script,manager-jmx,manager-status"/>\n</tomcat-users>' > ${TOMCAT_HOME}/conf/tomcat-users.xml
#-------------------------------------------------------------
#  Install JSPWiki
#-------------------------------------------------------------
# download jspwiki version
RUN  curl -O https://www.mirrorservice.org/sites/ftp.apache.org/jspwiki/${JSP_WIKI_VERSION}/binaries/webapp/JSPWiki.war && mv JSPWiki.war /tmp/jspwiki.war

# add jspwiki war, create JSPWiki webapps dir, unzip it there.
# create a directory where all jspwiki stuff will be hosted
RUN mkdir /var/jspwiki && \
# first remove default tomcat applications, we dont need them to run jspwiki
   cd ${TOMCAT_HOME}/webapps && rm -rf examples host-manager manager docs ROOT  
# create subdirectories where all jspwiki stuff will be hosted
RUN   cd /var/jspwiki && mkdir pages logs etc work && mkdir ${TOMCAT_HOME}/webapps/ROOT 
RUN   unzip  /tmp/jspwiki.war  -d  ${TOMCAT_HOME}/webapps/ROOT  
RUN   rm /tmp/jspwiki.war
RUN  curl -o /tmp/jspwiki-wikipages.zip https://www.mirrorservice.org/sites/ftp.apache.org/jspwiki/${JSP_WIKI_VERSION}/wikipages/jspwiki-wikipages-${JSPWIKI_WIKIPAGES_LANGUAGE}-${JSP_WIKI_VERSION}.zip 

RUN cd /tmp/ && unzip jspwiki-wikipages.zip -d /var/jspwiki/pages/ && rm -rf jspwiki-wikipages
# move the userdatabase.xml and groupdatabase to /var/jspwiki/etc
RUN cd ${TOMCAT_HOME}/webapps/ROOT/WEB-INF && mv userdatabase.xml groupdatabase.xml /var/jspwiki/etc
# arrange proper logging (jspwiki.use.external.logconfig = true needs to be set)
ADD log4j.properties ${TOMCAT_HOME}/lib/log4j.properties
#
# make everything owned by tomcat
RUN chown -R ${user}:${group} /var/jspwiki ${TOMCAT_HOME}/*
#
# set default environment entries to configure jspwiki
ENV LANG en_US.UTF-8
ENV jspwiki_pageProvider VersioningFileProvider
ENV jspwiki_fileSystemProvider_pageDir /var/jspwiki/pages
ENV jspwiki_basicAttachmentProvider_storageDir /var/jspwiki/pages
ENV jspwiki_workDir /var/jspwiki/work
ENV jspwiki_xmlUserDatabaseFile /var/jspwiki/etc/userdatabase.xml
ENV jspwiki_xmlGroupDatabaseFile /var/jspwiki/etc/groupdatabase.xml
ENV jspwiki_use_external_logconfig true
ENV jspwiki_templateDir haddock
ENV jspwiki_jspwiki_frontPage Main
ENV CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom

# run with user tomcat
USER ${user}


# make port visible in metadata
EXPOSE 8080
# 
# by default we start the Tomcat container when the docker container is started.
CMD ["/usr/local/tomcat/bin/catalina.sh","run", ">/usr/local/tomcat/logs/catalina.out"]
