################
 #Output
 ################


 output "floating_ip_ubuntu20_leader_" {
   value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.*.address
   description = "Public IP for Ubuntu 20 leader"
 }

 output "floating_ip_ubuntu20_follower_" {
   value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower_.*.address
   description = "Public IP for Ubuntu 20 followers"
 }

 output "floating_ip_ubuntu20_gpu_" {
   value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_gpu_.*.address
   description = "Public IP for Ubuntu 20 gpus"
 }

 resource "local_file" "ansible_inventory" {
   content = templatefile("${path.module}/inventory.tftpl",
   {
     ansible_leader_ip    = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader_.*.address,
     ansible_follower_ip  = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower_.*.address,
     ansible_gpu_ip	  = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_gpu_.*.address,
   }
   )
   filename  = "ansible/inventory.ini"
 }
