variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create rest api."
}

variable tags {
  type        = map(string)
  default     = {}
  description = "Tags to add to all resources."

  validation {
    condition     = can([for key, value in var.tags : length(key) <= 128])
    error_message = "AWS Tag Keys must be 128 characters or less in length."
  }

  validation {
    condition     = can([for key, value in var.tags : length(value) <= 256])
    error_message = "AWS Tag Values must be 256 characters or less in length."
  }

  validation {
    condition     = can([for key, value in var.tags : regex("^[\\w\\d\\s\\+\\-\\=\\.\\_\\:\\/\\@]+$", "${key} ${value}")])
    error_message = "AWS Tag Keys and Values must match RegExp ^[\\w\\d\\s\\+\\-\\=\\.\\_\\:\\/\\@]+$ ."
  }
}

variable api_gateway_default {
  description = "AWS API Gateway Settings default."
  type        = any
  default = {
    name                                = null
    api_key_source                      = null
    binary_media_types                  = null
    description                         = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    endpoint_configuration              = null
    minimum_compression_size            = null
    policy                              = null
    custom_domain                       = null
    acm_cert_arn                        = null
    api_gateway_client_cert_enabled     = false
    api_gateway_client_cert_description = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
  }
}

variable api_gateway {
  description = "AWS API Gateway Settings."
  type        = any
  default     = null
  /*
  type = object({
    api_key_source                      = any # "The source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER."
    binary_media_types                  = set(string) # "The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads."
    description                         = string # "The description of the REST API "
    endpoint_configuration              = object({
      types = set(string) This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE
      vpc_endpoint_ids = set(string) (Optional) A list of VPC Endpoint Ids.
    })
    minimum_compression_size            = any # "Minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default)."
    name                                = string # "The name of the API Gateway."
    policy                              = string
  })
  */

  // api_gateway not null
  validation {
    condition     = var.api_gateway != null
    error_message = "Variable object 'api_gateway' must be provided."
  }

  // name
  validation {
    condition     = try(length(tostring(var.api_gateway.name)) > 1)
    error_message = "Attribute 'name' of 'api_gateway' must be provided."
  }

  // description
  validation {
    condition     = can(tostring(lookup(var.api_gateway, "description", "")))
    error_message = "Optional attribute 'description' of 'api_gateway' must be a string if specified."
  }

  // binary_media_types
  validation {
    condition = can(toset([
      for binary_media_type in lookup(var.api_gateway, "binary_media_types", []) : regex("^[\\-\\w\\.]+/[\\-\\w\\.]+$", binary_media_type)
    ]))
    error_message = "Optional attribute 'binary_media_types' of 'api_gateway' must be a set of valid MIME types if specified."
  }

  // minimum_compression_size
  validation {
    condition     = tonumber(lookup(var.api_gateway, "minimum_compression_size", 0)) >= 0 && tonumber(lookup(var.api_gateway, "minimum_compression_size", 0)) <= 10485760
    error_message = "Optional attribute 'minimum_compression_size' of 'api_gateway' must be non-negative between 0 and 10485760 (inclusive) if specified."
  }

  // api_key_source
  validation {
    condition     = contains(["HEADER", "AUTHORIZER"], tostring(lookup(var.api_gateway, "api_key_source", "HEADER")))
    error_message = "Optional attribute 'api_key_source' of 'api_gateway' must be one of:\n\t- HEADER\n\t- AUTHORIZER\n if specified."
  }

  // custom_domain
  validation {
    condition     = can(tostring(lookup(var.api_gateway, "custom_domain", "")))
    error_message = "Optional attribute 'custom_domain' of 'api_gateway' must be a string if specified."
  }

  // acm_cert_arn
  validation {
    condition     = can(tostring(lookup(var.api_gateway, "acm_cert_arn", "")))
    error_message = "Optional attribute 'acm_cert_arn' of 'api_gateway' must be a string if specified."
  }
  // endpoint_configuration
  validation {
    condition     = can(var.api_gateway.endpoint_configuration) ? length(try(toset(var.api_gateway.endpoint_configuration.types), [])) == 1 : true
    error_message = "Optional attribute 'endpoint_configuration' of 'api_gateway' must be an object with a 'types' attribute of type set(string) and length 1."
  }

  // endpoint_configuration.types
  validation {
    condition     = can(var.api_gateway.endpoint_configuration.types[0]) ? contains(["EDGE", "REGIONAL", "PRIVATE"], var.api_gateway.endpoint_configuration.types[0]) : true
    error_message = "Attribute types of 'api_gateway.endpoint_configuration' must be of type set(string) and only include the following values:\n\t- EDGE\n\t- REGIONAL\n\t- PRIVATE\n."
  }

  // endpoint_configuration.vpc_endpoint_ids
  validation {
    condition = (
      try(var.api_gateway.endpoint_configuration.types[0], "") == "PRIVATE" ?
      can([
        for vpc_endpoint_id in var.api_gateway.endpoint_configuration.vpc_endpoint_ids :
        regex("^vpce-[a-z0-9]+$", vpc_endpoint_id)
      ]) :
      length(try(var.api_gateway.endpoint_configuration.vpc_endpoint_ids, [])) == 0
    )
    error_message = "Attribute types of 'api_gateway.endpoint_configuration.vpc_endpoint_ids' must: \n\t- only be specified when api_gateway.endpoint_configuration.types is PRIVATE\n\t- be a set of VPC Endpoint IDs\n."
  }
}

