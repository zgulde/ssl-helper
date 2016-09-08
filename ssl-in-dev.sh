# this script will 'fake' ssl for a development machine using a self-signed
# certificate. 
# This should be run on the development server you want to setup
# this script was built to work with the codeup vagrant box setup,
# but the general principles will apply to any setup

# usage
#   bash ssl-in-dev.sh codeup.dev

# make sure the site is passed on the command line
if [ -z "$1" ]; then
    echo 'Please pass the name of the site you would like to add a ssl '
    echo 'certificate to when invoking the script.'
    exit 1
fi

site=$1

# make sure a configuration file for that site exists
if [[ ! -e /etc/nginx/sites-available/$site ]]; then
    echo 'That site does not exist, please give a valid site'
    exit 1
fi

# check if the server is already listening on 443 and bail out if it already is
if grep 'listen 443 ssl' /etc/nginx/sites-available/$site > /dev/null; then
    echo "$site already has ssl setup."
    exit 1
fi

# create a folder for ssl certs if its not there already
sudo mkdir -p /etc/nginx/ssl/$site

# create a private key
sudo openssl genrsa -out /etc/nginx/ssl/$site/$site.key > /dev/null 2>&1

# generate csr without being prompted for input
sudo openssl req -new \
    -key /etc/nginx/ssl/$site/$site.key \
    -out /etc/nginx/ssl/$site/$site.csr \
    -subj "/C=US/ST=Texas/L=SA/O=Codeup/OU=IT Department/CN=$site" > /dev/null 2>&1

# sign the certificate
sudo openssl x509 -req -days 365 \
    -in /etc/nginx/ssl/$site/$site.csr \
    -signkey /etc/nginx/ssl/$site/$site.key \
    -out /etc/nginx/ssl/$site/$site.crt > /dev/null 2>&1

# modify the nginx config
# append the relevent ssl directives after the server name
cat /etc/nginx/sites-available/$site |\
    perl -pe 's/server_name '$site';/$&

  listen 443 ssl;

  ssl_certificate     \/etc\/nginx\/ssl\/'$site\\/$site'.crt;
  ssl_certificate_key \/etc\/nginx\/ssl\/'$site\\/$site'.key;/' |\
    sudo tee /etc/nginx/sites-available/$site > /dev/null

# for some reason a restart wasn't doing it, so we'll be explicit here
sudo service nginx stop
sudo service nginx start
