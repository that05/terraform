resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.waf_name}"
  description = "Waf in front of load balancer"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_name}"
    sampled_requests_enabled   = true
  }

  # tags = var.tags

  # Contains rules that are generally applicable to web applications. This provides protection against exploitation of a wide range of vulnerabilities, including those described in OWASP publications.

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2
    
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-common"
      sampled_requests_enabled   = true
    }
  }

  # This group contains rules that allow you to block requests from services that allow obfuscation of viewer identity. This can include request originating from VPN, proxies, Tor nodes, and hosting providers (including AWS). This is useful if you want to filter out viewers that may be trying to hide their identity from your application.

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name              = "${var.waf_name}-anonymous-ip"
      sampled_requests_enabled   = true
    }
  }

# This group contains rules that are based on Amazon threat intelligence. This is useful if you would like to block sources associated with bots or other threats.

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-reputation"
      sampled_requests_enabled   = true
    }
  }

  # Contains rules that allow you to block request patterns that are known to be invalid and are associated with exploitation or discovery of vulnerabilities. This can help reduce the risk of a malicious actor discovering a vulnerable application.

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 5

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-badinputs"
      sampled_requests_enabled   = true
    }
  }

  # This rule set allow us to define rate limits for requests matching given IPs, and block access when those rate limits are reached.

  rule {
    name     = "RateLimitingRuleSet"
    priority = 1

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = "${var.rate}"
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-badinputs"
      sampled_requests_enabled   = true
    }
  }

# waf_lb_association permits us to link our waf to the load balancer

}

resource "aws_wafv2_web_acl_association" "waf_lb_association" {
  count = var.enable_waf_alb_association ? 1 : 0
  resource_arn = var.load_balancer_arns[count.index]
  web_acl_arn = aws_wafv2_web_acl.waf.arn 
 } 
