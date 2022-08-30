#! /bin/bash

# Update OS
sudo apt-get update -y
sudo apt-get install -y curl wget openssh-server ca-certificates

# Solo ejecutar la primera vez
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi

# Swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# WildFly User, Group and Directories
sudo groupadd -g 2000 wildfly
sudo useradd -m -d /opt/wildfly -s /bin/bash -u 2100 -g wildfly wildfly

sudo mkdir -p /usr/lib/jvm/
sudo mkdir -p /home/wildfly/installers/
sudo mkdir -p /opt/wildfly/
sudo mkdir -p /etc/wildfly/

# Additional files
cat <<"EOF" > /home/wildfly/.bash_profile
${BASH_PROFILE}
EOF

cat <<"EOF" > /home/wildfly/installers/wildfly.conf
${WILDFLY_CONFIG}
EOF

cat <<"EOF" > /home/wildfly/installers/install-wildfly.sh
${WILDFLY_INSTALL}
EOF

cat <<"EOF" > /home/wildfly/installers/launch.sh
${WILDFLY_LAUNCH}
EOF

cat <<"EOF" > /home/wildfly/installers/wildfly.service
${WILDFLY_SERVICE}
EOF

# Oracle JDK
curl -m 120 -fL https://gitlab.cehd.devsecops-cibanco.com/oracle/jdk/-/raw/main/jdk-8u321-linux-x64.tar.gz?inline=false -o jdk-8u321-linux-x64.tar.gz
sudo mv ./jdk-8u321-linux-x64.tar.gz /home/wildfly/installers
sudo tar -xf /home/wildfly/installers/jdk-8u321-linux-x64.tar.gz -C /usr/lib/jvm/
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_321/bin/java 1

# WildFly Server
curl -m 120 -fL https://github.com/wildfly/wildfly/releases/download/26.1.1.Final/wildfly-26.1.1.Final.tar.gz -o wildfly-26.1.1.Final.tar.gz
sudo mv ./wildfly-26.1.1.Final.tar.gz /home/wildfly/installers
sudo tar -xf /home/wildfly/installers/wildfly-26.1.1.Final.tar.gz -C /tmp
sudo mv /tmp/wildfly-26.1.1.Final/* /opt/wildfly


# Permissions
sudo chown -R wildfly:wildfly /home/wildfly/
sudo chown -R wildfly:wildfly /opt/wildfly/
sudo chmod +x /home/wildfly/installers/install-wildfly.sh
sudo chmod +x /home/wildfly/installers/launch.sh


# Finish
touch /etc/startup_was_launched