server {
	listen 80;
    	listen [::]:80;
        server_name www.charlottevanbeusekom.com charlottevanbeusekom.com www.charlottevanbeusekom.nl charlottevanbeusekom.nl www.muacharlotte.com muacharlotte.com www.muacharlotte.nl muacharlotte.nl;
        return 301 $scheme://www.charlottevanbeusekom.nl;
}
