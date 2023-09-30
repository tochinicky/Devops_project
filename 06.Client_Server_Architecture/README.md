# Implementing a Client-Server Architecture Using MySQL server and MYSQL client

## Project Architecture

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/fa89752d-f5f2-4261-a796-368d6d532a48)

To demonstrate Client-Server architecture we will be using two Ec2 instances with mysql-server and mysql-client respectively.

Create and configure two Linux-based virtual servers (EC2 instances in AWS).
Note: Make sure they are both in the same subnet

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/5b20e7be-54a2-4205-96c8-90f9895fe991)

On the MySQL server Linux Server install MySQL Server software.

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/ac7b0e7f-a9d5-4728-93c9-93519e174274)

Make sure MYSQL is running, you can check it by running the following command:

`sudo systemctl status mysql`

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/3f1b2468-58f2-4cda-9028-e191504ac5e7)

On the MySQL client Linux Server install MySQL Client software.

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/02ce28c4-11c2-4cad-afa1-782e0377571b)

Open port 3306 on the Mysql server allows for connection. Both servers can communicate using private IPs since they belong to the same subnet

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/bc312e69-e1a4-4711-9575-8cbb06b4ade2")

Change bind-address on Mysql-server to allow for connection from any IP address. Set the bind address to 0.0.0.0 using the command below:

`sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf`

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/87e162e0-7543-49a8-909d-3444660c4bc6)

## Configure MySQL server and create a database and user

1. Set up a password with `sudo mysql_secure_installation`

   ![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/7c4c20a4-cd3e-4cdb-b142-1bc01bf5fe2a)

We access the MySQL terminal with the following command:

`sudo mysql`

2.  Create a user

Note: The setup is done on server A which has MySQL server

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/63d68e32-bb02-446e-bc6e-3e74a0983a1d)

3. Create database

   ![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/73ab38ff-8356-400c-bb1b-602119a0ca6f)

4. Grant all permission on the database

   ![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/9ea58855-1147-482c-906b-1f3c1b575c79)

From MySQL client Linux Server we connect remotely to MySQL server Database Engine without using SSH. We use the MySQL utility to perform this action.

![Image_Alt](https://github.com/tochinicky/client_server_architecture/assets/29289689/452f125f-6d48-4a24-8d94-17650af213be)

So with the above processes, we've successfully connected to a database sitting on a remote server from a client-server.
