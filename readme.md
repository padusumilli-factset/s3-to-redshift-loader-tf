1. fds_resources_access_role: fds-access-point, fds-sns,  s3, lambda-execution, sqs
2. redshift_lambda_execution_role: s3, lambda-execution, sqs, redshift


## Module Usage

In order to use FDS Terraform modules, a few pre-requisites need to be met:

* [Terraform](https://www.terraform.io/downloads.html) version `>= 0.13`


* [Python 3](https://www.python.org/downloads/) must be installed on the system running terraform


* We recommend running a virtualenv in the directory in which you will be executing your terraform. Within this virtualenv,
you will need to have `boto3` and python's `requests` libraries installed.


* `TF_VAR_STACK_PREFIX` - this environment variable *must* be set as it is required by both modules. 
This prefix can be associated with the current git branch from which you are deploying Terraform and enables deploying multiple branches 
of the same stack to the same AWS account. In the case of the master branch, the prefix should be set to an empty string. 
When deploying locally, this environment variable must be set manually in order for the modules to run.