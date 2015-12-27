server {
    listen 80;
    listen [::]:80;
    server_name  www.palstra.com palstra.com www.palstra.nl palstra.nl www.palstra.net palstra.net www.palstra.org palstra.org www.riemerpalstra.com riemerpalstra.com www.riemerpalstra.nl riemerpalstra.nl riemer.palstra.com www.palstra.frl palstra.frl;
    root   /www/palstra.com/site;
    index  index.php;
    set $cache_uri $request_uri;

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

    access_log  /var/log/nginx/palstra.com.access.log;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
 
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
 
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
 
    error_page  404              /404.html;
    location = /404.html {
        root   /usr/share/nginx/www;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/www;
    }

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

	root 	       	/www/palstra.com/site;
	try_files $uri 	$uri/ /index.php?$args;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass   	127.0.0.1:9001;
        fastcgi_index  	index.php;
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
