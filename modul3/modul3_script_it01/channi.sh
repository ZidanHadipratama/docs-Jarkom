apt install mariadb-server -y
service mysql start
mysql -u root -p <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123';
CREATE DATABASE laravel;
FLUSH PRIVILEGES;
EOF
cat << 'EOF' > /etc/mysql/my.cnf
# The MariaDB configuration file
#
# The MariaDB/MySQL tools read configuration files in the following order:
# 1. "/etc/mysql/mariadb.cnf" (this file) to set global defaults,
# 2. "/etc/mysql/conf.d/*.cnf" to set global options.
# 3. "/etc/mysql/mariadb.conf.d/*.cnf" to set MariaDB-only options.
# 4. "~/.my.cnf" to set user-specific options.
#
# If the same option is defined multiple times, the last one will apply.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.

#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

# Import all .cnf files from configuration directory
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
bind-address = 0.0.0.0
EOF
service mysql restart
apt install ufw -y
apt install iptables -y
ufw allow 3306
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save
service mysql restart
