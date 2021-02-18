terraform {
  required_version = "~> 0.13.1"
  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 3.8.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.13.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "~> 1.0.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1.2"
    }
  }
}
