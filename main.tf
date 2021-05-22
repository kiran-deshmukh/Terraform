provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

data "aws_availability_zones" "all" {}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "mykey"
  public_key = var.public_key
}

resource "aws_launch_configuration" "asg-launch-config-sample" {
  image_id        = "ami-0ac80df6eff0e70b5"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.busybox.id]
  key_name        = aws_key_pair.terraform-demo.key_name
  user_data = <<-EOF
              #! /bin/bash
                          sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Sample app to test terraform with AWS load_balancers</h1>" | sudo tee /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "busybox" {
  name = "study-busybox-sg"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "elb-sg" {
  name = "study-elb-sg"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg-sample" {
  launch_configuration = aws_launch_configuration.asg-launch-config-sample.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity

  load_balancers    = [aws_elb.sample.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "study-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "sample" {
  name               = "study-asg-elb"
  security_groups    = [aws_security_group.elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 60
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # Adding a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}
