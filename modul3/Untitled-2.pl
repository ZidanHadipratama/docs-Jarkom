cat << 'EOF' > /etc/nginx/sites-available/default
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

        # Enable Basic Authentication
        # auth_basic "Restricted Area";
        # auth_basic_user_file /etc/nginx/supersecret/htpasswd;

        # Proxy settings
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /dune {

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
