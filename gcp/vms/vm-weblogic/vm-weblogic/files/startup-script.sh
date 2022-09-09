#! /bin/bash

# Update OS
sudo apt-get update -y
sudo apt-get install -y curl wget openssh-server ca-certificates unzip

# Solo ejecutar la primera vez
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi

# Swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# Oracle User, Group and Directories
sudo groupadd -g 2000 oinstall
sudo useradd -m -d /home/oracle -s /bin/bash -u 2100 -g oinstall oracle

sudo mkdir -p /usr/lib/jvm/
sudo mkdir -p /home/oracle/middleware
sudo mkdir -p /home/oracle/domains
sudo mkdir -p /home/oracle/inventory
sudo mkdir -p /home/oracle/tools
sudo mkdir -p /home/oracle/installers

# Additional files
cat <<"EOF" > /home/oracle/.bash_profile
${BASH_PROFILE}
EOF

cat <<"EOF" > /etc/oraInst.loc
inventory_loc=/home/oracle/inventory
inst_group=oinstall
EOF

cat <<"EOF" > /home/oracle/installers/ora-response
${ORA_RESPONSE}
EOF

cat <<"EOF" > /home/oracle/installers/install-weblogic.sh
${INSTALL_WEBLOGIC}
EOF

cat <<"EOF" > /home/oracle/domains/create-domain.sh
${CREATE_DOMAIN}
EOF

cat <<"EOF" > /home/oracle/domains/domain-model.yaml
${DOMAIN_MODEL}
EOF

cat <<"EOF" > /home/oracle/domains/domain.properties
${DOMAIN_PROPERTIES}
EOF

# Oracle JDK
curl -m 120 -fL https://gitlab.cehd.devopsat.dev/oracle/jdk/-/raw/main/jdk-8u321-linux-x64.tar.gz?inline=false -o jdk-8u321-linux-x64.tar.gz
sudo mv ./jdk-8u321-linux-x64.tar.gz /home/oracle/installers
sudo tar -zxvf /home/oracle/installers/jdk-8u321-linux-x64.tar.gz -C /usr/lib/jvm/
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_321/bin/java 1

# Weblogic Deploy Tool
curl -m 120 -fL https://github.com/oracle/weblogic-deploy-tooling/releases/download/release-2.0.0/weblogic-deploy.zip -o ./weblogic-deploy.zip
sudo mv ./weblogic-deploy.zip /home/oracle/tools
sudo unzip /home/oracle/tools/weblogic-deploy.zip -d /home/oracle/tools/

# Weblogic Server
curl -m 120 -fL https://gitlab.cehd.devopsat.dev/oracle/weblogic/-/raw/main/fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip?inline=false -o fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip
sudo mv ./fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip /home/oracle/installers
sudo unzip /home/oracle/installers/fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip -d /home/oracle/installers/

# Permissions
sudo chown -R oracle:oinstall /home/oracle/
sudo chmod +x /home/oracle/installers/install-weblogic.sh
sudo chmod +x /home/oracle/domains/create-domain.sh

# Finish
touch /etc/startup_was_launched