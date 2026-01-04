# EBS volume (trwałość danych)
resource "aws_ebs_volume" "db_data" {
  availability_zone = aws_subnet.public[0].availability_zone
  size              = 20
  type              = "gp3"

  tags = {
    Name = "guestbook-db-data"
  }
}

# EC2 pod bazę
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.db_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data/db_init.sh.tpl", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = {
    Name = "guestbook-db"
  }
}

# Podpięcie EBS do EC2
resource "aws_volume_attachment" "db_data_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.db_data.id
  instance_id = aws_instance.db.id
}



