# Notes
In this document I am specifying how I accomplished the tasks for the DevOps home assignment.

## Creating the environment
1. Minikube cluster
    - I chose Minkikube because it is easy to install and works very well with my previously configured docker desktop environment.
2. Jenkins
    - I already had a Jenkins instance running on docker for learning.
    - Setup Kubernetes
        - Installed Kubernetes plugins and kubectl CLI on my Jenkins container.
        - Added KUBECONFIG for minikube in my Jenkins instance.
    - Docker registry credential
        - For docker image push I am using my own Dockerhub registry.
        - Added my credentials in Jenkins credentials so I can use it securely in the pipeline.
    - Why I chose Jenkins
        - Jenkins is widely used for CI/CD solutions and it offers a plenty of great options to resolve problems.
        - I mostly used Jenkins in my previous works and I really like to use it :) 
    - Other alternatives for Jenkins
        - Script: a simple bash or python script could also work for this lightweight CI/CD pipeline.
        - GitOps approach (ArgoCD): ArgoCD detects the changes in Git and applies it on the cluster.
        - Configuration management tools (Ansible): can handle the logic with playbooks.
## Create Docker image
- Tried to create the Dockerfile as simple as possible to avoid long build time.
- Utilizing the provided scripts in the image.
- Exposed port 8080.
- Combined ENTRYPOINT ["sh"] and CMD [ "run.sh" ]: by default it will start the container with the run.sh script.
- For testing the image we can simply run the container with the "test.sh" CMD.
- Tested the image locally before pushing it to the Git repo.
## Create Kubernetes/Helm files
- First, for testing I have created a deployment.yaml and service.yaml. I have created the Helm manifest and values files.
- To better represent the advantages of Helm I have created environment specific values files.
- Deployment: specified image, replicaCount and namespace.
- Service: Using NodePort for simplicity.
- I created dev and prod related values files.
    - dev: replicaCount:1, namespace: helloapp-dev
    - prod: replicaCount:3, namespace: helloapp-prod
- The greatest advantage of using Helm is that we do not have to recreate different files for resources if we want to use them in a new environment. 
## Implement the CI/CD pipeline
In my solution my objective was not only to create an effective CI/CD pipeline, but to implement it in a way to be able to reuse it for any other application. This means the code is generic and does not contain any harcoded values. 
1. Prepare the build
    - The pipeline using a yaml configuration to specify the build parameters. (This could also come from Jenkins parameters)
    - In the first stage the pipeline reads the configuration and prints it in the output. This is handy for debugging.
    - The job has an environment select choice parameter (dev/prod).
    - A unique tag is generated. Both the Jenkins build and image will use the same tag for better tracability.
2. Build the image
    - Build the docker image and push it to the repository using the configuration.
    - Used the withCredentials block for image push.
3. Test the image
    - Running a container using the test.sh script to see if it meets the requirements. 
    - If the test is failing the build is aborted. By this we are avoiding to deploy any faulty app.
4. Deploy the application on Kubernetes cluster
    - Based on the environment selected in the parameters find the right values yaml file.
    - Printing the helm template for debugging.
    - Deploying the application using helm upgrade.
        - Providing the image as parameters.
        - Using the --create-namespace flag to create the namespace if it does not exist.