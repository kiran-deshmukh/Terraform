variable "server_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 80
}

variable "elb_port" {
  description = "The port the elb will be listening"
  type        = number
  default     = 80
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "study"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "The desired number of EC2 Instances in the ASG"
  type        = number
  default     = 2
}


variable "access_key" {
  description = "AWS access_key key "
  type        = string
  default     = " "
}

variable "secret_key" {
  description = "AWS secret_key key "
  type        = string
  default     = " "
}

variable "region" {
  description = "AWS secret_key key "
  type        = string
  default     = "us-east-1"
}

variable "public_key" {
  description = "public_key to Login to Instances "
  type        = string
  default     = " "
}
