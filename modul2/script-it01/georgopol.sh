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

echo 'nameserver 10.64.1.2
nameserver 192.168.122.1' > /etc/resolv.conf
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

zone "siren.redzone.it01.com" {
    type master;
    file "/etc/bind/siren/siren.redzone.it01.com";
};' > /etc/bind/named.conf.local

# edit file /etc/bind/named/conf.options
echo 'options {
        directory "/var/cache/bind";

        // forwarders {
        //     0.0.0.0;
        //}

        dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;
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


