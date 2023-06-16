output "node_dns_info" {
  value = [
    for ec2 in concat([aws_instance.ec2_instance_control_plane_node], [aws_instance.ec2_instance_worker_node1], [aws_instance.ec2_instance_worker_node2]) : {
      ssh_cmd = ec2.tags["Name"] == "k8s-control-plane-node" ? "${ec2.tags["Name"]} : ssh -i ${local.pem_file} ubuntu@${ec2.public_ip} ; Run 'kubectl get nodes' to test cluster is up!" : "${ec2.tags["Name"]} : ssh -i ${local.pem_file} ubuntu@${ec2.public_ip}"
    }
  ]
  description = "Cluster Node DNS and IPs"
}
