module "alb" {
  source                   = "terraform-aws-modules/alb/aws"
  load_balancer_name       = "API-CANDIDATOS"
  logging_enabled          = false
  security_groups          = ["sg-a72307df"]
  subnets                  = ["subnet-0212de59", "subnet-358d4c53"]
  tags                     = "${map("Ambiente", "QA")}"
  vpc_id                   = "vpc-0946126e"
  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "API-CANDIDATOS", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "1"
}

data "template_file" "userdata_api-cand" {
  template = "${file("${path.module}/api-cand.sh.tpl")}"
}

## LAUNCH CONFIGURATION API CANDIDATOS
resource "aws_launch_configuration" "API-CANDIDATOS" {
  image_id        = "ami-03abb4c6fad1a34d3"
  instance_type   = "t2.micro"
  user_data       = "${data.template_file.userdata_api-cand.rendered}"
  key_name        = "jailson-treinamento-sp"
  security_groups = ["sg-a72307df"]

  lifecycle {
    create_before_destroy = true
  }
}

## AUTOSCALING
resource "aws_autoscaling_group" "API-CANDIDATOS" {
  name                  = "API-CANDIDATOS-${aws_launch_configuration.API-CANDIDATOS.name}"
  launch_configuration  = "${aws_launch_configuration.API-CANDIDATOS.name}"
  availability_zones    = ["${data.aws_availability_zones.available.names}"]
  min_size              = "${trimspace(chomp(var.min_size))}"
  max_size              = "${trimspace(chomp(var.max_size))}"
  desired_capacity      = "${trimspace(chomp(var.wait_for_elb_capacity))}"
  wait_for_elb_capacity = "${trimspace(chomp(var.wait_for_elb_capacity))}"

  target_group_arns = ["${module.alb.target_group_arns}"]
  health_check_type = "ELB"

  tags {
    key                 = "Aplicacao"
    value               = "API-CANDIDATOS-LATA"
    key                 = "Name"
    value               = "API-CANDIDATOS"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "15m"
  }
}
