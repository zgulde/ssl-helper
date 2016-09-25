**This document is a rough outline of what the `ssl-helper.sh` script is doing
behind the scenes. If you want to go through the process manually, feel free to
follow along here, otherwise follow along with the main README**

## prerequisites

1. a digital ocean server setup with warpspeed
2. a registered domain name that points to a site that is on your warpspeed
   server
   - if you're faking your `.com` with your hosts file, this **will not** work
3. the ability to log in to your server
4. your sudo password for the server
5. trust
    - we are going to run a script with root privileges on your production
      server

## warnings

1. if this is set up improperly, visitors to your site will see a nasty warning
   page
2. you have to renew this certificate every 90 days

## obtain a ssl certificate with certbot

1. edit your nginx config to allow access to `.well-known`

    ```
    sudo -e /etc/nginx/sites-availible/your-awesome-site.com
    ```

    add this

    ```
    location ~ /.well-known {
        allow all;
    }
    ```

1. restart nginx

    ```
    sudo service nginx restart
    ```

1. install certbot command line tool and make it executable

    ```
    # from ~/
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
    ```

1. run the certbot command line tool and pass it `certonly`

    ```
    ./certbot-auto certonly
    ```

1. follow the prompts when asked for your webroot, give it the path to your public directory

    ```
    /home/warpspeed/sites/my-awesome-site.com/public/
    ```

1. (hopefully) you'll get a success message telling you the certificate is intalled

## set up ssl with warpspeed.io

server > site > ssl certificates

1. copy over the ssl certificate and private key to the warpspeed web interface

    - you will need to be root to access these files

    ```
    sudo -s
    ```

    ```
    # certificate file
    cat /etc/letsencrypt/live/zgul.de/cert.pem
    # private key
    cat /etc/letsencrypt/live/zgul.de/privkey.pem
    ```

1. click 'install existing certificate'
1. under 'existing site certificates' click activate
1. reload the site
1. celebrate!
