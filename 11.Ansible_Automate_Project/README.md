# Ansible Automate Project

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/e51e1366-65b1-4ac7-93a6-dfd97eb88033)

We can use the following link to install jenkins in a Redhel server in AWS EC2 instance [here](https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/)

But we are using `Ubuntu`[here](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu) for the jenkins-ansible project

# Installing Ansible on Jenkins Server

We install ansible on our jenkins server and rename it to `Jenkins-Ansible`

    sudo apt update

    sudo apt install ansible

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/a222c414-14ff-4ab0-b9f5-e7161b521795)

Create a new repository called `ansible-config-mgt` on github and set up webhooks on it.

`https://<jenkins_url:port/github-webhooks>`

On the Jenkins server, create a job called `ansible` and configure automatic builds when a trigger is made on the `ansible-config-mgt` directory via GITScm polling.

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/3277043f-b81a-4003-a739-cc85e89f2cb8)

Test configuration by updating a README file on github.

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/987eb5d2-fcae-4f48-94a6-6cf8975e43ab)

# Prepare Development using VSCode

Download and install vscode which will be used to write and edit code.

# Ansible Configuration

Clone `ansible-config-mgt` repo on local machine and create a new branch for development

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/53e63b0e-9156-4c96-a4e7-bda007859e24)

- Create a playbooks directory for storing playbooks
- Create an inventory directory for storing inventory files
- In the playbooks folder, create a common.yml file
- In the inventory folder, create dev.yaml, prod.yaml, staging.yaml and uat.yaml for dev, prod, staging and uat environments respectively.

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/68e6f621-79b0-42d9-b075-7f60d242c3c7)

# Setting Up Inventory

we create inventories to execute Linux commands on remote hosts, and ensure that it is the intended configuration on a particular server that occurs. It is important to have a way to organize our hosts in such an Inventory.

## updating our /inventory/dev.yaml

    [nfs]
    <NFS-Server-Private-IP-Address> ansible_ssh_user='ec2-user'

    [webservers]
    <Web-Server1-Private-IP-Address> ansible_ssh_user='ec2-user'
    <Web-Server2-Private-IP-Address> ansible_ssh_user='ec2-user'

    [db]
    <Database-Private-IP-Address> ansible_ssh_user='ubuntu'

    [lb]
    <Load-Balancer-Private-IP-Address> ansible_ssh_user='ubuntu'

# Creating a Common Playbook

## Update code in /playbooks/common.yaml

    ---
    - name: update web, nfs servers
      hosts: webservers, nfs
      remote_user: ec2-user
      become: true
      become_user: root
      tasks:
        - name: ensure wireshark is at the latest version
          yum:
          name: wireshark
          state: latest

    - name: update LB and db server
      hosts: lb,db
      remote_user: ubuntu
      become: true
      become_user: root
      tasks:
        - name: Update apt repo
          apt:
          update_cache: yes

        - name: ensure wireshark is at the latest version
          apt:
          name: wireshark
          state: latest

Next push code into repository and create a pull request to the main branch. Jenkins checkout the code and builds an artifact that is published on the ansible server.

![image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/e758d349-c835-474a-858f-c0bf20688547)

We need to ssh into our target servers defined in the /inventory/dev.yaml

using SSH-Agent to upload our ssh public key to the jenkins-ansible server

    eval `ssh-agent -s`
    ssh-add <path-to-private-key>

**Note: The path to the private key is where we downloaded the key on the local machine.**

Confirm the key has been added with the command below, you should see the name of your key.

    ssh-add -l

Now, ssh into the Jenkins-Ansible server using ssh-agent.

    ssh -A ubuntu@public-ip

# RUN FIRST ANSIBLE TEST

The below command should be executed on the jenkin-ansible server after ssh into the server:

    ansible-playbook -i /var/lib/jenkins/jobs/ansible/builds/<build-number>/archive/inventory/dev.yam  /var/lib/jenkins/jobs/ansible/builds/<build-number>/archive/playbooks/common.yaml

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/d9b16969-d6cc-4b88-ac67-0e7c0f7c8612)
