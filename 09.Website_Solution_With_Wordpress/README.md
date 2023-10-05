# Implementing-Wordpress-Web-Solution

## Understanding 3 Tier Architecture

### Three-tier Architecture

Generally, web, or mobile solutions are implemented based on what is called the **Three-tier Architecture**.

**Three-tier Architecture** is a client-server software architecture pattern that comprise of 3 separate layers.

![](https://github.com/tochinicky/Devops_project/assets/29289689/aa04915a-342d-40d8-aa5f-f921df393be6)

1. **Presentation Layer (PL)**: This is the user interface such as the client server or browser on your laptop.
2. **Business Layer (BL)**: This is the backend program that implements business logic. Application or Webserver
3. **Data Access or Management Layer (DAL)**: This is the layer for computer data storage and data access. Database Server or File System Server such as FTP server, or NFS Server

## STEP1 Preparing Web Server

- Create a EC2 instance server on AWS

- On the EBS console, create 3 storage volumes for the instance. This serves as additional external storage to our EC2 machine.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/3cd06e20-c44c-48d1-963b-493c34f44447)

- Attach the created volumes to the EC2 instance.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/6dc28c9d-df36-4542-8513-531f5f2f43e6)

- SSH into the instance and on the EC2 terminal, view the disks attached to the instance. This is achieved using the lsblk command.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/a8847014-8295-41b3-b632-308fdbb59b4f)

- To see all mounts and free spaces on our server.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/7a4f6912-bae7-4746-bb6f-6a4b159095d4)

- Create single partitions on each volume on the server using `gdisk`

![image](https://github.com/tochinicky/Devops_project/assets/29289689/4af732da-bd18-427c-bf47-4543272f16be)
![image](https://github.com/tochinicky/Devops_project/assets/29289689/7916d470-6fed-4147-97ca-8381b44444f0)

- Installing LVM2 package for creating logical volumes on a linux server.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/82945d01-ebb2-4daf-be87-d21e04f17932)

- Creating Physical Volumes on the partitioned disk volumes

          `sudo pvcreate <partition_path>`

  ![image](https://github.com/tochinicky/Devops_project/assets/29289689/c50f24d2-ad86-4c3d-8562-ddf507c19b1a)

- Next we add up each physical volumes into a volume group

        `sudo vgcreate <grp_name> <pv_path1> ... <pv_path1000>`

![image](https://github.com/tochinicky/Devops_project/assets/29289689/4e83c666-dd1c-4d9d-9398-2440b4e7b813)

- Creating Logical volumes for the volume group

  `sudo lvcreate -n <lv_name> -L <lv_size> <vg_name>`

![image](https://github.com/tochinicky/Devops_project/assets/29289689/b85cc51a-8d47-4e81-9a8c-f953395e8b2a)

- Our logical volumes are ready to be used as filesystems for storing application and log data.

- Creating filesystems on both logical volumes

![image](https://github.com/tochinicky/Devops_project/assets/29289689/e842d8a6-7686-4e72-934c-d608b2ccebfa)

- The apache webserver uses the html folder in the var directory to store web content. We create this directory and also a directory for collecting log data of our application.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/ec6ac1f2-2ee5-423b-8927-37e33f2bc308)

- For our filesystem to be used by the server we mount it on the apache directory . Also we mount the logs filesystem to the log directory

![image](https://github.com/tochinicky/Devops_project/assets/29289689/0063451b-b35e-4ae7-85ec-247789e2b865)

- Mount logs logical volume to var logs

![image](https://github.com/tochinicky/Devops_project/assets/29289689/d1781b9a-1963-42f9-a9e1-1ad12011d58c)

- Restoring back var logs data into var logs

![image](https://github.com/tochinicky/Devops_project/assets/29289689/f8528324-9b34-414f-a979-3de7020efcce)

# Persisting Mount Points

- To ensure that all our mounts are not erased on restarting the server, we persist the mount points by configuring the /etc/fstab directory

- `sudo blkid` to get UUID of each mount points

![image](https://github.com/tochinicky/Devops_project/assets/29289689/fc5e7dc7-edc6-4227-a5cd-90cdaacd81f9)

- `sudo vi /etc/fstab` to edit the file.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/971a9f8f-caef-45ca-9eb8-d7495798d747)

- testing mount point persistence

![image](https://github.com/tochinicky/Devops_project/assets/29289689/560c426e-f4f1-40c9-8f87-8d614aff591b)

# STEP2 Preparing DataBase Server

- Launch a second RedHat EC2 instance that will have a role - 'DB Server' Repeat the same steps as for the Web Server, but instead of `apps-lv` create `db-lv` and mount it to `/db` directory instead of /var/www/html/

# STEP3 Install Wordpress on Web Server Ec2

- Run updates and install httpd on web server

  `sudo yum -y update`

  `sudo yum -y install wget httpd php php-mysqlnd php-fpm php-json`

- Start web server

![image](https://github.com/tochinicky/Devops_project/assets/29289689/605be91a-52f2-4c51-bd93-36c713bc28ec)

- Installing php and its dependencies

      sudo yum install https://dl.fedoraproject.org/pub/epel/         epel-release-latest-8.noarch.rpm

      sudo yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

      sudo yum module list php
      sudo yum module reset php

      sudo yum module enable php:remi-7.4

      sudo yum install php php-opcache php-gd php-curl php-mysqlnd

      sudo systemctl start php-fpm

      sudo systemctl enable php-fpm
      sudo setsebool -P httpd_execmem 1

- Restarting Apache: `sudo systemctl restart httpd`

- Downloading wordpress and moving it into the web content directory

        mkdir wordpress
        cd   wordpress
        sudo wget http://wordpress.org/latest.tar.gz
        sudo tar xzvf latest.tar.gz
        sudo rm -rf latest.tar.gz
        sudo cp wordpress/wp-config-sample.php  wordpress/wp-config.php
        sudo cp -R wordpress /var/www/html/

- Configure SELinux Policies

      sudo chown -R apache:apache /var/www/html/wordpress
      sudo chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R
      sudo setsebool -P httpd_can_network_connect=1

# STEP4 Installing MySQL on DB Server

        sudo yum -y update
        sudo yum install mysql-server

To ensure that database server starts automatically on reboot or system startup

        sudo systemctl restart mysqld
        sudo systemctl enable mysqld

# STEP5 Configure Db to work with WordPress

![image](https://github.com/tochinicky/Devops_project/assets/29289689/08bece74-29d6-486a-9c4f-ba32aaff5224)

- Ensure that we add port 3306 on our db server to allow our web server to access the database server.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/16943fe7-5a7a-4170-9a84-e9f946ae155a)

# Connecting Web Server to DB Server

- Installing MySQL client on the web server so we can connect to the db server

      sudo yum install mysql
      sudo mysql -u admin -p -h <DB-Server-Private-IP-address>

![image](https://github.com/tochinicky/Devops_project/assets/29289689/e0aad841-fd60-4fd6-8b08-c040eb5bd6db)

- On the web browser, access web server using the public ip address of the server.

Note that since it is being accessed via http, we need to open port 80 in our firewall on the web server EC2 instance.

![image](https://github.com/tochinicky/Devops_project/assets/29289689/cc069f37-c9e1-4ee0-825e-81d24f9ab3bb)

![image](https://github.com/tochinicky/Devops_project/assets/29289689/c77d0859-7afc-4791-8aa7-fecb9c5f445b)

### CONGRATULATIONS!

We have learned how to configure Linux storage susbystem and have also deployed a full-scale Web Solution using WordPress CMS and
MySQL RDBMS!
