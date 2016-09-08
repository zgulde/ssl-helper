# This script is for anyone who wishes to obtain a ssl certificate from
# letsencrypt and has a webserver that was provisioned with warpspeed.io
#
# Prerequisites:
#   - a site created with warpspeed
#   - a domain name whose DNS points to the above site
#
# this script is basically a wrapper around the `certbot-auto` command
# it will also edit the relevant nginx configuration to allow certbot-auto
# to do its thing.

# TODO: make this word for a different webroot
# TODO: make this work for a different certbot-auto installation location
#       we should probably check if its in the PATH

# download certbot, store it in the home directory, and make it executable
install-certbot(){
    echo 'It looks like we havent downloaded certbot-auto (or it is not in the'
    echo 'home directory). Lets go ahead and download it now.'
    curl -sS https://dl.eff.org/certbot-auto > $HOME/certbot-auto
    chmod +x $HOME/certbot-auto
    echo 
    echo 'certbot-auto installed!'
    echo
}

wait-to-continue(){
    echo
    echo
    echo -e '\nPress Enter to continue or Ctrl-C to exit'
    read
    echo 
}

# will add an entry to the nginx config file for $1 to allow acces to
# /.well-known
# the perl regex relies on the nginx config file being the one that is setup by
# warpspeed. Basically it looks for the entry in the file that disallows access
# to all hidden folders and appends the entry for certbot above that line
edit-nginx-conf(){
    cat /etc/nginx/sites-available/$1 |\
    perl -pe 's/.*deny all.*/    location ~ \/.well-known { allow all; }\n$&/' |\
    sudo tee /etc/nginx/sites-available/$1 > /dev/null
}

echo
echo 'It is recommended that you run this script will a full-size terminal'
echo 'window. There is a lot of information to see, and (oddly) the tool we are'
echo 'going to use to obtain a certificate has been known to crash if the'
echo 'terminal window it is run in is not big enough.'
echo
echo 'We will require admin privileges in order to edit the nginx configuration'
echo 'for the site and to run the certbot-auto tool.'

wait-to-continue

# start by getting the site name
read -p 'Enter your site name (example.com) ' site

echo
echo

echo 'Make sure the following is correct.'
echo "Site Name: $site"
echo "Webroot: /home/warpspeed/sites/$site/public"

wait-to-continue

# make sure that site exists
if [[ ! -e "/etc/nginx/sites-available/$site" ]]; then
    echo
    echo "It looks like that site either doesn't exist or wasn't setup properly"
    echo
    exit 1
fi

# check if we already edited the nginx config for this site, if not
# make sure certbot is able to access what it needs to access
if ! grep '/\.well-known' /etc/nginx/sites-available/$site > /dev/null; then
    echo 'We are going to need to edit the nginx config to allow ourselves to'
    echo 'prove that we own the site.'
    echo 'Editing nginx config...'
    edit-nginx-conf $site
    echo 'Reloading nginx...'
    sudo service nginx restart
    echo 'nginx configured!' 
    echo
fi

# install cerbot-auto if it isn't already
if [[ ! -e $HOME/certbot-auto ]]; then
    install-certbot
fi

echo
echo 'We are now going to run certbot. If this is your first time running'
echo 'certbot, certbot will need to install some things, and you will need to'
echo 'type yes to continue. You will also be asked for your email address and'
echo 'to agree to their TOS.'

wait-to-continue

$HOME/certbot-auto certonly -a webroot --webroot-path=/home/warpspeed/sites/$site/public -d $site

# check if certbot worked...
if [[ $? != 0 ]]; then
    echo 
    echo 'Looks like something went wrong with the cerbot command, read the'
    echo 'above message to find out what went wrong.'
    echo
    exit
fi

wait-to-continue

echo 'Hopefully everythings gone well at this point, and we should have a'
echo 'certificate issued to us!'

echo 'The next step is going to be to go to warpspeed.io and paste in your'
echo 'certificates.'
echo 'Go to your server > your site > click on the tab for ssl certificates.'
echo 'Scroll down to "Install an Existing Certificate", then come back here'

wait-to-continue

echo 'Your certificate will be displayed on the screen momentarily, when it is,'
echo 'copy it and paste it into the "Certificate" textarea, then come back here.'

wait-to-continue

sudo cat /etc/letsencrypt/live/$site/fullchain.pem

wait-to-continue

echo 'Now copy and paste the following for your Private Key:'

wait-to-continue

sudo cat /etc/letsencrypt/live/$site/privkey.pem

wait-to-continue

echo 'And click the big green "Install Existing Certificate" button.'

wait-to-continue

echo 'Under "Existing Site Certificates" you should now see an entry for your'
echo 'site. Go ahead and click activate.'

wait-to-continue

echo 'Restarting nginx...'

sudo service nginx restart

echo
echo "All Done! You can now go visit https://$site"

