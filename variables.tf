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
    error_message = "Variable object api_gateway must be provided."
  }

  // name
  validation {
    condition     = try(length(tostring(var.api_gateway.name)) > 1)
    error_message = "Attribute name of api_gateway must be provided."
  }

  // description
  validation {
    condition     = can(tostring(lookup(var.api_gateway, "description", "")))
    error_message = "Optional attribute description of api_gateway must be a string if specified."
  }

  // binary_media_types
  validation {
    condition = can(toset([
      for binary_media_type in lookup(var.api_gateway, "binary_media_types", []) : regex("^[\\-\\w\\.]+/[\\-\\w\\.]+$", binary_media_type)
    ]))
    error_message = "Optional attribute binary_media_types of api_gateway must be a set of valid MIME types if specified."
  }

  // minimum_compression_size
  validation {
    condition     = tonumber(lookup(var.api_gateway, "minimum_compression_size", 0)) >= 0 && tonumber(lookup(var.api_gateway, "minimum_compression_size", 0)) <= 10485760
    error_message = "Optional attribute minimum_compression_size of api_gateway must be non-negative between 0 and 10485760 (inclusive) if specified."
  }

  // api_key_source
  validation {
    condition     = contains(["HEADER", "AUTHORIZER"], tostring(lookup(var.api_gateway, "api_key_source", "HEADER")))
    error_message = "Optional attribute api_key_source of api_gateway must be one of:\n\t- HEADER\n\t- AUTHORIZER\n if specified."
  }

  // endpoint_configuration
  validation {
    condition     = can(var.api_gateway.endpoint_configuration) ? length(try(toset(var.api_gateway.endpoint_configuration.types), [])) == 1 : true
    error_message = "Optional attribute endpoint_configuration of api_gateway must be an object with a 'types' attribute of type set(string) and length 1."
  }

  // endpoint_configuration.types
  validation {
    condition     = can(var.api_gateway.endpoint_configuration.types[0]) ? contains(["EDGE", "REGIONAL", "PRIVATE"], var.api_gateway.endpoint_configuration.types[0]) : true
    error_message = "Attribute types of api_gateway.endpoint_configuration must be of type set(string) and only include the following values:\n\t- EDGE\n\t- REGIONAL\n\t- PRIVATE\n."
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
    error_message = "Attribute types of api_gateway.endpoint_configuration.vpc_endpoint_ids must: \n\t- only be specified when api_gateway.endpoint_configuration.types is PRIVATE\n\t- be a set of VPC Endpoint IDs\n."
  }
}

variable "api_gateway_deployment" {
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

variable "api_gateway_stages" {
  description = "AWS API Gateway stage."
  default     = []
  type        = set(any)
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

variable "api_gateway_models" {
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

variable "api_keys" {
  description = "AWS API Gateway API Keys."
  default     = []
  type        = set(any)
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

variable "vpc_links" {
  description = "AWS API Gateway VPC links."
  default     = []
  type        = set(any)
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
    error_message = "Optional attribute 'target_arns' of 'vpc_links' must be a set of at least one string."
  }
}

variable "authorizer_definitions" {
  description = "AWS API Gateway authorizer."
  default     = []
  type        = set(any)
  
  /*
  type = list(object({
    authorizer_name                  = string (required) - The name of the authorizer.
    authorizer_uri                   = string (required) - The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations.
    identity_source                  = string (optional) - The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. \"method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName\".
    identity_validation_expression   = string (optional) - A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response.
    authorizer_result_ttl_in_seconds = number (optional) - The TTL of cached authorizer results in seconds. Defaults to 300.
    authorizer_credentials           = string (optional) 
    authorizer_type                  = string (optional) The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN.
    authorization                    = string (optional) The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS).
    provider_arns                    = string (optional) Required for type COGNITO_USER_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}.
  }))
  */

  // authoizer_name
  validation {
    condition     = var.authorizer_definitions != [] ? ! can(index([for auth in var.authorizer_definitions : can(lookup(auth, "authorizer_name")) ? length(lookup(auth, "authorizer_name")) > 1 : false], false)) : true
    error_message = "If the set of 'authorizer_definitions' is provided, each value must contain an attribute 'authorizer_name' with length > 1."
  }
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
