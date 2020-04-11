#! /bin/bash
#install tomcat and configure management functions
#JAVA install
JAVA_VERSION=jdk-8u101-linux-x64
tar zxvf $JAVA_VERSION.tar.gz
mv $JAVA_VERSION /usr/local/
echo "export JAVA_HOME=/usr/local/$JAVA_VERSION" >> /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin" >> /etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib" >> /etc/profile
source /etc/profile
ln -s /usr/local/$JAVA_VERSION/bin/java /bin/java

#tomcat install
TOMCAT_VERSION=apache-tomcat-9.0.33
TOMCAT_HOME=/usr/local/tomcat
tar zxvf $TOMCAT_VERSION.tar.gz
rm -rf $TOMCAT_HOME
mv $TOMCAT_VERSION /usr/local/tomcat

#startup script
mv tomcat /etc/init.d/
chmod 644 /etc/init.d/tomcat

#start tomcat
service tomcat start

#info
echo "please access by IP+8080"

#management function
sed -i 's#<\/tomcat-users>##g' $tomcat_HOME/conf/tomcat-users.xml
echo -e "<role rolename=\"admin-gui\"/>\n<role rolename=\"admin-script\"/>\n<role rolename=\"manager-gui\"/>\n<role rolename=\"manager-script\"/>\n<role rolename=\"manager-jmx\"/>\n<role rolename=\"manager-status\"/>\n<user username=\"tomcat\" password=\"tomcatabc\" roles=\"admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status\"/>\n</tomcat-users>" >> $tomcat_HOME/conf/tomcat-users.xml
