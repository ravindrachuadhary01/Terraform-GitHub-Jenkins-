# -------------------------
# NAT EIP
# -------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# -------------------------
# NAT Gateway (PUBLIC SUBNET)
# -------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id

  # ⚠️ YOUR PUBLIC SUBNET NAME IS public_1
  subnet_id = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gateway"
  }
}

# -------------------------
# PRIVATE ROUTE TABLE (APP SUBNETS)
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
# ASSOCIATE PRIVATE APP SUBNETS
# -------------------------
resource "aws_route_table_association" "private_app_1_assoc" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_app_2_assoc" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_rt.id
}