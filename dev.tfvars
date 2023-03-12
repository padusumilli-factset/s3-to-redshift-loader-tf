aws_region = "us-east-1"

fds_aws_region = "us-east-1"

aws_profile = "default"

fds_resources_access_role = "client-access"

fds_access_point_alias = "ffd-stg-amercent-385-cp38ffh58uxrajma475d9t14sc17guse1b-s3alias"

fds_sns_arn = "arn:aws:sns:us-east-1:262979292457:ffd-stg-amercent-38522.fifo"

data_bucket_name = "fdss3-aci-data-bucket-1"

resources_bucket_name = "fdss3-aci-resources-bucket-1"

environment = "PoC-1"

vpc_id = "vpc-08230a4b234c1ab54"

## Redshift cluster
rs_cluster_identifier = "analytics-poc-cluster-1"

rs_database_name = "fds_analytics"

rs_master_username = "fds_analytics_user"

rs_master_pass = "FDSAnalytics1"

rs_node_type = "dc2.large"

rs_cluster_type = "multi-node"

s3_to_s3_copy_updates_topic = "s3-to-s3-copy-updates-topic.fifo"