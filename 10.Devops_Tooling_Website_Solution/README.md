# DevOps-Website-Solution

In the previous project [Website_Solution_With_Wordpress](https://github.com/tochinicky/Devops_project/tree/main/09.Website_Solution_With_Wordpress), we implemented a WordPress-based solution ready to be filled with content. It can be used as a full-fledged website or blog. In this project, I will add more value to my solution so that a member of a DevOps team could utilize it.

In this project, I will introduce the concept of file sharing for multiple servers to share the same web content and also a database for storing website-related data.

## Architectural Design

In the diagram below, you can see a common pattern where several stateless Web Servers share a common database and access the same files using Network File System (NFS) as shared file storage. Even though the NFS server might be located on completely separate hardware, for Web Servers, it looks like a local file system from where they can serve the same files.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/f55e7618-2cd2-4774-8753-5f1ff3df77cb)

This project consists of the following servers:

- Web server(RHEL)
- Database server(Ubuntu + MySQL)
- Storage/File server(RHEL + NFS server)

# Implementing a Business Website using NFS for Backend File Storage

## Preparing NFS Server

Create an EC2 instance (Red Hat Enterprise Linux 8 on AWS) on which we will set up our NFS (Network File Storage) Server.

On this server, attach 2 EBS volumes, each 10GB, as external storage to our instance. Create 3 logical volumes on it through which we will attach mounts from our external web servers.

