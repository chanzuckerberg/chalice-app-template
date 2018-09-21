# Chalice App Template

This repo is an AWS Lambda serverless app template with Terraform deployment management. It is intended to guide you to
good choices for ease of development and operations, without being overly opinionated about your workflow.

[AWS Lambda](https://aws.amazon.com/lambda/) is a serverless application platform that we use to build web services,
APIs, and event handlers on AWS. Lambda scales quickly to accommodate burst loads, and integrates tightly
with [many AWS event sources](http://docs.aws.amazon.com/lambda/latest/dg/invoking-lambda-function.html), allowing us to
build simpler, more efficient and maintainable applications on AWS.

[Terraform](https://www.terraform.io/) is
an [Infrastructure-as-Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) framework that we use to manage our
cloud resources. Terraform allows us to reproducibly and securely manage our AWS infrastructure.

Out of the box, Terraform and Lambda require a lot of configuration and domain knowledge to work together. You need to
know how to package your function and its dependencies, configure its IAM role, set up event sources, configure API
Gateway, set up a Terraform credentials source and state backend, and more, depending on your application. In this
repository, we provide the tools to take care of all this in a minimalistic, well-documented, intuitive way.

To manage the Lambda packaging, we use [Chalice](https://github.com/aws/chalice), a Python microframework developed by
AWS for Lambda. The template in this repo builds upon the output of `chalice new-project`.

Instead of letting Chalice directly deploy our app, we run `chalice package`, which builds the app and produces
a [SAM](https://github.com/awslabs/serverless-application-model) template, which is a kind
of [CloudFormation](https://aws.amazon.com/cloudformation/) template. We then use Terraform to deploy the app from this
template.

We also provide a recipe to easily manage Terraform credentials and state on AWS. The AWS API credentials are imported
on demand from your [AWS CLI](https://aws.amazon.com/cli/) config, which allows you to centrally manage your
credentials, [Assume Role](https://docs.aws.amazon.com/cli/latest/userguide/cli-roles.html) configurations, and regions
using standard AWS conventions. Terraform state files are saved using
the [Terraform S3 backend](https://www.terraform.io/docs/backends/types/s3.html), keyed by your app name.

To deploy the app, type `make deploy` in this directory.

Filename              | Purpose                                 | Information links
----------------------|-----------------------------------------|------------------------------------------
`app.py`              | The application entry point             | [Chalice](https://github.com/aws/chalice)
`requirements.txt`    | Application dependencies                | [Pip requirements files](https://pip.readthedocs.io/en/1.1/requirements.html)
`requirements-dev.txt`| Developer environment dependencies      | [Pip requirements files](https://pip.readthedocs.io/en/1.1/requirements.html)
`Makefile`            | Tools for packaging and deploying       |
`terraform-deploy.tf` | Terraform config file for deploying     | [Terraform Configuration](https://www.terraform.io/docs/configuration/)
`.chalice/config.json`| Chalice config file for the app         | [Chalice](https://github.com/aws/chalice)
`test/test.py`        | Test suite template                     | [Python unittest](https://docs.python.org/3/library/unittest.html)
`.travis.yml`         | Travis CI (CI/CD) configuration         | [Travis CI](https://docs.travis-ci.com/user/customizing-the-build/)

## How to create a new app from this template
1. Install the dependencies: `pip install -r requirements-dev.txt` and Terraform (`brew install terraform` or
   https://www.terraform.io/downloads.html)
1. Configure the AWS CLI (`pip install awscli`; `aws configure`).
1. Ensure the S3 bucket `tfstate-<YOUR_AWS_ACCOUNT_ID>` exists, or modify the Makefile to reference a different bucket.
1. Fork or copy the contents of this repo to a new directory.
1. Replace the name of your app in `.chalice/config.json`.
1. Edit `app.py` and `requirements.txt` to create your app.
1. Deploy your app by running `make deploy`. The deployment results, including your Lambda's EndpointURL, will be
   printed to the terminal.

To redeploy your app after updating, run `make deploy` again. To undeploy the app and delete all associated resources,
run `make destroy`.

## Testing
The test suite in `test/test.py` runs Chalice in local mode for unit testing. You can invoke it using `make test`.

## Managing the Lambda IAM role and assume role policy
TODO