variable "api_gateway_deployment_default" {
  description = "AWS API Gateway deployment default."
  type        = any
  default = {
    stage_name        = null
    stage_description = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    description       = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    variables         = null
  }
}

variable api_gateway_deployment {
  description = "AWS API Gateway deployment."
  default     = null
  type        = any
  /*
  type = object({
    stage_name        = string (required) - The name of the model.
    stage_description = string (optional) - The description of the stage.
    description       = string (optional) - The description of the model.
    variables         = map (Optional) - A map that defines variables for the stage.
  })
  */

  // stage_name
  validation {
    condition     = var.api_gateway_deployment != null ? try(length(tostring(lookup(var.api_gateway_deployment, "stage_name", null))) > 1, false) : true
    error_message = "If the optional api_gateway_deployment object is provided, attribute stage_name of api_gateway_deployment must be provided and must be a string of length > 1."
  }

  // stage_description
  validation {
    condition     = var.api_gateway_deployment != null ? can(tostring(lookup(var.api_gateway_deployment, "stage_description", ""))) : true
    error_message = "Optional attribute stage_description of api_gateway_deployment must be a string if specified."
  }

  // description
  validation {
    condition     = var.api_gateway_deployment != null ? can(tostring(lookup(var.api_gateway_deployment, "description", ""))) : true
    error_message = "Optional attribute description of api_gateway_deployment must be a string if specified."
  }

  // variables
  validation {
    condition     = var.api_gateway_deployment != null ? can(tomap(lookup(var.api_gateway_deployment, "variables", null))) : true
    error_message = "Optional attribute variables of api_gateway_deployment must be an object map."
  }
}

variable api_gateway_stage_default {
  description = "AWS API Gateway stage default."
  type        = any
  default = {
    stage_name            = null
    access_log_settings   = null
    cache_cluster_enabled = false
    cache_cluster_size    = null
    client_certificate_id = null
    documentation_version = null
    stage_description     = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    stage_variables       = null
    xray_tracing_enabled  = false
  }
}

variable api_gateway_stages {
  description = "AWS API Gateway stage."
  default     = []
  type        = any
  /*
  type = list(object({
    stage_name            = string (required) - The name of the stage. If the specified stage already exists, it will be updated to point to the new deployment. If the stage does not exist, a new one will be created and point to this deployment.
    stage_description     = string (optional) - The description of the stage.
    stage_variables       = map (optional) - A map that defines variables for the stage.
    cache_cluster_enabled = bool (optional) - Specifies whether a cache cluster is enabled for the stage.
    cache_cluster_size    = number (optional) - The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237.
    client_certificate_id = string (optional) - The identifier of a client certificate for the stage
    documentation_version = string (optional) - The version of the associated API documentation.
    xray_tracing_enabled  = bool (optional) - Whether to enable xray_tracing.
    access_log_settings = list(object({ - optional block
      destination_arn = string (required) - ARN of the log group to send the logs to. Automatically removes trailing :* if present.
      format          = string (optional) - The formatting and values recorded in the logs.
    }))
  }))
  */

  // stage_name
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : can(lookup(stage, "stage_name")) ? length(lookup(stage, "stage_name")) > 1 : false], false)) : true
    error_message = "If the set of 'api_gateway_stages' is provided, each value must contain an attribute 'stage_name' with length > 1."
  }

  // description
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : length(lookup(stage, "stage_description")) > 1], false)) : true
    error_message = "Optional attribute 'stage_description' of 'api_gateway_stages' must be a string if specified with length > 1."
  }

  // stage_variables
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : can(lookup(stage, "stage_variables")) ? can(tomap(lookup(stage, "stage_variables"))) : true], false)) : true
    error_message = "Optional attribute 'stage_variables' of 'api_gateway_stages' must be an object map."
  }

  // cache_cluster_enabled
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : can(lookup(stage, "cache_cluster_enabled")) ? can(tobool(lookup(stage, "cache_cluster_enabled"))) : true], false)) : true
    error_message = "Optional attribute 'cache_cluster_enabled' of 'api_gateway_stages' must be 'true' or 'false'."
  }

  // cache_cluster_size
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : can(lookup(stage, "cache_cluster_size")) ? can(tonumber(lookup(stage, "cache_cluster_size"))) && contains([0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237], lookup(stage, "cache_cluster_size")) : true], false)) : true
    error_message = "Optional attribute 'cache_cluster_size' of 'api_gateway_stages' must be a number in the following set [0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237]."
  }

  // client_certificate_id
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : length(lookup(stage, "client_certificate_id")) > 1], false)) : true
    error_message = "Optional attribute 'client_certificate_id' of 'api_gateway_stages' must be a string if specified with length > 1."
  }

  // documentation_version
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : length(lookup(stage, "documentation_version")) > 1], false)) : true
    error_message = "Optional attribute 'documentation_version' of 'api_gateway_stages' must be a string if specified with length > 1."
  }

  // xray_tracing_enabled
  validation {
    condition     = var.api_gateway_stages != [] ? ! can(index([for stage in var.api_gateway_stages : can(lookup(stage, "xray_tracing_enabled")) ? can(tobool(lookup(stage, "xray_tracing_enabled"))) : true], false)) : true
    error_message = "Optional attribute 'xray_tracing_enabled' of 'api_gateway_stages' must be 'true' or 'false'."
  }

  // TODO: access_log_settings
}

