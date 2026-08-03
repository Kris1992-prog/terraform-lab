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
  type      = string
  sensitive = true
  default   = "Luana1992" # Valore di default se il secret su GitHub manca
}

variable "db_username" {
  type        = string
  description = "Username del database"
  default     = "kris_admin"
}

variable "app_image_tag" {
  type        = string
  description = "Tag dell'immagine Docker per l'applicazione e-commerce"
  default     = "latest"
}