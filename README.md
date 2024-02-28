# k8cluster-terraform
This will create a k8 cluster using terraform on Jetstream 2. Has options for CPU and GPU nodes. Currently works on Jetstream 2.

## Howto
1. Add the name of your public key to k8.tfvars
2. Adjust the number of followers you need for your k8 cluster.
3. Run *terraform init* in the git repo
4. Run *terraform apply* and review the changes. Answer *yes* if changes look good.

If you run into issues with SSH, run these steps:
1. cd into the root directory of terraform-js2-k8cluster
2. eval $(ssh-agent)
3. ssh-add ../.ssh/your_ssh_key
