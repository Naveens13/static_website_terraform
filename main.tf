resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "owner_bucket" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}
resource "aws_s3_bucket_public_access_block" "publicbucket" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "aclbucket" {

  depends_on = [aws_s3_bucket_ownership_controls.owner_bucket, aws_s3_bucket_public_access_block.publicbucket]
  bucket     = aws_s3_bucket.mybucket.id
  acl        = "public-read"
}


resource "aws_s3_object" "index_object" {
  bucket = aws_s3_bucket.mybucket.id
  source = "index.html"
  key = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  source = "error.html"
  key = "error.html"
  acl = "public-read"
  content_type = "text/html"
}
resource "aws_s3_bucket_website_configuration" "website_hosting" {
  depends_on = [ aws_s3_object.index_object, aws_s3_object.error ]
  bucket = aws_s3_bucket.mybucket.id
  
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }

  provisioner "local-exec" {
    command = "echo terraformbucketwebsite2024.s3-website-us-east-1.amazonaws.com >> website.txt"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.mybucket.id
}

output "bucket__ip" {
  value = aws_s3_bucket_website_configuration.website_hosting.website_endpoint
}