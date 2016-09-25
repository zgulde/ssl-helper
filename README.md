This repo holds a couple scripts to help get codeup students setup with a ssl
certificate for their sites, and setup their development environment to be able
to test their sites with an encrypted connection.

The `ssl-helper.sh` script will obtain a ssl certificate from
[letsencrypt](https://letsencrypt.org/) by means of the
[certbot](https://certbot.eff.org/) tool for sites that are setup with
[warpspeed](https://warpspeed.io/).

The `ssl-in-dev.sh` script will setup a site on the [codeup vagrant
box](https://github.com/gocodeup/Codeup-Vagrant-Setup) with a self signed ssl
certificate for testing.

The `notes.md` file contains a rough draft of how to perform all the steps
that the script does by hand. This file is essentially my notes that the
`ssl-helper.sh` script is based off.

- [Installing in Production](#installing-a-ssl-certificate-in-production)
- [Installing in Development](#setting-up-ssl-in-development)
- [Renewing Existing Certificates](#renewing-existing-certificates)

# Installing a SSL Certificate in Production

## Caveats

- If ssl is improperly configured, visitors to your site will see a nasty error
  message about how your site is insecure.
- Letsencrypt certificates expire every 90 days, so you will have to renew your
  certificate.
- If you edited your nginx configuration for the site, it might break this
  script, see [the source for more details](https://github.com/zgulde/ssl-helper/blob/master/ssl-helper.sh#L40)

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

# Setting up SSL in Development

1. Download the `ssl-in-dev.sh` script onto your vagrant machine

    ```
    curl https://raw.githubusercontent.com/zgulde/ssl-helper/master/ssl-in-dev.sh > ssl-in-dev.sh
    ```

2. Run it and pass the name of the site you want to setup a certificate for as a
   command line argument

    ```
    bash ssl-in-dev.sh codeup.dev
    ```

After this process is finished you will have a self-signed certificate setup for
your `.dev`.

When you visit the `.dev` in the browser you will still be able to access it via
http, but can also test it by visiting the https version.

```
https://codeup.dev
```

Note that the first time you visit the site, your browser should give you an
error message about a untrusted certificate. This is expected because our
certificate is not verified by an external certificate authority, Go ahead and
click through and continue to the site.

# Renewing Existing Certificates

If you've already have a certificate installed you will need to renew it every
90 days. Luckily this process is pretty much the same as the initial setup.

1. Log into your server and run the `ssl-helper.sh` script again.

    ```bash
    bash ssl-helper.sh
    ```

1. Follow the prompts and input your site name.

1. When the script runs `certbot-auto` it will go ahead and renew the existing
   certificate.

1. Once we have a new certificate, follow along like normal and install it
   through the warpspeed web interface.

**Note that just obtaining a fresh certificate is not enough, you will need to
follow through with installing it through the warpspeed web interface, otherwise
your server will still be using the old certificate.**
