#!/bin/bash
DOMAIN=
USER=

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
# : bedeutet immer das ein parameter verlangt wird
while getopts “hp:u:d:” OPTION
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

HOME_DIR=/var/www/$DOMAIN

# Nutzer hinzufügen
useradd -d $HOME_DIR -G "www-data" -U -m -k ./skel -s /bin/bash $USER

# Nutzer noch der Gruppe hinzufügen
adduser www-data $USER

# Konfiguration für apache schreiben
cat www.example.com | sed "s/HOSTNAME/$DOMAIN/g" | sed "s/USER/$USER/g" | sed "s/GROUP/$USER/g" > /etc/apache2/sites-available/$DOMAIN

# logrotate Konfiguration schreiben
cat logrotate_template | sed "s/HOSTNAME/$DOMAIN/g" >> /etc/logrotate.d/vhosts

# Berechtigungen festlegen
echo "chmod 750 $HOME_DIR"
echo "chown $USER:$USER $HOME_DIR/*"
echo "chmod 750 $HOME_DIR/*"
echo "chmod 550 $HOME_DIR/conf"
echo "chown $USER:$USER $HOME_DIR/conf/php.ini"
echo "chmod 440 $HOME_DIR/conf/php.ini"
echo "chown $USER:$USER $HOME_DIR/php-fcgi/php-fcgi-starter"
echo "chmod 750 $HOME_DIR/php-fcgi/php-fcgi-starter"
