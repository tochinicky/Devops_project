# Lemp Stack Implementation

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

## Installing the Nginx Web Server

### What is Nginx

_Nginx (pronounced "engine x") is a high-performance, open-source web server software. It is known for its efficiency, speed, and scalability, making it a popular choice for serving web content, especially for high-traffic websites and applications._

We started by creating an EC2 instance on AWS, you can get the workflow on how to create it on our previous `LAMP STACK` project.

To access the VM from your local machine:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/e67a944d-3f15-416f-81d5-0569ba68646e)

Installing Nginx using Ubuntu's package manager `apt`

`sudo apt update`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/08486094-4a04-4535-9f8e-5a4a41cb1267)

`sudo apt install nginx`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/8a737ded-9d6c-4728-9037-6c6b0ec57240)

To verify that Nginx is running as a service in our OS, we use the following command:

`sudo systemctl status nginx`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/39ce2119-c6db-45b4-a3d1-76e2deabd421)

First, we access it on our Ubuntu shell using the `curl` command

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/2d3f82f6-ab97-4aee-b295-0c82d881933d)

or

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/569f181a-6b78-45fa-9e6f-eb7f7d06a905)

We evaluate the responsiveness of our Nginx web server, which is capable of handling requests from the internet through web browsers. We utilize the EC2 instance's public IP provided by AWS, specifically on port 80.

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/f22f883f-b7a6-436d-a8b5-08d5c079a0df)

Another way to retrieve your public IP address, other than to check it in the AWS console is:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/ae69f731-096e-41e7-930e-276516d9ca6d)

## Installing MySQL

Now that we have the Apache HTTP server up and running, we need to install a database management system to store and manage data.

`sudo apt install mysql-server`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/2279b0d4-c29c-4259-992a-dc6888df9a5f)

After installation, we log in to MySQL with the following command:

`sudo mysql`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/f237ac51-6272-492b-b251-457e0c49adda)

_It's recommended that you run a security script that comes pre-installed with MySQL. This script will remove some insecure default settings and lock down access to your database system. Before running the script you will set a password for the root user, using mysql_native_password as the default authentication method We're defining this user's password as PassWord.1_

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/0688dd5f-017b-4dc4-b96e-43f8ca5741fa)

Then exit from MySQL

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/9f666068-b5cb-409d-8bec-3bdf58e14401)

We start the interactive script by running

`sudo mysql_secure_installation`

This is to make sure that passwords that don't match certain criteria will be rejected by MySQL

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/ce63f22c-6ba2-480e-98b6-2a8cadbba233)

_After running the above command, we log in to MySQL but this time we add the -p flag which will prompt you for the password used after changing the root user password_

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/2a373722-207b-4e62-ae68-6995653a50a1)

Then type the `exit` command to exit MySQL

## Installing PHP

You have Nginx installed to serve your content and MySQL installed to store and manage your data. PHP is the component of our setup that will process code to display dynamic content to the end user.

While Apache embeds the PHP interpreter in each request, Nginx requires an external program to handle PHP processing and act as a bridge between the PHP interpreter itself and the web server. This allows for better overall performance in most PHiP-based websites, but it requires additional configuration. You'll need to install php-fpm, which stands for "PHP fastCGI process manager", and tell Nginx to pass PHP requests to this software for processing.
Additionally, you'll need php-mysql, a PHP module that allows PHP to communicate with MYSQL-based databases. Core PHP packages will automatically be installed as dependencies.

To install these 2 packages at once, run:

`sudo apt install php-fpm php-mysql`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/de987059-c1e9-42cb-8685-aa5e4983ee02)

## Configuring Nginx to Use PHP Processor

When using the Nginx web server, we can create server blocks (similar to virtual hosts in Apache) to encapsulate configuration details and host more than one domain on a single server.
In this guide, we will use `projectLEMP` as an example domain name.

On Ubuntu 20.04, Nginx has one server block enabled by default and is configured to serve documents out of a directory at `/var/www/html`. While this works well for a single site, it can become difficult to manage if you are hosting multiple sites. Instead of modifying `/var/www/html`, we'll create a directory structure within `/var/www` for the your_domain website, leaving `/var/www/html` in place as the default directory to be served if a client request does not match any other sites.
Create the root web directory for your_domain as follows:

`sudo mkdir /var/www/projectLEMP`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/9b29d421-cb54-4332-8428-ae74635a37fa)

### Next, assign ownership of the directory with the $USER environment variable, which will reference your current system user:

`sudo chown -R $USER:$USER /var/www/projectLEMP`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/79b31456-f43e-422d-a4fe-7c8594fb9309)

Create a new configuration file in Nginx sites-available folder using the `nano` command and the following command in full

`sudo nano /etc/nginx/sites-available/projectLEMP`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/55d6f855-8c86-415f-885b-bf275346cea0)

It will create an empty file, Add the following configuration to the file:

`#/etc/nginx/sites-available/projectlEMP
server {
  listen 80;
  server name projectLEMP www.projectLEMP;
  root /var/www/projectLEMP;
  index index.html index.htm index.php;
  location / {
    try files $uri $uri/ =404;
    }
  location ~ \. php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;.
  }
  location ~ /\.ht {
    deny all;
  }
}`

#### Here's what each of these directives and location blocks do:

