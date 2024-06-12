# Masquerade
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.64.0.0/16