variable api_gateway_model_default {
  description = "AWS API Gateway model default."
  type        = any
  default = {
    name         = null
    description  = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    content_type = "application/json"
    schema       = "{\"type\":\"object\"}"
  }
}

variable api_gateway_models {
  description = "AWS API Gateway models."
  default     = []
  type        = set(any)
  /*
  type = list(object({
      name         = string (required) - The name of the model.
      description  = string (optional) - The description of the model.
      content_type = string (optional) - The content_type of the model. defaults to "application/json"
      schema       = string (required) - The schea of the model. defaults to "{\"type\":\"object\"}"
  }))
  */

  // name
  validation {
    condition     = var.api_gateway_models != [] ? ! can(index([for model in var.api_gateway_models : can(lookup(model, "name")) ? length(lookup(model, "name")) > 1 : false], false)) : true
    error_message = "If the set of 'api_gateway_models' is provided, each value must contain an attribute 'name' with length > 1."
  }

  // description
  validation {
    condition     = var.api_gateway_models != [] ? ! can(index([for model in var.api_gateway_models : length(lookup(model, "description")) > 1], false)) : true
    error_message = "Optional attribute 'description' of 'api_gateway_models' must be a string if specified with length > 1."
  }

  // content_type
  validation {
    condition     = var.api_gateway_models != [] ? ! can(index([for model in var.api_gateway_models : length(lookup(model, "content_type")) > 1], false)) : true
    error_message = "Optional attribute 'content_type' of 'api_gateway_models' must be a string if specified with length > 1."
  }

  // schema
  validation {
    condition     = var.api_gateway_models != [] ? ! can(index([for model in var.api_gateway_models : length(lookup(model, "schema")) > 1], false)) : true
    error_message = "Optional attribute 'schema' of 'api_gateway_models' must be a string if specified with length > 1."
  }
}

variable api_keys_default {
  description = "AWS API Gateway API Keys default"
  type        = any
  default = {
    key_name        = null
    key_description = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    enabled         = true
    value           = null
  }
}

variable api_keys {
  description = "AWS API Gateway API Keys."
  default     = []
  type        = any
  /*
  type = list(object({
    key_name        = string (required) - The name of the API key.
    key_description = string (optional) - The API key description. Defaults to \"Managed by Terraform\".
    enabled         = string (optional) - Whether the API Key is enabled
    value           = string (optional) - The value of the key (if not auto generated)
  }))
  */

  // key_name
  validation {
    condition     = var.api_keys != [] ? ! can(index([for api_key in var.api_keys : can(lookup(api_key, "key_name")) ? length(lookup(api_key, "key_name")) > 1 : false], false)) : true
    error_message = "If the set of 'api_keys' is provided, each value must contain an attribute 'key_name' with length > 1."
  }

  // key_description
  validation {
    condition     = var.api_keys != [] ? ! can(index([for api_key in var.api_keys : length(lookup(api_key, "key_description")) > 1], false)) : true
    error_message = "Optional attribute 'key_description' of 'api_keys' must be a string if specified with length > 1."
  }

  // enabled
  validation {
    condition     = var.api_keys != [] ? ! can(index([for api_key in var.api_keys : can(lookup(api_key, "enabled")) ? can(tobool(lookup(api_key, "enabled"))) : true], false)) : true
    error_message = "Optional attribute 'enabled' of 'api_keys' must be 'true' or 'false'."
  }

  // value
  validation {
    condition     = var.api_keys != [] ? ! can(index([for api_key in var.api_keys : length(lookup(api_key, "value")) > 1], false)) : true
    error_message = "Optional attribute 'value' of 'api_keys' must be a string if specified with length > 1."
  }
}

