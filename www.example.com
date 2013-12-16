<VirtualHost *:80>
    # Variablen deklarieren
    Define servername HOSTNAME
    # Allgemeine Konfiguration
    ServerAdmin support@synaxon.de
    ServerName ${servername}
    # Konfiguriere hier die Serveralias
    # ServerAlias www.${servername}
    # Der Client bekommt keine Informationen gesendet, auf welchem Server unsere Webseite läuft.
    ServerSignature Off

    # Fuehre die Seite mit diesen Benutzerrechten aus
    SuexecUserGroup USER GROUP 
    DocumentRoot /var/www/${servername}/htdocs
    DirectoryIndex index.htm index.html index.php
    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>
    # Berechtigung fuer das Document root
    <Directory "/var/www/${servername}/htdocs">
        Options Indexes MultiViews FollowSymLinks +ExecCGI
        # PHP Konfiguration
        # jede PHP Datei wird vom fcgi handler verarbeitet
        AddHandler fcgid-script .php
        # das ist der Handler der dann den PHP Process startet
        FCGIWrapper /var/www/${servername}/php-fcgi/php-fcgi-starter .php
        Order allow,deny
        Allow from all
        AllowOverride All
    </Directory>
    ErrorLog /var/www/${servername}/log/error.log
    LogLevel warn
    CustomLog /var/www/${servername}/log/access.log combined
</VirtualHost>
