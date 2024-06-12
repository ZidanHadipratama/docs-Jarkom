apt-get update
apt-get install nginx -y
service nginx stop
apt-get install apache2 -y
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod lbmethod_bybusyness
a2enmod lbmethod_bytraffic
apt-get install apache2-utils -y
echo "===============Setup Load Balancer Apache2 default====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.1.2
        BalancerMember http://10.64.1.3
        BalancerMember http://10.64.1.4
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer Apache2 byrequest====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.1.2
        BalancerMember http://10.64.1.3
        BalancerMember http://10.64.1.4
        ProxySet lbmethod=byrequests
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer Apache2 bytraffic====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.1.2
        BalancerMember http://10.64.1.3
        BalancerMember http://10.64.1.4
        ProxySet lbmethod=bytraffic
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer Apache2 bybusyness====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.1.2
        BalancerMember http://10.64.1.3
        BalancerMember http://10.64.1.4
        ProxySet lbmethod=bybusyness
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
service apache2 stop
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer NGINX Round Robin====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/;
    }
}
EOF
service nginx start
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark Round Robin================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer NGINX IP Hash====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    ip_hash;
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
service nginx restart
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark IP Hash================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer NGINX Generic Hash====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    hash $request_uri consistent;
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
service nginx restart
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark IP Hash================"
ab -n 5000 -c 150 http://10.64.4.3/
echo "===============Setup Load Balancer NGINX Least Connections====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    least_conn;
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
EOF
service nginx restart
echo "===============Load Balancer NGINX Nyala====================="
htpasswd /etc/nginx/supersecret/htpasswd secmart
echo "===============Setup passwd, passing, and allowed for NGINX================"
cat << 'EOF' > /etc/nginx/sites-available/default
# Define IP whitelist in a reusable map
map $remote_addr $ip_allowed {
    default 0;
    10.64.1.37 1;
    10.64.1.67 1;  # Example IP address allowed to access
    10.64.2.203 1;
    10.64.2.207 1;  # Another example IP address allowed to access
    # Add more IP addresses as needed
}

upstream backend {
    least_conn;
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
}

server {
    listen 80;

    # Apply IP whitelist to all locations
    location / {
        # Allow only specific IP addresses
        if ($ip_allowed = 0) {
            return 403;  # Forbidden
        }

        # Enable Basic Authentication
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/supersecret/htpasswd;

        # Proxy settings
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /dune {
        # Apply IP whitelist to /dune location
        if ($ip_allowed = 0) {
            return 403;  # Forbidden
        }

        # Redirect to the external site using HTTPS
        proxy_pass https://www.dunemovie.com.au/;
        proxy_set_header Host www.dunemovie.com.au;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Optionally, to make sure the URL path is preserved
        proxy_redirect off;
    }
}
EOF
service nginx restart
echo "===============Load Balancer NGINX Nyala====================="
echo "===============Setup buat atreides================"
cat << 'EOF' > /etc/nginx/sites-available/default
# Define IP whitelist in a reusable map
map $remote_addr $ip_allowed {
    default 0;
    10.64.1.37 1;
    10.64.1.67 1;  # Example IP address allowed to access
    10.64.2.203 1;
    10.64.2.207 1;  # Another example IP address allowed to access
    # Add more IP addresses as needed
}

upstream backend {
    least_conn;
    server 10.64.1.2;
    server 10.64.1.3;
    server 10.64.1.4;
    server 10.64.2.4;
    server 10.64.2.3;
    server 10.64.2.2;
}

server {
    listen 80;

    # Apply IP whitelist to all locations
    location / {

        Enable Basic Authentication
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/supersecret/htpasswd;

        # Allow only specific IP addresses
        if ($ip_allowed = 0) {
            return 403;  # Forbidden
        }

        # Proxy settings
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /dune {
        # Apply IP whitelist to /dune location
        if ($ip_allowed = 0) {
            return 403;  # Forbidden
        }


        # Redirect to the external site using HTTPS
        proxy_pass https://www.dunemovie.com.au/;
        proxy_set_header Host www.dunemovie.com.au;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Optionally, to make sure the URL path is preserved
        proxy_redirect off;
    }
}
EOF
service nginx restart
echo "===============Load Balancer NGINX Nyala====================="