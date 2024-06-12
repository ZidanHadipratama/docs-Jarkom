# Ubah nameserver menggunakan nameserver IP erangel
echo nameserver 192.168.122.1 > /etc/resolv.conf
cat /etc/resolv.conf

# install bind9
apt-get update
apt-get install bind9 -y

# edit file named.conf.local
echo 'zone "airdrop.it01.com" {
    type master;
    also-notify { 10.64.3.2; };
    allow-transfer { 10.64.3.2; };
    file "/etc/bind/airdrop/airdrop.it01.com";
};

zone "redzone.it01.com" {
    type master;
    also-notify { 10.64.3.2; };
    allow-transfer { 10.64.3.2; };
    file "/etc/bind/redzone/redzone.it01.com";
};

zone "loot.it01.com" {
    type master;
    also-notify { 10.64.3.2; };
    allow-transfer { 10.64.3.2; };
    file "/etc/bind/loot/loot.it01.com";
};

zone "4.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/reverse/4.64.10.in-addr.arpa";
};' > /etc/bind/named.conf.local

# Membuat folder baru untuk masing-masing domain (no 2-6)
mkdir /etc/bind/airdrop
mkdir /etc/bind/redzone
mkdir /etc/bind/loot
mkdir /etc/bind/reverse

# Copy file db.local ke file konfigurasi masing-masing domain
cp /etc/bind/db.local /etc/bind/airdrop/airdrop.it01.com
cp /etc/bind/db.local /etc/bind/redzone/redzone.it01.com
cp /etc/bind/db.local /etc/bind/loot/loot.it01.com
cp /etc/bind/db.local /etc/bind/reverse/4.64.10.in-addr.arpa

# Edit file /etc/bind/airdrop/airdrop.it01.com
echo ';
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     airdrop.it01.com. root.airdrop.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      airdrop.it01.com.
@       IN      A       10.64.4.3   ; IP Stalber
@       IN      AAAA    ::1
www     IN      CNAME   airdrop.it01.com.
medkit  IN      A       10.64.4.4       ; IP Lipovka' > /etc/bind/airdrop/airdrop.it01.com

# Edit file /etc/bind/redzone/redzone.it01.com
echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     redzone.it01.com. root.redzone.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      redzone.it01.com.
@       IN      A       10.64.4.2   ; IP Severny
@       IN      AAAA    ::1
www     IN      CNAME   redzone.it01.com.' > /etc/bind/redzone/redzone.it01.com

# Edit file /etc/bind/loot/loot.it01.com
echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     loot.it01.com. root.loot.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      loot.it01.com.
@       IN      A       10.64.4.5   ; IP Mylta
@       IN      AAAA    ::1
www     IN      CNAME   loot.it01.com.' > /etc/bind/loot/loot.it01.com

# Edit file /etc/bind/reverse/4.64.10.in-addr.arpa
echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     redzone.it01.com. root.redzone.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
4.64.10.in-addr.arpa.   IN      NS      redzone.it01.com.
2       IN      PTR     redzone.it01.com.       ; Byte ke 4 nya Severny' > /etc/bind/reverse/4.64.10.in-addr.arpa

# Buat folder baru siren
mkdir /etc/bind/siren

# Menyalin file redzone ke siren
cp /etc/bind/redzone/redzone.it30.com /etc/bind/siren/siren.redzone.it01.com

# edit file siren.redzone.it01.com
echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     redzone.it01.com. root.redzone.it01.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      redzone.it01.com.
@       IN      A       10.64.4.2 ; IP Severny
www     IN      CNAME   redzone.it01.com.
siren   IN      A       10.64.3.2 ; IP Georgopol
ns1     IN      A       10.64.3.2 ; IP Georgopol
siren   IN      NS      ns1
@       IN      AAAA    ::1' > /etc/bind/siren/siren.redzone.it01.com

# edit file named.conf.options
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

# Restart bind9
service bind9 restart
