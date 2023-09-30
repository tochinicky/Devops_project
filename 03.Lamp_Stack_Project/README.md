# Lamp Stack Implementation

## Launch an EC2 instance on AWS

_Create an AWS account to launch an EC2 instance_

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/bafb24a8-8e68-4c98-a12f-0fad2bd69a89)

`Note: After creating an instance, you'll need to download a key to access the VM on your local machine
`

### Accessing the VM

Navigate to where the key was downloaded and run the following command:

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/af592205-0f00-4326-a497-d1a001cab151)

_To receive traffic from the internet we'll need to modify/add our inbound rules_

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/4cbe8801-762c-43fe-9855-ffb96e6e7c08)

## Installing Apache and Updating the Firewall

### What is Apache

_Apache is a software application that serves web pages to users' browsers. It receives requests from clients (like web browsers), processes those requests, and sends back the requested web pages._

Installing Apache using Ubuntu's package manager `apt`

`sudo apt update`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/55f5bffd-3785-4acb-8cc3-f084790e0c88)

`sudo apt install apache2`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/65739eb0-469f-420c-a824-e12601996123)

To verify that Apache2 is running as a service in our OS, we use the following command:

`sudo systemctl status apache2`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/07db247a-69e3-4783-b879-01648dfe876b)

First, we access it on our Ubuntu shell using the `curl` command

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/d530e451-14fd-47c5-bd43-4e4aa515a8e2)

We evaluate the responsiveness of our Apache HTTP server, which is capable of handling requests from the internet through web browsers. We utilize the EC2 instance's public IP provided by AWS, specifically on port 80.

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/c80ec128-a459-4580-b34c-971f736ddc07)

## Installing MySQL

Now that we have the Apache HTTP server up and running, we need to install a database management system to store and manage data.

`sudo apt install mysql-server`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/dbcb1be4-29e7-415c-9910-2f4d3b3b2475)

After installation, we log in to MySQL with the following command:

`sudo mysql`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/9c1e7b85-679f-4826-a769-f5c0f876656d)

_It's recommended that you run a security script that comes pre-installed with MySQL. This script will remove some insecure default settings and lock down access to your database system. Before running the script you will set a password for the root user, using mysql_native_password as the default authentication method We're defining this user's password as PassWord.1_

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/dd1fa13f-737c-4dc9-aa86-8fd66f7cc226)

Then exit from MySQL

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/d453f2c2-ac54-48a8-ac2e-fe8352b8ce99)

We start the interactive script by running

`sudo mysql_secure_installation`

This is to make sure that passwords that don't match certain criteria will be rejected by MySQL

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/3230c7be-986c-4da4-971c-e435c7520953)

_After running the above command, we log in to MySQL but this time we add the -p flag which will prompt you for the password used after changing the root user password_

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/4dfd578d-a283-4609-9f39-4683d6ac5aa1)

Then type the `exit` command to exit MySQL

## Installing PHP

You have Apache installed to serve your content and MySQL installed to store and manage your data. PHP is the component of our setup that will process code to display dynamic content to the end user. In addition to the PHP package, you'll need php-mysql, a PHP module that allows PHP to communicate with MySQL-based databases.
You'll also need libapache2-mod-php to enable Apache to handle PHP files. Core PHP packages will automatically be installed as dependencies.
To install these 3 packages at once, run:

`sudo apt install PHP libapache2-mod-php php-mysql`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/6f767c2a-eaa0-4edd-ad4e-5c3c406aee9c)

To check the version of PHP

`php -v`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/f4fd8364-6b0f-4038-9c18-9d3da51b86ad)

## Creating a Virtual Host for your Website using Apache

### Set up a domain named `projectlamp`. Then create a directory using the command:

`sudo mkdir /var/www/projectlamp`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/61fe36f0-d857-42d9-8d4c-5990fe251034)

### Also, change the ownership of the directory to the current user using the command:

`sudo chown -R $USER:$USER /var/www/projectlamp`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/9dab5ccd-782e-4469-8653-7e53fc615f75)

Create a new configuration file in Apache's sites-available folder using the `nano` command and the following command in full

`sudo nano /etc/apache2/sites-available/projectlamp.conf`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/bf4e566d-abbd-4959-bd1c-8ddb5727b7ba)

It will open an empty file, Add the following configuration to the file

`<VirtualHost *:80>
ServerName projectlamp
ServerAlias www.projectlamp
ServerAdmin webmaster@localhost
DocumentRoot /var/www/projectlamp
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>`

you can use the `ls` command to show the new file in `sites-available` directory

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/4e8ad6c8-0f2f-42ff-85a3-5e5d474872fd)

With this VirtualHost configuration, we're telling Apache to serve projectlamp using `/var/www/projectlampl` as its web root directory. If you would like to test Apache without a domain name, you can remove or comment out the options Server Name and ServerAlias by adding a # character in the beginning of each option's lines. Adding the # character there will tell the program to skip processing the instructions on those lines.

To enable the new virtual host:

` sudo a2ensite projectlamp`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/4f95cbaf-8da9-47b5-9651-e273bafac490)

You might want to disable the default website that comes installed with Apache. This is required if you're not using a custom domain name, because in this case Apache's default configuration would overwrite your virtual host. To disable Apache's default website use a2dissite command, type:

`sudo a2dissite 000-default`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/18e73abd-9532-40ea-b66f-22f298a3befd)

To make sure your configuration doesn't contain any syntax errors, run:

`sudo apache2ctl configtest`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/6d9f2994-888a-4410-9913-758f74197895)

So, we need to reload Apache so that the changes can take effect:

`sudo systemctl reload apache2`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/7db5a344-62b1-4268-83b5-da20c980ca77)

Our new website is now active, but the web root `/var/www/projectlamp` is still empty.
We create an `index.html` file in that location so that we can test that the virtual host works as expected:

`sudo echo 'Hello LAMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/projectlamp/index.html`

Note: This IP address `169.254.169.254` is a special-purpose IP address used for accessing metadata and information about an AWS EC2 instance when you're running your code within an EC2 instance.

Now, we go to our browser to access the website using the public IP:

`http://<public-ip-address>:80`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/d455bb57-7d61-4f5f-ba1e-c545e1f521e2)

We can also use the DNS to retrieve our website content:

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/a49b29cf-75a4-4be9-88d2-ca8799957957)

## Enable PHP on our Website

With the default DirectoryIndex settings on Apache, a file named `index.html` will always take precedence over an `index. php` file. This is useful for setting up maintenance pages in PH applications, by creating a temporary `index.html` file containing an informative message to visitors. Because this page will take precedence over the `index.php` page, it will then become the landing page for the application.

Once maintenance is over, the `index.html` is renamed or removed from the document root, bringing back the regular application page.
In case you want to change this behavior, you'll need to edit the `/etc/apache2/mods-enabled/dir.conf` file and change the order in which the `index.php` file is listed within the DirectoryIndex directive:

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/cad6c85d-7fa3-40f1-9ab3-1e83310b9c36)

After changing the behavior we save and reload Apache.

`sudo systemctl reload apache2`

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/4264d108-ab64-4108-9f7e-59cfa2df7990)

Finally, we create a PHP script to test that PHP is installed correctly and configured on our server.

create a new file named `index.php` inside our custom web root folder.

`nano /var/www/projectlamp/index.php`

Then paste the below PHP code:

`<?php
phpinfo();`

After saving the above file, refresh the browser

![Image Alt](https://github.com/tochinicky/LampStack/assets/29289689/fd3a357e-57d5-4002-85fd-4266885515aa)

It was a nice experience going through the deployment of a Lamp Stack project.
