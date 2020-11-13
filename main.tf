provider "aws" {
  region = "us-east-1"
}

locals {

  ##################
  ## Set defaults ##
  ##################

  default_managedby_description = "Managed by the P&G AWS API Gateway Terraform Module https://github.com/procter-gamble/terraform-module-aws-api-gateway.git"

  // api_gateway
  api_gateway_defaults = {
    // name                              = string (required)
    api_key_source                      = null
    binary_media_types                  = null
    description                         = local.default_managedby_description
    endpoint_configuration              = null
    minimum_compression_size            = null
    policy                              = null
    custom_domain                       = null
    hosted_zone                         = null
    api_gateway_client_cert_enabled     = null
    api_gateway_client_cert_description = local.default_managedby_description
  }
  api_gateway = merge(local.api_gateway_defaults, var.api_gateway)

  // api_gateway_deployment defaults
  api_gateway_deployment_defaults = {
    // stage_name      = string (required)
    stage_description = local.default_managedby_description
    description       = local.default_managedby_description
    variables         = null
  }
  api_gateway_deployment = var.api_gateway_deployment != null ? merge(local.api_gateway_deployment_defaults, var.api_gateway_deployment) : null

  // api_gateway_stages defaults
  api_gateway_stage_defaults = {
    // stage_name          = string
    access_log_settings   = null
    cache_cluster_enabled = null
    cache_cluster_size    = null
    client_certificate_id = null
    documentation_version = null
    stage_description     = local.default_managedby_description
    stage_variables       = null
    xray_tracing_enabled  = null
  }
  api_gateway_stages = var.api_gateway_stages != null ? [for stage in var.api_gateway_stages : merge(local.api_gateway_stage_defaults, stage)] : null

  // api_gateway_models defaults
  api_gateway_model_defaults = {
    // name         = string (required)
    description  = local.default_managedby_description
    content_type = "application/json"
    schema       = "{\"type\":\"object\"}"
  }
  api_gateway_models = var.api_gateway_models != null ? [for model in var.api_gateway_models : merge(local.api_gateway_model_defaults, model)] : null

  // api_keys
  api_keys_defaults = {
    // key_name         = string (required)
    key_description = local.default_managedby_description
    enabled         = true
    value           = null
  }
  api_gatewapi_keys = var.api_keys != null ? [for api_key in var.api_keys : merge(local.api_keys_defaults, api_key)] : null

  // vpc_links
  vpc_links_defaults = {
    // vpc_link_name     = string (required)
    vpc_link_description = local.default_managedby_description
    vpc_link_name        = "asdf"
    // target_arns       = ["arn"]
  }
  vpc_links = var.vpc_links != null ? [for vpc_link in var.vpc_links : merge(local.vpc_links_defaults, vpc_link)] : null

  ###########################
  ## Resource path parsing ##
  ###########################
  /*
  paths = [for method in var.api_gateway_methods : method.resource_path]

  paths_as_segments = [for path in local.paths : split("/", path)]

  unique_paths = (toset(
    flatten(
      [for path_segments in local.paths_as_segments :
        [for end_index in range(length(path_segments), 0) :
  join("/", slice(path_segments, 0, end_index))]])))

  length_paths_map = (transpose({ for path in local.unique_paths : path => [length(split("/", path))] }))

  length_path_segments_map = ({ for quantity, paths in local.length_paths_map : quantity => [for path in paths : split("/", path)] })

  max_number_of_levels = length(local.length_path_segments_map)

  resource_method_map = (
    merge(
      zipmap(flatten(local.length_paths_map[1]), values(aws_api_gateway_resource.first_paths)[*]["id"]),
      local.max_number_of_levels > 1 ? zipmap(flatten(local.length_paths_map[2]), values(aws_api_gateway_resource.second_paths)[*]["id"]) : {},
      local.max_number_of_levels > 2 ? zipmap(flatten(local.length_paths_map[3]), values(aws_api_gateway_resource.third_paths)[*]["id"]) : {},
      local.max_number_of_levels > 3 ? zipmap(flatten(local.length_paths_map[4]), values(aws_api_gateway_resource.fourth_paths)[*]["id"]) : {},
      local.max_number_of_levels > 4 ? zipmap(flatten(local.length_paths_map[5]), values(aws_api_gateway_resource.fifth_paths)[*]["id"]) : {}
    )
  )

  ########################
  ## Authorizor mapping ##
  ########################
  authorizers = zipmap([for auth in var.authorizer_definitions : auth.authorizer_name], aws_api_gateway_authorizer.default[*]["id"])
*/
}

