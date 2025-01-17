output "ssm_document_arn" {
  description = "ARN of the created SSM document"
  value       = aws_ssm_document.wait_for_cloud_init.arn
}

output "ssm_association_id_res" {
  description = "ID of the created SSM association"
  value       = aws_ssm_association.res_association.association_id
}

output "ssm_association_id_pc" {
  description = "ID of the created SSM association"
  value       = aws_ssm_association.parallelcluster_association.association_id
}
