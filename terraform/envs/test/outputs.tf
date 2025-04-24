
output "test_topic_arn" {
  description = "ARN of the test SNS topic"
  value       = aws_sns_topic.test_topic.arn
}