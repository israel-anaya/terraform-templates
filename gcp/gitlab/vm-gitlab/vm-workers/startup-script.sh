sudo apt-get update -y

sudo apt-get install -y curl wget openssh-server ca-certificates gnupg lsb-release

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io 

sysctl -w vm.max_map_count=524288

sysctl -w fs.file-max=131072

ulimit -n 131072

ulimit -u 8192

docker pull gcr.io/cloudsql-docker/gce-proxy:1.19.1

docker pull gitlab/gitlab-runner:latest

sudo mkdir -p /home/workers/stateful/cloudsql

cat <<"EOF" > /home/workers/proxy-sql.sh
${PROXY_SQL}
EOF

cat <<"EOF" > /home/workers/shared-runner.sh
${SHARED_RUNNER}
EOF

cat <<"EOF" > /home/workers/docker-template-config.toml
${RUNNER_CONFIG}
EOF

sudo chmod +x /home/workers/proxy-sql.sh

sudo chmod +x /home/workers/shared-runner.sh