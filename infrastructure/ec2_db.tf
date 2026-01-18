resource "aws_instance" "postgres" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.small"
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data/postgres.sh")

  tags = {
    Name = "guestbook-postgres"
  }
}

# EBS dla trwalosci danych
resource "aws_ebs_volume" "postgres_data" {
  availability_zone = aws_instance.postgres.availability_zone
  size              = 20
  type              = "gp3"
}

resource "aws_volume_attachment" "postgres_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.postgres_data.id
  instance_id = aws_instance.postgres.id
}
