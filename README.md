# My IaC for K8s

![Randy C. Bunney, Great Circle Photography](https://upload.wikimedia.org/wikipedia/commons/e/e5/Scross_helmsman.jpg "Kubernetes stands for 'helmsman' or 'pilot' or 'governor' in Greek")
_Kubernetes means for "helmsman" or "pilot" or "governor" in Greek" - Randy C. Bunney, Great Circle Photography, from wikipedia.org - CC BY-SA 2.5_

If you have no idea about what Kubernetes (K8s) is, please visit: https://kubernetes.io/. In short, it's an open-source system for automating deployment, scaling, and management of containerized applications.

## Objective 

Deploy a webapp (currently Drupal) easily and safely to a high-available K8s cluster.

## Motivation

This is a simple IaC prototype to deploy Drupal to AWS EKS using Terraform. I started this project from scratch using the technologies I've been using ultimately. Why from scratch? It's simple: technology changes all the time, even tiny changes matter. This is the opportunity I have to explore new features and share my thoughts with you. So far, I'm focused on delivering a basic and working project. It might change drastically during the course of the roadmap. Let me know your thoughts, feel free to contribute :)

## Roadmap

This is the current roadmap. It might change during the development.

 1. ~~Create a basic AWS Network Setup script~~
 1. ~~Create a basic AWS EKS Cluster with worker nodes script~~
 1. ~~Create a basic Drupal deployment script~~
 1. Support HELM Charts deployment
 1. Add metrics and monitoring services
 1. Add log management and analysis services
 1. Add end-to-end distributed tracing services  
 1. Add Basic WAF rules
 1. Code/Modules review to support multi-app, multi-region, multi-cloud providers
 1. Implement multi-app support
 1. Add support to GKE, AKS and OpenStack
 1. Add support to local development (Docker Desktop, Minikube, Raspberry PI, etc)
 1. Create a CLI to create project's templates (?)
 1. Find more stuff to do. Overall, this is a never-ending project :)

## 10,000-foot view 

_Note: This will be updated according to the the project's progress!_

### Architecture overview
![Project's Diagram](pilot.png "Project's Diagram")

#### High-availability
The main goal of this project is to deliver a very basic high-available Drupal webapp. It starts with 2 pods per AZ (using 3 AZs). There are 2 auto-scaling mechanisms:
 * EC2 Instance (provisioning resources), provided by [EKS Managed Node Groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html). It creates/registers/unregisters/terminates EC2 instances automatically, based on pods allocation. Capacity: _min=3 instances (1 per AZ), max=30 instances (10 per region)_
 * [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/): Auto scales pods (small application instances) according to the pod's resource settings. If Pod's CPU usage is over 80%, HPA will allocate more pods in the cluster to attend the demand. When the web traffic cools down, HPA will rebalance the pods. I might use another diagram tool to detail in the Architecture Overview section. Capacity: _min=2 replicas, max=20 replicas, pod_cpu_limit: 1 core, pod_mem_limit: 512mb_ 


## Current Terraform Code Pattern

Today, the project has 3 modules:
 * Module `app-infra`: Network basics. Creates a VPC with 1 public subnet for ALB, 3 private subnets (for databases, eks worker nodes, systems __*__ and cache __*__ ) and 1 VPN gateway.
 * Module `app-cluster`: Basic EKS Cluster. Creates a EKS Cluster and a RDS instance with all credentials setup. It also setups your local kube config (I might rethink about this later).
 * Module `k8s-app`: Basic Kubernetes deployment. Creates k8s objects (deployment, services, etc) for Drupal.
 * Module `k8s-services`: Basic services like ingress.

__*__ _: Not in use yet_

## Dependencies

 * `Terraform ^0.12.26` - https://www.terraform.io/downloads.html
 * `AWS CLI ^1.17.9` - https://aws.amazon.com/cli/
 * `kubectl ^1.18.0` - https://kubernetes.io/docs/tasks/tools/install-kubectl/
 * `Helm ^3.2.2` - https://helm.sh/docs/intro/install/
 * `GNU Make ^3.81` - https://www.gnu.org/software/make/

## How to deploy

Once all the dependencies above are satisfied, clone the project:
```
$ git clone https://github.com/manoelhc/k8s-simple-deployment.git
```

Run `make check` to run all the plans. Run `make all` to apply all the plans. Note: `make all` has auto-approve flag.

#### Testing

After deployment the application, check the ingress Load Balancer Address by running `kk get services -n drupal`. You might get something like:
```
$ kubectl get services -n drupal
NAME     TYPE           CLUSTER-IP     EXTERNAL-IP                                                               PORT(S)        AGE
drupal   LoadBalancer   172.20.19.97   a258ae76e7fa246deaa8832f1asd1235-1307389120.us-east-1.elb.amazonaws.com   80:30460/TCP   21m
```
And then run `curl -H 'HOST:drupal.aws' http://<EXTERNAL-IP value>`

* Note: This example doesn't create Route 53 RecordSets.
