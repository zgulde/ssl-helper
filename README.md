This script will obtain a ssl certificate from
[letsencrypt](https://letsencrypt.org/) by means of the
[certbot](https://certbot.eff.org/) tool for sites that are setup with
[warpspeed](https://warpspeed.io/).

The `walkthrough.md` file contains a rough draft of how to perform all the steps
that the script does by hand.

## Caveats

- If ssl is improperly configured, visitors to your site will see a nasty error
  message about how your site is insecure.
- Letsencrypt certificates expire every 90 days, so you will have to renew your
  certificate.
- If you edited your nginx configuration for the site, it might break this
  script, see [the source for more details](https://github.com/zgulde/ssl-helper/blob/master/ssl-helper.sh#L35)

## Prerequisites 

1. a digital ocean server setup with warpspeed
2. a registered domain name that points to a site that is deployed with
   warpspeed and setup on your warpspeed server
   - if you're faking your `.com` with your hosts file, this **will not** work
3. your sudo password for the server

## Usage

1. Log in to your server

    ```
    ssh warpspeed@YOUR_IP_ADDRESS
    ```

2. Download the installer script

    ```
    curl https://raw.githubusercontent.com/zgulde/ssl-helper/master/ssl-helper.sh > ssl-helper.sh
    ```

3. Run the script and follow the instructions.

    ```
    bash ssl-helper.sh
    ```

## Troubleshooting

Make sure the site was setup with warpspeed.

Make sure there is something deployed to the site, even if it is a hello world
page.

Make sure that your DNS is setup to point to your site. That is, you should be
able to view the regular http version of your site before this process will
work.

## Reverting back to a non-ssl site

While this is not possible through the warpspeed.io web interface, you can do it
with the warpspeed command line tool.

Log into your server and run the following:

```
warpspeed site:create <type> <your-site> --force
```

Where `<type>` is the type of site it was setup as (e.g. php) and `<your-site>`
is the name of your site (e.g. example.com). 
