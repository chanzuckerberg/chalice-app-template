SHELL=/bin/bash -o pipefail
export APP_NAME=$(shell jq -r .app_name .chalice/config.json)
export STAGE=dev
export TF_DATA_DIR=.terraform.$(STAGE)
export TFSTATE_FILE=$(TF_DATA_DIR)/remote.tfstate
export TF_CLI_ARGS_output=--state $(TFSTATE_FILE)
export TF_CLI_ARGS_init=--backend-config $(APP_HOME)/$(TF_DATA_DIR)/aws_config.json

# See https://github.com/terraform-providers/terraform-provider-aws/issues/1184
export AWS_SDK_LOAD_CONFIG=1

deploy: init
	echo "$$(jq .resource.aws_api_gateway_deployment.rest_api.lifecycle.create_before_destroy=true chalice.tf.json)" > chalice.tf.json
	terraform apply

init: package
	$(eval AWS_REGION = $(shell aws configure get region))
	$(eval AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity | jq -r .Account))
	$(eval TF_S3_BUCKET = tfstate-$(AWS_ACCOUNT_ID))
	-rm -f $(TF_DATA_DIR)/*.tfstate
	mkdir -p $(TF_DATA_DIR)
	jq -n ".region=env.AWS_REGION | .bucket=env.TF_S3_BUCKET | .key=env.APP_NAME+env.STAGE" > $(TF_DATA_DIR)/aws_config.json
	terraform init

package:
	chalice package --pkg-format terraform .

destroy: init
	terraform destroy

clean:
	rm -rf dist .terraform .chalice/deployments

lint:
	flake8 *.py test

test: lint
	python ./test/test.py -v

.PHONY: deploy package init destroy clean lint test
