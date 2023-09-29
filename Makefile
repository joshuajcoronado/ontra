# Define the Terraform commands
TF_APPLY_ECR = terraform apply -target=aws_ecr_repository.ontra_repository -auto-approve
TF_APPLY = terraform apply -auto-approve
TF_DESTROY = terraform destroy -auto-approve

# Define the create target
create:
	@echo "Applying Terraform to create ECR repository..."
	@$(TF_APPLY_ECR)
	@echo "Login into our ECR repo"
	@eval $$(terraform output -json | jq -r '.docker_login_command.value')
	@echo "Building Docker image..."
	@docker build -t ontra -f Containerfile .
	@echo "Tag the Docker image..."
	@eval $$(terraform output -json | jq -r '.docker_tag_command.value')
	@echo "PUSH the image..."
	@eval $$(terraform output -json | jq -r '.docker_push_command.value')
	@echo "Applying Terraform to create remaining resources..."
	@$(TF_APPLY)

# Define the destroy target
destroy:
	@echo "Destroying all images in ecr.."
	@./delete-images.sh  $(shell terraform output -json image_repo_name) $(shell terraform output -json region)
	@echo "Destroying all Terraform resources..."
	@$(TF_DESTROY)

get:
	@echo "Let's test the endpoint..."
	@curl "$(shell terraform output -json api_gateway_url)" -H "Accept: application/json"

# Define the default target
all: create
