resource "aws_instance" "monitoring_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04
  instance_type = "t3.micro"
  key_name      = "cheia-ta-ssh"
  
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]

  tags = {
    Name = "Prometheus-External-Monitor"
  }
}