#!/bin/bash
#
# Persistent MAC Address randomizer for linux desktop
#
#
#check for NetworkManager
sudo systemctl is-active --quiet NetworkManager
if [ "$?" -ne "0" ]; then
    echo "[-] NetworkManager not active; ensure you are         [-]"
    echo "[-] on a supported linux distribution and try again.  [-]"
    exit 1
fi
#
echo "[+] Please select how you prefer to connect...            [+]"
#
wifisetting="random" #default
#
read -t 60 -p 'Random MAC for each Wifi connection (1), or Random MAC that persists per SSID (2) ?  ' wifisettingnum
if [ $wifisettingnum != "1" ]  && [ $wifisettingnum != "2" ]; then
    echo "[-] Invalid input. Try again with a 1 or 2 selection. [-]"
    exit 1
elif [ $wifisettingnum == "1" ]; then
    wifisetting="random"
elif [ $wifisettingnum == "2" ]; then
    wifisetting="stable"
else 
    echo ""
fi
#
ethernetsetting="stable" #default
#
read -t 60 -p 'Random MAC for each wired Ethernet connection (1), or Random MAC that persists per wired network (2) ?  ' ethernetsettingnum
if [ $ethernetsettingnum != "1" ]  && [ $ethernetsettingnum != "2" ]; then
    echo "[-] Invalid input. Try again with a 1 or 2 selection. [-]"
    exit 1
elif [ $ethernetsettingnum == "1" ]; then
    ethernetsetting="random"
elif [ $ethernetsettingnum == "2" ]; then
    ethernetsetting="stable"
else 
    echo ""
fi
#
#build config file
echo ""
echo "[+] Building config file...                               [+]"
sudo rm /tmp/00-macrandomize.conf >/dev/null 2>&1 #try delete in case script has been run before
cat << 'EOF' > /tmp/00-macrandomize.conf
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=WIFISETTING
ethernet.cloned-mac-address=ETHSETTING
connection.stable-id=${CONNECTION}/${BOOT}
EOF
#
sed -i "s!WIFISETTING!${wifisetting}!" /tmp/00-macrandomize.conf
sed -i "s!ETHSETTING!${ethernetsetting}!" /tmp/00-macrandomize.conf
sudo rm /etc/NetworkManager/conf.d/00-macrandomize.conf >/dev/null 2>&1 #try delete in case script has been run before
sudo mv /tmp/00-macrandomize.conf /etc/NetworkManager/conf.d/00-macrandomize.conf
sudo chown root:root /etc/NetworkManager/conf.d/00-macrandomize.conf
ls -hal /etc/NetworkManager/conf.d/00-macrandomize.conf
cat /etc/NetworkManager/conf.d/00-macrandomize.conf
echo ""
#
echo "[+] Compare the output of the following ip commands       [+]"
echo "[+] to ensure your MAC address has been randomized:       [+]"
echo ""
echo 'ip -f link address'
ip -f link address
echo ""
echo "[+] Restarting NetworkManager service to apply changes... [+]"
sudo systemctl restart NetworkManager
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "[-] Error bringing NetworkManager service back up :(  [-]"
    exit $retVal
fi
echo ""
sleep 1s
echo 'ip -f link address'
ip -f link address
echo ""
echo "Finished."
echo ""