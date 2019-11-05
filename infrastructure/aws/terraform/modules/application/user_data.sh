#!/bin/sh
sudo touch /opt/tomcat/bin/setenv.sh
sudo chmod 777 /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS"\" >> /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS -Ddomain=${aws_db_endpoint}"\" >> /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS -Dbucket=${bucketName}\"" >> /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS -DdbName=${dbName}"\" >> /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS -Dusername=${dbUserName}"\" >> /opt/tomcat/bin/setenv.sh
sudo echo "JAVA_OPTS=\"\$JAVA_OPTS -Dpassword=${dbPassword}\"" >> /opt/tomcat/bin/setenv.sh
sudo /opt/tomcat/bin/./shutdown.sh
sudo /opt/tomcat/bin/./startup.sh