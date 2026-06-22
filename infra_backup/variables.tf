variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "bucket_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}