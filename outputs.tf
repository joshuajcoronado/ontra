output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.ontra_api.id}.execute-api.${var.region}.amazonaws.com/v1/time"
}

output "image_repo" {
  value = "${aws_ecr_repository.ontra_repository.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
}
