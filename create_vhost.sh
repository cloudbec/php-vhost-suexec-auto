#!/bin/bash
DOMAIN=
USER=
PASSWORD=

usage()
{
    cat <<EOF
    usage: $0 options

    This script will create a user and a database. 

    OPTIONS:
    -h      Show this message
    -u      the user name
    -p      the password
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
        p)
            PASSWORD=$OPTARG
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

if [[ -z $USER ]] || [[ -z $PASSWORD ]] || [[ -z $DOMAIN ]]
then
    usage
    exit 1
fi

HOME_DIR=/var/www/$DOMAIN

# Nutzer hinzufügen
useradd -d $HOME_DIR -G "www-data" -U -m -k skel -s /bin/bash $USER

# Nutzer noch der Gruppe hinzufügen
adduser www-data $USER

# Konfiguration für apache schreiben
cat www.example.com | sed "s/HOSTNAME/$DOMAIN/g" | sed "s/USER/$USER/g" | sed "s/GROUP/$USER/g" > /etc/apache2/sites-available/$DOMAIN

# Berechtigungen festlegen
chmod 750 $HOME_DIR
chown $USER:$USER $HOME_DIR/*
chmod 750 $HOME_DIR/*
chmod 550 $HOME_DIR/conf
chown $USER:$USER $HOME_DIR/conf/php.ini
chmod 440 $HOME_DIR/conf/php.ini
chown $USER:$USER $HOME_DIR/php-fcgi/php-fcgi-starter
chmod 750 $HOME_DIR/php-fcgi/php-fcgi-starter
