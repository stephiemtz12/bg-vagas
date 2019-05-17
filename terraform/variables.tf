variable "wait_for_elb_capacity" {
  default = 1
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 2
}
