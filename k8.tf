################
#VMs
################
# creating leader

resource "openstack_compute_instance_v2" "Ubuntu20_leader_" {
  name = "terraform_Ubuntu20_leader_"
  # ID of JS-API-Featured-Ubuntu20-Latest
  image_name = "Featured-Ubuntu20"
  flavor_id   = var.leader_flavor
  # you'll need to set this to your public key name on jetstream
  key_pair  = var.public_key
  security_groups   = ["terraform_ssh__ping_${var.public_key}", "default"]
  metadata = {
    terraform_controlled = "yes"
    ansible_role = "leader"
    terrform_role = "k8"
  }
  network {
    name = "auto_allocated_network"
  }
}

resource "openstack_networking_floatingip_v2" "terraform_floatip_ubuntu20_leader_" {
  pool = "public"
}

# assigning floating ip from public pool to Ubuntu20 VM
resource "openstack_compute_floatingip_associate_v2" "terraform_floatubntu20_leader_" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.address}"
  instance_id = "${openstack_compute_instance_v2.Ubuntu20_leader_.id}"
}



# creating Ubuntu20 instance (CPU)
resource "openstack_compute_instance_v2" "Ubuntu20_follower_" {
  name = "terraform_Ubuntu20_follower_${count.index}"
  # ID of JS-API-Featured-Ubuntu20-Latest
  image_name = "Featured-Ubuntu20"
  flavor_id   = var.follower_flavor
  # this public key is set above in security section
  key_pair  = var.public_key
  security_groups   = ["terraform_ssh__ping_${var.public_key}", "default"]
  count     = var.vm_number
  metadata = {
    terraform_controlled = "yes"
    ansible_role = "follower"
    terrform_role = "k8"
  }
  network {
    name = "auto_allocated_network"
  }
}
# creating floating ip from the public ip pool
resource "openstack_networking_floatingip_v2" "terraform_floatip_ubuntu20_follower_" {
  pool = "public"
    count     = var.vm_number
}

# assigning floating ip from public pool to Ubuntu20 VM
resource "openstack_compute_floatingip_associate_v2" "terraform_floatubntu20_follower_" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower_[count.index].address}"
  instance_id = "${openstack_compute_instance_v2.Ubuntu20_follower_[count.index].id}"
    count     = var.vm_number
}


# creating Ubuntu20 instance (GPU)
resource "openstack_compute_instance_v2" "Ubuntu20_gpu_" {
  name = "terraform_Ubuntu20_gpu_${count.index}"
  # ID of JS-API-Featured-Ubuntu20-Latest
  image_name = "Featured-Ubuntu20"
  flavor_id   = var.gpu_flavor
  # this public key is set above in security section
  key_pair  = var.public_key
  security_groups   = ["terraform_ssh__ping_${var.public_key}", "default"]
  count     = var.vm_gpu_number
  metadata = {
    terraform_controlled = "yes"
    ansible_role = "gpu"
    terrform_role = "k8"
  }
  network {
    name = "auto_allocated_network"
  }
}
# creating floating ip from the public ip pool
resource "openstack_networking_floatingip_v2" "terraform_floatip_ubuntu20_gpu_" {
  pool = "public"
    count     = var.vm_gpu_number
}

# assigning floating ip from public pool to Ubuntu20 VM
resource "openstack_compute_floatingip_associate_v2" "terraform_floatubntu20_gpu_" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_gpu_[count.index].address}"
  instance_id = "${openstack_compute_instance_v2.Ubuntu20_gpu_[count.index].id}"
    count     = var.vm_gpu_number
}


resource "null_resource" "ansible_provisioners" {
  provisioner "remote-exec" {
    inline = [
      "echo \"Checking if cloud init is running\"",
      "sudo cloud-init status --wait",
      "sudo apt update",
      "sudo apt install python3 ansible -y",
      "rm -rf ~/ansible"
    ]
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.address}"
        user = "ubuntu"
      }
  }
  provisioner "file" {
    source = "ansible"
    destination = "ansible"
  }
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.address}"
        user = "ubuntu"
      }
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/k8_setup.yaml ",
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/leader.yaml ",
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/follower.yaml ",
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/gpu.yaml "
    ]
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.address}"
        user = "ubuntu"
      }
    }

  depends_on = [openstack_compute_floatingip_associate_v2.terraform_floatubntu20_leader_]
}

