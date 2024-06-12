apt-get update
apt-get install isc-dhcp-server
dhcpd --version

echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

echo '# Default lease time dan max lease time
default-lease-time 300; # 5 menit

# Subnet untuk House Harkonen
subnet 10.64.1.0 netmask 255.255.255.0 {
    range 10.64.1.14 10.64.1.28;
    range 10.64.1.49 10.64.1.70;
    option routers 10.64.1.1;
    option broadcast-address 10.64.1.255;
    option domain-name-servers 10.64.3.2;
    default-lease-time 300; # 5 menit
    max-lease-time 5220; 
}

# Subnet untuk House Atreides
subnet 10.64.2.0 netmask 255.255.255.0 {
    range 10.64.2.15 10.64.2.25;
    range 10.64.2.200 10.64.2.210;
    option routers 10.64.2.1;
    option broadcast-address 10.64.2.255;
    option domain-name-servers 10.64.3.2;
    default-lease-time 1200; # 20 menit
    max-lease-time 5220; 
}

subnet 10.64.3.0 netmask 255.255.255.0{}
subnet 10.64.4.0 netmask 255.255.255.0{}' > /etc/dhcp/dhcpd.conf

#restart
service isc-dhcp-server restart