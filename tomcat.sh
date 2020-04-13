#! /bin/bash
#install tomcat and configure management functions
#JAVA install
#每运行一次，/etc/profile会增加好几行；
JAVA_VERSION=jdk-8u101-linux-x64.tar.gz
JAVA_NAME=jdk1.8.0_101
tar zxf $JAVA_VERSION
rm -rf /usr/local/$JAVA_NAME
/usr/bin/mv $JAVA_NAME /usr/local/
echo -e "export JAVA_HOME=/usr/local/$JAVA_NAME\nexport PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin\nexport CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib" >> /etc/profile
source /etc/profile
rm -f /bin/java
ln -s /usr/local/$JAVA_NAME/bin/java /bin/java

#JAVA optimized
sed -i 's#securerandom.source=file:\/dev\/random#securerandom.source=file:\/dev\/urandom#g' $JAVA_HOME/jre/lib/security/java.security

#tomcat install
TOMCAT_VERSION=apache-tomcat-9.0.33
tar zxf $TOMCAT_VERSION.tar.gz
rm -rf /usr/local/$TOMCAT_VERSION
/usr/bin/mv $TOMCAT_VERSION /usr/local/
TOMCAT_HOME=/usr/local/$TOMCAT_VERSION
echo -e "export TOMCAT_VERSION=apache-tomcat-9.0.33\nexport TOMCAT_HOME=/usr/local/$TOMCAT_VERSION" >>/etc/profile
source /etc/profile

#startup script
rm -f /etc/init.d/tomcat
cat > /etc/init.d/tomcat <<EOF
#!/bin/bash 
TOMCAT_HOME=$TOMCAT_HOME
SHUTDOWN=\$TOMCAT_HOME/bin/shutdown.sh
STARTTOMCAT=\$TOMCAT_HOME/bin/startup.sh
case \$1 in
start)
echo "启动\$TOMCAT_HOME"
\$STARTTOMCAT
;;
stop)
echo "关闭\$TOMCAT_HOME"
\$SHUTDOWN
#pidlist=`ps -ef |grep java |grep -v "grep"|awk '{print $2}'`
#kill -9 \$pidlist
;;
restart)
echo "关闭\$TOMCAT_HOME"
\$SHUTDOWN
#pidlist=`ps -ef |grep java |grep -v "grep"|awk '{print $2}'`
#kill -9 \$pidlist
sleep 5
echo "启动\$TOMCAT_HOME"
\$STARTTOMCAT
;;
esac
EOF
chmod 755 /etc/init.d/tomcat

#management function
#user setup
sed -i 's#<\/tomcat-users>##g' $TOMCAT_HOME/conf/tomcat-users.xml
echo -e "<role rolename=\"admin-gui\"/>\n<role rolename=\"admin-script\"/>\n<role rolename=\"manager-gui\"/>\n<role rolename=\"manager-script\"/>\n<role rolename=\"manager-jmx\"/>\n<role rolename=\"manager-status\"/>\n<user username=\"tomcat\" password=\"tomcatabc\" roles=\"admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status\"/>\n</tomcat-users>" >> $TOMCAT_HOME/conf/tomcat-users.xml
echo -e "\033[33m tomcat management user:pw = tomcat:tomcatabc \033[0m"
increaseIP () {
echo $IP
sed -i "s/|0:0:0:0:0:0:0:1/|0:0:0:0:0:0:0:1|$IP/g" $TOMCAT_HOME/webapps/host-manager/META-INF/context.xml
sed -i "s/|0:0:0:0:0:0:0:1/|0:0:0:0:0:0:0:1|$IP/g" $TOMCAT_HOME/webapps/manager/META-INF/context.xml
}

#allow IP
#add IP
#if you use local linux,you can change eth0 to ens33;
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
		eth0IP=`ip addr |grep eth0 |tail -1|awk '{print $2}'|awk -F '/' '{print $1}'`
		echo -e "\033[33m checking eth0IP=$eth0IP \033[0m"
	  	a=`echo $eth0IP |awk -F '.' '{print $1"."$2"."$3}'`	
		c=$a\.\*
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
		echo -e "\033[33m checking add .* all IP allowed \033[0m"
		IP=\.\*
		increaseIP
		break
		;;
          *)
             	continue
        	;;
        esac
    fi    
  done

#management
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
echo -e "\033[33m checking please access by IP+8080 \033[0m"
