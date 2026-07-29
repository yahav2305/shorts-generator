# shorts-media-generator

Generates a shorts-style text reading over video for popular shorts platform using AWS.

## Deploying infrastructure

All IaC is defined under `infrastructure/modules`, while configuration specific to a certain environment lives under `infrastructure/environments`.\
On a pull request to main from a feature branch with changes to the `infrastructure` folder, a CI/CD pipeline runs `terraform plan` for both dev and prod. Once the PR is merged the IaC for `dev` is applied, the CI/CD pauses for human review, and only once human review is accepted the `prod` environment is deployed, and once it has been deployed the dev environment is deleted to reduce costs.

## Deploying images

When a new image is created, its appropriate CI/CD pipeline will run.\
It will test the image, build it, push it to ECR (or update the image tag in ECR if it has been previously built in a feature branch), and update the terraform Iac configuration in the `infrastructure` folder to use the newer image tag. This will cause the infrastructure CI/CD pipeline to run again and deploy the new image to the relevant AWS resources.

## Hashing python packages

We hash python packages to ensure that we will not be effected from changes to the packages under the same tag. The process is done like this:

1. Create two files in the current working directory: one with the requirements.txt file that we want to add the hashes of the packages from (requirements.in), and one that we will write the package hashes to (requirements.out). Make sure that requirements.in has the necessary packages that we want to hash (dependencies, distributions, and operating systems will be resolved automatically).

1. Run a python environment in the required version for generating the requirements.txt file with the package hashes:

    ```sh
    docker run --rm \
      -v $(pwd):/app \
      -w /app \
      python:3.13 \
      sh -c "pip install pip-tools && pip-compile --generate-hashes requirements.in -o requirements.out"
    ```

1. Copy the contents of requirements.out to the relevant requirements.txt file in the repository

## Working in a local devcontainer

Each folder under the `docker` folder represents a Docker image. To work on one locally, use the devcontainer with the same name.\
After entering the devcontainer, make sure to run `aws login` to fetch credentials for working with AWS.
