#step 1
resource "aws_vpc" "main" {
  cidr_block       =var.cidr_block 
  instance_tenancy = "default"
enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(var.common_tags,
  {
    Name="${local.name}-vpc"
  },var.vpc_tag)
}
#step 2
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags =merge(var.common_tags,
  {
    Name="${local.name}-igw"
  },var.igw_tag)
}
#step 3  requires av zone data
resource "aws_subnet" "public_sub" {
  count = length(var.public_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags =merge(var.common_tags,
  {
    Name="public-${local.name}-${local.azs[count.index]}"
  },var.public_sub_tag)
}
resource "aws_subnet" "private_sub" {
  count = length(var.private_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags =merge(var.common_tags,
  {
    Name="private-${local.name}-${local.azs[count.index]}"
  },var.private_sub_tag)
}
resource "aws_subnet" "database_sub" {
  count = length(var.database_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.database_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(var.common_tags,
  {
    Name="database-${local.name}-${local.azs[count.index]}"
  },var.database_sub_tag)
}
resource "aws_db_subnet_group" "default" {
  name = "${local.name}"
  subnet_ids = aws_subnet.database_sub[*].id
  tags =  {
    Name="${local.name}"
  }
}
#step 4

resource "aws_eip" "eip" {
  domain = "vpc"
  
}
#step 5
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_sub[0].id

  tags = merge(var.common_tags,
  {
    Name="ngw-${local.name}"
  },
  var.ngw_tag)

  depends_on = [aws_internet_gateway.gw]
}
#step 6
resource "aws_route_table" "public_rtbale" {
  vpc_id = aws_vpc.main.id 

  tags = merge(var.common_tags,
  {
    Name="public-${local.name}"
  },var.public_rtbale_tag)
}

resource "aws_route_table" "private_rtbale" {
  vpc_id = aws_vpc.main.id 

  tags = merge(var.common_tags,
  {
    Name="private-${local.name}"
  },var.private_rtbale_tag)
}
resource "aws_route_table" "database_rtbale" {
  vpc_id = aws_vpc.main.id 

  tags = merge(var.common_tags,
  {
    Name="database-${local.name}"
  },var.database_rtbale_tag)
}

#step 7
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_rtbale.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_rtbale.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}
resource "aws_route" "database_route" {
  route_table_id = aws_route_table.database_rtbale.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
  
}
#step 8
resource "aws_route_table_association" "public_sub_rtable" {
   count = length(var.public_cidr)
   subnet_id      = element(aws_subnet.public_sub[*].id,count.index)
  route_table_id = aws_route_table.public_rtbale.id

}
resource "aws_route_table_association" "private_sub_rtable" {
   count = length(var.private_cidr)
   subnet_id      = element(aws_subnet.private_sub[*].id,count.index)
  route_table_id = aws_route_table.private_rtbale.id

}
resource "aws_route_table_association" "database_sub_rtable" {
   count = length(var.database_cidr)
   subnet_id      = element(aws_subnet.database_sub[*].id,count.index)
  route_table_id = aws_route_table.database_rtbale.id

}
#step 9  
resource "aws_vpc_peering_connection" "peering" {
  count=var.is_peering_required ?1 :0
  vpc_id = aws_vpc.main.id
peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default_vpc.id : var.acceptor_vpc_id
  auto_accept =  var.acceptor_vpc_id == "" ?true: false
  tags = merge(var.common_tags,
  {
    Name="peering-${local.name}"
  },var.peering_tag)
}

#step 10
resource "aws_route" "acceptor_route" {
   count=var.is_peering_required && var.acceptor_vpc_id== "" ?1 :0
  route_table_id = data.aws_route_table.default.id
  destination_cidr_block = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "public_vpc_default" {
   count=var.is_peering_required && var.acceptor_vpc_id== "" ?1 :0
  route_table_id =aws_route_table.public_rtbale.id
  destination_cidr_block =data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "private_vpc_default" {
   count=var.is_peering_required && var.acceptor_vpc_id== "" ?1 :0
  route_table_id = aws_route_table.private_rtbale.id
  destination_cidr_block = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "database_vpc_default" {
   count=var.is_peering_required && var.acceptor_vpc_id== "" ?1 :0
  route_table_id =aws_route_table.database_rtbale.id
  destination_cidr_block =data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
  