variable vpc_link_default {
  description = "AWS API Gateway VPC link defaults."
  type        = any
  default = {
    vpc_link_name        = null
    vpc_link_description = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"
    vpc_link_name        = null
    target_arns          = null
  }
}

variable vpc_links {
  description = "AWS API Gateway VPC links."
  default     = []
  type        = any
  /*
  type = list(object({
    vpc_link_name        = string (required) - The name used to label and identify the VPC link.
    vpc_link_description = string (optional) - The description of the VPC link.
    target_arns          = set(string) - The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target.
  }))
  */

  // vpc_link_name
  validation {
    condition     = var.vpc_links != [] ? ! can(index([for vpc_link in var.vpc_links : can(lookup(vpc_link, "vpc_link_name")) ? length(lookup(vpc_link, "vpc_link_name")) > 1 : false], false)) : true
    error_message = "If the set of 'vpc_links' is provided, each value must contain an attribute 'vpc_link_name' with length > 1."
  }

  // vpc_link_description
  validation {
    condition     = var.vpc_links != [] ? ! can(index([for vpc_link in var.vpc_links : length(lookup(vpc_link, "vpc_link_description")) > 1], false)) : true
    error_message = "Optional attribute 'vpc_link_description' of 'vpc_links' must be a string if specified with length > 1."
  }

  // target_arns
  validation {
    condition     = var.vpc_links != [] ? ! can(index([for vpc_link in var.vpc_links : length(try(toset(vpc_link.target_arns), [])) == 1], false)) : true
    error_message = "Required attribute 'target_arns' of 'vpc_links' must be a set of at least one string."
  }
}

variable authorizer_definition_default {
  description = "AWS API Gateway authorizer default."
  type        = any

  default = {
    authorizer_name                  = null
    authorizer_uri                   = null
    identity_source                  = "method.request.header.Authorization"
    identity_validation_expression   = null
    authorizer_result_ttl_in_seconds = 0
    authorizer_type                  = "TOKEN"
    authorizer_credentials           = null
    provider_arns                    = null
  }
}

variable authorizer_definitions {
  description = "AWS API Gateway authorizer."
  default     = []
  type        = any

  /*
  type = list(object({
    authorizer_name                  = string (required) - The name of the authorizer.
    authorizer_uri                   = string (required) - The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations.
    identity_source                  = string (optional) - The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. \"method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName\".
    authorizer_type                  = string (optional) - The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN.
    authorizer_credentials           = string (optional) - The credentials required for the authorizer. To specify an IAM Role for API Gateway to assume, use the IAM Role ARN.
    authorizer_result_ttl_in_seconds = number (optional) - The TTL of cached authorizer results in seconds. Defaults to 0.
    identity_validation_expression   = string (optional) - A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response.
    provider_arns                    = string (optional) - Required for type COGNITO_USER_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}.
  }))
  */

  // authoizer_name
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(lookup(auth, "authorizer_name")) ? length(lookup(auth, "authorizer_name")) > 1 : false], false)) : true
    error_message = "If the set of 'authorizer_definitions' is provided, each value must contain an attribute 'authorizer_name' with length > 1."
  }

  // authoizer_uri
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(lookup(auth, "authorizer_uri")) ? length(lookup(auth, "authorizer_uri")) > 1 : false], false)) : true
    error_message = "If the set of 'authorizer_definitions' is provided, each value must contain an attribute 'authorizer_uri' with length > 1."
  }

  // identity_source
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : length(lookup(auth, "identity_source")) > 1], false)) : true
    error_message = "Optional attribute 'identity_source' of 'authorizer_definitions' must be a string if specified with length > 1."
  }

  // authorizer_type
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(lookup(auth, "authorizer_type")) ? ! contains(["TOKEN", "REQUEST"], lookup(auth, "authorizer_type")) : false], true)) : true
    error_message = "Optional attribute 'authorizer_type' of 'authorizer_definitions' must be a string equal to 'TOKEN' or 'REQUEST'."
  }

  // authorizer_credentials
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : length(lookup(auth, "authorizer_credentials")) > 1], false)) : true
    error_message = "Optional attribute 'authorizer_credentials' of 'authorizer_definitions' must be a string if specified with length > 1."
  }

  // authorizer_result_ttl_in_seconds
  validation {

    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(lookup(auth, "authorizer_result_ttl_in_seconds")) ? tonumber(lookup(auth, "authorizer_result_ttl_in_seconds")) >= 0 && tonumber(lookup(auth, "authorizer_result_ttl_in_seconds")) <= 3600 : true], false)) : true
    error_message = "Optional attribute 'authorizer_result_ttl_in_seconds' of 'authorizer_definitions' must be a number in range 0 - 3600."
  }

  // identity_validation_expression
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : length(lookup(auth, "identity_validation_expression")) > 1], false)) : true
    error_message = "Optional attribute 'identity_validation_expression' of 'authorizer_definitions' must be a string if specified with length > 1."
  }

  // provider_arns
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(toset(lookup(auth, "provider_arns")))], false)) : true
    error_message = "Optional attribute 'provider_arns' of 'authorizer_definitions' must be a set of at least one string."
  }
}

