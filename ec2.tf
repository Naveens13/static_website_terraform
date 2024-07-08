resource "aws_instance" "test" {
  ami = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    when = destroy
    command = "echo ${self.public_ip} >> public_ip.txt"
  }
}

output "ip" {
  value = aws_instance.test.private_ip
}