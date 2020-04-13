#! /bin/bash
# maven install
MAVEN_VERSION=apache-maven-3.6.3
tar zxvf $MAVEN_VERSION-bin.tar.gz
rm -rf /usr/local/$MAVEN_VERSION
mv $MAVEN_VERSION /usr/local/
/usr/local/$MAVEN_VERSION/bin/mvn --version
