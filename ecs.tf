resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.environment}my-cluster" # Naming the cluster
}

resource "aws_ecs_task_definition" "my_first_task" {
  family = "my-first-task" # Naming our first task
  container_definitions = jsonencode([{
    name      = "my-first-task"
    image     = data.aws_ecr_repository.service.repository_url
    essential = true
    portMappings = [
      {
        "containerPort" : var.container_port,
        "hostPort" : var.container_port
    }]
    memory = var.fg_mem
    cpu    = var.fg_cpu
  }])

  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.fg_mem  # Specifying the memory our container requires
  cpu                      = var.fg_cpu  # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    "Name" = "${var.environment}ab-task"
  }
}


resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                        # Naming our first service
  cluster         = aws_ecs_cluster.my_cluster.id             # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.my_first_task.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.my_first_task.family
    container_port   = var.container_port # Specifying the container port
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true                                           # Providing our containers with public IPs
    security_groups  = [aws_security_group.service_security_group.id] # Setting the security group
  }

  tags = {
    "Name" = "${var.environment}-ab-service"
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.environment}-service-sg"
  }
}