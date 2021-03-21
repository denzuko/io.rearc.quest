terraform {
    required_version = ">= 0.14.8"
    required_providers {

        aws =  {
            version = ">= 3.32.0"
            source = "hashicorp/aws"
        }

        template = {
            version = ">= 2.2.0"
            source = "hashicorp/template"
        }
    }
}
