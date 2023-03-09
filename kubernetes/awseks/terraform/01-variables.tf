variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}
variable "cluster_name" {
  default = "testeks"
}
variable "cluster_min_size"{
  default = 1
}
variable "cluster_max_size"{
  default = 3
}
variable "cluster_desired_size"{
  default = 1
}
variable "cluster_version"{
  default = 1.25
}