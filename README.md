[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry]

# terraform-azurerm-lb

A Terraform module for deploying the parts required to load balance traffic into an Azure instance group.  Both HTTP(80) and HTTPS(443) proxies are deployed - the later optionally only if the required SSL certificate is provided.

_WARNING_: This module should be used to create a "basic" Application Gateway with minimal configuration and which will work.  For production use-cases you are encouraged to develop your own module and explore the premium SKUs available to match your requirements.

## Usage

This module assumes you already have a deployed network and a subnet that can connect to the internet - you will need the ID of this public subnet for the deployment and it is recommended that you deploy it into a dedicated `/24` CIDR range subnet.

```hcl
module "collector_lb" {
  source = "snowplow-devops/lb/azurerm"

  name                = "collector-lb"
  resource_group_name = "pipeline"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/pipeline/providers/Microsoft.Network/virtualNetworks/pipeline/subnets/public"

  # Note: this is the path for a Snowplow Collector
  probe_path = "/health"
}
```

### Adding a custom certificate

To add a certificate to the load balancer and therefore enable the TLS endpoint you will need to populate three extra variables:

```hcl
module "collector_lb" {
  source = "snowplow-devops/lb/azurerm"

  name                = "collector-lb"
  resource_group_name = "pipeline"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/pipeline/providers/Microsoft.Network/virtualNetworks/pipeline/subnets/public"

  # Note: this is the path for a Snowplow Collector
  probe_path = "/health"

  ssl_certificate_enabled  = true
  ssl_certificate_data     = "<The base64-encoded PFX certificate data>"
  ssl_certificate_password = "<Password used in certificate generation>"
}
```

An example of how to generate a self-signed certificate that matches this requirement leveraging OpenSSL:

```
openssl req \
  -x509 \
  -newkey rsa:2048 \
  -keyout cert.key \
  -out cert.crt \
  -days 365 \
  -nodes \
  -subj "/C=UK/O=Snowplow/OU=Support/CN=*.acme.com"

openssl pkcs12 \
  -export \
  -out cert.p12 \
  -inkey cert.key \
  -in cert.crt \
  -passout pass:changeme

cat cert.p12 | base64
```

The final result is what you would paste in the "ssl_certificate_data" portion.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.58.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.58.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [random_uuid.ip_domain_name_label](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_probe_path"></a> [probe\_path](#input\_probe\_path) | The path to bind for health checks | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to deploy the Application Gateway into | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id to deploy the load balancer across | `string` | n/a | yes |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | The capacity units assigned to the load balancer (1-32) | `number` | `2` | no |
| <a name="input_egress_port"></a> [egress\_port](#input\_egress\_port) | The port that the downstream webserver exposes over HTTP | `number` | `8080` | no |
| <a name="input_probe_match_status_codes"></a> [probe\_match\_status\_codes](#input\_probe\_match\_status\_codes) | The valid status codes for health checks | `list(string)` | <pre>[<br>  "200-399"<br>]</pre> | no |
| <a name="input_ssl_certificate_data"></a> [ssl\_certificate\_data](#input\_ssl\_certificate\_data) | The base64-encoded PFX certificate data | `string` | `""` | no |
| <a name="input_ssl_certificate_enabled"></a> [ssl\_certificate\_enabled](#input\_ssl\_certificate\_enabled) | A boolean which triggers adding or removing the HTTPS proxy | `bool` | `false` | no |
| <a name="input_ssl_certificate_password"></a> [ssl\_certificate\_password](#input\_ssl\_certificate\_password) | The base64-encoded PFX certificate password | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agw_backend_address_pool_id"></a> [agw\_backend\_address\_pool\_id](#output\_agw\_backend\_address\_pool\_id) | The logical ID of the allocated Backend Address Pool needed to attach servers to the gateway |
| <a name="output_agw_backend_address_pool_name"></a> [agw\_backend\_address\_pool\_name](#output\_agw\_backend\_address\_pool\_name) | The name of the allocated Backend Address Pool needed to attach servers to the gateway |
| <a name="output_agw_backend_egress_port"></a> [agw\_backend\_egress\_port](#output\_agw\_backend\_egress\_port) | The egress port defined for the load balancer |
| <a name="output_agw_id"></a> [agw\_id](#output\_agw\_id) | The logical ID of the allocated Application Gateway |
| <a name="output_agw_name"></a> [agw\_name](#output\_agw\_name) | The name of the allocated Application Gateway |
| <a name="output_agw_probe_id"></a> [agw\_probe\_id](#output\_agw\_probe\_id) | The logical ID of the health probe |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The allocated dynamic IP Address used by the Application Gateway |
| <a name="output_ip_address_fqdn"></a> [ip\_address\_fqdn](#output\_ip\_address\_fqdn) | The fully qualified domain name of the deployment |
| <a name="output_ip_address_id"></a> [ip\_address\_id](#output\_ip\_address\_id) | The logical ID of the allocated IP address |

# Copyright and license

The Terraform Azurerm Load Balancer project is Copyright 2023-2023 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/snowplow-devops/terraform-azurerm-lb/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-azurerm-lb

[ci]: https://github.com/snowplow-devops/terraform-azurerm-lb/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-azurerm-lb/workflows/ci/badge.svg

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[registry]: https://registry.terraform.io/modules/snowplow-devops/lb/azurerm/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform
