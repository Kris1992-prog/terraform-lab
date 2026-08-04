# 1. SECURITY GROUP PER IL DATABASE (RDS)
resource "aws_security_group" "db_sg" {
  name        = "db-server-sg"
  description = "Permetti traffico MySQL solo dal Web Server"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. IL DATABASE RDS MYSQL
resource "aws_db_instance" "ecommerce_db" {
  allocated_storage       = 20
  db_name                 = "ecommercedb"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  storage_encrypted       = true  #  MODIFICA: Abilita la cifratura dello storage RDS
  backup_retention_period = 1     # Conservazione dei backup automatici per 7 giornis
  publicly_accessible     = false # Impedisce l'accesso pubblico diretto al database
  deletion_protection     = false # Protezione dalla cancellazione accidentale
  username                = "kris_admin"
  password                = var.db_password

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]
}