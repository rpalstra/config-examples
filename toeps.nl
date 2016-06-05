server {
    listen 80;
    listen [::]:80;
    server_name  www.toeps.nl toeps.nl toeps.palstra.com;
    root   /www/toeps.nl/site;
    index  index.php index.html;
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

    access_log  /var/log/nginx/toeps.nl.access.log;

    location / {
    index  index.php index.html index.htm;
      if (!-e $request_filename) {
        rewrite ^/(.*)/$ http://www.toeps.nl/fotografie/ last;
      }
    }

    location @blog {
    rewrite ^/blog(.*) /blog/index.php?q=$1;
    }

    location /blog {
        alias /www/toeps.nl/site/blog;
        index index.php index.html index.htm;
        try_files $uri $uri/ @blog;

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
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass    127.0.0.1:9003;
        fastcgi_index   index.php;
	fastcgi_buffers 16 16k; 
	fastcgi_buffer_size 32k;
	fastcgi_read_timeout 300;
        fastcgi_param   SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include         fastcgi_params;
        }
    }


    location @fotografie {
    rewrite ^/fotografie(.*) /fotografie/index.php?q=$1;
    }
    
    location /fotografie {
        alias /www/toeps.nl/site/fotografie;
        index index.php index.html index.htm;
        try_files $uri $uri/ @fotografie;

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
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass    127.0.0.1:9003;
        fastcgi_index   index.php;
        fastcgi_param   SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include         fastcgi_params;
	}    
    }

    location /portfolio {
        alias /www/toeps.nl/site/portfolio;
        index index.php index.html index.htm;
        try_files $uri $uri/ @portfolio;

        location ~ \.php$ {
        fastcgi_cache_bypass 1;
        fastcgi_no_cache 1;
        fastcgi_cache_use_stale updating;
        fastcgi_pass    127.0.0.1:9003;
        fastcgi_index   index.php;
	fastcgi_buffers 16 16k; 
	fastcgi_buffer_size 32k;
	fastcgi_read_timeout 300;
        fastcgi_param   SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include         fastcgi_params;
	}    
    }
    
    location @handmodel {
    rewrite ^/handmodel(.*) /handmodel/index.php?q=$1;
    }
    
    location /handmodel {
        alias /www/toeps.nl/site/handmodel;
        index index.php index.html index.htm;
        try_files $uri $uri/ @handmodel;

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
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass    127.0.0.1:9003;
        fastcgi_index   index.php;
	fastcgi_buffers 16 16k; 
	fastcgi_buffer_size 32k;
	fastcgi_read_timeout 300;
        fastcgi_param   SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include         fastcgi_params;
    	}
    }

    
    error_page  404              /404.html;
    location = /404.html {
        root   /usr/share/nginx/www;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
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

	root 	       	/www/toeps.nl/site;
	try_files $uri 	$uri/ /index.php?$args;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass   	127.0.0.1:9003;
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
