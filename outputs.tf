output "bucket_arn" {
  description = "Il codice univoco ARN del nostro bucket"
  value       = aws_s3_bucket.mio_bucket.arn
}

output "bucket_nome_reale" {
  description = "Il nome effettivo del bucket creato"
  value       = aws_s3_bucket.mio_bucket.id
}

output "il_mio_account_id" {
  description = "Il numero ID del mio account AWS"
  value       = data.aws_caller_identity.corrente.account_id
}
