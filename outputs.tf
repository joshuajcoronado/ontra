output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.ontra_api.id}.execute-api.${var.region}.amazonaws.com/v1/time"
}

output "docker_login_command" {
  value = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.ontra_repository.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
}

output "docker_tag_command" {
  value = "docker tag ontra:latest ${aws_ecr_repository.ontra_repository.repository_url}:${var.image_tag}"
}

output "docker_push_command" {
  value = "docker push ${aws_ecr_repository.ontra_repository.repository_url}:${var.image_tag}"
}

output "ecr_delete" {
  value = "aws ecr --region ${var.region} batch-delete-image --repository-name ${aws_ecr_repository.ontra_repository.name} --image-ids imageTag=my-image:1."
}

output "region" {
  value = "${var.region}"
}

output "image_repo_name" {
  value = "${var.name}"
}

output "image_repo" {
  value = "${aws_ecr_repository.ontra_repository.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
}