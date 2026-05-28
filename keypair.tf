resource "aws_key_pair" "deployer_key" {
  key_name   = "ravindra-key"
  public_key = file("${path.module}/id_ed25519.pub")
}