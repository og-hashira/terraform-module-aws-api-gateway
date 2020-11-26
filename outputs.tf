output "id" {
  value       = values(aws_api_gateway_rest_api.default)[*]["id"]
  description = "The ID of the REST API."
}

output "execution_arn" {
  value       = values(aws_api_gateway_rest_api.default)[*]["execution_arn"]
  description = "The Execution ARN of the REST API."
}