# Resource    : API Gateway 
# Description : Terraform resource to create an API Gateway REST API on AWS.
resource aws_api_gateway_rest_api default {
  count = var.enabled ? 1 : 0

  api_key_source           = local.api_gateway.api_key_source
  binary_media_types       = local.api_gateway.binary_media_types
  description              = local.api_gateway.description
  minimum_compression_size = local.api_gateway.minimum_compression_size
  name                     = local.api_gateway.name
  policy                   = local.api_gateway.policy

  dynamic endpoint_configuration {
    for_each = local.api_gateway.endpoint_configuration == null ? [] : [local.api_gateway.endpoint_configuration]
    content {
      types            = endpoint_configuration.value.types
      vpc_endpoint_ids = lookup(endpoint_configuration.value, "vpc_endpoint_ids", null)
    }
  }

  tags = var.tags
}

# Resource    : Api Gateway Client Certificate
# Description : Terraform resource to create Api Gateway Client Certificate on AWS.
resource aws_api_gateway_client_certificate default {
  count = can(local.api_gateway.api_gateway_client_cert_enabled) ? 1 : 0

  description = local.api_gateway.api_gateway_client_cert_description
  tags        = var.tags
}

# # Resource    : Api Gateway Custom Domain Name
# # Description : Terraform resource to create Api Gateway Custom Domain on AWS.
# resource aws_api_gateway_domain_name api_domain {
#   count = length(local.api_gateway.custom_domain) > 0 ? 1 : 0

#   certificate_arn = module.acm_certificate.arn[count.index]
#   domain_name     = local.api_gateway.custom_domain
# }

# # Resource    : Api Gateway Base Path Mapping
# # Description : Terraform resource to create Api Gateway base path mapping on AWS.
# resource aws_api_gateway_base_path_mapping test {
#   count      = length(local.api_gateway.custom_domain) > 0 ? 1 : 0
#   depends_on = [aws_api_gateway_deployment.default]

#   api_id = aws_api_gateway_rest_api.default.*.id[0]
#   // TODO:  Which stage?
#   // stage_name  = var.stage_name
#   domain_name = local.api_gateway.custom_domain
# }

# Resource    : Api Gateway Deployment
# Description : Terraform resource to create Api Gateway Deployment on AWS.
resource aws_api_gateway_deployment default {
  count = local.api_gateway_deployment != null ? length(local.api_gateway_deployment) : 0

  // depends_on = [aws_api_gateway_method.default, aws_api_gateway_integration.default]

  rest_api_id       = aws_api_gateway_rest_api.default.*.id[0]
  stage_name        = local.api_gateway_deployment.stage_name
  description       = local.api_gateway_deployment.description
  stage_description = local.api_gateway_deployment.stage_description
  variables         = local.api_gateway_deployment.variables
}

# Resource    : Api Gateway Stage
# Description : Terraform resource to create Api Gateway Stage on AWS
resource aws_api_gateway_stage default {
  count = local.api_gateway_deployment != null ? length(local.api_gateway_stages) : 0

  rest_api_id           = aws_api_gateway_rest_api.default.*.id[0]
  deployment_id         = aws_api_gateway_deployment.default.*.id[0]
  stage_name            = element(local.api_gateway_stages, count.index).stage_name
  cache_cluster_enabled = element(local.api_gateway_stages, count.index).cache_cluster_enabled
  cache_cluster_size    = element(local.api_gateway_stages, count.index).cache_cluster_size
  client_certificate_id = length(element(local.api_gateway_stages, count.index).client_certificate_id) > 0 ? element(local.api_gateway_stages, count.index).client_certificate_id : (local.api_gateway.api_gateway_client_cert_enabled ? aws_api_gateway_client_certificate.default.*.id[0] : "")
  description           = element(local.api_gateway_stages, count.index).stage_description
  documentation_version = element(local.api_gateway_stages, count.index).documentation_version
  variables             = element(local.api_gateway_stages, count.index).stage_variables
  xray_tracing_enabled  = element(local.api_gateway_stages, count.index).xray_tracing_enabled

  dynamic "access_log_settings" {
    for_each = element(local.api_gateway_stages, count.index).access_log_settings
    content {
      destination_arn = access_log_settings.value["destination_arn"]
      format          = access_log_settings.value["format"]
    }
  }

  tags = var.tags
}

