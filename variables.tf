# Module      : Api Gateway
# Description : Terraform Api Gateway module variables.
variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create rest api."
}

variable "custom_domain" {
  type        = string
  default     = ""
  description = "Custom API Gateway Domain name."
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "ID of the Route53 hosted zone."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

# Module      : Api Gateway
# Description : Terraform Api Gateway module variables.
variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create rest api."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "api_gateway" {
  description = "AWS API Gateway Settings."
  default     = null
  # type = object({
  #   name                                = string (required) - The name of the API Gateway.
  #   description                         = string (optional) - The description of the REST API
  #   binary_media_types                  = list(string) (optional) - The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads.
  #   minimum_compression_size            = number (optional) - Minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default).
  #   api_key_source                      = bool (optional) - The source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER.
  #   type                                = list(string) (optional) - [\"EDGE\""] or [\"REGIONAL\"] or [\"PRIVATE\"]
  #   custom_domain                       = string (optional) - Custom API Gateway Domain name.
  #   hosted_zone_id                      = string (optional) - ID of the Route53 hosted zone if specifying a custom_domain.
  #   api_gateway_client_cert_enabled     = bool (optional) - Whether to create client certificate.
  #   api_gateway_client_cert_description = string (optional) - The description of the client certificate.
  # })
  validation {
    condition     = var.api_gateway != null && length(var.api_gateway.name) > 1
    error_message = "The api_gateway variable is required and must contain a string attribute called 'name' with length > 1."
  }
}

variable "api_gateway_deployment" {
  description = "AWS API Gateway deployment."
  default     = null
  # type = object({
  #   stage_name        = string (required) - The name of the model.
  #   stage_description = string (optional) - The description of the stage.
  #   description       = string (optional) - The description of the model.
  #   variables         = map (Optional) - A map that defines variables for the stage.
  # })
  validation {
    condition     = var.api_gateway_deployment != null ? length(var.api_gateway_deployment.stage_name) > 1 : true
    error_message = "The api_gateway_deployment variable is optional, but if specified, it must contain a string attribute called 'stage_name' with length > 1."
  }
}

variable "api_gateway_models" {
  description = "AWS API Gateway models."
  default     = []
  type = list(object({
    name         = any # "The name of the model."
    description  = any # "The description of the model."
    content_type = any # "The content_type of the model."
    schema       = any # "The schea of the model."
  }))
}

variable "api_keys" {
  description = "AWS API Gateway API Keys."
  default     = []
  type = list(object({
    key_name        = any # "The name of the API key."
    key_description = any # "The API key description. Defaults to \"Managed by Terraform\"."
    enabled         = any # "Whether the API Key is enabled"
    value           = any # "The value of the key (if not auto generated)"
  }))
}

variable "vpc_links" {
  description = "AWS API Gateway VPC links."
  default     = []
  type = list(object({
    vpc_link_name        = any # "The name used to label and identify the VPC link."
    vpc_link_description = any # "The description of the VPC link."
    target_arns          = any # "The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target."
  }))
}

variable "api_gateway_stages" {
  description = "AWS API Gateway stage."
  type = list(object({
    stage_name            = any # "The name of the stage. If the specified stage already exists, it will be updated to point to the new deployment. If the stage does not exist, a new one will be created and point to this deployment."
    stage_description     = any # "The description of the stage."
    stage_variables       = any # "A map that defines variables for the stage."
    cache_cluster_enabled = any # "Specifies whether a cache cluster is enabled for the stage."
    cache_cluster_size    = any # "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
    client_certificate_id = any # "The identifier of a client certificate for the stage"
    documentation_version = any # "The version of the associated API documentation."
    xray_tracing_enabled  = any # "Whether to enable xray_tracing."
    # log_enabled is the presence or absence of access_log_settings
    access_log_settings = list(object({
      destination_arn = any # "ARN of the log group to send the logs to. Automatically removes trailing :* if present."
      format          = any # "The formatting and values recorded in the logs."
    }))
  }))
}

variable "authorizer_definitions" {
  description = "AWS API Gateway authorizer."
  type = list(object({
    authorizer_name                  = any # "The name of the authorizer."
    authorizer_uri                   = any # "The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations."
    identity_source                  = any # "The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. \"method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName\"."
    identity_validation_expression   = any # "A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response."
    authorizer_result_ttl_in_seconds = any # "The TTL of cached authorizer results in seconds. Defaults to 300."
    authorizer_credentials           = any
    authorizer_type                  = any # "The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN."
    authorization                    = any # "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
    provider_arns                    = any # "Required for type COGNITO_USER_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}."
  }))
}

variable "api_gateway_methods" {
  description = "AWS API Gateway methods."
  type = list(object({
    resource_path        = any # "The path of this API resource.  Do not start with a /"
    http_method          = any # "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
    api_key_required     = any # "Specify if the method requires an API key."
    request_models       = any # "A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws_api_gateway_model's name."
    request_validator_id = any # "The ID of a aws_api_gateway_request_validator."
    request_parameters   = any # "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
    authorization        = any # "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
    authorizer_uri       = any # "The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations."
    authorizer_name      = any # "(Optional if not providing authorizer_uri).  The authorizer name that is being created as a part of this module in the authorizer definition"
    authorization_scope  = any # "The authorization scopes used when the authorization is COGNITO_USER_POOLS."

    integration = object(
      {
        connection_type         = any # "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
        connection_id           = any # "The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK."
        credentials             = any # "The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::*:user/*." 
        passthrough_behavior    = any # "The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used."
        cache_key_parameters    = any # "A list of cache key parameters for the integration."
        cache_namespace         = any # "The integration's cache namespace."
        timeout_milliseconds    = any # "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
        integration_http_method = any # "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
        integration_type        = any # "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
        uri                     = any # "The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations."

        integration_request = object(
          {
            request_parameters       = any # "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
            request_templates        = any # "A map of the integration's request templates."
            request_content_handling = any # "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through."
          }
        )
        integration_response = object(
          {
            response_parameters       = any # "A map of response parameters that can be read from the backend response. For example: response_parameters = { \"method.response.header.X-Some-Header\" = \"integration.response.header.X-Some-Other-Header\" }."
            response_templates        = any # "A map specifying the templates used to transform the integration response body."
            response_content_handling = any # "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification."
          }
        )
      }
    )
    gateway_method_response = object({
      status_code         = any # "The HTTP status code of the Gateway Response."
      response_type       = any # "The response type of the associated GatewayResponse."
      response_models     = any # "A map of the API models used for the response's content type."
      response_template   = any # "A map specifying the templates used to transform the response body."
      response_parameters = any # "A map specifying the parameters (paths, query strings and headers) of the Gateway Response."
    })
  }))
}
