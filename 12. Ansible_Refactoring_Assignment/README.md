# Jenkins CI/CD on a 3-tier application && Ansible Configuration Management Dev and UAT servers using Static Assignments

## Ansible Refactoring and Static Assignments (IMPORTS AND ROLES)

In the previous project, I implemented CI/CD and Configuration Managment solution on the Development Servers using Ansible [Ansible_Automate_Project](https://github.com/tochinicky/Devops_project/tree/main/11.Ansible_Automate_Project).

**In this project, I will be extending the functionality of this architecture and introducing configurations for UAT environment.**

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/89a906a7-7002-4f74-9828-56b3490bf3fc)

## STEP 1 - Jenkins Job Enhancement

Install a plugin on Jenkins-Ansible server called `COPY-ARTIFACTS.`

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/b1643149-c439-48a7-b5c5-9af1c369441d)

On the Jenkins-Ansible server, create a new directory called `ansible-config-artifact`

    sudo mkdir /home/ubuntu/ansible-config-artifact

Change permission of the directory

    sudo chmod -R 0777 /home/ubuntu/ansible-config-artifact/

Create a new Freestyle project on Jenkins and name it `save_artifacts.`

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/c55dd1d5-f8a1-40c6-9009-bd07c74c868d)

This project will be triggered by completion of your existing ansible project. Configure it accordingly:

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/a032a0a5-43c2-4f64-b24c-26f565502705)
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/a3000af5-0b50-4320-b5d4-94872ddfc784)
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/4d11a94e-516a-42b4-a16e-bb8a382839dd)

We configured the number of build to 2. This is useful because whenever the jenkins pipeline runs, it creates a directory for the artifacts and it takes alot of space. By specifying the number of build, we can choose to keep only 2 of the latest builds and discard the rest.

Test your set up by making some change in `README.md` file inside your ansible-config-mgt repository (right inside master/main branch).

If both Jenkins jobs have completed one after another – you shall see your files inside `/home/ubuntu/ansible-config-artifact` directory and it will be updated with every commit to your master/main branch.

Now your Jenkins pipeline is more neat and clean.
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/d23d6d5c-a830-4cdb-a924-50cb2b02811e)

## Step 2 – Refactor Ansible code by importing other playbooks into site.yaml

In [Project 11](https://github.com/tochinicky/Devops_project/tree/main/11.Ansible_Automate_Project) , I wrote all tasks in a single playbook common.yaml, now it is pretty simple set of instructions for only 2 types of OS, but imagine you have many more tasks and you need to apply this playbook to other servers with different requirements. In this case, you will have to read through the whole playbook to check if all tasks written there are applicable and is there anything that you need to add for certain server/OS families. Very fast it will become a tedious exercise and your playbook will become messy with many commented parts. Your DevOps colleagues will not appreciate such organization of your codes and it will be difficult for them to use your playbook.

- In playbooks folder, create a new file and name it site.yaml – This file will now be considered as an entry point into the entire infrastructure configuration.

- Create a new folder in root of the repository and name it static-assignments. The static-assignments folder is where all other children playbooks will be stored.

- Move common.yaml file into the newly created static-assignments folder.

- Inside site.yaml file, import common.yaml playbook.
  ![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/c6ff05da-02ff-4a4f-820e-5603a89d6785)

- Run ansible-playbook command against the dev environment.

- create another playbook under static-assignments and name it common-del.yaml. In this playbook, configure deletion of wireshark utility.

      ---
      - name: update web, nfs and db servers
        hosts: webservers, nfs, db
        remote_user: ec2-user
        become: yes
        become_user: root
        tasks:
        - name: delete wireshark
          yum:
            name: wireshark
            state: removed

      - name: update LB server
        hosts: lb
        remote_user: ubuntu
        become: yes
        become_user: root
        tasks:
        - name: delete wireshark
          apt:
            name: wireshark-qt
            state: absent
            autoremove: yes
            purge: yes
            autoclean: yes

- We update site.yaml with `- import_playbook: ../static-assignments/common-del.yaml` instead of common.yml and run it against dev servers

        cd /home/ubuntu/ansible-config-mgt/


        ansible-playbook -i inventory/dev.yaml playbooks/site.yaml

**Note: use the ssh-agent configured to access the host**
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/f59e7015-57bd-4883-b37c-10739886418e)

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/1afe5aa3-10e6-4e86-baaa-f523642f4fb9)

- Make sure that wireshark is deleted on all the servers by running wireshark --version
  ![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/6397a9ed-8ba5-4fe2-bb25-53a0a853b487)

# CONFIGURE UAT WEBSERVERS WITH A ROLE ‘WEBSERVER’

## Step 3 – Configure UAT Webservers with a role ‘Webserver’

- Launch 2 fresh EC2 instances using RHEL 8 image, we will use them as our uat servers, so give them names accordingly – Web1-UAT and Web2-UAT.

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/9bd25f39-b4aa-404d-bb54-81edb8c50076)

- Create a role using an Ansible utility called ansible-galaxy inside ansible-config-mgt/roles directory (you need to create roles directory upfront)

There are two ways how you can create this folder structure:

- Use an Ansible utility called ansible-galaxy inside ansible-config-mgt/roles directory

      mkdir roles
      cd roles
      ansible-galaxy init webserver

- Create the directory or files structure manually

**Note:** You can choose either way, but since you store all your codes in GitHub, it is recommended to create folders and files there rather than locally on Jenkins-Ansible server.

- removing unnecessary directories and files, the roles structure should look like this

        └── webserver
            ├── README.md
            ├── defaults
            │   └── main.yml
            ├── handlers
            │   └── main.yml
            ├── meta
            │   └── main.yml
            ├── tasks
            │   └── main.yml
            └── templates

