# Terraform-Ansible-Example
------
Quick guide to how to provision with Ansible in Terraform, in this example I'll be spinning an ec2 mahcine (ubuntu) using Terraform and provisioning it with Ansible to install ngnix.

## Prerequisite
- Anisble ([installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
- Terraform ([instlalltion](https://www.terraform.io/intro/getting-started/install.html))
- AWS account with IAM setup to create/modify resource ([To create access and secret key](https://aws.amazon.com/iam/?sc_channel=PS&sc_campaign=acquisition_US&sc_publisher=google&sc_medium=iam_b&sc_content=aws_iam_p&sc_detail=aws%20iam&sc_category=iam&sc_segment=208382128927&sc_matchtype=p&sc_country=US&s_kwcid=AL!4422!3!208382128927!p!!g!!aws%20iam&ef_id=WZEyFgAAATvt6PWy:20180622154740:s))

PS: You may get charged for creating instances over AWS, so please do take note of that, and I'm not responsible for any changes occurred.

Once you have installed Ansible, Terraform and setup an access and secret key, follow below setps

1) Create a private key which will be attached to instance created and will be used to ssh to box and provision using Ansible.
 a) Create a directory and a key using below command 
   ```sh
   $ mkdir ssh_keys && cd ssh_keys
   $ ssh-keygen -t rsa -C "tmp-key" -P '' -f ssh_keys/tmp-key
   ```
2) Modify ``vars.tfvars`` and update replace below variables with your access and secret keys
    - access_key
    - secret_key
3) Execute  below command to initialize/download Terraform modules, like in our case aws modules
    ```sh
    $ terraform init
    ```
     On executing above you should see below output
    >Initializing provider plugins...
    Checking for available provider plugins on https://releases.hashicorp.com...
    Downloading plugin for provider "aws" (1.24.0)...
The following providers do not have any version constraints in configuration,
so the latest version was installed.
To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.
 provider.aws: version = "~> 1.24"
Terraform has been successfully initialized!
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
4) Once all the require modules have been downloaded, let's see what Terraform will do for us by executing below command 
    ```sh
    terraform plan -var-file="vars.tfvars"
    ```
    On executing above command, you should see below 
    > Refreshing Terraform state in-memory prior to plan...
    > The refreshed state will be used to calculate this plan, but will not be
peristed to local or remote state storage.
    ...
    ...
    ...
    Plan: 3 to add, 0 to change, 0 to destroy.

Above output displays what all resources Terraform will create.     

5) Now its time to unleash Terraform to create resources
    ```sh
    $ terraform apply -var-file="vars.tfvars"
    ```
    The above command will create an aws machine and install nginx using Ansible, it will also write the public ip to access crated instance to a file `ip_address.txt`
To verify stuffs, just copy the ip address from `ip_address.txt` file and paste it browser and you should see nginx welcome page.

6) To destroy infra you've just created, just type in below command
    ```sh
    $ terraform destroy -var-file="vars.tfvars"
    ```
    
