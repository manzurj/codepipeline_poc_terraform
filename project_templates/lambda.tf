# Zip the lambda code
data "archive_file" "StartStopRDS" {
  type        = "zip"
  source_dir  = "lambda_code/StartStopRDS/"
  output_path = "output_lambda_zip/StartStopRDS/StartStopRDS.zip"
}

# Create lambda function
resource "aws_lambda_function" "StartStopRDS" {
  filename      = data.archive_file.StartStopRDS.output_path
  function_name = "StartStopRDS"
  role          = aws_iam_role.role.arn
  handler       = "main_handler.lambda_handler"
  description   = "Start-Stop RDS Instances"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.StartStopRDS.output_path)

  runtime = "python3.9"
  timeout = "120"
}

data "archive_file" "DeleteDBSnapshot" {
  type        = "zip"
  source_dir  = "lambda_code/DeleteDBSnapshot/"
  output_path = "output_lambda_zip/DeleteDBSnapshot/DeleteDBSnapshot.zip"
}

# Create lambda function
resource "aws_lambda_function" "DeleteDBSnapshot" {
  filename      = data.archive_file.DeleteDBSnapshot.output_path
  function_name = "DeleteDBSnapshot"
  role          = aws_iam_role.role.arn
  handler       = "main_handler.lambda_handler"
  description   = "Delete RDS DB Snapshot"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.DeleteDBSnapshot.output_path)

  runtime = "python3.9"
  timeout = "120"
}