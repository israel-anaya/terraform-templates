#! /bin/sh

# . Copy the wildfly.conf file from the package files to to the /etc/wildfly/ folder:
sudo cp /home/wildfly/installers/wildfly.conf /etc/wildfly/

# Copy the launch.sh script from the WildFly package to the /opt/wildfly/bin/ folder:
sudo cp /home/wildfly/installers/launch.sh /opt/wildfly/bin/

# The last file to copy is the wildfly.service unit file to your system’s services folder /etc/systemd/system
sudo cp /home/wildfly/installers/wildfly.service /etc/systemd/system/

# Finally, you have to inform your system that you have added a new unit file. This can be done by reloading the systemctl daemon:
sudo systemctl daemon-reload

# Enable the wildfly service at boot
sudo systemctl enable wildfly