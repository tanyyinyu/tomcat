#! /bin/bash
#install tomcat and configure management functions
#JAVA install
JAVA_VERSION=jdk-8u101-linux-x64.tar.gz
JAVA_NAME=jdk1.8.0_101
tar zxvf $JAVA_VERSION
/usr/bin/mv $JAVA_NAME /usr/local/
echo -e "export JAVA_HOME=/usr/local/$JAVA_NAME\nexport PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin\nexport CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib" >> /etc/profile
source /etc/profile
ln -s /usr/local/$JAVA_NAME/bin/java /bin/java

#JAVA optimized
sed -i 's#securerandom.source=file:\/dev\/random#securerandom.source=file:\/dev\/urandom#g' $JAVA_HOME/jre/lib/security/java.security

#tomcat install
TOMCAT_VERSION=apache-tomcat-9.0.33
tar zxvf $TOMCAT_VERSION.tar.gz
/usr/bin/mv $TOMCAT_VERSION /usr/local/
TOMCAT_HOME=/usr/local/$TOMCAT_VERSION
echo -e "export TOMCAT_VERSION=apache-tomcat-9.0.33\nexport TOMCAT_HOME=/usr/local/$TOMCAT_VERSION" >>/etc/profile
source /etc/profile

#startup script
/usr/bin/mv tomcat /etc/init.d/
chmod 644 /etc/init.d/tomcat

#management function
#user setup
sed -i 's#<\/tomcat-users>##g' $TOMCAT_HOME/conf/tomcat-users.xml
echo -e "<role rolename=\"admin-gui\"/>\n<role rolename=\"admin-script\"/>\n<role rolename=\"manager-gui\"/>\n<role rolename=\"manager-script\"/>\n<role rolename=\"manager-jmx\"/>\n<role rolename=\"manager-status\"/>\n<user username=\"tomcat\" password=\"tomcatabc\" roles=\"admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status\"/>\n</tomcat-users>" >> $TOMCAT_HOME/conf/tomcat-users.xml
#allow IP
#IP
addIP () {
while :
  do
    read -p "please input the IP you would like to add or you can add all or internal": IP
    if echo "$IP" | egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
      then
	increaseIP	
	break
      else
        case $IP in
          "internal")
		ens33IP=`ip addr |grep ens33 |tail -1|awk '{print $2}'|awk -F '/' '{print $1}'`
    		echo "ens33IP=$ens33IP"
	  	a=`echo $ens33IP |awk -F '.' '{print $1"."$2"."$3}'`	
		c=$a.*
		read -p "if this range $c you would like to add (y or n):" b
		case $b in
			"y")
			  IP=$c
			  increaseIP
			  break
			  ;;
			"n")
			  continue
			  ;;
			"*")
			  continue
			  ;;
		esac
		;;
          "all")
  		echo "all"
		echo "add .* all IP, zhihoutihuan"
		IP=".*"
		increaseIP  
		break
		;;
          *)
             	continue
        	;;
        esac
    fi    
  done
}
increaseIP () {
sed -i 's/0:0:0:0:0:0:0:1|/0:0:0:0:0:0:0:1|$IP/g' $TOMCAT_HOME/webapps/host-manager/META-INF/context.xml 
sed -i 's/0:0:0:0:0:0:0:1|/0:0:0:0:0:0:0:1|$IP/g' $TOMCAT_HOME/webapps/manager/META-INF/context.xml 

#management
TOMCAT_HOME=/usr/local/tomcat9
f=`wc -l $TOMCAT_HOME/conf/server.xml|awk '{print $1}'`
/usr/bin/mv $TOMCAT_HOME/conf/server.xml $TOMCAT_HOME/conf/server.xml.bak
d=`grep org.apache.catalina.core.ThreadLocalLeakPreventionListener -n $TOMCAT_HOME/conf/server.xml.bak|awk -F ':' '{print $1}'`
head -$d $TOMCAT_HOME/conf/server.xml.bak > $TOMCAT_HOME/conf/server.xml
echo "<Listener className=\"org.apache.catalina.storeconfig.StoreConfigLifecycleListener\"/>" >> $TOMCAT_HOME/conf/server.xml
e=$(($f-$d))
tail -$e $TOMCAT_HOME/conf/server.xml.bak >> $TOMCAT_HOME/conf/server.xml

#start tomcat
service tomcat start

#info
echo "please access by IP+8080"
