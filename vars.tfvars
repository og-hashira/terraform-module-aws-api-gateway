tags    = { "bu" = "xyz" }

api_gateway = {
  name = "api-gateway"
  # description                         = "The test api-gateway"
  # binary_media_types                  = ["UTF-8-encoded"]
  # minimum_compression_size            = -1
  # api_key_source                      = "HEADER"
  # type                                = ["EDGE"]
  custom_domain = "api.bitlocker.np.pgcloud.com"
  hosted_zone   = "np.pgcloud.com"
  # api_gateway_client_cert_enabled     = false
  # api_gateway_client_cert_description = ""
}

# api_gateway_deployment = {
#   stage_name        = "deploy"
#   stage_description = "This is a default description"
#   description       = "This is a default description"
#   variables         = null
# }

# api_gateway_stages = [
#     {
#       stage_name            = "asd"
#       stage_description     = "The description of the stage."
#       stage_variables       = {}
#       cache_cluster_enabled = true
#       # cache_cluster_size    = null
#       client_certificate_id = ""
#       documentation_version = ""
#       xray_tracing_enabled  = true
#       access_log_settings = [
#         # {
#         #   destination_arn = "blah"
#         #   format          = "blah2"
#         # }
#       ]
#     },
#     {
#       stage_name            = "asdfa"
#       stage_description     = "The description of the stage."
#       stage_variables       = {}
#       cache_cluster_enabled = false
#       cache_cluster_size    = 0.5
#       client_certificate_id = ""
#       documentation_version = ""
#       xray_tracing_enabled  = true
#       access_log_settings = [
#         {
#           destination_arn = "blah"
#           format          = "blah2"
#         }
#       ]
#     },
#     {
#       stage_name = "hello"
#       }
# ]

authorizer_definitions = [
  {
    authorizer_name                  = "pingFedAuth"
    authorizer_uri                   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-authorizor-lambda/invocations"
    identity_source                  = ""
    identity_validation_expression   = ""
    authorizer_result_ttl_in_seconds = 0
    authorizer_type                  = ""
    authorizer_credentials           = ""
    authorization                    = "CUSTOM"
    provider_arns                    = []
  },
  {
    authorizer_name                  = "pingFedAuth2"
    authorizer_uri                   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-authorizor-lambda/invocations"
    identity_source                  = ""
    identity_validation_expression   = ""
    authorizer_result_ttl_in_seconds = 0
    authorizer_type                  = ""
    authorizer_credentials           = ""
    authorization                    = "CUSTOM"
    provider_arns                    = []
  }
]

api_gateway_methods = [
  {
    resource_path        = "blah"
    http_method          = "POST"
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {}
    authorization        = ""
    authorizer_name      = ""
    authorizer_uri       = ""
    authorization_scope  = []

    integration = {
      connection_type         = ""
      connection_id           = ""
      credentials             = ""
      passthrough_behavior    = ""
      cache_key_parameters    = []
      cache_namespace         = ""
      timeout_milliseconds    = ""
      integration_http_method = ""
      integration_type        = ""
      uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"

      integration_request = {
        request_parameters       = {}
        request_templates        = {}
        request_content_handling = ""
      }
      integration_response = {
        response_parameters       = {}
        response_templates        = {}
        response_content_handling = ""
      }
    }
    gateway_method_response = {
      status_code         = ""
      response_type       = ""
      response_models     = {}
      response_template   = ""
      response_parameters = {}
    }
  },
  {
    resource_path        = "bosh"
    http_method          = "POST"
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {}
    authorization        = ""
    authorizer_uri       = ""
    authorizer_name      = ""
    authorization_scope  = []

    integration = {
      connection_type         = ""
      connection_id           = ""
      credentials             = ""
      passthrough_behavior    = ""
      cache_key_parameters    = []
      cache_namespace         = ""
      timeout_milliseconds    = ""
      integration_http_method = ""
      integration_type        = ""
      uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"

      integration_request = {
        request_parameters       = {}
        request_templates        = {}
        request_content_handling = ""
      }
      integration_response = {
        response_parameters       = {}
        response_templates        = {}
        response_content_handling = ""
      }
    }
    gateway_method_response = {
      status_code         = ""
      response_type       = ""
      response_models     = {}
      response_template   = ""
      response_parameters = {}
    }
  },
  {
    resource_path        = "blah/ble/bre"
    http_method          = "POST"
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {}
    authorization        = "CUSTOM"
    authorizer_uri       = ""
    authorizer_name      = "pingFedAuth2"
    authorization_scope  = []

    integration = {
      connection_type         = ""
      connection_id           = ""
      credentials             = ""
      passthrough_behavior    = ""
      cache_key_parameters    = []
      cache_namespace         = ""
      timeout_milliseconds    = ""
      integration_http_method = ""
      integration_type        = ""
      uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"

      integration_request = {
        request_parameters       = {}
        request_templates        = {}
        request_content_handling = ""
      }
      integration_response = {
        response_parameters       = {}
        response_templates        = {}
        response_content_handling = ""
      }
    }
    gateway_method_response = {
      status_code         = ""
      response_type       = ""
      response_models     = {}
      response_template   = ""
      response_parameters = {}
    }
  },
  {
    resource_path        = "blah/ble/bre2"
    http_method          = "POST"
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {}
    authorization        = "CUSTOM"
    authorizer_uri       = ""
    authorizer_name      = "pingFedAuth"
    authorization_scope  = []

    integration = {
      connection_type         = ""
      connection_id           = ""
      credentials             = ""
      passthrough_behavior    = ""
      cache_key_parameters    = []
      cache_namespace         = ""
      timeout_milliseconds    = ""
      integration_http_method = ""
      integration_type        = ""
      uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"

      integration_request = {
        request_parameters       = {}
        request_templates        = {}
        request_content_handling = ""
      }
      integration_response = {
        response_parameters       = {}
        response_templates        = {}
        response_content_handling = ""
      }
    }
    gateway_method_response = {
      status_code         = ""
      response_type       = ""
      response_models     = {}
      response_template   = ""
      response_parameters = {}
    }
  }
]

api_gateway_models = [
  {
    name         = "asdfasdf"
#     description  = "model1 desc"
#     content_type = ""
#     schema       = ""
  }
]

# api_keys = [
#   {
#     key_name        = "KeyName"
#     key_description = "KeyDesc"
#     enabled         = true
#     value           = ""
#   }
# ]

# vpc_links = [
#   {
#     vpc_link_name         = "blah"
#     vpc_link_description  = "desc"
#     target_arns           = ["arn"]
#   }
# ]

