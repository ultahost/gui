#!/bin/bash

rm -Rfv /etc/yum.repos.d/CentOS-Vault.repo &> /dev/null

curl -O http://vestacp.com/pub/vst-install.sh && bash vst-install.sh --nginx yes --apache yes --phpfpm no --named yes --remi yes --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin no --clamav no --softaculous no --mysql yes --postgresql no --password as#^jf8d
#rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro 
#rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
#systemctl stop firewalld.service && /bin/systemctl disable firewalld.service 

cat > /etc/yum.repos.d/mariadb.repo << HERE 
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
HERE

systemctl stop mariadb 
yum remove mariadb mariadb-server -y
yum install MariaDB-server MariaDB-client -y
systemctl start mariadb 
mysql_upgrade
cat >>/etc/my.cnf << HERE 
performance-schema=0
innodb_file_per_table=1
innodb_buffer_pool_size=134217728
max_allowed_packet=268435456
open_files_limit=2048
#innodb_buffer_pool_size=3000M
sql_mode=NO_ENGINE_SUBSTITUTION
default-storage-engine=MyISAM
max_connections = 5000000
HERE 

systemctl restart mariadb

yum install ffmpeg ffmpeg-devel nano mc htop atop iftop lsof bzip2 traceroute gdisk php74-php-curl php74-php-mbstring  php74-php-xml php74-php-gd php74-php-fileinfo php74-php-exif php74-php-intl php74-php-zip php74-php-mysqli php74-php-curl php74-php-ctype php74-php-openssl php74-php-pdo php74-php-opcache php74-php-simplexml php74-php-mysql php72-php-mbstring php72-php-xml php72-php-gd php72-php-fileinfo php72-php-intl php72-php-zip php72-php-mysqli php72-php-curl php72-php-ctype php72-php-openssl php72-php-pdo php72-php-exif php72-php-opcache php72-php-simplexml php72-php-mysql php72-php-curl php74-php-xdebug php73-php-xdebug php72-php-xdebug php70-php-xdebug php72-php-soap php73-php-soap php74-php-soap -y

wget https://raw.githubusercontent.com/Skamasle/sk-php-selector/master/sk-php-selector2.sh && chmod +x sk-php-selector2.sh && bash sk-php-selector2.sh php70 php71 php72 php73



cat >>/etc/httpd/conf.d/fcgid.conf << HERE 

FcgidBusyTimeout 72000
FcgidIOTimeout 72000
IPCCommTimeout 72000
MaxRequestLen 320000000000
FcgidMaxRequestLen 320000000000
HERE

VESTA CP FileManager:
cat >> /usr/local/vesta/conf/vesta.conf << HERE 
FILEMANAGER_KEY='mykey'
SFTPJAIL_KEY='mykey'
HERE

sed -i 's|v_host=|#v_host=|' /usr/local/vesta/bin/v-activate-vesta-license
sed -i 's|answer=$(curl -s $v_host/activate.php?licence_key=$license&module=$module)|answer=0|' /usr/local/vesta/bin/v-activate-vesta-license
sed -i 's|check_result|#check_result|' /usr/local/vesta/bin/v-activate-vesta-license
sed -i 's|$BIN/v-check-vesta-license|#$BIN/v-check-vesta-license|' /usr/local/vesta/bin/v-backup-users


# Sending notification to admin email
echo -e "Congratulations, you have just successfully installed \
Vesta Control Panel

    https://$ip:8083
    username: admin
    password: $vpass