# Resource    : Api Gateway Model
# Description : Terraform resource to create Api Gateway model on AWS.
resource aws_api_gateway_model default {
  count = length(local.api_gateway_models)

  rest_api_id  = aws_api_gateway_rest_api.default.*.id[0]
  name         = element(local.api_gateway_models, count.index).name
  description  = element(local.api_gateway_models, count.index).description
  content_type = element(local.api_gateway_models, count.index).content_type
  schema       = element(local.api_gateway_models, count.index).schema
}

# Resource    : Api Gateway Api Key
# Description : Terraform resource to create Api Gateway Api Key on AWS.
resource aws_api_gateway_api_key default {
  count = length(local.api_keys)

  name        = element(local.api_keys, count.index).key_name
  description = length(element(local.api_keys, count.index).key_description) > 0 ? element(local.api_keys, count.index).key_description : ""
  enabled     = element(local.api_keys, count.index).enabled
  value       = length(element(local.api_keys, count.index).value) > 0 ? element(local.api_keys, count.index).value : null

  tags = var.tags
}

# Resource    : Api Gateway VPC Link
# Description : Terraform resource to create Api Gateway VPC Link on AWS.
resource aws_api_gateway_vpc_link default {
  count = length(local.vpc_links)

  name        = element(local.vpc_links, count.index).vpc_link_name
  description = length(element(local.vpc_links, count.index).vpc_link_description) > 0 ? element(local.vpc_links, count.index).vpc_link_description : ""
  target_arns = element(local.vpc_links, count.index).target_arns

  tags = var.tags
}

# # Module      : Api Gateway Authorizer
# # Description : Terraform module to create Api Gateway Authorizer resource on AWS.
# resource "aws_api_gateway_authorizer" "default" {
#   count = length(var.authorizer_definitions)

#   rest_api_id                      = aws_api_gateway_rest_api.default.*.id[0]
#   name                             = element(var.authorizer_definitions, count.index).authorizer_name
#   authorizer_uri                   = length(element(var.authorizer_definitions, count.index).authorizer_uri) > 0 ? element(var.authorizer_definitions, count.index).authorizer_uri : ""
#   authorizer_credentials           = length(element(var.authorizer_definitions, count.index).authorizer_credentials) > 0 ? element(var.authorizer_definitions, count.index).authorizer_credentials : ""
#   authorizer_result_ttl_in_seconds = element(var.authorizer_definitions, count.index).authorizer_result_ttl_in_seconds > 0 ? element(var.authorizer_definitions, count.index).authorizer_result_ttl_in_seconds : 0
#   identity_source                  = length(element(var.authorizer_definitions, count.index).identity_source) > 0 ? element(var.authorizer_definitions, count.index).identity_source : "method.request.header.Authorization"
#   type                             = length(element(var.authorizer_definitions, count.index).authorizer_type) > 0 ? element(var.authorizer_definitions, count.index).authorizer_type : "TOKEN"
#   identity_validation_expression   = length(element(var.authorizer_definitions, count.index).identity_validation_expression) > 0 ? element(var.authorizer_definitions, count.index).identity_validation_expression : ""
#   provider_arns                    = length(element(var.authorizer_definitions, count.index).provider_arns) > 0 ? element(var.authorizer_definitions, count.index).provider_arns : null
# }

# # Module      : Api Gateway Resources (curently supporting up to 5 nested levels)
# # Description : Terraform module to create Api Gateway resource on AWS, at the root level
# resource "aws_api_gateway_resource" "first_paths" {
#   for_each = toset(flatten(local.length_path_segments_map[1]))

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   parent_id   = aws_api_gateway_rest_api.default.*.root_resource_id[0]
#   path_part   = each.value
# }

# resource "aws_api_gateway_resource" "second_paths" {
#   for_each = local.max_number_of_levels > 1 ? { for path in local.length_path_segments_map[2] : join("/", path) => { segment = path[1], parent = join("/", slice(path, 0, 1)) } } : {}

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   parent_id   = aws_api_gateway_resource.first_paths[each.value.parent].id
#   path_part   = each.value.segment
# }

