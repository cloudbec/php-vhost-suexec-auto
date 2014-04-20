<VirtualHost *>
  ServerName HOSTNAME
  ServerAlias HOSTNAME
  ServerAdmin webmaster@HOSTNAME
  DocumentRoot /srv/www/HOSTNAME/public_html/

  <IfModule mod_fcgid.c>
	SuexecUserGroup USER USER
    <Directory /srv/www/HOSTNAME/public_html/>
      Options +ExecCGI
      AllowOverride All
      AddHandler fcgid-script .php
      FCGIWrapper /srv/www/php-fcgi-scripts/HOSTNAME/php-fcgi-starter .php
      Order allow,deny
      Allow from all
    </Directory>
  </IfModule>

  ErrorLog /var/log/apache2/HOSTNAME/error.log
  CustomLog /var/log/apache2/HOSTNAME/access.log combined
  ServerSignature Off

</VirtualHost>


