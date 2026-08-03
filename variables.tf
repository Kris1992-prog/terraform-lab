variable "nome_bucket" {
  description = "Il nome del mio bucket S3"
  type        = string
  default     = "kris-bucket-test-2026-nuovo"
}

variable "instance_type" {
  description = "Tipo di istanza EC2"
  type        = string
  default     = "t3.micro"
}

variable "db_password" {
  description = "La master password del database RDS"
  type        = string
  sensitive   = true # Evita che la password venga stampata in chiaro nei log del terminale
}

variable "app_image_tag" {
  type        = string
  description = "Tag dell'immagine Docker per l'applicazione e-commerce"
  default     = "latest"
}