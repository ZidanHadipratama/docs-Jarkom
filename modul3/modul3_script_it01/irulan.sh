# Install bind9
apt-get update
apt-get install -y bind9

# Configure DNS Server di /etc/bind/named.conf.local
echo '
zone "atreides.it01.com" {
  type master;
  file "/etc/bind/atreides/atreides.it01.com";
};

zone "harkonen.it01.com" {
  type master;
  file "/etc/bind/harkonen/harkonen.it01.com";
};' >  /etc/bind/named.conf.local

mkdir /etc/bind/atreides
mkdir /etc/bind/harkonen

cp /etc/bind/db.local /etc/bind/atreides/atreides.it01.com
cp /etc/bind/db.local /etc/bind/harkonen/harkonen.it01.com


echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     atreides.it01.com. root.atreides.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides.it01.com.
@       IN      A       10.64.2.2 ; IP Leto Atreides
@       IN      AAAA    ::1' > /etc/bind/atreides/atreides.it01.com


echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     harkonen.it01.com. root.harkonen.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      harkonen.it01.com.
@       IN      A       10.64.1.2 ; IP Vladimir Harkonen
@       IN      AAAA    ::1' > /etc/bind/harkonen/harkonen.it01.com


echo 'options {
        directory "/var/cache/bind";

        forwarders {
                192.168.122.1;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        //dnssec-validation auto;
        allow-query { any; };
        auth-nxdomain no;
        listen-on-v6 { any; };
};' > /etc/bind/named.conf.options

# Restart DNS Server service
service bind9 restart
