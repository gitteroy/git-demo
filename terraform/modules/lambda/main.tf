resource "aws_iam_role" "exec" {
  name = "${var.function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "read_secret" {
  name = "${var.function_name}-read-secret-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "secretsmanager:GetSecretValue",
      Effect   = "Allow",
      Resource = var.secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secret" {
  role       = aws_iam_role.exec.name
  policy_arn = aws_iam_policy.read_secret.arn
}

resource "aws_lambda_function" "this" {
  filename      = "dummy.zip"
  function_name = var.function_name
  role          = aws_iam_role.exec.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.11"

  lifecycle {
    ignore_changes = [
      filename,
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.secret]
}