# resource "aws_api_gateway_resource" "third_paths" {
#   for_each = local.max_number_of_levels > 2 ? { for path in local.length_path_segments_map[3] : join("/", path) => { segment = path[2], parent = join("/", slice(path, 0, 2)) } } : {}

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   parent_id   = aws_api_gateway_resource.second_paths[each.value.parent].id
#   path_part   = each.value.segment
# }

# resource "aws_api_gateway_resource" "fourth_paths" {
#   for_each = local.max_number_of_levels > 3 ? { for path in local.length_path_segments_map[4] : join("/", path) => { segment = path[3], parent = join("/", slice(path, 0, 3)) } } : {}

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   parent_id   = aws_api_gateway_resource.third_paths[each.value.parent].id
#   path_part   = each.value.segment
# }

# resource "aws_api_gateway_resource" "fifth_paths" {
#   for_each = local.max_number_of_levels > 4 ? { for path in local.length_path_segments_map[5] : join("/", path) => { segment = path[4], parent = join("/", slice(path, 0, 4)) } } : {}

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   parent_id   = aws_api_gateway_resource.fourth_paths[each.value.parent].id
#   path_part   = each.value.segment
# }

# # Module      : Api Gateway Method
# # Description : Terraform module to create Api Gateway Method resource on AWS.
# resource "aws_api_gateway_method" "default" {
#   count = length(var.api_gateway_methods)

#   rest_api_id          = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id          = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method          = element(var.api_gateway_methods, count.index).http_method
#   authorization        = length(element(var.api_gateway_methods, count.index).authorization) > 0 ? element(var.api_gateway_methods, count.index).authorization : "NONE"
#   authorizer_id        = length(element(var.api_gateway_methods, count.index).authorizer_uri) > 0 ? element(var.api_gateway_methods, count.index).authorizer_uri : length(element(var.api_gateway_methods, count.index).authorizer_name) > 0 ? lookup(local.authorizers, element(var.api_gateway_methods, count.index).authorizer_name, null) : null
#   authorization_scopes = length(element(var.api_gateway_methods, count.index).authorization_scope) > 0 ? element(var.api_gateway_methods, count.index).authorization_scope : null
#   api_key_required     = element(var.api_gateway_methods, count.index).api_key_required
#   request_models       = length(element(var.api_gateway_methods, count.index).request_models) > 0 ? element(var.api_gateway_methods, count.index).request_models : { "application/json" = "Empty" }
#   request_validator_id = length(element(var.api_gateway_methods, count.index).request_validator_id) > 0 ? element(var.api_gateway_methods, count.index).request_validator_id : null
#   request_parameters   = length(element(var.api_gateway_methods, count.index).integration.integration_request.request_parameters) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_request.request_parameters : {}
# }

# resource "aws_api_gateway_method" "options_method" {
#   count = length(var.api_gateway_methods)

#   rest_api_id   = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id   = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "options_200" {
#   count = length(var.api_gateway_methods)

#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method = aws_api_gateway_method.options_method.*.http_method[count.index]
#   status_code = "200"

#   response_models = { "application/json" = "Empty" }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"      = true
#     "method.response.header.Access-Control-Allow-Headers"     = true
#     "method.response.header.Access-Control-Allow-Methods"     = true
#     "method.response.header.Access-Control-Allow-Credentials" = true
#   }

#   depends_on = [aws_api_gateway_method.options_method]
# }

# # Module      : Api Gateway Method Response
# # Description : Terraform module to create Api Gateway Method Response resource on AWS.
# resource "aws_api_gateway_method_response" "default" {
#   count = length(var.api_gateway_methods)

#   rest_api_id         = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id         = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method         = aws_api_gateway_method.default.*.http_method[count.index]
#   status_code         = length(element(var.api_gateway_methods, count.index).gateway_method_response.status_code) > 0 ? element(var.api_gateway_methods, count.index).gateway_method_response.status_code : 200
#   response_models     = length(element(var.api_gateway_methods, count.index).gateway_method_response.response_models) > 0 ? element(var.api_gateway_methods, count.index).gateway_method_response.response_models : {}
#   response_parameters = length(element(var.api_gateway_methods, count.index).gateway_method_response.response_parameters) > 0 ? element(var.api_gateway_methods, count.index).gateway_method_response.response_parameters : {}
# }

