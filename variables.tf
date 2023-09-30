variable "name" {
  type    = string
  default = "ontra"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "image_tag" {
  type = string
  default = "0.0.1"
}

variable "image_arch" {
  type = string
  default = "arm64"
}
