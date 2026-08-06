resource "aws_s3_bucket" "mio_bucket" {
  bucket        = "kris-bucket-test-2026-nuovo"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "mio_bucket_versioning" {
  bucket = aws_s3_bucket.mio_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mio_bucket_crypto" {
  bucket = aws_s3_bucket.mio_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Questa sorgente dati legge le informazioni dell'account AWS in uso
data "aws_caller_identity" "corrente" {}

resource "aws_s3_bucket_public_access_block" "sicurezza_bucket" {
  bucket = aws_s3_bucket.mio_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 1. CERCHIAMO IL SISTEMA OPERATIVO (Data Source)
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # ID ufficiale di Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# # 2. IL TUO SERVER WEB
resource "aws_instance" "mio_primo_server" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = var.instance_type
  key_name               = "MioServerKeyMilano"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  # CONFIGURAZIONE AUTOMATICA (USER DATA):
  user_data = <<-EOF
              #!/bin/bash
              # 1. Aggiorna i pacchetti e installa Docker, Docker Compose e Git
              apt-get update -y
              apt-get install -y docker.io docker-compose git wget

              # 2. Avvia e abilita il servizio Docker
              systemctl start docker
              systemctl enable docker

              # 3. Dai i permessi all'utente ubuntu per usare Docker senza sudo
              usermod -aG docker ubuntu

              # 4. Clona il repository nella home dell'utente ubuntu
              mkdir -p /home/ubuntu/progetto-ecommerce
              git clone https://github.com/Kris1992-prog/progetto-ecommerce.git /home/ubuntu/progetto-ecommerce || true

              # 5. Genera il file di configurazione .env dinamico
              cat << 'ENV_EOF' > /home/ubuntu/progetto-ecommerce/.env
              DB_HOST=${aws_db_instance.ecommerce_db.address}
              DB_USER=kris_admin
              DB_PASS=${var.db_password}
              DB_NAME=ecommercedb
              ENV_EOF

              # 6. Correggi i permessi della cartella assegnandola all'utente ubuntu
              chown -R ubuntu:ubuntu /home/ubuntu/progetto-ecommerce
              EOF

  tags = {
    Name = "Server-Kris-Terraform"
  }
}

# SECURITY GROUP PER IL SERVER WEB
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Permetti traffico HTTP e SSH"

  ingress {
    description = "Traffico HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Accesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Traffico in uscita"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. Legge l'Elastic IP che hai già riservato su AWS (sostituisci con il tuo IP)
data "aws_eip" "ip_permanente" {
  public_ip = "18.102.134.191" # es. "3.120.150.45"
}

# 2. Collega l'IP permanente al nuovo server quando fai terraform apply
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.mio_primo_server.id
  allocation_id = data.aws_eip.ip_permanente.id
}

# STAMPA L'INDIRIZZO DEL DATABASE SUL TERMINALE
output "database_endpoint" {
  description = "L'indirizzo da usare per connettersi al database"
  value       = aws_db_instance.ecommerce_db.endpoint
}

output "IP_ELASTICO" {
  value       = data.aws_eip.ip_permanente.public_ip
  description = "L'IP pubblico statico (Elastic IP) del server e-commerce"
}

# Bucket dedicato alla conservazione dei log
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "kris-bucket-logs-2026"
  force_destroy = true
}

# Configurazione per collegare il bucket principale a quello dei log
resource "aws_s3_bucket_logging" "mio_bucket_logging" {
  bucket        = aws_s3_bucket.mio_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}