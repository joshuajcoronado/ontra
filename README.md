# ontra

## How to

Hi! This repo contains all you need to deploy a small api endpoint to AWS that responds to HTTP GET requests and returns a JSON
payload in the form `{"The current epoch time": <EPOCH_TIME>}` where `<EPOCH_TIME>` is an
integer representing the current epoch time in seconds.
### Requirements
To get started, make sure you have the following things installed locally
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [docker](https://docs.docker.com/desktop/)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Deploy
```bash
# start by exporting your AWS creds for use by terraform and awscli
# make sure to replace with your creds
export AWS_SECRET_ACCESS_KEY="mysecretkey"
export AWS_ACCESS_KEY_ID="mysecretid"

# assuming you've downloaded this repo locally, and are in the directory
# let's build our infra!
make build

# let's test our infra!
make get

# now that we're done, let's destroy everything
make destroy
```

## How things work
At a high level, we leverage an [Amazon API Gateway](https://aws.amazon.com/api-gateway/) to act as the front door to our service hosted on [AWS Lambda](https://aws.amazon.com/lambda/). 
Our container image is hosted in [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/).

### make build
1. A targeted `terraform apply` to creates our ECR registry to host our container image
2. It then authenticates docker with ECR, so you can push a local image to it
3. A docker build is kicked off that builds an arm64 image, and pushed to ECR
   - ECR doesn't support multiarch images, and so we build specifically for arm64, so that architecture differences between build machines don't break this step
   - The entire application is contained in `app.py` which simply returns a formatted json response with the time
   - The `Containerfile` is a multistage build that creates a distroless small footprint image that
   - The created image is then pushed to ECR
4. A complete `terraform apply` which creates the following
   - An REST API gateway that has an `/time` path that accepts GET requests
   - A lambda that runs our image from ECR
   - A API Gateway integration to link up the gateway to the lambda function
   - Permissions to connect ECR + Lambda, Cloudwatch + Lambda (for monitoring), Lambda + API Gateway
   
### Make get
This just runs a curl against our service

### Make destroy
1. This starts by deleting images in the ECR gateway
2. Runs `terraform destroy` to delete all our resources

## Developing
### Testing locally
You can test locally, by spinning up a docker image. 

```shell
$ docker run -p 9000:8080  ontra
30 Sep 2023 00:43:17,508 [INFO] (rapid) exec '/usr/bin/python' (cwd=/var/task, handler=app.handler)

# in another shell
$ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'                           [17:42:57]
{"statusCode": 200, "body": "{\"The current epoch time\": 1696034577}", "headers": {"Content-Type": "application/json"}}%
```

