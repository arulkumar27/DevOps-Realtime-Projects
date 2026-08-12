resource "aws_acm_certificate" "cert" {
  provider = aws.us_east_1

  domain_name               = var.domain-name
  validation_method         = "DNS"
  subject_alternative_names = ["www.${var.domain-name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate-validation" {
  for_each = {
    for option in aws_acm_certificate.cert.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.certificate-validation :
    record.fqdn
  ]
}
