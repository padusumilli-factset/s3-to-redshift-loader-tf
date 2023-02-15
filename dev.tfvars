aws_region = "us-east-1"

aws_profile = "default"

fds_resources_access_role     = "client-access"
fds_resources_access_role_arn = "arn:aws:iam::648803228730:role/client-access"

fds_access_point_arn = "arn:aws:s3:us-east-1:262979292457:accesspoint/ffd-stg-amercent-38522"

fds_sns_arn = "arn:aws:sns:us-east-1:262979292457:ffd-stg-amercent-38522.fifo"

data_bucket_name = "fdss3-aci-data-bucket"

resources_bucket_name = "fdss3-aci-resources-bucket"

environment = "PoC"

vpc_id = "vpc-08230a4b234c1ab54"

## Redshift cluster

rs_cluster_identifier = "analytics-poc-cluster"

rs_database_name = "fdsanalytics"


rs_master_username = "fdsanalyticsuser"

rs_master_pass = "FDSAnalytics1"

rs_nodetype = "dc2.large"

rs_cluster_type = "single-node"

vpc_cidr = "10.0.0.0/16"

redshift_subnet_cidr_1 = "10.0.1.0/24"

redshift_subnet_cidr_2 = "10.0.2.0/24"

