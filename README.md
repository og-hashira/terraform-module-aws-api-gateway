<h1 align="center">
    terraform-module-aws-api-gateway
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create an AWS API Gateway and related objects.
</p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.13-green" alt="Terraform">
</a>

</p>

## Prerequisites

This module has a dependency: 

- [Terraform 0.13](https://learn.hashicorp.com/terraform/getting-started/install.html)

## Limitations

Currently this module only supports resource paths nested 5 levels deep, e.g. <endpoint>/one/two/three/four/five.  Adding additional levels is trivial if the use case ever arises.  Stopping at 5 for now to keep the code more concise.

<!-- ## Examples

Here is an example of how you can use this module in your inventory structure:
### Basic Example
```hcl
  module "acm_certificate" {
    source         = "git::git@github.com:procter-gamble/terraform-module-aws-acm-certificate.git"
    domain         = "test.np.pgcloud.com"
    hosted_zone_id = "<hosted_zone_id>"
    tags           = var.tags
  }
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | The domain associated with the certificate. | `string` | `` | yes |
| hosted_zone_id | The id of the Route53 hosted zone. | `string` | `` | yes |
| tags | Tags to be applied to the resource | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The arn of the Certificate. | -->
