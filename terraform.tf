#* Following seed deployment, uncomment below and replace TODOs 

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "demo-tf-remote-state-75krra0v50"                                                    #* replace with remote_state_bucket name
    dynamodb_table = "demo-tf-locks"                                                                      #* replace with tf_locks_table name
    region         = "us-east-2"                                                                          #* replace with deployment region
    key            = "aws-ci-cd-pipelines/PROD/terraform.tfstate"                                         #* replace with name of the repo which will define all pipelines
    kms_key_id     = "arn:aws:kms:us-east-2:901968315793:key/0bb9a12d-1e94-428a-98d9-963425908a46"        #* replace with cmk_arn
  }
}
