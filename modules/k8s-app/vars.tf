variable "namespace" {
  default = "k8s-app"
}

variable "name" {
  default = "myapp"
}
variable "ecr_uri" {
  default = ""
}

variable "image" {}

variable "image_tag" {
  default = "5.4.1-php7.2-apache"
}
variable "environment" {
  default = "dev"
}

variable "filter_prefix" {
  default = "eks-cluster"
}

variable "region" {}

variable "domain" {
  default = "drupal.aws"
}

variable "postgres_engine" {
  default = "11"
}

variable "db_instance_class" {
  default = "db.t3.small"
}
