# -------------------------
# Elastic IP for NAT Gateway
# -------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# -------------------------
# NAT Gateway (must be in PUBLIC subnet)
# -------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id

  # ⚠️ IMPORTANT: change this if your subnet name is different
  subnet_id = aws_subnet.public-subnet-2.id

  depends_on = [aws_eip.nat]

  tags = {
    Name = "nat-gateway"
  }
}

# -------------------------
# PRIVATE Route Table
# -------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

# -------------------------
# Associate Private Subnet
# -------------------------
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}