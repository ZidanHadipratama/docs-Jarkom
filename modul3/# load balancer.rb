# load balancer
apache2 default = 2373.34 request / second
apache2 byrequest = 2154.62 request / second
apache2 bytraffic = 2217.87 request / second
nginx Round Robin = 1193.80 request / second
nginx IP Hash = 1721.08 request / second
nginx Least Connections = 1132.30 request / second
nginx Generic Hash = 1790.02 request / second

# 3.3
register 154.61 request / second
me 209.54 request / second
login 27.53 request / second

# login
fpm1 32.50 request / second
fpm2 32.48 request / second
fpm3 203.16 request / second

# me
fpm1 190.70 request / second
fpm2 147.73 request / second
fpm3 202.80 request / second

# register
fpm1 31.07 request / second
fpm2 181.70 request / second
fpm3 31.70 request / second