# # # Module      : Api Gateway Integration
# # # Description : Terraform module to create Api Gateway Integration resource on AWS.
# resource "aws_api_gateway_integration" "default" {
#   count = length(var.api_gateway_methods)

#   rest_api_id             = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id             = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method             = aws_api_gateway_method.default.*.http_method[count.index]
#   integration_http_method = length(element(var.api_gateway_methods, count.index).integration.integration_http_method) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_http_method : "POST"
#   type                    = length(element(var.api_gateway_methods, count.index).integration.integration_type) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_type : "AWS_PROXY"
#   connection_type         = length(element(var.api_gateway_methods, count.index).integration.connection_type) > 0 ? element(var.api_gateway_methods, count.index).integration.connection_type : "INTERNET"
#   connection_id           = length(element(var.api_gateway_methods, count.index).integration.connection_id) > 0 ? element(var.api_gateway_methods, count.index).integration.connection_id : ""
#   uri                     = length(element(var.api_gateway_methods, count.index).integration.uri) > 0 ? element(var.api_gateway_methods, count.index).integration.uri : ""
#   credentials             = length(element(var.api_gateway_methods, count.index).integration.credentials) > 0 ? element(var.api_gateway_methods, count.index).integration.credentials : ""
#   request_parameters      = length(element(var.api_gateway_methods, count.index).integration.integration_request.request_parameters) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_request.request_parameters : {}
#   request_templates       = length(element(var.api_gateway_methods, count.index).integration.integration_request.request_templates) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_request.request_templates : {}
#   passthrough_behavior    = length(element(var.api_gateway_methods, count.index).integration.passthrough_behavior) > 0 ? element(var.api_gateway_methods, count.index).integration.passthrough_behavior : null
#   cache_key_parameters    = length(element(var.api_gateway_methods, count.index).integration.cache_key_parameters) > 0 ? element(var.api_gateway_methods, count.index).integration.cache_key_parameters : []
#   cache_namespace         = length(element(var.api_gateway_methods, count.index).integration.cache_namespace) > 0 ? element(var.api_gateway_methods, count.index).integration.cache_namespaces : ""
#   content_handling        = length(element(var.api_gateway_methods, count.index).integration.integration_request.request_content_handling) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_request.request_content_handling : null
#   timeout_milliseconds    = length(element(var.api_gateway_methods, count.index).integration.timeout_milliseconds) > 0 ? element(var.api_gateway_methods, count.index).integration.timeout_milliseconds : 29000

#   depends_on = [aws_api_gateway_method.default]
# }

# # Module      : Api Gateway Integration Response
# # Description : Terraform module to create Api Gateway Integration Response resource on AWS for creating api.
# resource "aws_api_gateway_integration_response" "default" {
#   count       = length(aws_api_gateway_integration.default.*.id)
#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method = aws_api_gateway_method.default.*.http_method[count.index]
#   status_code = aws_api_gateway_method_response.default.*.status_code[count.index]

#   response_parameters = length(element(var.api_gateway_methods, count.index).integration.integration_response.response_parameters) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_response.response_parameters : {}
#   response_templates  = length(element(var.api_gateway_methods, count.index).integration.integration_response.response_templates) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_response.response_templates : {}
#   content_handling    = length(element(var.api_gateway_methods, count.index).integration.integration_response.response_content_handling) > 0 ? element(var.api_gateway_methods, count.index).integration.integration_response.response_content_handling : null
# }

# resource "aws_api_gateway_integration" "options_integration" {
#   count       = length(aws_api_gateway_method.default.*.id)
#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method = aws_api_gateway_method.options_method.*.http_method[count.index]

#   type             = "MOCK"
#   content_handling = "CONVERT_TO_TEXT"

#   depends_on = [aws_api_gateway_method.options_method]
# }

# resource "aws_api_gateway_integration_response" "options_integration_response" {
#   count       = length(aws_api_gateway_integration.options_integration.*.id)
#   rest_api_id = aws_api_gateway_rest_api.default.*.id[0]
#   resource_id = lookup(local.resource_method_map, element(var.api_gateway_methods, count.index).resource_path)
#   http_method = aws_api_gateway_method.options_method.*.http_method[count.index]
#   status_code = aws_api_gateway_method_response.options_200.*.status_code[count.index]

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
#     "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
#   }

#   depends_on = [
#     aws_api_gateway_method_response.options_200,
#     aws_api_gateway_integration.options_integration,
#   ]
# 
