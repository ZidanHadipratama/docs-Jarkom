echo 'nameserver 192.168.122.1' > /etc/resolv.conf
cat /etc/resolv.conf

# Install bind9 untuk menjadi DNS Slave
apt-get update
apt-get install bind9 -y

# edit file named.conf.local
echo 'zone "airdrop.it01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/lib/bind/airdrop.it01.com";
};

zone "redzone.it01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/lib/bind/redzone.it01.com";
};

zone "loot.it01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/lib/bind/loot.it01.com";
};

zone "siren.redzone.it30.com" {
    type master;
    file "/etc/bind/siren/siren.redzone.it30.com";
};' > /etc/bind/named.conf.local

# edit file /etc/bind/named/conf.options
echo 'options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};' > /etc/bind/named.conf.options

# buat directory baru siren
mkdir /etc/bind/siren

#copy db.local
cp /etc/bind/db.local /etc/bind/siren/siren.redzone.it01.com

# edit siren.redzone.it01.com
echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     siren.redzone.it01.com. root.siren.redzone.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      siren.redzone.it01.com.
@       IN      A       10.64.3.2       ; IP Georgopol
www     IN      CNAME   siren.redzone.it01.com.
log     IN      A       10.64.3.2       ; IP Georgopol
www.log IN      CNAME   siren.redzone.it01.com.
@       IN      AAAA    ::1' > /etc/bind/siren/siren.redzone.it01.com

# restart bind9
service bind9 restart

echo 'nameserver 10.64.1.2' > /etc/resolv.conf