• listen - Defines what port Nginx will listen on. In this case, it will listen on port 80 the default port for HTTP.
• root - Defines the document root where the files served by this website are stored.
• index - Defines in which order Nginx will prioritize index files for this website. It is a common practice to list index.html files with higher precedence than index.php files to allow for quickly setting up a maintenance landing page in PHP applications. You can adjust these settings to better suit your application needs.
• server_name - Defines which domain names and/or IP addresses this server block should respond for. Point this directive to your server's domain name or public IP address.
• location / %- The first location block includes a `try_files` directive, which checks for the existence of files or directories matching a URI request. If Nginx cannot find the appropriate resource, it will return a 404 error.
• location ~ \.php$ - This location block handles the actual PHP processing by pointing Nginx to the `fastcgi-php.conf` configuration file and the `php7.4-fpm.sock` file, which declares what socket is associated with `php-fpm`.
• location ~ /\.ht - The last location block deals with `.htaccess` files, which Nginx does not process. By adding the deny all directive, if any `.htaccess` files happen to find their way into the document root, they will not be served to visitors.

Activate your configuration by linking to the config file from Nginx's `sites-enabled` directory:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/e5be06e2-04f5-4eaf-a8b4-089ee87eca6c)

To make sure your configuration doesn't contain any syntax errors, run:

`sudo nginx -t`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/202dd516-af1e-400f-af21-e0bc806ebbe1)

We also need to disable default Nginx host that is currently configured to listen on port 80, for this run:

`sudo unlink /etc/nginx/sites-enabled/default`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/ffa3b3d6-dfaf-49e7-a571-d5602198c702)

After that, we reload nginx to apply changes

`sudo systemctl reload nginx`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/28964fdb-f11d-4ab8-b1ba-08ca470b99e3)

Our new website is now active, but the web root `/var/www/projectLEMP` is still empty.
We create an `index.html` file in that location so that we can test that the virtual host works as expected:

`sudo echo 'Hello LEMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/projectlEMP/index.html`

Note: This IP address `169.254.169.254` is a special-purpose IP address used for accessing metadata and information about an AWS EC2 instance when you're running your code within an EC2 instance.

Now, we go to our browser to access the website using the public IP:

`http://<public-ip-address>:80`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/8c8220fa-5fd9-4df9-9cc2-d171ef542445)

We can also use the DNS to retrieve our website content:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/f38000c4-f94a-45b2-b1d2-9ffe4f6db172)

## Testing PHP with Nginx

To validate that Nginx can correctly handle `.php` files off to the PHP processor, we can do this by creating a test PHP file in our document root:

`sudo nano /var/www/projectLEMP/info.php`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/95d0681c-44e4-4533-8259-1c69c589a9c3)

when the file is open add the following script:

`<?PHP
phpinfo();`

We can now access the page in our web browser by visiting either the domain name or IP address that's already set up in the Nginx configuration file, followed by `/info.php`

`http://domain_name_or_IP/info.php`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/76aac376-f689-4a48-8d06-6bda010f2a77)

After checking the relevant information about your PHP server through that page, it's best to remove the file we created as it contains sensitive information about our PHP environment and Ubuntu server. You can use `rm` command to remove the file:

`sudo rm /var/www/projectLEMP/info.php`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/e7ffc073-fd48-44a1-b1c3-306ee4682931)

## Retrieving data from MYSQL Database with PHP

In this step, we will create a test database with a simple `ToDo list` and configure access to it, so the Nginx website would be able to query data from the DB and display it.

First, connect to the MYSQL console using the root account:

`sudo mysql -p`

To create a new database run the following command:

`CREATE DATABASE `todo_database``

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/4471c2b5-b8f5-46c8-b739-7d380f5addf0)

We create a new user `tochi` using mysql_native_password as a default authentication method. We define the user's password as `passWord.1`, but you should replace the password with a secured password of your choosing.

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/7497f418-cbe6-4658-ac69-cb0fc2d2d26b)

Now we need to give the user permission over the `todo_database` database:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/50ea81e8-6586-4e03-ad9b-cffcc5f6536b)

To exit from the MySQL shell:

`exit`

We can test if the user has the proper permissions by logging in to the MySQL console again, this time using the custom user credentials:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/318c21cd-92f5-4437-b848-962585928c78)

Let's confirm if we have access to the `todo_database`:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/990f9b69-b741-41f1-a9d1-926effaa0c8a)

Next, let's create a test table named `todo_list` from the MySQL console:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/98817b5e-3fb9-4197-a8f8-83c147a48acb)

Next, let's insert a few rows in the test table, this can be repeated

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/b34418c1-5e79-4c31-af28-c63fc2c3b377)

To confirm that the data was successfully saved:

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/1837fe00-e105-46f7-a446-dc11ffe3762c)

We are done, Let's exit from the MySQL console:

`exit`

Now, we can create a PHP script that will connect to MySQL database and queries for the content of the `todo_list` table, displaying the result in a list. If there's a problem with the database connection it will throw an exception.

`nano /var/www/projectLEMP/todo_list.php`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/1c62a628-b544-46ad-8657-4add081d9ee6)

Save and close when done editing.

Finally, we can now access the page in our web browser by visiting either the domain name or IP address that's already set up in the Nginx configuration file, followed by `/todo_list.php`

![Image Alt](https://github.com/tochinicky/LempStack/assets/29289689/e6029ec7-4d9f-4eb6-80ae-53537c9dd18b)

It was a nice experience deploying a LEMP STACK project.
