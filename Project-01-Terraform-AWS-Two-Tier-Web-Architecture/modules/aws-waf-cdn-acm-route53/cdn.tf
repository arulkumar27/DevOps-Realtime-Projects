resource "aws_cloudfront_distribution" "cdn" {
  provider = aws.us_east_1

  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.domain-name, "www.${var.domain-name}"]
  comment         = "CDN ALB Distribution"
  price_class     = "PriceClass_100"
  web_acl_id      = aws_wafv2_web_acl.web-acl.arn

  origin {
    domain_name = data.aws_lb.web-alb.dns_name
    origin_id   = "web-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "web-alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = var.cdn-name
  }

  depends_on = [
    aws_acm_certificate_validation.cert
  ]
}
