variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0f5ee92e2d63afc18"
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "ravindra-key"
  public_key = file("${path.module}/id_ed25519.pub")
}