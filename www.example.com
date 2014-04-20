<VirtualHost *:80>
  ServerName HOSTNAME
  ServerAlias HOSTNAME
  ServerAdmin USER@HOSTNAME
  DocumentRoot /srv/www/HOSTNAME/public_html/

  <IfModule mod_fcgid.c>
	SuexecUserGroup USER USER
    <Directory /srv/www/HOSTNAME/public_html/>
      Options +ExecCGI +SymlinksIfOwnerMatch +Includes
      AllowOverride All
      AddHandler fcgid-script .php
      FCGIWrapper /srv/www/HOSTNAME/php-fcgi-scripts/php-fcgi-starter .php
	DirectoryIndex index.html index.php	
      Order allow,deny
      Allow from all
    </Directory>
  </IfModule>

ErrorLog /srv/www/HOSTNAME/log/error.log
  CustomLog /srv/www/HOSTNAME/log/access.log combined

  ServerSignature Off

</VirtualHost>


