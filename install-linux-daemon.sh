#!/bin/bash

URL='https://github.com/QRAX-LABS/Binaries/releases/download/v2.0.0/qrax-2.0.0-x86_64-linux-gnu.tar.gz'
NAME="$(basename ${URL})"

cd ~

if [[ "$(type -t wget)" = "file" ]]
    then
        wget -O ./${NAME} ${URL}
    elif [[ "$(type -t curl)" = "file" ]]
        then
            echo -e "\n'WGET' not installed. Try 'CURL'\n"
            curl -L -J --output ./${NAME} ${URL}
    else
        echo -e "\nPlease, install 'WGET' or 'CURL' for download QRAX daemon automatically.\nOr try download it manually by the link ${URL}\n"
        exit 0
fi

mkdir backend
tar -C backend --strip 1 -xf ${NAME}

cd ~/backend

#./install-params.sh
cd bin
cp qraxd qrax-cli qrax-tx /usr/local/bin/
cd ~
mkdir /var/lib/qrax
mkdir /etc/qrax/
mkdir /run/qrax/

touch /etc/qrax/qrax.conf
echo "daemon=1
txindex=1" > /etc/qrax/qrax.conf

useradd qrax
chown -R qrax.qrax /var/lib/qrax
chown -R qrax.qrax /run/qrax/
chown -R qrax.qrax /etc/qrax/

echo "
# It is not recommended to modify this file in-place, because it will
# be overwritten during package upgrades. If you want to add further
# options or overwrite existing ones then use
# $ systemctl edit coinlogy.service
# See man systemd.service for details.

# Note that almost all daemon options could be specified in
# /etc/qrax/qrax.conf

[Unit]
Description=QRAX Core daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/qraxd -daemon -datadir=/var/lib/qrax -conf=/etc/qrax/qrax.conf -pid=/run/qrax/qraxd.pid

RuntimeDirectory=qrax
User=qrax
Type=forking
PIDFile=/run/qrax/qraxd.pid
Restart=always

# Hardening measures
####################

# Provide a private /tmp and /var/tmp.
PrivateTmp=true

# Mount /usr, /boot/ and /etc read-only for the process.
ProtectSystem=full

# Disallow the process and all of its children to gain
# new privileges through execve().
NoNewPrivileges=true

# Use a new /dev namespace only populated with API pseudo devices
# such as /dev/null, /dev/zero and /dev/random.
PrivateDevices=true

# Deny the creation of writable and executable memory mappings.
# Commented out as it's not supported on Debian 8 or Ubuntu 16.04 LTS
#MemoryDenyWriteExecute=true

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/qrax@.service

systemctl daemon-reload
systemctl enable qrax@1
systemctl start qrax@1
mkdir ~/.qrax/
echo "conf=/etc/qrax/qrax.conf
datadir=/var/lib/qrax/" > ~/.qrax/qrax.conf
rm -rf ~/backend
rm -f ~/$NAME