Based on our LVM experience from [Website_Solution_With_Wordpress](https://github.com/tochinicky/Devops_project/tree/main/09.Website_Solution_With_Wordpress), Configure LVM on the Server.

- Ensure there are 3 logical volumes `lv-opt`, `lv-apps` and `lv-logs`

- Create mount points on `/mnt` directory for the logical volumes as follows:
  - Mount `lv-apps` on `/mnt/apps` - To be used by webservers.
  - Mount `lv-logs` on `/mnt/logs` to be used by webserver logs.
  - Mount `lv-opt` on `/mnt/opt`to be used by Jenkins server in later project

Install `nfs-server` on the NFS instance and ensure that it starts on system reboot.

    sudo yum -y update
    sudo yum install nfs-utils -y
    sudo systemctl start nfs-server.service
    sudo systemctl enable nfs-server.service
    sudo systemctl status nfs-server.service

![image](https://github.com/tochinicky/Devops_project/assets/29289689/99fffb3e-b806-46c9-beff-76128facb5bc)

Set the mount point directory to allow read and write permissions to our webserver.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/d1d50a06-6955-41e3-b3f5-4846f3fbba93)

Restart NFS server `sudo systemctl restart nfs-server`

**Note: In this project, we will be creating our NFS server, web servers, and database server all in the same subnet. In production, we would probably want to separate each tier inside its own subnet for a higher level of security.**

Next, we configure NFS to interact with clients present in the same subnet.

We can find the subnet ID and CIDR in the Networking tab of our instances.
![image](https://github.com/tochinicky/Devops_project/assets/29289689/c1404223-8558-4aad-ad76-fb306f6adc8e)
![image](https://github.com/tochinicky/Devops_project/assets/29289689/f8cc5d47-ce6d-4eb4-b0dd-4ccf0ef80f28)

Configure access to NFS for clients within the same subnet (example of Subnet CIDR - 172.31.32.0/20 ):

    sudo vi /etc/exports

    On the vim editor add the lines as seen in the image below

    sudo exportfs -arv

![image](https://github.com/tochinicky/Devops_project/assets/29289689/5c6c1252-5a1e-4bdb-a931-b2ec38833124)

To check which port is used by NFS and open it using Security Groups (add new Inbound Rule).

    rpcinfo -p | grep nts

![image](https://github.com/tochinicky/Devops_project/assets/29289689/68c83945-7a6b-4649-b8ff-e733d504597b)

**Important note: In order for NFS server to be accessible from client, you must also open the following ports: TCP 111, UDP 111, UDP 2049**

![image](https://github.com/tochinicky/Devops_project/assets/29289689/6113c0d5-a39c-4d48-bc58-52a7d405152d)

# Configure Backend Database as Part of 3 Tier Architecture

## Configure the Database Server

Create an Ubuntu Server on AWS which will serve as our Database. Ensure it's in the same subnet as the NFS Server.

- Install `mysql-server`

       sudo apt -y update
       sudo apt install -y mysql-server

To enter the database environment, run:

        sudo mysql

- Create a database and name it `tooling`
- Create a database user and name it `webaccess`
- Grant permission to `webaccess` user on `tooling`database to do anything only from the webservers subnet CIDR.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/76096deb-a653-4838-891c-d071d66a80ca)

**Note: Open port 3306 on the AWS EC2 instance Database server which allows for connection. Both servers can communicate using private IPs since they belong to the same subnet**

Change bind-address on Mysql-server to allow for connection from any IP address. Set the bind address to 0.0.0.0 using the command below:

    sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo systemctl restart mysql

# Preparing Web Servers

Create a RHEL EC2 instance on AWS which serves as our web server. Also remember to have in the same subnet.

A couple of configurations will be done on the web servers:

- configuring NFS client
- deploying tooling website application
- configure servers to work with database

### Installing NFS-Client

        sudo yum install nfs-utils nfs4-acl-tools -y

![image](https://github.com/tochinicky/Devops_project/assets/29289689/200a80e4-ccdc-474e-94ac-6926be47ebde)

We will be connecting our `/var/www` directory to our webserver with the `/mnt/apps` on NFS server. This is acheived by mounting the NFS server directory to the webserver directory.

    sudo mkdir /var/www
    sudo mount -t nfs -o rw,nosuid <NFS-Server-Private-IP-Address>:/mnt/apps /var/www

![image](https://github.com/tochinicky/Devops_project/assets/29289689/124d4239-dd48-466b-a3e6-a29b9e11a988)

We then need to ensure that our mounts remain intact when the server reboots. This is achieved by configuring the `fstab` directory.

    sudo vi /etc/fstab

Add the following line `<NFS-Server-Private-IP-Address>:/mnt/apps /var/www nfs defaults 0 0`

![image](https://github.com/tochinicky/Devops_project/assets/29289689/52b12e75-a83a-4c7d-ad4e-152ce3d78758)

### Installing Apache and Php

    sudo yum install httpd -y

    sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

    sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

    sudo dnf module reset php

    sudo dnf module enable php:remi-7.4

    sudo dnf install php php-opcache php-gd php-curl php-mysqlnd

    sudo systemctl start php-fpm

    sudo systemctl enable php-fpm

    sudo setsebool -P httpd_execmem 1

We can see that both `/var/www` and `/mnt/apps` contain the same content. This shows that both mount points are connected via NFS.
![image](https://github.com/tochinicky/Devops_project/assets/29289689/eb13bbfb-c929-48a1-8250-6cad6751165d)
![image](https://github.com/tochinicky/Devops_project/assets/29289689/01030e4f-251c-47a3-b807-1f951d59ed8b)

We locate the log folder for Apache on the Web Server and mount it to NFS server’s export for logs. Make sure the mount point will persist after reboot.
![image](https://github.com/tochinicky/Devops_project/assets/29289689/09dfc458-ec97-441e-b950-92b943b4539e)

On the `/etc/fstab` persist log mount point using this command:

    sudo vi /etc/fstab

![image](https://github.com/tochinicky/Devops_project/assets/29289689/3a17a658-471b-426d-b9b1-c3a53dbd14c7)

On the NFS Server, add web content into the `/mnt/apps` directory. This should contain an html folder. The same content will be present in the `/var/www` directory on the web server.

Fork [Darey.io Github Account](https://github.com/darey-io/tooling) repository to our Github Account. The reason behind this is to have web content that we can deploy.

Now, the way i added the web content on the NFS server was by cloning the above repository by installing git on the NFS server. Then, i moved the contents to `/mnt/apps` which will automatically be present in the `/var/www` directory on the web server.

In the `/var/www/html` directory , edit the already written php script to connect to the database `sudo vi /var/www/html/functions.php`. The "functions.php" was part of what we cloned from the above repository.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/27ff53bb-4422-4718-bbba-ccb1a5af78c9)

After the modification , install MySQL client on the web server by running the following command: `sudo yum install mysql`.

connect to the database server from the web server using:

     sudo mysql -h <databse-private-ip> -u <db-username> -p <db-name> < tooling-db.sql

![image](https://github.com/tochinicky/Devops_project/assets/29289689/5a64a4a2-d103-42f1-b6d4-f22eb73a8202)

The above command runs the Sql script on the database server to create table on the tooling db.

We can confirm that by checking the database server if it ran successfully:
![image](https://github.com/tochinicky/Devops_project/assets/29289689/1f4eef52-13e9-47d3-85bc-2fa0006b329d)
![image](https://github.com/tochinicky/Devops_project/assets/29289689/e0f6beca-8bc4-4998-aab5-b5bf9820e624)

We can simulate a sign-up process by adding user credentials manually to the database.
![image](https://github.com/tochinicky/Devops_project/assets/29289689/b100b6ca-04b7-4510-9828-a58c3ec69b08)

**Note TCP port 80 should be open on the web server EC2 instance.**

Run `<public_ip_address>/index.php` on a web browser to access the site. Use public IP address of the web server.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/8c4de5c8-3a02-4e77-8258-446acb2899b4)
![image](https://github.com/tochinicky/Devops_project/assets/29289689/2ab56320-dd74-4a13-aea5-fef247a33e73)

# Conclusion

In this project, we've successfully implemented a three-tier architecture for a business website using NFS for backend file storage. This architecture allows for efficient sharing of web content across multiple servers and ensures data integrity through a centralized database.

Key Achievements:

- Configured an NFS server for shared file storage, providing a seamless experience for web servers to access and serve web content.
- Established a MySQL database server, enabling the storage of website-related data and ensuring secure access from web servers.
- Set up web server with Apache and PHP, creating a robust environment for hosting the website.
- Integrated the web servers with the NFS server, ensuring consistent and reliable content delivery.

By following this guide, you've created a robust foundation for hosting web applications in a scalable and secure manner. Congratulations on a successful implementation!
