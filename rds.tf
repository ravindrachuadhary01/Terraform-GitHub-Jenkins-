# ---------------- DB Subnet Group ----------------
resource "aws_db_subnet_group" "db_subnet" {
  name = "app-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]

  tags = {
    Name = "DBSubnetGroup"
  }
}