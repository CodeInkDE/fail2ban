#!/bin/sh
apt-get install python3 python3-pyinotify python3-systemd dialog -y
python setup.py install
touch /var/log/fail2ban.log
cp config/jail.local /etc/fail2ban/

email=$(\
   dialog --title "Fail2ban E-Mail Einstellungen" \
          --inputbox "Gebe deine E-Mail ein mit der Fail2ban senden soll." 8 40 \
  3>&1 1>&2 2>&3 3>&- \
)
sed -i 's/%EMAIL%/$email/g' /etc/fail2ban/jail.local

dialog --title "Fail2ban Blocklist Einstellungen" --yesno "Blocklist.de konfigurieren?" 8 40
response=$?

if [ $response = 0 ]
        then
			blocklist=$(\
				dialog 	--title "Fail2ban E-Blocklist Einstellungen" \
						--inputbox "Gebe deinen API Key von Blocklist.de ein." 8 40 \
				3>&1 1>&2 2>&3 3>&- \
			)
			sed -i 's/%BLOCKLIST%/$blocklist/g' /etc/fail2ban/jail.local
			sed -i 's/%ACTION%/action_blocklist_de/g' /etc/fail2ban/jail.local
        else
		sed -i 's/%ACTION%/action_mwl/g' /etc/fail2ban/jail.local
fi

cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban restart
clear


