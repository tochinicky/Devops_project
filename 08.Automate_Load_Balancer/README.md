# Automating Loadbalancer configuration with Shell scripting

# Automate the Deployment of Webservers

## Automate the Deployment of Webservers

In implementing a load balancer with the Nginx course, We deployed two backend servers, with a load balancer distributing traffic across the web servers. We did that by typing commands right on our terminal.
In this project, we will be automating the entire process. We will do that by writing a shell script that when run, all that will be done manually will be done for us automatically. As DevOps Engineers automation is at the heart of the work we do. Automation helps us speed up the deployment of services and reduce the chance of making errors in our day-to-day activities.
This project will give a great introduction to automation.

# Deploying and Configuring the Webservers

## Deploying and Configuring the Webservers

All the process we need to deploy our webservers has been codified in the shell script below:

    `#!/bin/bash

    ############################################################################################
    ##### This automates the installation and configuring of apache webserver to listen on port 8000
    ##### Usage: Call the script and pass in the Public_IP of your EC2 instance as the first argument as shown below:
    ####### •/install_configure_apache. sh 127.0.0.1
    #################################################################################################

    set -x # debug mode
    set -e # exit the script if there is an error
    set -o pipefail # exit the script when there is a pipe failure

    PUBLIC_IP=$1

    [ -z "${PUBLIC_IP}" ] && echo "Please pass the public IP of your EC2 instance as an argument to the script" && exit 1

    sudo apt update -y && sudo apt install apache2 -y

    sudo systemctl status apache2

    if [[ $? -eq 0 ]]; then
        sudo chmod 777 /etc/apache2/ports.conf
        echo "Listen 8000" >> /etc/apache2/ports.conf
        sudo chmod 777 -R /etc/apache2/

        sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8000>/' /etc/apache2/sites-available/000-default.conf
    fi
    sudo chmod 777 -R /var/www/
    echo "<!DOCTYPE html>
         <html>
         <head>
                 <title>My EC2 Instance</title>
         </head>
         <body>
                 <h1>Welcome to my second EC2 instance</h1>
                 <p>Public IP: "${PUBLIC_IP}"</p>
        </body>
        </html>" > /var/www/html/index.html

    sudo systemctl restart apache2
    `

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/4a560dac-3d8a-44f2-b49d-4ead0194eb18)

Follow the steps below to run the script:
**Step 1**: Provision an EC2 instance running bunt 20.04. You can refer to this project [Implementing load balancer with Nginx ](https://github.com/tochinicky/loadbalancer_nginx)

**Step 2**: Open port 8000 to allow traffic from anywhere using the security group.

**Step 3**: Connect to the web server via the terminal using SSH client.

**Step 4**: Open a file, paste the script above, and close the file using the command below:

`sudo nano install.sh`

To save and close, use `ctl + o`, then Enter key, then `ctl+x`

**Step 5**: Change the permissions on the file to make an executable using the command below:

`sudo chmod +x install.sh`

**Step 6**: Run the shell script using the command below.

    The public ip can be gotten from the EC2 instance

    `./install.sh PUBLIC_IP`

The below screenshot is the final result after running the above script:

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/7d7f5b72-c862-43b6-9038-8c202e4bad09)

We can confirm from the browser that the ip and port are accessible:

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/a8ab3ac6-7e6a-443b-a178-a2876f5ccc12)

The same process can be repeated on the second web server:

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/458cb5b2-ba70-411e-bc25-9e01c1b2a3a0)

# Deployment of Nginx as a Load Balancer using Shell script

## Automate the Deployment of Nginx as a Load Balancer using the Shell script

Having successfully deployed and configured two web servers, We will move on to the load balancer. As a prerequisite, we need to provision an EC2 instance running Ubuntu 22.04, open port 80 to anywhere using the security group, and connect to the load balancer via the terminal.

# Deploying and Configuring Nginx Load Balancer

All the steps followed in the Implementing Load Balancer with Nginx course have been codified in the script below:

```shell:
#!/bin/bash
################################################################################################################################
##### This automates the configuration of Nginx to act as a load balancer
##### Usage: The script is called with 3 command line arguments. The public IP of the EC2 instance where Nginx is installed ##### the webserver urls for which the load balancer distributes traffic. An example of how to call the script is shown below:
##### ./configure_nginx_loadbalancer.sh PUBLIC_IP Webserver-1 Webserver-2
################ ./configure_nginx_loadbalancer.sh 127.0.0.1 192.2.4.6:8000 192.32.5.8:8000
################################################################################################

PUBLIC_IP=$1
firstWebserver=$2
secondWebserver=$3
[ -z "${PUBLIC_IP}" ] && echo "Please pass the Public IP of your EC2 instance as the argument to the script" && exit 1

[ -z "${firstWebserver}" ] && echo "Please pass the Public IP together with its port number in this format: 127.0.0.1:8000 as the second argument to the script" && exit 1

[ -z "${secondWebserver}" ] && echo "Please pass the Public IP together with its port number in this format: 127.0.0.1:8000 as the third argument to the script" && exit 1

set -x # debug mode
set -e # exit the script if there is an error
set -o pipefail # exit the script when there is a pipe failure

sudo apt update -y && sudo apt install nginx -y

sudo systemctl status nginx

if [[ $? -eq 0 ]]; then
      sudo touch /etc/nginx/conf.d/loadbalancer.conf

      sudo chmod 777 /etc/nginx/conf.d/loadbalancer.conf
      sudo chmod 777 -R /etc/nginx/

      echo " upstream backend_servers {
          server "${firstWebserver}"; # public ip and port for webserver 1
          server "${secondWebserver}"; # public ip and port for webserver 2
      }

      server {
          listen 80;
          server_name "${PUBLIC_IP}";

          location / {
              proxy_pass http://backend_servers;
          }
      }
      " > /etc/nginx/conf.d/loadbalancer.conf
fi

sudo nginx -t

sudo systemctl restart nginx
```

# Steps to Run the Shell Script

**Step 1**: On your terminal, open a file nginx.sh using the command below:

     `sudo nano nginx.sh`


**Step 2**: Copy and Paste the script inside the file, then save.

**Step 3**: Change the file permission to make it an executable using the command below:

      `sudo chmod +× nginx.sh`


**Step 4**: Run the script with the command below:

    `./nginx.sh PUBLIC_IP Webserver-1 Webserver-2`

    Note: the PUBLIC_IP  is the nginx ip and the webserver-1 and webserver-2 are the public IP and port of the webservers respectively

After successfully following the above steps, we can verify it via the browser:

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/4be1bcd0-f0c3-42c7-b188-d9dd1a66cfc4)

![image](https://github.com/tochinicky/automate_loadbalancer/assets/29289689/83f251af-0020-454f-beae-72e077f49996)

The above screenshots show that the load balancer uses the **Round Robin** algorithm. for more information on the load balancing algorithm you can get it [here](https://github.com/tochinicky/loadbalancer_nginx)
