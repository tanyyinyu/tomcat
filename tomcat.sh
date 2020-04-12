#! /bin/bash
#install tomcat and configure management functions
#JAVA install
JAVA_VERSION=jdk-8u101-linux-x64
tar zxvf $JAVA_VERSION.tar.gz
mv $JAVA_VERSION /usr/local/
echo -e "export JAVA_HOME=/usr/local/$JAVA_VERSION\nexport PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin\nexport CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib" >> /etc/profile
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
#user setup
sed -i 's#<\/tomcat-users>##g' $TOMCAT_HOME/conf/tomcat-users.xml
echo -e "<role rolename=\"admin-gui\"/>\n<role rolename=\"admin-script\"/>\n<role rolename=\"manager-gui\"/>\n<role rolename=\"manager-script\"/>\n<role rolename=\"manager-jmx\"/>\n<role rolename=\"manager-status\"/>\n<user username=\"tomcat\" password=\"tomcatabc\" roles=\"admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status\"/>\n</tomcat-users>" >> $TOMCAT_HOME/conf/tomcat-users.xml
#allow IP
#IP
while :
  do
    read -p "please input the external IP you would like to add or you can add all or internal": IP
    if echo "$IP" | egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
      then
        echo "IP begin"
      else
        case $IP in
          "internal")
    		echo "internal"
		break
		;;
          "all")
  		echo "all"
		break
		;;
          *)
             	continue
        	;;
        esac
    fi    
  done
increase IP () {
echo "0:0:0:0:0:0:0:1|" | sed -i 's/0:0:0:0:0:0:0:1|/0:0:0:0:0:0:0:1|$IP/g' $TOMCAT_HOME/webapps/host-manager/META-INF/context.xml 
echo "0:0:0:0:0:0:0:1|" | sed -i 's/0:0:0:0:0:0:0:1|/0:0:0:0:0:0:0:1|$IP/g' $TOMCAT_HOME/webapps/manager/META-INF/context.xml 

}
