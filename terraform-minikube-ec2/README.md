# Creating A Minikube Cluster using Terraform and AWS EC2

## Usage

### Provisioning the Infrastructure

```bash
terraform apply
```

### Connecting to the k8s cluster

You can export the Kubeconfig file using this helper
```bash
$(terraform output -raw kubeconfig_command)
```

### Checking the connection

```bash
kubectl cluster-info
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version  |
| ------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0   |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >=3.28.0 |

## Providers

| Name                                                 | Version |
| ---------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)    | 3.63.0  |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0   |
| <a name="provider_tls"></a> [tls](#provider\_tls)    | 3.1.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                            | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_eip.instance_elastic_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                  | resource    |
| [aws_eip_association.minikube_eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association)           | resource    |
| [aws_instance.minikube_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                          | resource    |
| [aws_key_pair.aws_keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)                                | resource    |
| [aws_security_group.allow_additional_exposed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource    |
| [aws_security_group.allow_kube_api_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)          | resource    |
| [null_resource.download_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)                      | resource    |
| [tls_private_key.private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                          | resource    |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)                                            | data source |

## Inputs

| Name                                                                                                                 | Description                                | Type                                                                                | Default                                                                     | Required |
| -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | :------: |
| <a name="input_exposed_ports"></a> [exposed\_ports](#input\_exposed\_ports)                                          | Ports to expose from Minikube EC2 instance | <pre>list(object({<br>    port     = number<br>    protocol = string<br>  }))</pre> | <pre>[<br>  {<br>    "port": 80,<br>    "protocol": "tcp"<br>  }<br>]</pre> |    no    |
| <a name="input_kubeconfig_output_location"></a> [kubeconfig\_output\_location](#input\_kubeconfig\_output\_location) | KubeConfig file Location                   | `string`                                                                            | n/a                                                                         |   yes    |
| <a name="input_minikube_instance_name"></a> [minikube\_instance\_name](#input\_minikube\_instance\_name)             | Minikube EC2 Instance name                 | `string`                                                                            | `"minikube-on-ec2"`                                                         |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                                 | AWS Region                                 | `string`                                                                            | `"eu-west-1"`                                                               |    no    |

## Outputs

| Name                                                                                           | Description                                                                     |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command)   | Command that needs to be run in order for your kubectl to point to the minikube |
| <a name="output_minikube_public_ip"></a> [minikube\_public\_ip](#output\_minikube\_public\_ip) | MiniKube instance public ip address                                             |
<!-- END_TF_DOCS -->
