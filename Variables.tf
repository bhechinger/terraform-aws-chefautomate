data "aws_region" "current" {
  current = true
}

locals {
  stage_ca = "https://acme-staging.api.letsencrypt.org"
  prod_ca  = "https://acme-v01.api.letsencrypt.org"
  region   = "${data.aws_region.current.name}"

  AMIs = {
    us-east-1      = "ami-90b241ea"
    us-east-2      = "ami-a3537ec6"
    ap-south-1     = "ami-bb5514d4"
    eu-west-2      = "ami-e4aebd80"
    eu-west-1      = "ami-bb9c57c2"
    ap-northeast-2 = "ami-7cd60c12"
    ap-northeast-1 = "ami-6944910f"
    sa-east-1      = "ami-fda7db91"
    ca-central-1   = "ami-cf68d1ab"
    ap-southeast-1 = "ami-c2c2b1a1"
    ap-southeast-2 = "ami-4e4dac2c"
    eu-central-1   = "ami-a2e152cd"
    us-west-1      = "ami-876656e7"
    us-west-2      = "ami-9acb32e2"
  }

  ami = "${local.AMIs[local.region]}"
}
