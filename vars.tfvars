# tags = { "bu" = "xyz" }


api_gateway = {
  name = "api-gateway"
  # description = "The test api-gateway"
  # binary_media_types                  = ["UTF-8-encoded"]
  # minimum_compression_size            = -1
  # api_key_source = "HEADER"
  # type           = ["EDGE"]
  # custom_domain = "api.bitlocker.np.pgcloud.com"
  # acm_cert_arn   = ""
  # api_gateway_client_cert_enabled     = false
  # api_gateway_client_cert_description = ""
}

# api_gateway_deployment = {
#   stage_name        = "afasdf"
# stage_description = "This is a default description"
# description       = "This is a default description"
#   variables         = {}
# }

# api_gateway_stages = [
#   {
#     stage_name = "asdf"
#     # stage_description     = null
#     stage_variables       = {}
#     cache_cluster_enabled = true
#     # cache_cluster_size    = 0.5
#     client_certificate_id = null
# documentation_version = "asdf"
# xray_tracing_enabled  = true
# access_log_settings = [
#   # {
#   #   destination_arn = "blah"
#   #   format          = "blah2"
#   # }
# ]
# },
# {
#   stage_name            = ""
#   stage_description     = "The description of the stage."
#   stage_variables       = {}
#   cache_cluster_enabled = false
#   cache_cluster_size    = 0.5
#   client_certificate_id = ""
#   documentation_version = ""
#   xray_tracing_enabled  = true
#   # access_log_settings = [
#   #   {
#   #     destination_arn = "blah"
#   #     format          = "blah2"
#   #   }
#   # ]
# },
#     {
#       stage_name = "hello"
#       }
# ]

# api_gateway_models = [
#   {
#     name = "asdf"
#         description  = {}
#             #     content_type = ""
#     #     schema       = ""
#   }
# ]

# api_keys = [
#   {
#     key_name        = "dfdfd"
# #     key_description = "KeyDesc"
#     enabled         = true
# #     value           = ""
#   }
# ]

# vpc_links = [
#   {
#     vpc_link_name = "asdf"
#     vpc_link_description  = "desc"
#     target_arns = ["arn"]
#   }
# ]

authorizer_definitions = [
  {
    authorizer_name = "pingFedAuth"
    authorizer_uri  = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-authorizor-lambda/invocations"
    # provider_arns = []
  }
]

api_gateway_methods = [
  {
    resource_path = "getBitlockerKey"
    api_method = {
      http_method     = "GET"
      authorizer_name = "pingFedAuth"
      # authorization = "NONE"
      integration = {
        uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"
      }
    }
    options_method = {
      integration_response = {
        response_parameters = {
          "method.response.header.Access-Control-Allow-Credentials" = "'true'"
          "method.response.header.Access-Control-Allow-Origin"      = "'https://blah'"
          "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
          "method.response.header.Access-Control-Allow-Methods"     = "'OPTIONS,GET,POST'"
        }
      }
    }
  },
  {
    resource_path = "getBitlockerKey/blah"
    api_method = {
      http_method     = "GET"
      authorizer_name = "pingFedAuth"
      # authorization = "NONE"
      integration = {
        uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"
      }
    }
    options_method = {
      integration_response = {
        response_parameters = {
          "method.response.header.Access-Control-Allow-Credentials" = "'true'"
          "method.response.header.Access-Control-Allow-Origin"      = "'https://blah'"
          "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
          "method.response.header.Access-Control-Allow-Methods"     = "'OPTIONS,GET,POST'"
        }
      }
    }
  },
  {
    resource_path = "getBitlockerKey/blah/getBitlockerKey"
    api_method = {
      http_method     = "GET"
      authorizer_name = "pingFedAuth"
      # authorization = "NONE"
      integration = {
        uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"
      }
    }
    options_method = {
      integration_response = {
        response_parameters = {
          "method.response.header.Access-Control-Allow-Credentials" = "'true'"
          "method.response.header.Access-Control-Allow-Origin"      = "'https://blah'"
          "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
          "method.response.header.Access-Control-Allow-Methods"     = "'OPTIONS,GET,POST'"
        }
      }
    }
  },
  {
    resource_path = "blah/getBitlockerKey"
    api_method = {
      http_method     = "GET"
      authorizer_name = "pingFedAuth"
      # authorization = "NONE"
      integration = {
        uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:459235286243:function:my-awesome-lambda/invocations"
      }
    }
    options_method = {
      integration_response = {
        response_parameters = {
          "method.response.header.Access-Control-Allow-Credentials" = "'true'"
          "method.response.header.Access-Control-Allow-Origin"      = "'https://blah'"
          "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
          "method.response.header.Access-Control-Allow-Methods"     = "'OPTIONS,GET,POST'"
        }
      }
    }
  }
]