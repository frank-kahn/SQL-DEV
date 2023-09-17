ls -lrth /soft/p13390677_112040_Linux-x86-64_*.zip

su - oracle -c "unzip /soft/p13390677_112040_Linux-x86-64_1of7.zip -d /soft"
su - oracle -c "unzip /soft/p13390677_112040_Linux-x86-64_2of7.zip -d /soft"

chown oracle.oinstall /soft -R
