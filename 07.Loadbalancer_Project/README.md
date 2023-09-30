# IMPLEMENTING LOAD BALANCERS WITH NGINX

We'll learn how to distribute traffic efficiently on multiple servers, optimize performance, and ensure high availability for web applications

# Intoduction to load-balancing and Nginx

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/157a32c2-6b59-43df-8112-a5d0500bc41a)

Load balancing is like having a team of helpers working together to make sure a big job gets done smoothly and efficiently. Imagine you have a lot of heavy boxes to carry, but you can't carry them all by yourself because they are too heavy.
Load balancing is when you call your friends to help you carry the boxes. Each friend takes some of the boxes and carries them to the right
place. This way, the work gets done much faster because everyone is working together.
In computer terms, load balancing means distributing the work or tasks among several computers or servers so that no one computer gets overloaded with too much work. This helps to keep everything running smoothly and ensures that websites and apps work quickly and don't get too slow. It's like teamwork for computers!
Let's say you have a set of web servers serving your website. In other to distribute the traffic evenly between the webservers, a load balancer is deployed. The load balancer stands in front of the web servers, all traffic gets to it first, and it then distributes the traffic across the set
of web servers. This is to ensure no webserver gets overworked, consequently improving system performance.
Nginx is a versatile software, it can act like a web server, reverse proxy, load balancer, etc. All that is needed is to configure it properly to
server your use case.

In this project, we'll learn how to configure Nginx as a load balancer.

# Setting Up a Basic load balancer

## Setting Up a Basic Load Balancer

We are going to be provisioning two EC2 instances running Ubuntu 22.04 and installing an Apache web server in them. We will open port 8000 to allow traffic from anywhere and finally update the default page of the webservers to display their public IP address.
Next, we will provision another EC2 instance running Ubuntu 22.04, this time we will install Nginx and configure it to act as a load balancer distributing traffic across the webservers.

**Step 1** Provisioning EC2 instance
• Open your AWS Management Console, and click on EC2. Scroll down the page and click on Launch instance:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/ad50a10f-a6fe-4f73-9f94-fc36d0c8cfb2)

• Under Name, Provide a unique name for each of your webservers:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/8d0c4284-c3c2-403c-bfbc-37f69fb55b99")

• Under Applications and OS Images, click on Quick Start and click on Ubuntu:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/159e90a5-1544-4ae6-bead-3cb01898a86b)

• Under Key Pair, click on Create New key pair if you do not have one. You can use the same key pair for all the instances you provision for this lesson:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/728594ec-27fc-42f1-bca3-6e36107b1602)

• And Finally click on launch instance:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/0c198b6b-42b9-4574-ad1c-059f187c3b38)

**Step 2**: Open Port 8000 We will be running our webservers on port 8000 while the load balancers run on port 80. We need to open the port
8000 to allow traffic from anywhere. To do this we need to add a rule to the security group of each of our web servers

• Click on the instance ID to get the details of your EC2 instance,

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/2cf35751-dc39-478c-8b48-72226606dda7)

• On that same page, scroll down and click on security, then click on security groups:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/76c4a65b-3622-4b27-b53e-b7cc0fdf6aa6)

• On the top of the page click on Action and select Edit inbound rules:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/a3f9a73c-5a09-4311-8a47-6fd382b57cad)

• Add your rules and save:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/30780433-80a8-4cd3-9e8d-3469bf5fc867)

**Step 3**: Install Apache Webserver
After provisioning both of our servers and having opened the necessary ports, It's time to install Apache software on both servers. To do so we must first connect to each of the webservers via ssh. Then we can run commands on the terminal of our webservers.

• Connecting to the web server: To connect to the web server, click on your instance ID, at the top of the page click on connect, and copy the SSH command:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/89346082-2bc7-44c5-81a7-38b2235b74e3)

• Open a terminal in your local machine, `cd` into your Downloads folder. Paste the ssh command you copied in the previous step

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/185c5017-6bb3-41f3-b0a8-0500c8a62b5d)

• Next install Apache with the command below:

    `sudo apt update -y && sudo apt install apache2 -y`

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/d0815fef-317f-4652-b835-a06a0fea7162)

• Verify that Apache is running using the command below:

    `sudo systemctl status apache2`

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/075c720c-7cc4-4097-a1c4-1d535efca281)

**Step 4**: Configure Apache to server a page showing its public IP:
We will start by configuring the Apache webserver to serve content on port 8000 instead of its default which is port 80. Then we will create a new index.html file. The file will contain code to display the public IP of the EC2 instance. We will then override the Apache webserver's default html file with our new file.

