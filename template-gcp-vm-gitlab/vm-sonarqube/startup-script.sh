sudo apt-get update -y

sudo apt-get install -y curl wget openssh-server ca-certificates gnupg lsb-release nginx certbot python-certbot-nginx

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io 

sysctl -w vm.max_map_count=524288

sysctl -w fs.file-max=131072

ulimit -n 131072

ulimit -u 8192

docker pull bitnami/sonarqube:9.3.0

sudo mkdir -p /home/sonarqube/

cat <<"EOF" > /home/sonarqube/shared-sonarqube.sh
${SHARED_SONARQUBE}
EOF

sudo chmod +x /home/sonarqube/shared-sonarqube.sh


