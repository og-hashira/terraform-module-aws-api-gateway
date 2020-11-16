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

- Currently this module only supports resource paths nested 5 levels deep, e.g. "endpoint"/one/two/three/four/five.  Adding additional levels is trivial if the use case ever arises.  Stopping at 5 for now to keep the code more concise.
- Although you can specify a list of 'method_responses' and 'integration_responses' as a part of 'api_gateway_methods', and these settings have proper default overrides built into the validation process, these settings are mostly ignored for now and instead the resources are hard coded for "sane defaults".  This is a TODO for the future.

## Examples

Here is an example of how you can use this module in your inventory structure:
### Basic Example
```hcl
  module "api_gateway" {
    source = "git@github.com:procter-gamble/terraform-module-aws-api-gateway"
    
    api_gateway = {
      name = "api-gateway"
    }

    api_gateway_methods = [
      {
        resource_path   = "myPath"

        integration = {
          uri         = "<valid_lambda_function_invoke_arn>"
        }
      }
    ]

    tags    = var.tags
  }
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Whether to create the REST API or not | `bool` | `true` | no |
| tags | Tags to be applied to the resource | `map(string)` | `{}` | no |
| api_gateway | AWS API Gateway Settings | `object` | `null` | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the REST API. |
| execution_arn | The Execution ARN of the REST API. | 

## Input Data Structures

### Variable: api_gateway
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| name | Name of the REST API | `string` | yes | `null` |
| api_key_source | The source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER. | `string` | no | `null` |
| binary_media_types | The set of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads. | `set(string)` | no | `null` |
| description | The description of the REST API. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| endpoint_configuration.types | This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE | `set(string)` | no | `null` |
| endpoint_configuration.vpc_endpoint_ids | A list of VPC Endpoint Ids. | `list(string)` | no | `null` |
| minimum_compression_size | Minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default). | `number` | no | `null` |
| custom_domain | The custom domain to associate to this REST API. | `string` | no | `null` |
| acm_cert_arn | The AWS ACM Certificate arn to associate to this REST API custom domain. | `string` | no | `null` |
| api_gateway_client_cert_enabled | Whether or not to generate a client certificate for this REST API. | `string` | no | `false` |
| api_gateway_client_cert_description | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git | `string` | no | `null` |
| policy | The IAM Policy applied to the REST API. | `string` | no | `null` |