variable api_gateway_method_default {
  description = "AWS API Gateway methods default."
  type        = any

  default = {
    resource_path        = null
    http_method          = "POST"
    authorizer_id        = null
    authorization_scopes = null
    api_key_required     = false
    request_models       = null
    request_validator_id = null
    request_parameters   = null

    authorization        = null
    authorizer_id        = null
    authorizer_name      = null
    authorization_scopes = null

    integration = {
      http_method             = "GET"
      integration_http_method = "POST"
      type                    = "AWS_PROXY"
      connection_type         = "INTERNET"
      connection_id           = null
      uri                     = null
      credentials             = null
      request_templates       = null
      request_parameters      = null
      passthrough_behavior    = null
      cache_key_parameters    = null
      cache_namespace         = null
      content_handling        = null
      timeout_milliseconds    = 29000

      integration_responses = []
    }

    method_responses = []
  }
}

variable integration_response_default {
  type = any
  default = {
    http_method         = "POST"
    status_code         = "200"
    selection_pattern   = null
    response_templates  = null
    response_parameters = null
    content_handling    = null
  }
}

variable method_response_default {
  type = any
  default = {
    status_code         = "200"
    response_type       = null
    response_models     = null
    response_template   = null
    response_parameters = null
  }
}

variable api_gateway_methods {
  description = "AWS API Gateway methods."
  default     = []
  type        = any
  /*
  type = list(object({
    resource_path        = string (required) - The path of this API resource.  Do not start with a /"
    http_method          = string (required) - The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY).
    authorizer_id        = string (Optional) - The authorizer id to be used when the authorization is CUSTOM or COGNITO_USER_POOLS
    authorization_scopes = set(string) - (Optional) The authorization scopes used when the authorization is COGNITO_USER_POOLS
    api_key_required     = bool (optional) - Specify if the method requires an API key.
    request_models       = map (optional) - A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws_api_gateway_model's name.
    request_validator_id = string (optional) - The ID of a aws_api_gateway_request_validator.
    request_parameters   = map (optional) - A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request.
    
    authorization        = any # "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS).
    authorizer_id        = any # "The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations.
    authorizer_name      = any # "(Optional if not providing authorizer_uri).  The authorizer name that is being created as a part of this module in the authorizer definition
    authorization_scopes = any # "The authorization scopes used when the authorization is COGNITO_USER_POOLS.

    integration = object(
      {
        http_method - (Required) The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) when calling the associated resource.
        integration_http_method - (Optional) The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST.
        type - (Required) The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC.
        connection_type - (Optional) The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC).
        connection_id - (Optional) The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK
        uri - (Optional) The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations. For private integrations, the URI parameter is not used for routing requests to your endpoint, but is used for setting the Host header and for certificate validation.
        credentials - (Optional) The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::\*:user/\*.
        request_templates - (Optional) A map of the integration's request templates.
        request_parameters - (Optional) A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header" }
        passthrough_behavior - (Optional) The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used.
        cache_key_parameters - (Optional) A list of cache key parameters for the integration.
        cache_namespace - (Optional) The integration's cache namespace.
        content_handling - (Optional) Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through.
        timeout_milliseconds - (Optional) Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds.
        integration_response = object(
          {
            http_method - (Required) The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)
            status_code - (Required) The HTTP status code
            selection_pattern - (Optional) Specifies the regular expression pattern used to choose an integration response based on the response from the backend. Setting this to - makes the integration the default one. If the backend is an AWS Lambda function, the AWS Lambda function error header is matched. For all other HTTP and AWS backends, the HTTP status code is matched.
            response_templates - (Optional) A map specifying the templates used to transform the integration response body
            response_parameters - (Optional) A map of response parameters that can be read from the backend response. For example: response_parameters = { "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }
            content_handling - (Optional) Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification.
          }
        )
      }
    )
    gateway_method_response = object({
      status_code         = any # "The HTTP status code of the Gateway Response.
      response_type       = any # "The response type of the associated GatewayResponse.
      response_models     = any # "A map of the API models used for the response's content type.
      response_template   = any # "A map specifying the templates used to transform the response body.
      response_parameters = any # "A map specifying the parameters (paths, query strings and headers) of the Gateway Response.
    })
  }))
  */

  // resource_path
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "resource_path")) ? length(lookup(method, "resource_path")) > 1 && lookup(method, "resource_path") : false], false)) : true
    error_message = "If the set of 'api_gateway_methods' is provided, each value must contain an attribute 'resource_path' with length > 1."
  }

  // http_method
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(lookup(method, "http_method")) ?
          contains(["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "ANY"], lookup(method, "http_method")) : # if can find http_method true
        false]                                                                                                  # Required so result should be false - http_method not found
      , false))                                                                                                 # index function lookup value
    : true)                                                                                                     # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "Required attribute 'http_method' of 'api_gateway_methods' must be a string equal to GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY."
  }

  // authorization     
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "authorization")) ? contains(["NONE", "CUSTOM", "AWS_IAM", "COGNITO_USER_POOLS"], lookup(method, "authorization")) : false], false)) : true
    error_message = "Required attribute 'authorization' of 'api_gateway_methods' must be a string equal to NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS."
  }

  // authorizer_id
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "authorizer_id")) ? length(lookup(method, "authorizer_id")) > 1 : true], false)) : true
    error_message = "Optional attribute 'authorizer_id' of 'api_gateway_methods' must be a string with length > 1."
  }

  // authorization_scopes
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(method.authorization_scopes) ? length(try(toset(method.authorization_scopes), [])) == 1 : true], false)) : true
    error_message = "Optional attribute 'authorization_scopes' of 'api_gateway_methods' must be a set of string with length > 1."
  }

  // api_key_required
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "api_key_required")) ? can(tobool(lookup(method, "api_key_required"))) : true], false)) : true
    error_message = "Optional attribute 'api_key_required' of 'api_gateway_methods' must be 'true' or 'false'."
  }

  // request_models
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "request_models")) ? can(tomap(lookup(method, "request_models"))) : true], false)) : true
    error_message = "Optional attribute 'request_models' of 'api_gateway_methods' must be an object map."
  }

  // request_validator_id
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "request_validator_id")) ? length(lookup(method, "request_validator_id")) > 1 : true], false)) : true
    error_message = "Optional attribute 'request_validator_id' of 'api_gateway_methods' must be a string with length > 1."
  }

  // request_parameters
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "request_parameters")) ? can(tomap(lookup(method, "request_parameters"))) : true], false)) : true
    error_message = "Optional attribute 'request_parameters' of 'api_gateway_methods' must be an object map."
  }

  // authorizer_name
  validation {
    condition     = var.api_gateway_methods != [] ? ! can(index([for method in var.api_gateway_methods : can(lookup(method, "authorizer_name")) ? length(lookup(method, "authorizer_name")) > 1 : true], false)) : true
    error_message = "Optional attribute 'authorizer_name' of 'api_gateway_methods' must be a string with length > 1."
  }

  // integration.http_method
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.http_method) ?
          contains(["GET", "POST", "PUT", "DELETE", "HEAD", "OPTION", "ANY"], method.integration.http_method) : # if http_method found... validate it
          false :                                                                                               # Required - If integration specified, http_method must be provided so return false
        true]                                                                                                   # integration is not required, so return true
      , false))                                                                                                 # index function lookup value
    : true)                                                                                                     # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, required attribute 'http_method' must be a string equal to GET, POST, PUT, DELETE, HEAD, OPTION, ANY."
  }

  // integration.integration_http_method
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.integration_http_method) ?
          contains(["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "ANY", "PATCH"], method.integration.integration_http_method) : # if integration_http_method found... validate it
          true :                                                                                                                      # Optional - If not specified, the module assumes "POST" for lambda integrations in locals
        true]                                                                                                                         # integration is not required, so return true
      , false))                                                                                                                       # index function lookup value
    : true)                                                                                                                           # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'integration_http_method' must be a string equal to GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY, PATCH."
  }

  // integration.integration_type
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.integration_type) ?
          contains(["HTTP", "MOCK", "AWS", "AWS_PROXY", "HTTP_PROXY"], method.integration.integration_type) : # if type found... validate it
          true :                                                                                              # Optional - If not specified, the module assumes "AWS_PROXY" for lambda integrations in locals
        true]                                                                                                 # integration is not required, so return true
      , false))                                                                                               # index function lookup value
    : true)                                                                                                   # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'integration_type' must be a string equal to HTTP, MOCK, AWS, AWS_PROXY, HTTP_PROXY."
  }

  // integration.connection_type
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.connection_type) ?
          contains(["INTERNET", "VPC_LINK"], method.integration.connection_type) : # if type found... validate it
          true :                                                                   # Optional 
        true]                                                                      # integration is not required, so return true
      , false))                                                                    # index function lookup value
    : true)                                                                        # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'connection_type' must be a string equal to INTERNET, VPC_LINK."
  }

  // integration.connection_id
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.connection_id) ?
          can(tostring(method.integration.connection_id)) && length(method.integration.connection_id) > 1 : # if type found... validate it
          true :                                                                                            # Optional 
        true]                                                                                               # integration is not required, so return true
      , false))                                                                                             # index function lookup value
    : true)                                                                                                 # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'connection_id' must be a string with length > 1."
  }

  // integration.uri
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.uri) ?
          can(tostring(method.integration.uri)) && length(method.integration.uri) > 1 : # if type found... validate it
          true :                                                                        # Optional 
        true]                                                                           # integration is not required, so return true
      , false))                                                                         # index function lookup value
    : true)                                                                             # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'uri' must be a string with length > 1."
  }

  // integration.credentials
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.credentials) ?
          can(tostring(method.integration.credentials)) && length(method.integration.credentials) > 1 : # if type found... validate it
          true :                                                                                        # Optional 
        true]                                                                                           # integration is not required, so return true
      , false))                                                                                         # index function lookup value
    : true)                                                                                             # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'credentials' must be a string with length > 1."
  }

  // integration.request_parameters
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.request_parameters) ?
          can(tomap(method.integration.request_parameters)) && length(method.integration.request_parameters) >= 1 : # if type found... validate it
          true :                                                                                                    # Optional 
        true]                                                                                                       # integration is not required, so return true
      , false))                                                                                                     # index function lookup value
    : true)                                                                                                         # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'request_parameters' must be a map with attributes > 1."
  }

  // integration.request_templates
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.request_templates) ?
          can(tomap(method.integration.request_templates)) && length(method.integration.request_templates) >= 1 : # if type found... validate it
          true :                                                                                                  # Optional 
        true]                                                                                                     # integration is not required, so return true
      , false))                                                                                                   # index function lookup value
    : true)                                                                                                       # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'request_templates' must be a map with attributes > 1."
  }

  // integration.passthrough_behavior
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.passthrough_behavior) ?
          contains(["WHEN_NO_MATCH", "WHEN_NO_TEMPLATES", "NEVER"], method.integration.passthrough_behavior) : # if type found... validate it
          true :                                                                                               # Optional 
        true]                                                                                                  # integration is not required, so return true
      , false))                                                                                                # index function lookup value
    : true)                                                                                                    # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'passthrough_behavior' must be a string equal to WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER."
  }

  // integration.cache_key_parameters
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.cache_key_parameters) ?
          can(toset(method.integration.cache_key_parameters)) && length(method.integration.cache_key_parameters) >= 1 : # if type found... validate it
          true :                                                                                                        # Optional 
        true]                                                                                                           # integration is not required, so return true
      , false))                                                                                                         # index function lookup value
    : true)                                                                                                             # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'cache_key_parameters' must be a set of string > 1."
  }

  // integration.cache_namespace
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.cache_namespace) ?
          can(tostring(method.integration.cache_namespace)) && length(method.integration.cache_namespace) > 1 : # if type found... validate it
          true :                                                                                                # Optional 
        true]                                                                                                   # integration is not required, so return true
      , false))                                                                                                 # index function lookup value
    : true)                                                                                                     # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'cache_namespace' must be a string with length > 1."
  }

  // integration.content_handling
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.content_handling) ?
          contains(["CONVERT_TO_BINARY", "CONVERT_TO_TEXT"], method.integration.content_handling) : # if type found... validate it
          true :                                                                                    # Optional 
        true]                                                                                       # integration is not required, so return true
      , false))                                                                                     # index function lookup value
    : true)                                                                                         # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'content_handling' must be a string equal to CONVERT_TO_BINARY, CONVERT_TO_TEXT."
  }

  // integration.timeout_milliseconds
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.timeout_milliseconds) ?
          can(tonumber(method.integration.timeout_milliseconds)) && method.integration.timeout_milliseconds >= 50 && method.integration.timeout_milliseconds <= 29000 : # if type found... validate it
          true :                                                                                                                                                        # Optional 
        true]                                                                                                                                                           # integration is not required, so return true
      , false))                                                                                                                                                         # index function lookup value
    : true)                                                                                                                                                             # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'timeout_milliseconds' must be a number >= 50 and <= 29,000."
  }

  // integration.integration_responses
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration) ?
          can(method.integration.integration_responses) ?
          can(toset(method.integration.integration_responses)) && length(method.integration.integration_responses) > 0 : # if type found... validate it
          true :                                                                                                         # Optional 
        true]                                                                                                            # integration is not required, so return true
      , false))                                                                                                          # index function lookup value
    : true)                                                                                                              # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration' is specified, optional attribute 'integration_responses' must be a set of objects > 1."
  }

  // integration.integration_responses.response_parameters
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration.integration_responses) ?
          ! can(index([for response in method.integration.integration_responses : can(response.response_parameters) ?
            can(tomap(response.response_parameters)) && length(response.response_parameters) > 0 :
            true]   # integration_responses is optional
          , false)) # did any falses return in the list?
        : true]     # integration_responses are not required, so return true
      , false))     # did any falses return in the outer list?
    : true)         # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration.integration_responses' is specified, optional attribute 'response_parameters' must be a map with attributes > 0."
  }

  // integration.integration_responses.response_templates
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration.integration_responses) ?
          ! can(index([for response in method.integration.integration_responses : can(response.response_templates) ?
            can(tomap(response.response_templates)) && length(response.response_templates) > 0 :
            true]   # integration_responses is optional
          , false)) # did any falses return in the list?
        : true]     # integration_responses are not required, so return true
      , false))     # did any falses return in the outer list?
    : true)         # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration.integration_responses' is specified, optional attribute 'response_templates' must be a map with attributes > 0."
  }

  // integration.integration_responses.content_handling
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        # build an array of true/false values describing if the validation is passed for each record...  if 'false' found via the index function, return false
        [for method in var.api_gateway_methods : can(method.integration.integration_responses) ?
          ! can(index([for response in method.integration.integration_responses : can(response.content_handling) ?
            contains(["CONVERT_TO_BINARY", "CONVERT_TO_TEXT"], response.content_handling) : # the validation
            true]                                                                           # integration_responses is optional
          , false))                                                                         # did any falses return in the list?
        : true]                                                                             # integration_responses are not required, so return true
      , false))                                                                             # did any falses return in the outer list?
    : true)                                                                                 # if var.api_gateway_methods == [] it wasn't passed at all.  Since this is optional, pass validation
    error_message = "If 'api_gateway_methods.integration.integration_responses' is specified, optional attribute 'content_handling' must be a string equal to CONVERT_TO_BINARY or CONVERT_TO_TEXT."
  }

  // method_responses
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        [for method in var.api_gateway_methods : can(method.method_responses) ?
          can(toset(method.method_responses)) && length(method.method_responses) > 0 :
        true] # method_responses is optional
      , false)) :
    true)
    error_message = "Optional attribute 'method_responses' of 'api_gateway_methods' must be a set of objects with size > 0."
  }

  // method_responses.status_code
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        [for method in var.api_gateway_methods : can(method.method_responses) ?
          ! can(index([for response in method.method_responses : can(response.status_code) ?
            can(tostring(response.status_code)) && length(response.status_code) > 1 : # the validation
            true]                                                                     # method_responses is optional
          , false)) :                                                                 # did any falses return in the list?
        true]
      , false)) :
    true)
    error_message = "Optional attribute 'method_responses.status_code' of 'api_gateway_methods' must be a string with length > 1."
  }

  // method_responses.response_models
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        [for method in var.api_gateway_methods : can(method.method_responses) ?
          ! can(index([for response in method.method_responses : can(response.response_models) ?
            can(tomap(response.response_models)) && length(response.response_models) > 0 : # the validation
            true]                                                                          # method_responses is optional
          , false)) :                                                                      # did any falses return in the list?
        true]
      , false)) :
    true)
    error_message = "Optional attribute 'method_responses.response_models' of 'api_gateway_methods' must be a map with attributes > 0."
  }

  // method_responses.response_parameters
  validation {
    condition = (var.api_gateway_methods != [] ?
      ! can(index(
        [for method in var.api_gateway_methods : can(method.method_responses) ?
          ! can(index([for response in method.method_responses : can(response.response_parameters) ?
            can(tomap(response.response_parameters)) && length(response.response_parameters) > 0 : # the validation
            true]                                                                                  # method_responses is optional
          , false)) :                                                                              # did any falses return in the list?
        true]
      , false)) :
    true)
    error_message = "Optional attribute 'method_responses.response_parameters' of 'api_gateway_methods' must be a map with attributes > 0."
  }
}
