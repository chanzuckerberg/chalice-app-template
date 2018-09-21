SHELL=/bin/bash
SAM_TX="import sys, json, boto3, samtranslator.translator.transform as t, samtranslator.public.translator as pt; \
        print(json.dumps(t.transform(json.load(sys.stdin), {}, pt.ManagedPolicyLoader(boto3.client('iam')))))"
GET_CREDS="import json, boto3.session as s; \
           print(json.dumps(s.Session().get_credentials().get_frozen_credentials()._asdict()))"

export AWS_REGION=$(shell aws configure get region)
export AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity | jq -r .Account)
export TF_S3_BUCKET=tfstate-$(AWS_ACCOUNT_ID)
export APP_NAME=$(shell jq -r .app_name .chalice/config.json)

deploy: init package
	$(eval LAMBDA_MD5 = $(shell md5sum dist/deployment.zip | cut -f 1 -d ' '))
	aws s3 cp dist/deployment.zip s3://$(TF_S3_BUCKET)/$(LAMBDA_MD5).zip
	cat dist/sam.json | \
            jq '.Resources.APIHandler.Properties.CodeUri="s3://$(TF_S3_BUCKET)/$(LAMBDA_MD5).zip"' | \
            python -c $(SAM_TX) > dist/cloudformation.json
	terraform apply
	terraform state show aws_cloudformation_stack.lambda

package:
	chalice package dist

get-config:
	@python -c $(GET_CREDS) | jq ".region=env.AWS_REGION | .bucket=env.TF_S3_BUCKET | .key=env.APP_NAME"

init:
	-rm -f .terraform/terraform.tfstate
	terraform init --backend-config <($(MAKE) get-config)

destroy: init
	terraform destroy

clean:
	rm -rf dist .terraform .chalice/deployments

lint:
	flake8 *.py test

test: lint
	python ./test/test.py -v

.PHONY: deploy package init destroy clean lint test
