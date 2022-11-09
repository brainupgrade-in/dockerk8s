variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}
varible "account_id"{
  default = "11111111"
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
  default = 1.23
}