#!/bin/bash
USER=
DOMAIN=
usage()
{
    cat <<EOF
    usage: $0 options

    This script will create a user and a database. 

    OPTIONS:
    -h      Show this message
    -u      the user name
    -d      the domain name
EOF
}
# all the information 
while getopts "hp:u:d:p:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        d)
            DOMAIN=$OPTARG
            ;;
        u)
            USER=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [[ -z $USER ]] || [[ -z $DOMAIN ]]
then
    usage
    exit 1
fi


WEB_DIR=/srv/www/$DOMAIN

# webdir is home

# create the group of the user, the user, its password and its home (for sftp) 

groupadd $USER

useradd -s /bin/false -d $WEB_DIR -g $USER  -m $USER

# create the domain directory with the good permission and content

mkdir -p $WEB_DIR

cp -r skel/* $WEB_DIR/

# configuration of userss vhost


cat www.example.com | sed "s/HOSTNAME/$DOMAIN/g" | sed "s/USER/$USER/g" | sed "s/GROUP/$USER/g" > $DOMAIN.conf

mv $DOMAIN.conf /etc/apache2/vhosts.d/

# configuration of each users' PHP
sed -i "s/HOSTNAME/$DOMAIN/g" $WEB_DIR/php-fcgi-scripts/php-fcgi-starter
sed -i "s%HOME_DIR%$WEB_DIR/tmp%g" $WEB_DIR/conf/php.ini

# logrotate
#cat logrotate_template | sed "s/HOSTNAME/$DOMAIN/g" >> /etc/logrotate.d/vhosts

# rights management

chown -R $USER:$USER $WEB_DIR
chmod 550 $WEB_DIR/conf
chown $USER:$USER $WEB_DIR/conf/php.ini
chmod 440 $WEB_DIR/conf/php.ini
chown $USER:$USER $WEB_DIR/php-fcgi-scripts/php-fcgi-starter
chmod 755 $WEB_DIR/php-fcgi-scripts/php-fcgi-starter




