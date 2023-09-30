# docker
DOCKER_BUILDER_NAME = ontrabuilder

# vars to use
export DOCKER_CLI_EXPERIMENTAL=enabled
export TF_VAR_region=us-west-2
export TF_VAR_repo_name=ontra
export TF_VAR_image_tag=4.0.0
export TF_VAR_image_arch=arm64

build:
	@echo "Create the ECR image registry..."
	@terraform apply -target=aws_ecr_repository.ontra_repository -auto-approve
	@echo "Now, let's login into ECR"
	@ECR_REPO_URL=$$(terraform output -raw image_repo) && \
	 aws ecr get-login-password --region $${TF_VAR_region} | docker login --username AWS --password-stdin $${ECR_REPO_URL}
	@if ! docker buildx ls | grep -q ${DOCKER_BUILDER_NAME}; then \
		echo "Creating a new builder instance '${DOCKER_BUILDER_NAME}'..."; \
		docker buildx create --use --name ${DOCKER_BUILDER_NAME} --platform linux/${TF_VAR_image_arch}; \
	else \
		echo "'${DOCKER_BUILDER_NAME}' instance already exists. Using existing instance..."; \
		docker buildx use ${DOCKER_BUILDER_NAME}; \
	fi
	@echo "Let's build our image!"
	@ECR_REPO_URL=$$(terraform output -raw image_repo) && \
     docker buildx build --platform linux/${TF_VAR_image_arch} -t $${ECR_REPO_URL}/${TF_VAR_repo_name}:${TF_VAR_image_tag} -f Containerfile . --push
	@echo "Apply the rest of the terraform..."
	@terraform apply -auto-approve

destroy:
	@echo "Destroying our image.."
	@aws ecr batch-delete-image --repository-name ${TF_VAR_repo_name} --image-ids imageTag=${TF_VAR_image_tag} --region ${TF_VAR_region}
	@echo "Destroying all Terraform resources..."
	@terraform destroy -auto-approve

get:
	@echo "Let's test the endpoint at $(shell terraform output -json api_gateway_url)"
	@echo curl "$(shell terraform output -json api_gateway_url)" -H "Accept: application/json"
	@curl "$(shell terraform output -json api_gateway_url)" -H "Accept: application/json"
