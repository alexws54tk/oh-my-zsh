#!/bin/zsh

function mount_iode_13() {
	sshfs alex@172.16.12.13:/usr/local/www/servers /var/www/app2 -p 8022 -o allow_other,uid=1000,gid=80
}

function mount_iode_212() {
	sshfs alex@172.16.12.212:/var/www /var/www/apps -p 8022 -o allow_other,uid=1000,gid=80
}


function mount_iode_226() {
	sshfs alex@172.16.12.226:/var/www /var/www/app3 -p 8022 -o allow_other,uid=1000,gid=80
}

function rgb2hex() {
	printf "%02x%02x%02x\n" $1 $2 $3
}

