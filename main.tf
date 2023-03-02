provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0f3c9c466bb525749"
  instance_type = "t2.micro"
  key_name      = "ansible-key"
  vpc_security_group_ids = [
    aws_security_group.webserver_sg.id,
  ]
  subnet_id = "subnet-02230e7fadbe1fa21"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ec2-user/SED-Challenge/ansible-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install nginx1.12",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo echo '<html><head><title>Hello World</title></head><body><h1>Hello World!</h1></body></html>' > /usr/share/nginx/html/index.html",
    ]
  }
}

resource "aws_security_group" "webserver_sg" {
  name_prefix = "webserver_sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
}
