# ANSIBLE DYNAMIC ASSIGNMENTS (INCLUDE) AND COMMUNITY ROLES

In this project, we introduced the concept of the use of **Dynamic assignments**. The major difference between **static** and **dynamic assignments** is in the use of **import** and **include** statements.

When the **import** module is used, all statements are pre-processed at the time playbooks are parsed. Meaning, when you execute `site-yaml` playbook, Ansible will process all the playbooks referenced during the time it is parsing the statements. This also means that, during actual execution, if any statement changes, such statements will not be considered. Hence, it is static.

On the other hand, when **include** module is used, all statements are processed only during execution of the playbook. Meaning, after the statements are parsed, any changes to the statements encountered during execution will be used.
Take note that in most cases it is recommended to use `static assignments` for playbooks, because it is more reliable. With `dynamic` ones, it is hard to debug playbook problems due to its dynamic nature. However, you can use dynamic assignments for environment specific variables as we will be introducing in this project.

## Introducing dynamic assignment into our structure

In your `https://github.com/<your-name>/ansible-config-mgt` GitHub repository start a new branch and call it dynamic-assignments.

Create a new folder, name it dynamic-assignments . Then inside this folder, create a new file and name it `env-vars.yaml`. We will instruct `site.yaml` to include this playbook later. For now, let us keep building up the structure.

Your GitHub shall have following structure by now.

**Note:** Depending on what method you used in the previous project you may have or not have roles folder in your GitHub repository - if you used `ansible-galaxy`, then roles directory was only created on your `Jenkins-Ansible` server locally. It is recommended to have all the codes managed and tracked in GitHub, so you might want to recreate this structure manually in this case - it is up to you.

            └── dynamic-assignments
            │   └── env-vars.yaml
            ├── inventory
                └── dev
                └── stage
                └── uat
                └── prod
            ├── playbooks
            │   └── site.yaml
            ├── roles
            │   └── ...(optional subfolders & files)
            ├── static-assignments
            │   └── common.yaml

Since we will be using the same Ansible to configure multiple environments, and each of these environments will have certain unique attributes, such as `servername`, `ip-address` etc., we will need a way to set values to variables per specific environment.
For this reason, we will now create a folder to keep each environment's variables file. Therefore, create a new folder `env-vars` ,then for each environment, create new **YAML** files which we will use to set variables.

Your layout should now look like this.

            └── dynamic-assignments
            │   └── env-vars.yaml
            ├── env-vars
                └── dev.yaml
                └── stage.yaml
                └── uat.yaml
                └── prod.yaml
            ├── inventory
                └── dev
                └── stage
                └── uat
                └── prod
            ├── playbooks
            │   └── site.yaml
            ├── static-assignments
                └── common.yaml
                └── uat-webservers.yaml

Now paste the instructions below into dynamic-assignments/env-vars.yaml

        ---
        - name: collate variables from env specific file, if it exists
          hosts: all
          tasks:
            - name: looping through list of available files
              include_vars: "{{ item }}"
              with_first_found:
                - files:
                    - dev.yaml
                    - stage.yaml
                    - prod.yaml
                    - uat.yaml
                  paths:
                    - "{{ playbook_dir }}/../env-vars"
              tags:
                - always

Notice 3 things to notice here:

1. We used `include_vars` syntax instead of `include`, this is because Ansible developers decided to separate different features of the module. From Ansible version 2.8, the `include` module is deprecated and variants of `include_*` must be used. These are:
   - include_role
   - include_tasks
   - include_vars

In the same version, variants of import were also introduces, such as

- import_role
- import_tasks

2. We made use of a special variables `{{ playbook_dir }}` and `{{ inventory_file }}`. `{{ playbook_dir 3}}` will help Ansible to determine the location of the running playbook, and from there navigate to other path on the filesystem. `{{ inventory_file }}` on the other hand will dynamically resolve to the name of the inventory file being used, then append `.yaml` so that it picks up the required file within the `env-vars` folder.

3. We are including the variables using a loop. with_first_found implies that, looping through the list of files, the first one found is used. This is good so that we can always set default values in case an environment specific env file does not exist.

### Update site.yml with dynamic assignments

Update `site.yaml` file to make use of the dynamic assignment. (At this point, we cannot test it yet. We are just setting the stage for what is yet to come. So hang on to your hats).

**site.yaml** should now look like this.

        ---
        - name: Import common file
        import_playbook: ../static-assignments/common.yaml
        tags:
            - always

        - name: Include dynamic variables
        import_playbook: ../dynamic-assignments/env-vars.yaml
        tags:
            - always

        - hosts: uat-webservers
        - import_playbook: ../static-assignments/uat-webservers.yaml

**Community Roles**

Now it is time to create a role for MySQL database - it should install the MySQL package, create a database and configure users. But why should we re-invent the wheel? There are tons of roles that have already been developed by other open source engineers out there. These roles are actually production ready, and dynamic to accomodate most of Linux flavours. With Ansible Galaxy again, we can simply download a ready to use ansible role, and keep going.

