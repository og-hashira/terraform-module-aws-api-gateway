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

This module has the following dependencies: 

- [Terraform 0.13](https://learn.hashicorp.com/terraform/getting-started/install.html)
- Hashicorp AWS Provider ~> 3.0

## Limitations

- Currently this module only supports resource paths nested 5 levels deep, e.g. "endpoint/one/two/three/four/five".  Adding additional levels is trivial if the use case ever arises.  Stopping at 5 for now to keep the code more concise.
- Although you can specify a list of 'method_responses' and 'integration_responses' as a part of 'api_gateway_methods', and these settings have proper default overrides built into the validation process, these settings are mostly ignored for now and instead the resources are hard coded for "sane defaults".  This is a TODO for the future.

## Examples

Here is an example of how you can use this module in your inventory structure:
### Basic Example
```hcl
  module "api_gateway" {
    source = "git@github.com:procter-gamble/terraform-module-aws-api-gateway"
    providers = { aws = aws }

    api_gateway = {
      name = "api-gateway"
    }

    api_gateway_methods = [
      {
        resource_path   = "myPath"
        integration = {
          uri = "<valid_lambda_function_invoke_arn>"
        }
      }
    ]

    tags = var.tags
  }
```

### Basic Example with Lambda Authorizers and a Custom Domain
```hcl
  module "api_gateway" {
    source = "git@github.com:procter-gamble/terraform-module-aws-api-gateway"
    providers = { aws = aws }

    api_gateway = {
      name = "api-gateway"
      custom_domain = "api.myapp.np.pgcloud.com"
      acm_cert_arn = <valid arn string>
    }

    authorizer_definitions = [
      {
        authorizer_name = "pingFedAuth"
        authorizer_uri  = <valid authorizer lanbda arn>
      }
    ]

    api_gateway_methods = [
      {
        resource_path   = "getBitlockerKey"
        authorizer_name = "pingFedAuth"

        integration = {
          uri         = <valid lambda arn>
        }
      }
    ]

    tags = var.tags
  }
```

## Inputs

Note:  If you choose to provide the optional objects below, you will have to reference the section below called "Detailed Input Structures" to find which attributes are required for the object.

| Name | Description | Type | Required | Default |
|------|-------------|------|---------|:--------:|
| enabled | Whether to create the REST API or not | `bool` | no | `true` |
| tags | Tags to be applied to the resource | `map(string)` | no | `{}` |
| api_gateway | AWS API Gateway Settings | `object` | yes | `{}` |
| api_gateway_deployment | AWS API Gateway Deployment | `object` | no | `{}`  |
| api_gateway_stages | AWS API Gateway Stages | `set(object)` | no | `[]` |
| api_gateway_models | AWS API Gateway Models | `set(object)` | no | `[]` |
| api_keys | AWS API Keys | `set(any)` | no | `[]` |
| vpc_links | AWS API Gateway VPC Links | `set(object)` | no | `[]` |
| authorizer_definitions | AWS API Gateway Authorizers | `set(object)` | no | `[]` |
| api_gateway_methods | AWS API Gateway Methods | `set(object)` | no | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the REST API. |
| execution_arn | The Execution ARN of the REST API. | 

## Detailed Input Data Structures

### Variable: api_gateway
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| name | Name of the REST API | `string` | yes | `null` |
| api_key_source | The source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER. | `string` | no | `null` |
| binary_media_types | The set of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads. | `set(string)` | no | `null` |
| description | The description of the REST API. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| endpoint_configuration types | This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE | `set(string)` | no | `null` |
| endpoint_configuration vpc_endpoint_ids | A list of VPC Endpoint Ids. | `list(string)` | no | `null` |
| minimum_compression_size | Minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default). | `number` | no | `null` |
| custom_domain | The custom domain to associate to this REST API. | `string` | no | `null` |
| acm_cert_arn | The AWS ACM Certificate arn to associate to this REST API custom domain. | `string` | no | `null` |
| client_cert_enabled | Whether or not to generate a client certificate for this REST API. | `string` | no | `false` |
| client_cert_description | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git | `string` | no | `null` |
| policy | The IAM Policy applied to the REST API. | `string` | no | `null` |

### Variable: api_gateway_deployment
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| stage_name | Name of the deployment. | `string` | yes | `null` |
| stage_description | The description of the stage. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| description | The description of the deployment. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| variables | A map that defines variables for the deployment. | `object` | no | `null` |

### Variable: api_gateway_stage
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| stage_name | The name of the stage. If the specified stage already exists, it will be updated to point to the new deployment. If the stage does not exist, a new one will be created and point to this deployment. | `string` | yes | `null` |
| stage_description | The description of the stage. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| stage_variables | A map that defines variables for the stage. | `object` | no | `null` |
| cache_cluster_enabled | Specifies whether a cache cluster is enabled for the stage. | `bool` | no | `false` |
| cache_cluster_size | The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `number` | no | `null` |
| client_certificate_id | The identifier of a client certificate for the stage. | `string` | no | `null` |
| documentation_version | The version of the associated API documentation. | `string` | no | `null` |
| xray_tracing_enabled | Specifies whether to enable xray_tracing. | `bool` | no | `false` |
| access_log_settings destination_arn | ARN of the log group to send the logs to. Automatically removes trailing :* if present. | `string` | no | `null` |
| access_log_settings format | The formatting and values recorded in the logs. | `string` | no | `null` |

