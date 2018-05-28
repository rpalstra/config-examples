server {
    listen 80;
    listen [::]:80;
    server_name  www.toepsmedia.nl toepsmedia.nl;
    rewrite ^ https://$server_name$request_uri? permanent;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name www.toepsmedia.nl toepsmedia.nl;
    root   /www/toepsmedia.nl/site;
    index  index.php index.html;
    set $cache_uri $request_uri;
    set $cache_uri $request_uri;
    ssl_certificate      /etc/letsencrypt/live/toeps.nl/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/toeps.nl/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/nginx/conf.d/dhparams.pem;
    keepalive_timeout    70;
    ssl_session_timeout  10m;

    client_max_body_size 200M;
    etag on;
    expires 7d;
    if_modified_since before;

    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types text/plain text/xml image/svg+xml # text/html in core already.
      application/rss+xml application/atom+xml application/xhtml+xml
      text/css application/json application/x-javascript
      application/font-otf application/font-ttf;

    # POST requests and urls with a query string should always go to PHP
    if ($request_method = POST) {
      set $cache_uri 'null cache';
    }
    if ($query_string != "") {
      set $cache_uri 'null cache';
    }

    # Don't cache uris containing the following segments
    if ($request_uri ~* "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(_index)?.xml|[a-z0-9_-]+-sitemap([0-9]+)?.xml)") {
      set $cache_uri 'null cache';
    }

    # Don't use the cache for logged in users or recent commenters
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in") {
      set $cache_uri 'null cache';
    }

    access_log  /var/log/nginx/toepsmedia.nl.access.log;

#    location / {
#    index  index.php index.html index.htm;
#    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

#    error_page  404              /blog/404/;
#    error_page  500 502 503 504  /blog/50x/;

    location ~ \.php$ {
	set $skip_cache 1;
    	if ($cache_uri != "null cache") {
     	  add_header X-Cache-Debug "$cache_uri $cookie_nocache $arg_nocache$arg_comment $http_pragma $http_authorization";
      	  set $skip_cache 0;
    	}
    	fastcgi_cache_bypass $skip_cache;
    	fastcgi_cache microcache;
    	fastcgi_cache_key $scheme$host$request_uri$request_method;
    	fastcgi_cache_valid any 8m;
    	fastcgi_cache_use_stale updating;
    	fastcgi_cache_bypass $http_pragma;

	root 	       	/www/toepsmedia.nl/site;
	try_files $uri 	$uri/ /index.php?$args;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass   	127.0.0.1:9004;
        fastcgi_index  	index.php;
	fastcgi_buffers 16 16k; 
	fastcgi_buffer_size 32k;
	fastcgi_read_timeout 300;
	fastcgi_param  	SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        	fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
