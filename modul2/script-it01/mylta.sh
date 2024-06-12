# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

echo "==============Install & Setup==============="
echo "nameserver 10.64.1.2" > /etc/resolv.conf
apt-get update
apt-get install apache2 -y
service apache2 restart
apt-get install lynx -y
apt-get install nginx -y
service nginx stop
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod lbmethod_bybusyness
a2enmod lbmethod_bytraffic
apt-get install apache2-utils -y
service apache2 restart
echo "===============Setup Load Balancer Apache2 default====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.4.2/index.php
        BalancerMember http://10.64.4.3/index.php
        BalancerMember http://10.64.4.4/index.php
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer Apache2 byrequest====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.4.2/index.php
        BalancerMember http://10.64.4.3/index.php
        BalancerMember http://10.64.4.4/index.php
        ProxySet lbmethod=byrequests
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer Apache2 bytraffic====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.4.2/index.php
        BalancerMember http://10.64.4.3/index.php
        BalancerMember http://10.64.4.4/index.php
        ProxySet lbmethod=bytraffic
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer Apache2 bybusyness====================="
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        BalancerMember http://10.64.4.2/index.php
        BalancerMember http://10.64.4.3/index.php
        BalancerMember http://10.64.4.4/index.php
        ProxySet lbmethod=bybusyness
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF
service apache2 restart
echo "===============Load Balancer Apache2 Nyala====================="
echo "===============Apache2 Benchmark ================"
ab -n 1000 -c 50 http://10.64.4.5/
service apache2 stop
echo "===============Load Balancer Apache2 Mati====================="
echo "===============Setup Load Balancer NGINX Round Robin====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    server 10.64.4.2;
    server 10.64.4.3;
    server 10.64.4.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
service nginx start
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark Round Robin================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer NGINX Least Connections====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    least_conn;
    server 10.64.4.2;
    server 10.64.4.3;
    server 10.64.4.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
service nginx start
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark Least Connections================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer NGINX IP Hash====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    ip_hash;
    server 10.64.4.2;
    server 10.64.4.3;
    server 10.64.4.4;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
service nginx start
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark IP Hash================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Setup Load Balancer NGINX Generic Hash====================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    hash $request_uri consistent;
    server 10.64.4.2;
    server 10.64.4.3;
    server 10.64.4.4;
}

server {
    listen 14000;

    location / {
        proxy_pass http://backend/index.php;
    }
}

server {
    listen 14400;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF
echo "===============Setup Listening di Port 14000 & 14400====================="
iptables -A INPUT -p tcp --dport 14000 -j ACCEPT
iptables -A INPUT -p tcp --dport 14400 -j ACCEPT
service nginx start
echo "===============Load Balancer NGINX Nyala====================="
echo "===============NGINX Benchmark Generic Hash================"
ab -n 1000 -c 50 http://10.64.4.5/
echo "===============Yang dipakai: NGINX Round Robin==================="
cat << 'EOF' > /etc/nginx/sites-available/default
upstream backend {
    server 10.64.4.2;
    server 10.64.4.3;
    server 10.64.4.4;
}

server {
    listen 14000;

    location / {
        proxy_pass http://backend/index.php;
    }
}

server {
    listen 14400;

    location / {
        proxy_pass http://backend/index.php;
    }
}
EOF

rm /etc/nginx/sites-enabled/default

service nginx start
echo "===============Load Balancer NGINX Nyala====================="