### Variable: api_gateway_models
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| name | The name of the model. | `string` | yes | `null` |
| description | The description of the model. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| content_type | The content_type of the model. | `string` | no | "application/json" |
| schema | The schea of the model. | `string` | no | "{\"type\":\"object\"}" |

### Variable: api_keys
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| key_name | The name of the API key. | `string` | yes | `null` |
| key_description | The description of the API key. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| enabled | Whether the API Key is enabled. | `bool` | no | true |
| value | The value of the key (if not auto generated) | `string` | no | `null` |

### Variable: vpc_links
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| vpc_link_name | The name used to label and identify the VPC link. | `string` | yes | `null` |
| vpc_link_description | The description of the VPC link. | `string` | no | Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git |
| target_arns | The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target. | `set(string)` | no | `null` |

### Variable: authorizer_definitions
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| authorizer_name | The name of the authorizer. | `string` | yes | `null` |
| authorizer_uri | The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/. | `string` | yes | `null` |
| identity_source | The source of the identity in an incoming request. | `string` | no | "method.request.header.Authorization" |
| identity_validation_expression | A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response. | `string` | no | `null` |
| authorizer_result_ttl_in_seconds | The TTL of cached authorizer results in seconds. | `number` | no | 0 |
| authorizer_type | The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN. | `string` | no | "TOKEN" |
| authorizer_credentials | The credentials required for the authorizer. To specify an IAM Role for API Gateway to assume, use the IAM Role ARN. | `string` | no | `null` |
| provider_arns | Required for type COGNITO_USER_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}. | `set(string)` | no | `null` |

### Variable: api_gateway_methods
| Name | Description | Type | Required  | Default|
|------|-------------|------|---------|:--------:|
| resource_path | The resource path.  It can be up to 5 levels deep, and must not start with a '/'.  e.g. "path1/path2/path3/path4/path5" is ok. | `string` | yes | `null` |
| http_method | The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY). | `string` | no | "POST" |
| authorizer_id | The authorizer id to be used when the authorization is CUSTOM or COGNITO_USER_POOLS. | `string` | no | `null` |
| authorization_scopes | The authorization scopes used when the authorization is COGNITO_USER_POOLS. | `string` | no | `null` |
| api_key_required | Specify if the method requires an API key. | `bool` | no | `false` |
| request_models | A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws_api_gateway_model's name. | `map` | no | `null` |
| request_validator_id | The ID of a aws_api_gateway_request_validator. | `string` | no | `null` |
| request_parameters | A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request. | `object` | no | `null` |
| authorization | The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS). | `string` | no | "CUSTOM" |
| authorizer_id | The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/. | `string` | no | `null` |
| authorizer_name | (Optional if not providing authorizer_uri).  The authorizer name that is being created as a part of this module in the authorizer definition. | `string` | no | `null` |
| authorization_scopes | The authorization scopes used when the authorization is COGNITO_USER_POOLS. | `set(string)` | no | `null` |
| integration | The integration definition. | `object` | no | `null` |
| integration http_method | The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) when calling the associated resource. | `string` | no | "GET" |
| integration integration_http_method |  | `string` | no | "POST" |
| integration type | The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC. | `string` | no | "AWS_PROXY" |
| integration connection_type | The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC). | `string` | no | "INTERNET" |
| integration connection_id | The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK. | `string` | no | `null` |
| integration uri | The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations. For private integrations, the URI parameter is not used for routing requests to your endpoint, but is used for setting the Host header and for certificate validation. | `string` | no | `null` |
| integration credentials | The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::\*:user/\*. | `string` | no | `null` |
| integration request_templates | A map of the integration's request templates. | `object` | no | `null` |
| integration request_parameters | A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header" } | `object` | no | `null` |
| integration passthrough_behavior | The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used. | `string` | no | `null` |
| integration cache_key_parameters |  | `object` | no | `null` |
| integration cache_namespace | The integration's cache namespace. | `string` | no | `null` |
| integration content_handling | Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through. | `string` | no | `null` |
| integration timeout_milliseconds | Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds. | `number` | no | 29000 |
| integration integration_responses | The set of integration_responses for this integration. | `set(object)` | no | `[]` |
| integration integration_responses http_method | The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY) | `string` | no | "POST |
| integration integration_responses status_code | The HTTP status code | `string` | no | "200 |
| integration integration_responses selection_pattern | Specifies the regular expression pattern used to choose an integration response based on the response from the backend. Setting this to - makes the integration the default one. If the backend is an AWS Lambda function, the AWS Lambda function error header is matched. For all other HTTP and AWS backends, the HTTP status code is matched. | `string` | no | `null` |
| integration integration_responses response_templates | A map specifying the templates used to transform the integration response body. | `object` | no | `null` |
| integration integration_responses response_parameters | A map of response parameters that can be read from the backend response. For example: response_parameters = { "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" } | `object` | no | `null` |
| integration integration_responses content_handling | Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification. | `string` | no | `null` |
| method_responses status_code | The HTTP status code of the Gateway Response. | `set(object)` | no | "200" |
| method_responses response_type | The response type of the associated GatewayResponse. | `string` | no | `null` |
| method_responses response_models | A map of the API models used for the response's content type. | `object` | no | `null` |
| method_responses response_template | A map specifying the templates used to transform the response body. | `string` | no | `null` |
| method_responses response_parameters | A map specifying the parameters (paths, query strings and headers) of the Gateway Response. | `object` | no | `null` |