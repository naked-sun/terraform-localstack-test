# terraform-testapp

Terraform assignment.

## Pre-requisites

## Architecture

### Design decisions

The blackhole in the database was implemented creating a network interface without attachment and adding it as target of the general route, generating a black-hole for any traffic that is not comming from the local ip's.

### Caveats

* `LocalStack doesn't work due to the lack of ELBv2 feature in the free version.`
* S3 backed terraform state is not implemented in this excercise to avoid race conditions on stack creation, having that this may be tested in different accounts between interviewer and interviewee for the defined stacks and localstack.
In a real world scenario I would add S3 backed terraform state with dynamodb locks.
* The deployment with Ansible, while useful, might not be a compatible practice with terraform and AWS stack, I could be a cleaner implementation to rely on AMI, Snapshots and/or docker images.
* I favored using local modules over external versioned modules due to the time-contraint and to facilitate the access and reading of the excercise. In a real-world scenario I would evaluate if the modules are better to be implemented local alongside the workspaces or in a separated repository with it's own versioning and pipeline. Independent remote modules could make testing with tools like terratest easier as well.
* The S3 bucket is defined without versioning or encryption for costs reduction.
* The S3 bucket is setup with `force_destroy = true` to allow quick delete on stack destroy. In production I would add encryption and maybe MFA authentication for deletion.

### Directory structure

- `ansible`: Contains the ansible files to deploy configurations in the backend instances.
- `scripts`: Contain scripts and templates.
- `tfapp`: Contains the terraform files and modules.
- `tfapp/main`: Terraform source code for workspace root directory files.
- `tfapp/modules`: Contain terraform modules instanciated from the main workspace files.
- `tfapp/euw1`: Contain symlinks to `tfapp/main` and variables for the `euw1` stack.
- `tfapp/localstack`: Contain symlinks to `tfapp/main` and variables for the `localstack` stack.

## Deploy

### Terraform Setup

* I use tfenv to manage multiple versions of terraform. It's not indispensable, but makes management easier.
* Install current version (1.6.5)
* Setup environment variables.

### Provider

#### LocalStack Setup

This won't work anyway because LocalStack does not support ELBv2 in the free version.

```shell
$ localstack start
```
```shell
# Install terraform-local
# Use tflocal
```

#### AWS Setup

Having an AWS account profile configured in your shell session is a pre-requisite. if you can execute AWS CLI commands from your shell session, the following steps should work.

### Environment Setup

#### Python Environment  (Optional) 

Only required to manage awscli and tfenv packages if that's the way terraform will be installed in the workstation.
* Pre-requisites - Python Virtual environment
* pyenv activate venvdev

### Deployment

* Assumption: this repository is checked out into ~/workspace.
* Change directory into the desired stack (euw1) that's the terraform workspace to be deployed.
```shell
$ cd ~/workspace/terraform-localstack-test/tfapp/euw1/
```
Update the file `terraform.tfvars` with your internet IP to allow access into the bastion. Add the IP to the variable `remote_admin_ip`.

* Initialize the environment and apply the changes (could take a while).
```shell
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```
* Run the script to update ansible inventory and ssh config file. Staying into the workspace directory to allow the use of `terraform output` call the script `configure_ssh.sh`.
```shell
$ ../scripts/configure_ssh.sh
```
The script should populate ansible/hosts.cfg and output the ssh configuration

* Change directory into the ansible repository.
```shell
cd ../../ansible
```
* Update the backend hosts configuration with ansible-playbook. The ansible package should be installed in the workstation that'll run the commands. The ssh key is automatically installed by terraform and the ssh configuration is output of the configure_ssh.sh script.
```shell
$ ansible-playbook -i hosts.cfg ansible-ubuntu-playbook.yml -b
```

## Remove Stack

* Destroy the stack with the following command, sitting in the terraform workspace of the stack to be erased.
```shell
$ terraform destroy -auto-approve
```

### Terraform ssh_resource (to be added)
* https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource

# Test

From the terraform workspace directory of the desired stack check the outputs to obtain the url for the site.
```shell
$ terraform output load_balancer_http_url
```
There is an https version as well, but, nevertheless the http version redirects to the https n

### Linting

```shell
$ cd tfapp
$ terraform fmt -recursive -diff
```