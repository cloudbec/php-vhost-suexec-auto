<VirtualHost *:80>
    # Allgemeine Konfiguration
    ServerAdmin support@synaxon.de
    ServerName HOSTNAME
    # Konfiguriere hier die Serveralias
    # ServerAlias www.HOSTNAME
    # Der Client bekommt keine Informationen gesendet, auf welchem Server unsere Webseite läuft.
    ServerSignature Off

    # Fuehre die Seite mit diesen Benutzerrechten aus
    SuexecUserGroup USER GROUP 
    DocumentRoot /var/www/HOSTNAME/htdocs
    DirectoryIndex index.htm index.html index.php
    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>
    # Berechtigung fuer das Document root
    <Directory "/var/www/HOSTNAME/htdocs">
        Options -Indexes MultiViews FollowSymLinks +ExecCGI
        # PHP Konfiguration
        # jede PHP Datei wird vom fcgi handler verarbeitet
        AddHandler fcgid-script .php
        # das ist der Handler der dann den PHP Process startet
        FCGIWrapper /var/www/HOSTNAME/php-fcgi/php-fcgi-starter .php
        Order allow,deny
        Allow from all
        AllowOverride All
    </Directory>
    ErrorLog /var/www/HOSTNAME/log/error.log
    LogLevel warn
    CustomLog /var/www/HOSTNAME/log/access.log combined
</VirtualHost>
