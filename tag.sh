#!/bin/bash

# Tag resources func.
tag_config_rules(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws configservice tag-resource --region $region --resource-arn $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_code_pipeline(){
    paste -d@ listarn.csv listname.csv | while IFS="@", read -r arn name 
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws codepipeline tag-resource --region $1 --resource-arn "$arn" --tags key=CostCenter,value=$name
    done
    printf "CostCenter tagging completed.\n"
    rm list.json listarn.csv listname.csv
}

tag_cw_resources(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws cloudwatch tag-resource --region $region --resource-arn $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_rds_resources(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws rds add-tags-to-resource --region $region --resource-name $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_elasticache_resources(){
    while IFS=, read -r id region name
    do
        export AWS_PAGER=""
        printf "Adding CostCenter tag to $name ..\n"
        aws elasticache add-tags-to-resource --region $region --resource-name $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_ec2_resources(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws ec2 create-tags --region $region --resources "$id" --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_elb(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws elbv2 add-tags --region $region --resource-arns "$id" --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_secrets(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws secretsmanager tag-resource --region $region --secret-id "$id" --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_opensearch_domains(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws opensearch add-tags --region $region --arn "$id" --tag-list Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_sns_topic(){
    paste -d@ listarn.csv listname.csv | while IFS="@", read -r arn name 
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws sns tag-resource --region $1 --resource-arn "$arn" --tags Key=CostCenter,Value=$name
    done
    printf "CostCenter tagging completed.\n"
    rm list.json listarn.csv listname.csv
}

tag_sqs(){
    paste -d@ listurl.csv listname.csv | while IFS="@", read -r url name 
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws sqs tag-queue --region $1 --queue-url "$url" --tags CostCenter=$name
    done
    printf "CostCenter tagging completed.\n"
    rm list.json listurl.csv listname.csv
}

tag_lambda(){
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws lambda tag-resource --region $region --resource $id --tags "CostCenter=$name"
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_docdb(){ ##################################
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws docdb add-tags-to-resource --region $region --resource-name $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_mq(){ ##################################
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws mq create-tags --region $region --resource-arn $id --tags CostCenter=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_ecs(){ ##################################
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws ecs tag-resource --region $region --resource-arn $id --tags key=CostCenter,value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_ecr(){ ##################################
    while IFS=, read -r id region name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws ecr tag-resource --region $region --resource-arn $id --tags Key=CostCenter,Value=$name
    done < list.csv
    printf "CostCenter tagging completed.\n"
    rm list.csv
}

tag_s3_buckets(){
    jq -r '.Buckets[].Name' < list.json | while IFS=, read -r name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws s3api put-bucket-tagging --region $1 --bucket $name --tagging "TagSet=[{Key="CostCenter",Value="$name"}]"
    done
    printf "CostCenter tagging completed.\n"
    rm list.json
}
tag_ec2_volumes(){
    jq -r '.Volumes[].VolumeId' < list.json | while IFS=, read -r name
    do
        printf "Adding CostCenter tag to $name ..\n"
        aws ec2 create-tags --region $1 --resources "$name" --tags Key=CostCenter,Value=$name
    done
    printf "CostCenter tagging completed.\n"
    rm list.json
}
get_config_rules(){
    printf "Getting list of Config Rules...\n"
    
    aws configservice describe-config-rules --region $1 --query 'ConfigRules[*].[ConfigRuleArn,ConfigRuleName]' --output text | awk -v r=$1 '{print($1,",",r,",",$2)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_config_rules; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_codepipeline(){
    printf "Getting list of Codepipelines...\n"
    aws codepipeline list-pipelines --region $1 > list.json

    jq -r '.pipelines[].name' < list.json | while IFS=, read -r name
    do
        aws codepipeline get-pipeline --region $1 --name "$name" --query 'metadata.pipelineArn' --output text | awk -v r=$1 '{print($1)}' | tr -d '[:blank:]' >> listarn.csv
    done
    cat listarn.csv | cut -d ":" -f6 > listname.csv

    paste -d@ listarn.csv listname.csv | while IFS="@", read -r arn name 
    do
        printf "$arn will be tagged : $name \n"
    done

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_code_pipeline $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

# get arns and names for cloudwatch alarms and pass it to tag_resources func.
get_cloudwatch_alarms(){
    printf "Getting the list of CW Alarms...\n"
    aws cloudwatch describe-alarms --region $1 --query 'MetricAlarms[*].[AlarmArn,AlarmName]' --output text | awk -v r=$1 '{print($1,",",r,",",$2)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_cw_resources; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

#  get s3 bucket names and pass it
get_s3_buckets(){
    printf "Getting the list of S3 Buckets...\n"
    aws s3api list-buckets --region $1  > list.json

    jq -r '.Buckets[].Name' < list.json | while IFS=, read -r name
    do
        printf "$name will be tagged : $name \n"
    done

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_s3_buckets $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_rds_instances(){
    printf "Getting list of RDS DBs...\n"
    aws rds describe-db-instances --region $1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_rds_resources; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}
get_ec2_instances(){
    printf "Getting list of EC2 instances...\n"
    aws ec2 describe-instances --region $1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`]| [0].Value,InstanceId]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv
    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_ec2_resources; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_ec2_volume(){
    printf "Getting list of EC2 volumes...\n"
    aws ec2 describe-volumes --region $1 --query 'Volumes[*].VolumeId' --output text | awk -v r=$1 '{print($1,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv
    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_ec2_resources; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}
get_ec2_volume(){
    printf "Getting list of EC2 Volumes...\n"
    aws ec2 describe-volumes --region $1  > list.json

    jq -r '.Volumes[].VolumeId' < list.json | while IFS=, read -r name
    do
        printf "$name will be tagged : $name \n"
    done

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_ec2_volumes $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_elb(){
    printf "Getting list of Elastic Load Balancers...\n"
    
    aws elbv2 describe-load-balancers --region $1 --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_elb; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_elasticache_clusters(){
    printf "Getting list of Elasticache Clusters...\n"
    
    aws elasticache describe-cache-clusters --region $1 --query 'CacheClusters[*].[CacheClusterId,ARN]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_elasticache_resources; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_docdb_clusters(){
    printf "Getting list of DocumentDB Clusters...\n"
    
    aws docdb describe-db-clusters --region $1 --query 'DBClusters[*].[DBClusterIdentifier,DBClusterArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_docdb; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_mq_brokers(){
    printf "Getting list of MQ Brokers...\n"
    
    aws mq list-brokers --region $1 --query 'BrokerSummaries[*].[BrokerName,BrokerArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_mq; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_ecs_clusters(){
    printf "Getting list of ECS Clusters...\n"
    
    aws ecs describe-clusters --region $1 --query 'clusters[*].[clusterName,clusterArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_ecs; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_ecr_repos(){
    printf "Getting list of ECR Repositories...\n"
    
    aws ecr describe-repositories --region $1 --query 'repositories[*].[repositoryName,repositoryArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_ecr; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_secrets(){
    printf "Getting list of Secrets...\n"
    
    aws secretsmanager list-secrets --region $1 --query 'SecretList[*].[Name,ARN]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_secrets; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}


get_opensearch_domain(){
    printf "Getting list of Opensearch domains...\n"
    aws opensearch list-domain-names --region $1  > list.json

    jq -r '.DomainNames[].DomainName' < list.json | while IFS=, read -r name
    do
        aws opensearch describe-domains --region $1 --domain-names "$name" --query 'DomainStatusList[*].[DomainName,ARN]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' >> list.csv
    done

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_opensearch_domains $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_sns_topic(){
    printf "Getting list of SNS Topics...\n"
    aws sns list-topics --region $1  > list.json
    jq -r '.Topics[].TopicArn' list.json > listarn.csv
    jq -r '.Topics[].TopicArn' list.json | cut -d ":" -f6 > listname.csv

    paste -d@ listarn.csv listname.csv | while IFS="@", read -r arn name 
    do
        printf "$arn will be tagged : $name \n"
    done

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_sns_topic $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_sqs(){
    printf "Getting list of SQS queues...\n"
    aws sqs list-queues --region $1  > list.json
    jq -r '.QueueUrls[]' list.json > listurl.csv
    jq -r '.QueueUrls[]' list.json | cut -d "/" -f5 > listname.csv

    paste -d@ listurl.csv listname.csv | while IFS="@", read -r url name 
    do
        printf "$url will be tagged : $name \n"
    done

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_sqs $1; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

get_lambda(){
    printf "Getting list of Lambda functions...\n"
    
    aws lambda list-functions --region $1 --query 'Functions[*].[FunctionName,FunctionArn]' --output text | awk -v r=$1 '{print($2,",",r,",",$1)}' | tr -d '[:blank:]' > list.csv

    while IFS=, read -r id region name
    do
        printf "$id will be tagged : $name \n"
    done < list.csv

    printf "\nList is ready!\n"

    while true; do
        read -p "Do you wish to continue? [y/n] : " yn
        case $yn in
            [Yy]* ) tag_lambda; printf "All resources tagged."; break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.";;
        esac
    done
}

printf "\n= AWS CostCenter Tagger =\n\n\n"


if [[ $1 == 'cw-alarms' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_cloudwatch_alarms $aws_region
elif [[ $1 == 's3' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_s3_buckets $aws_region
elif [[ $1 == 'rds' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_rds_instances $aws_region
elif [[ $1 == 'ec2' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_ec2_instances $aws_region
elif [[ $1 == 'elb' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_elb $aws_region
elif [[ $1 == 'lambda' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_lambda $aws_region
elif [[ $1 == 'elasticache' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_elasticache_clusters $aws_region
elif [[ $1 == 'ec2-volume' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_ec2_volume $aws_region
elif [[ $1 == 'opensearch' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_opensearch_domain $aws_region
elif [[ $1 == 'docdb' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_docdb_clusters $aws_region
elif [[ $1 == 'mq' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_mq_brokers $aws_region
elif [[ $1 == 'ecs' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_ecs_clusters $aws_region
elif [[ $1 == 'ecr' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_ecr_repos $aws_region
elif [[ $1 == 'sns' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_sns_topic $aws_region
elif [[ $1 == 'sqs' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_sqs $aws_region
elif [[ $1 == 'secretsmanager' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_secrets $aws_region
elif [[ $1 == 'config-rule' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_config_rules $aws_region
elif [[ $1 == 'code-pipeline' ]]
then
    read -p "Enter the region [eu-west-1]: " aws_region
    aws_region=${aws_region:-eu-west-1}
    get_codepipeline $aws_region
elif [[ $1 == 'help' ]]
then
    echo "You can add 'CostCenter' tag to various AWS resources with this script. Use following commands to tag resources:"
    echo "cw-alarms      : Cloudwatch Alarms"
    echo "s3             : S3 Buckets"
    echo "rds            : RDS Database Instances"
    echo "ec2            : EC2 Instances"
    echo "ec2-volume     : EC2 Volumes"
    echo "elb            : Elastic Load Balancers"
    echo "lambda         : Lambda Functions"
    echo "elasticache    : Elasticache Clusters"
    echo "opensearch     : Opensearch Clusters (aka Elasticsearch)"
    echo "docdb          : DocumentDB Clusters"
    echo "mq             : Managed RabbitMQ Brokers"
    echo "ecs            : ECS Clusters"
    echo "ecr            : ECR Repositories"
    echo "sns            : SNS Topics"
    echo "sqs            : SQS Queues"
    echo "secretsmanager : SM Secrets"
    echo "config-rule : Config Service Rules"
    echo "code-pipeline : Code Pipelines"
    echo "help           : For this help section"
else
    echo "Please see help section with 'help' command."
fi