**Download MySQL Ansible Role**

You can browse available community roles [here](https://galaxy.ansible.com/ui/)

We will be using a [MySQL role developed by](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/mysql/) `geerlingguy`.

**Hint:** To preserve your your GitHub in actual state after you install a new role - make a commit and push to master your 'ansible-config-mgt' directory. Of course you must have git installed and configured on Jenkins-Ansible server and for more convenient work with codes, you can configure Visual Studio Code to work with this directory.

In this case, you will no longer need webhook and Jenkins jobs to update your codes on `Jenkins-Ansible` server, so you can disable it - we will be using Jenkins later for a better purpose.

On Jenkins-Ansible server make sure that git is installed with git —version, then go to 'ansible-config-mgt' directory and run

        git init
        git pull https://github.com/<your-name>/ansible-config-mgt.git
        git remote add origin https://github.com/<your-name>/ansible-config-mgt.git
        git branch roles-feature
        git switch roles-feature

Inside `roles` directory create your new MySQL role with `ansible-galaxy install geerlingguy.mysql` and rename the folder to `mysql`

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/879dd9c3-6cbd-48db-8da3-b75f73b0fd20)

Read `README.md` file, and edit roles configuration to use correct credentials for MySQL required for the `tooling` website.

Now it is time to upload your changes to Github

    git add
    git commit -m "Commit new role files into GitHub"
    git push --set-upstream origin roles-feature

Now, if you are satisfied with your codes, you can create a Pull Request and merge it to the `main `branch on GitHub.

**Load Balancer roles**

We want to be able to choose which Load Balancer to use, `Nginx` or `Apache` ,so we need to have two roles respectively:

1. Nginx
2. Apache

![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/638bddf0-a680-4240-be19-37ccc318a0d7)

With your experience on Ansible so far you can:

- Decide if you want to develop your own roles, or find available ones from the community
- Update both `static-assignment` and `site.yaml` files to refer the roles

**Important Hints:**

- Since you cannot use both **Nginx** and **Apache** load balancer, you need to add a condition to enable either one - this is where you can make use of variables.
- Declare a variable in `defaults/main.yaml` file inside the **Nginx** and **Apache** roles. Name each variables `enable_nginx_lb` and `enable_apache_lb` respectively.
- Set both values to `false` like this `enable_nginx_lb: false` and `enable_apache_lb: false`.
- Declare another variable in both roles `load_balancer_is_required` and set its value to `false` as well
- Update both assignment and `plabooks/site.yaml` files respectively

In the static-assignments directory create a `loadbalancers.yaml` file with the following and update the `site.yaml`

    ---
    - hosts: nginx
    roles:
        - { role: nginx, when: enable_nginx_lb and load_balancer_is_required }
        - { role: apache, when: enable_apache_lb and load_balancer_is_required }

`site.yaml`

    - name: Loadbalancers assignment
      import_playbook: ../static-assignments/loadbalancers.yaml
      when: load_balancer_is_required

Now you can make use of `env-vars\uat.yaml` file to define which loadbalancer to use in UAT environment by setting respective environmental variable to `true`

You will activate load balancer, and enable `nginx` by setting these in the respective environment's env-vars file.

    enable_nginx_lb: true
    load_balancer_is_required: true

The same must work with `apache` LB, so you can switch it by setting respective environmental variable to `true` and other to `false`

To test this, you can update inventory for each environment and run Ansible against each environment.
![Image](https://github.com/tochinicky/ansible-config-mgt/assets/29289689/6654f529-1651-4407-b727-fb7c6fd9deb1)

## Conclusion

In this project, we delved into the concept of dynamic assignments in Ansible, which is a powerful way to manage the inclusion of playbooks and variables based on real-time conditions during execution. We explored the distinction between static and dynamic assignments, emphasizing how import and include statements operate differently.

The project walked through the creation of a dynamic-assignments branch on the GitHub repository and introduced a new folder named `dynamic-assignments`. Inside this folder, an `env-vars.yaml` playbook was established, which is a critical component for handling environment-specific variables.

The project underscored the importance of using dynamic assignments for environment-specific variables while maintaining static assignments for playbooks, ensuring stability and ease of debugging. The utilization of `include_vars` and special variables like `{{ playbook_dir }}` and `{{ inventory_file }}` was emphasized for effective variable handling.

The project also advised on using Git to preserve the state of the GitHub repository after introducing new roles, providing guidance on initializing a Git repository, pulling changes, and creating a new branch. The incorporation of community roles, specifically the MySQL role developed by `geerlingguy`, was highlighted as an efficient way to leverage pre-built, production-ready roles.

Furthermore, the project addressed the need for Load Balancer roles, outlining the steps to create roles for both Nginx and Apache. It introduced the concept of using conditional variables to enable or disable specific roles based on project requirements.

By the end of this project, the groundwork has been laid for implementing dynamic assignments, leveraging community roles, and introducing flexibility in load balancer choices. This approach sets the stage for managing complex configurations across multiple environments efficiently.
