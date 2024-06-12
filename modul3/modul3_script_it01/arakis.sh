iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.64.0.0/16

apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

echo '
# IP DHCP Server -> IP Mohiam
SERVERS="10.64.3.3"
# Interfaces to listen on
INTERFACES="eth1 eth2 eth3 eth4"
# Options to pass to the DHCP relay
OPTIONS=""
' > /etc/default/isc-dhcp-relay

service isc-dhcp-relay restart