### Configuring Apache to Serve content on port 8000:

      1. Using your text editor(eg vi, nano) open the file /etc/apache2/ports.conf

          `sudo nano /etc/apache2/ports.conf`

      2. Add a new Listen directive for port 8000, Then save your file.

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/dda79b0d-dbd4-4637-afdd-fc1f88198182)

    3. Next open the file /etc/apache2/sites-available/000-default.conf and change port 80 on the virtualhost to 8000 like the screenshot below:

    `sudo nano /etc/apache2/sites-available/000-default.conf`

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/56890167-deaa-42ed-8039-20e79293c2f4)

    4. Save and Close the file by pressing `CTL + O`, then press the return key or Enter key, then press `CTL + X` to exit

    5. Restart Apache to load the new configuration using the command below:

        `sudo systemctl restart apache2`

### Creating our new HTML file:

    1. Open a new index.html file with the command below:

        `sudo nano index.html`

    2. Before pasting the HTML file, get the public IP of your EC2 instance from the AWS Management Console and replace the placeholder text for the IP address in the HTML file.

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/56d95f41-a622-4927-949f-756203ac0fe2)

    3. Change file ownership of the index.html file with the command below:

      `sudo chown www-data:www-data /index.html`

### Overriding the Default HTML file of Apache Webserver:

    1. Replace the default HTML file with our new HTML file using the command below:

        `sudo cp -f ./index.html /var/www/html/index.html`

    2. Restart the webserver to load the new configuration using the command below:

      `sudo systemctl restart apache2`

    3. You should find a page on the browser like so:

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/0cc7462a-7fbc-44b1-98cb-eb46f9f40a7d)

**NOTE: We repeated the same process on webserver2, and we should find a page on the browser like so:**

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/b0dbd254-8592-4b7f-ac46-c64e8f3eb768)

**Step 5**: Configuring Nginx as a Load Balancer

    • Provision a new EC2 instance running Ubuntu 22.04. Make sure port 80 is opened to accept traffic from anywhere.
    • Next SSH into the instance.
    • Install Nginx into the instance using the command below:

        `sudo apt update -y && sudo apt install nginx -y`


![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/027841b5-f33b-4254-bfb2-bbc9958a9d88)

    • Verify that Nginx is installed with the command below:

      `sudo systemctl status nginx`

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/25f0f245-7a48-4732-b4a8-b4a74b086d80)

    • Open the Nginx configuration file with the command below:

      `sudo nano /etc/nginx/conf.d/loadbalancer.conf`

    • Paste the configuration file below to configure nginx to act like a load balancer. A screenshot of an example config file is shown below:
        Make sure you edit the file and provide necessary information like your server IP address etc.

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/f3abc1cf-9403-4a32-a760-e7a74d279792)

**Note**: upstream `backendservers` defines a group of backend servers. The server lines inside the upstream block list the addresses and ports of your backend servers. `proxy_pass` inside the location block sets up the load balancing, passing the requests to the backend servers.
The `proxy_set_header` lines pass necessary headers to the backend servers to correctly handle the requests

    • Test your configuration with the command below:

      `sudo nginx -t`

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/6d714b4a-dc4c-4c44-b2f2-e0383e531337)

    • If there are no errors, restart Nginx to laod the new configuration with the command below:
        `sudo systemctl restart nginx`

    • Paste the public IP address of Nginx load balancer, you should see the same webpages served by the webservers.

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/6c0482c5-f34c-4d58-9512-77585630817a)

![Image](https://github.com/tochinicky/loadbalancer_nginx/assets/29289689/b7b77aba-5f16-4495-ab8f-1a1cbab34469)

**Note**: From the 2 above images, Nginx uses a **Round Robin** algorithm that distributes requests sequentially to each server in the pool. It is simple to implement and ensures an even distribution of traffic. It works well when all servers have similar capabilities and resources.

# THINGS TO NOTE ON LOAD BALANCING ALGORITHM

Load balancer algorithms are techniques used to distribute incoming network traffic or workload across multiple servers, ensuring efficient utilization of resources and improving overall system performance, reliability, and availability. Here are some common load balancer algorithms:

1. **Round Robin**: This algorithm distributes requests sequentially to each server in the pool. It is simple to implement and ensures an even distribution of traffic. It works well when all servers have similar capabilities and resources.
2. **Least Connections**: This algorithm routes new requests to the server with the least number of active connections. It is effective when servers have varying capacities or workloads, as it helps distribute traffic to the least busy server.
3. **Weighted Round Robin**: Similar to the Round Robin algorithm, servers are assigned different weights based on their capabilities.
   Servers with higher capacities receive more requests. This approach is useful when servers have varying capacities or performance
   levels.
4. **Weighted Least Connections**: Similar to the Least Connections algorithm, servers are assigned different weights based on their capabilities. Servers with higher capacities receive more connections. This approach balances traffic based on server capacities.
5. **IP Hash**: This algorithm uses a hash function based on the client's IP address to consistently map the client to a specific server. This ensures that the same client always reaches the same server, which can be helpful for maintaining session data or stateful connections.
