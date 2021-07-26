#!/bin/bash
AWS_CLI=/bin/aws
SIZE=50
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\"`"
EC2_AWSAVZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EC2_REGION=${EC2_AWSAVZONE::-1}
VOL_ID=$($AWS_CLI ec2 describe-volumes  --filters Name=attachment.device,Values=/dev/xvda Name=attachment.instance-id,Values=$EC2_INSTANCE_ID --query 'Volumes[*].{ID:VolumeId}' --region $EC2_REGION --output text | awk '{print $NF'})
echo "[INFO] Found Volume ID $VOL_ID"
$AWS_CLI ec2 modify-volume --region=$EC2_REGION --volume-id $VOL_ID --size=$SIZE
sleep 20
sudo growpart /dev/xvda 1
sleep 10
sudo xfs_growfs /dev/xvda1

