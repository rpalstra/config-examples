server {
	listen 80;
    	listen [::]:80;
        server_name www.charlottevanbeusekom.com charlottevanbeusekom.com www.charlottevanbeusekom.nl charlottevanbeusekom.nl;
        return 301 $scheme://www.muacharlotte.com;
}