- Update your inventory `ansible-config-mgt/inventory/uat.yaml` file with IP addresses of your 2 UAT Web servers

        [uat-webservers]
        <Web1-UAT-Server-Private-IP-Address> ansible_ssh_user='ec2-user'

        <Web2-UAT-Server-Private-IP-Address> ansible_ssh_user='ec2-user'

- In `/etc/ansible/ansible.cfg` file uncomment `roles_path` string and provide a full path to your roles directory `roles_path    = /home/ubuntu/ansible-config-mgt/roles`, so Ansible could know where to find configured roles.

**Note:** By default, ansible will be using the default settings. However, i created an ansible config file so that it can be used going forward.

        sudo mkdir /etc/ansible

        sudo touch /etc/ansible/ansible.cfg

Then we can set the role_path in the config like this:
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/c27acd2c-a504-4224-830b-e99a22d2d5e9)

It is time to start adding some logic to the webserver role. Go into configuration tasks directory, and within the `main.yaml` file, start writing configuration tasks to do the following:

- Install and configure Apache (`httpd` service)
- Clone Tooling website from GitHub `https://github.com/<your-name>/tooling.git`
- Ensure the tooling website code is deployed to /var/www/html on each of 2 UAT Web servers.
- Make sure `httpd` service is started

Add the following to the main.yaml of the webserver role

     ---
     - name: install apache
       become: true
       ansible.builtin.yum:
       name: "httpd"
       state: present

     - name: install git
       become: true
       ansible.builtin.yum:
       name: "git"
       state: present

    - name: clone a repo
      become: true
      ansible.builtin.git:
      repo: https://github.com/<your-name>/tooling.git
      dest: /var/www/html
      force: yes

    - name: copy html content to one level up
      become: true
      command: cp -r /var/www/html/html/ /var/www/

    - name: Start service httpd, if not started
      become: true
      ansible.builtin.service:
      name: httpd
      state: started

    - name: recursively remove /var/www/html/html/ directory
      become: true
      ansible.builtin.file:
      path: /var/www/html/html
      state: absent

# REFERENCE WEBSERVER ROLE

## Step 4 – Reference ‘Webserver’ role

Within the `static-assignments` folder, create a new assignment for uat-webservers uat-webservers.yaml. This is where you will reference the role.

     ---
     - hosts: uat-webservers
       roles:
         - webserver

Since the entry point to our ansible configuration is the `site.yaml` file. Therefore, you need to refer your `uat-webservers.yaml` role inside `site.yaml`.

So, we should have this in site.yaml:

    ---
    - hosts: all
    - import_playbook: ../static-assignments/common.yaml

    - hosts: uat-webservers
    - import_playbook: ../static-assignments/uat-webservers.yaml

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/44537a1c-05b7-4d00-a394-acf9c715d6ff)

- Commit your changes, create a Pull Request and merge them to main branch, make sure webhook triggered two consequent Jenkins jobs, they ran successfully and copied all the files to your Jenkins-Ansible server into `/home/ubuntu/ansible-config-mgt/` directory.
  ![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/51032dbc-69c3-4221-896e-52b5096bf3c3)

Now run the playbook against your uat inventory and see what happens:

    sudo ansible-playbook -i /home/ubuntu/ansible-config-mgt/inventory/uat.yaml /home/ubuntu/ansible-config-mgt/playbooks/site.yaml

Test the webserver configurations on the browser
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/4ec73c7d-1ac8-4f45-bd57-0047fb1670ce)
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/808b3642-aefb-4864-a642-a3fa1961455b)

Note: We opened port 80 to accept http requests from our Inbound rule:
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/f71a4d8c-fe8d-4ff6-8a65-d38acc06c7d0)

In conclusion, this project demonstrates a comprehensive approach to CI/CD and Configuration Management, expanding from Development to UAT environments. The process involves the integration of Jenkins and Ansible to automate tasks and deploy artifacts.

Key Steps:

1. **Jenkins Job Enhancement**:

   - Installed the `COPY-ARTIFACTS` plugin for Jenkins to manage artifacts.
   - Created a designated directory for artifacts and configured permissions.
   - Set up a new Freestyle project named `save_artifacts` for managing artifacts.
   - Configured the project to trigger upon completion of the existing ansible project, and limited the number of builds to maintain a clean pipeline.

2. **Refactoring Ansible Code**:

   - Refactored the Ansible code by introducing `site.yaml` as an entry point for the entire infrastructure configuration.
   - Created a new folder named `static-assignments` to store additional playbooks.
   - Imported the existing `common.yaml` playbook into `site.yaml`.
   - Introduced a new playbook, `common-del.yaml`, to handle the deletion of the Wireshark utility.

3. **Configuring UAT Webservers with a Role ‘Webserver’**:

   - Launched two fresh EC2 instances for UAT servers, ensuring they were named appropriately.
   - Created a role named `webserver` using `ansible-galaxy` utility.
   - Developed configuration tasks within the `main.yaml` file of the `webserver` role to install Apache, clone a GitHub repository, and deploy the website code to the appropriate directory.
   - Started the `httpd` service and removed unnecessary directories.

4. **Referencing the ‘Webserver’ Role**:
   - Created a new assignment file, `uat-webservers.yaml`, within the `static-assignments` folder to reference the `webserver` role.
   - Included the `uat-webservers.yaml` role inside the main `site.yaml` file.

By following these steps, the project achieves a seamless flow from CI/CD to Configuration Management, extending functionality to the UAT environment. The integration of Jenkins and Ansible streamlines the deployment process and ensures consistency across different environments.
