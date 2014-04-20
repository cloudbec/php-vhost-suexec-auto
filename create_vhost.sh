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
while getopts "hp:u:d:" OPTION
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

HOME_DIR=/srv/www/$DOMAIN

# create the group of the user, the user and its directory


useradd -s /bin/false -d $HOME_DIR  -m -k ./skel $USER


# configuration du vhost
cat www.example.com | sed "s/HOSTNAME/$DOMAIN/g" | sed "s/USER/$USER/g" | sed "s/GROUP/$USER/g" > /etc/apache2/vhost.d/$DOMAIN.conf

# configuration de PHP
sed -i "s/HOSTNAME/$DOMAIN/g" /srv/www/php-fcgi/$DOMAIN/php-fcgi-starter
sed -i "s%HOME_DIR%$HOME_DIR/tmp%g" $HOME_DIR/conf/php.ini

# logrotate
#cat logrotate_template | sed "s/HOSTNAME/$DOMAIN/g" >> /etc/logrotate.d/vhosts

# rights management
chmod 550 $HOME_DIR/conf
chown $USER:$USER $HOME_DIR/conf/php.ini
chmod 440 $HOME_DIR/conf/php.ini
chown $USER:$USER /srv/www/php-fcgi/$DOMAIN/php-fcgi-starter
chmod 755 /srv/www/php-fcgi/$DOMAIN/php-fcgi-starter

