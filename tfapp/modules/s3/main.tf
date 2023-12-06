locals {
  bucket_name = "${var.name}-${var.region}-backendfiles"
}

resource "aws_s3_bucket" "testapp" {
  bucket = local.bucket_name

  force_destroy = true

  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_object" "tux_image" {
  bucket = aws_s3_bucket.testapp.id
  key    = "images/tux.jpeg"
  source = "../modules/s3/files/tux.jpeg"

  etag = filemd5("../modules/s3/files/tux.jpeg")
}

resource "aws_iam_role" "backend" {
  name = "${var.name}-backend-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "backend_instance" {
  name = "${var.name}-backend"
  role = aws_iam_role.backend.name
}

resource "aws_iam_role_policy" "backend" {
  name   = "${var.name}-policy"
  role   = aws_iam_role.backend.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${local.bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${local.bucket_name}/*"]
    }
  ]
}
EOF
}
