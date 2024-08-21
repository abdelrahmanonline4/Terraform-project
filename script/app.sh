#!/bin/bash
sudo -i
# Install Java 1.8
yum install java-1.8* -y

# Install git, maven, wget
dnf install git maven wget -y

# Download and install Apache Tomcat
cd /tmp/
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz

# Add tomcat user
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

# Copy Tomcat files to installation directory
cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/

# Set ownership to the tomcat user
chown -R tomcat.tomcat /usr/local/tomcat

# Create systemd service file for Tomcat
SERVICE_FILE_PATH="/etc/systemd/system/tomcat.service"
sudo bash -c "cat > $SERVICE_FILE_PATH <<EOF
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and start Tomcat
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# Clone vprofile project from GitHub
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

# Update application.properties with necessary configurations
PROPERTIES_FILE="src/main/resources/application.properties"

# Check if the file exists and update it
if [ ! -f "$PROPERTIES_FILE" ]; then
    echo "Properties file does not exist: $PROPERTIES_FILE"
    exit 1
fi

cat <<EOL > "$PROPERTIES_FILE"

jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://mydb.che8i0woaiqe.eu-west-2.rds.amazonaws.com:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin123


# Memcached Configuration For Active and StandBy Host
# For Active Host
memcached.active.host=my-cache-cluster.s1py7c.0001.euw2.cache.amazonaws.com
memcached.active.port=11211

# RabbitMQ Configuration
rabbitmq.address=b-30f3587f-71ac-41bb-8dbd-e4e7744a4262.mq.eu-west-2.amazonaws.com
rabbitmq.port=5671
rabbitmq.username=admin
rabbitmq.password=admin12345678
rabbitmq.protocol=amqps

# Elasticsearch Configuration
elasticsearch.host=192.168.1.85
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOL

echo "Properties file has been updated successfully."

# Build the project using Maven
mvn install 

# Stop Tomcat temporarily
systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
 systemctl start tomcat
chown tomcat.tomcat /usr/local/tomcat/webapps -R
 systemctl restart tomcat

# Create or modify setenv.sh for Tomcat settings
sudo sh -c 'cat <<EOF >> /usr/local/tomcat/bin/setenv.sh
export CATALINA_OPTS="\$CATALINA_OPTS --add-opens java.base/java.lang.invoke=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED"
EOF'

# Restart Tomcat
sudo systemctl restart tomcat

