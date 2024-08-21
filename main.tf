###########################################################################################################
# hello my name is abdelrahman ahmed this project Multi-tier WebApp Deployment  to AWS by terraform 
# we're going to create (VPC , sg , RDS , Amazon MQ, Elastic Cache, EC2 instance for application and ELB )  
###########################################################################################################
#step 1 Create A VPC 
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
            Name = "myTerraformVPC"
    }
}
#step 2 Create A subnets 
# Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "mySubnet1"
  }
}

# Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "mySubnet2"
  }
}

# Subnet 3
resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "mySubnet3"
  }
}

#step 3 create iGW 
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.myvpc.id
}

#step 4 create route tables 
# Route Table for Subnet 1
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myRouteTable1"
  }
}

# Associate Route Table 1 with Subnet 1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

# Route Table for Subnet 2
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myRouteTable2"
  }
}

# Associate Route Table 2 with Subnet 2
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

# Route Table for Subnet 3
resource "aws_route_table" "rt3" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myRouteTable3"
  }
}

# Associate Route Table 3 with Subnet 3
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt3.id
}
#to connect to network 
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


#step 5 we create a sg group (backend , application , ELB)
# 1 : SG FOR ELB
resource "aws_security_group" "elb_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "elb_security_group"
  description = "Security group for ELB allowing HTTP traffic on port 80 from everyone"

  # Ingress Rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # port 80 to every one 
  }

  # Egress Rules
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]  # Allow access to port 8080 only for the application's security group
  }

  tags = {
    Name = "myELBSecurityGroup"
  }
}

# 2 : SG FOR APP
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "app_security_group"
  description = "Security group for the application"

  # Ingress Rules

  # Allow HTTP traffic (port 80) from ELB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }

  # Allow TCP traffic on port 8080 from ELB Security Group
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.elb_sg.id] # Allow access to port 8080 from the security group ofـ ELB
  }

  # Allow SSH traffic (port 22) from everyone
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myAppSecurityGroup"
  }
}

# 3 SG FOR BACKEND
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "backend_security_group"
  description = "Security group for the backend"

  # Ingress Rules

  # Allow all traffic to the application (App SG)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.app_sg.id]
  }
  
  #You must modify the security group under the backend and let it see each other after creation

  # Egress Rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myBackendSecurityGroup"
  }
}
## Oh, after creating the entire network and the security group,
## we are now taking a special step. We will enter the create aws services
#########################################################################
# step 6 create Backend Services 
# step 1 create RDS 

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb_subnet_group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]  # Add your subnets here

  tags = {
    Name = "myDBSubnetGroup"
  }
}

resource "aws_db_instance" "myrds" {
  engine            = "mysql"
  engine_version    = "8.0.35"
  instance_class    = "db.t3.medium"
  allocated_storage = 200
  storage_type      = "gp2"
  identifier        = "mydb"
  username          = "admin"
  password          = "admin123"

  db_subnet_group_name = aws_db_subnet_group.mydb_subnet_group.name

  vpc_security_group_ids = [aws_security_group.backend_sg.id]  # Attach the backend security group

  multi_az            = true       # Enable Multi-AZ for high availability
  backup_retention_period = 7       # Retain backups for 7 days
  skip_final_snapshot = true        # Skip final snapshot on deletion
  publicly_accessible = false       # Make the RDS instance private
  storage_encrypted   = true        # Enable storage encryption
  apply_immediately   = true        # Apply changes immediately

  tags = {
    Name = "myRDSInstance"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  name       = "my-cache-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  tags = { Name = "myCacheSubnetGroup" }
}

# ElastiCache Cluster with Memcached
resource "aws_elasticache_cluster" "my_cache_cluster" {
  cluster_id           = "my-cache-cluster"
  engine               = "memcached"               # Changed to Memcached
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.cache_subnet_group.name
  security_group_ids   = [aws_security_group.backend_sg.id]

  tags = { Name = "myCacheCluster" }
}
resource "aws_mq_broker" "my_mq_broker" {
  broker_name           = "my-mq-broker"
  engine_type           = "RabbitMQ"                # Change to "RabbitMQ"
  engine_version        = "3.13"                 # Example version for RabbitMQ
  host_instance_type    = "mq.m5.large"
  publicly_accessible   = false                     # Make the broker private
  auto_minor_version_upgrade = true
  security_groups       = [aws_security_group.backend_sg.id]  # Attach backend security group

  subnet_ids            = [
    aws_subnet.subnet1.id
  ]

  user {
    username = "admin"
    password = "admin12345678"
  }

  logs {
    general = true
  }

  tags = {
    Name = "myMQBroker"
  }
}

resource "aws_instance" "my_app_instance" {
  ami                    = "ami-05ea2888c91c97ca7"  # AMI ID
  instance_type          = "t3.medium"  # Instance type
  subnet_id              = aws_subnet.subnet1.id  # Subnet ID
  vpc_security_group_ids = [aws_security_group.app_sg.id]  # Security Group
  associate_public_ip_address = true
  key_name               = "teero"  # Name of the existing Key Pair in AWS

   # User data script to configure the instance
  user_data = file("D:/devops Bootcamb/project 4 terraform/script/app.sh")

  tags = {
    Name = "myAppInstance"
  }
}
# Create Target Group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "appTargetGroup"
  }
}

# Create Load Balancer
resource "aws_lb" "my_elb" {
  name               = "my-application-elb"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  enable_deletion_protection = false

  listener {
    port     = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app_target_group.arn
    }
  }

  enable_cross_zone_load_balancing = true
  idle_timeout                      = 400
  access_logs {
    bucket  = "my-access-logs-bucket"
    enabled = false
  }

  tags = {
    Name = "myELB"
  }
}

# Attach Target Group to Load Balancer
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Attach Instance to Target Group
resource "aws_lb_target_group_attachment" "app_target_group_attachment" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.my_app_instance.id
  port             = 8080
}















