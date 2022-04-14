#!/bin/bash

systemctl stop qrax@1
rm -rf /run/qrax
rm -rf /etc/qrax
rm -rf ~/.qrax/
rm -rf /usr/local/bin/qrax*
rm -f /etc/systemd/system/multi-user.target.wants/qrax@1.service
rm -f /etc/systemd/system/qrax@.service
cp /var/lib/qrax/wallet.dat ~/wallet.dat.backup
cp -R /var/lib/qrax/backups/ ~/qrax-wallets/
rm -rf /var/lib/qrax
systemctl daemon-reload
userdel qrax

