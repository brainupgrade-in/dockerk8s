resource "aws_iam_role_policy" "${local.cluster_name}" {
  name = "${local.cluster_name}"
  role = iam_role_name.${local.cluster_name}Dev

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
     {
            "Effect": "Allow",
            "Action": [
                "eks:ListClusters",
                "eks:DescribeCluster",
                "eks:ListNodegroups",
                "eks:DescribeFargateProfile",
                "eks:ListTagsForResource",
                "eks:ListAddons",
                "eks:DescribeAddon",
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "eks:DescribeIdentityProviderConfig",
                "eks:ListUpdates",
                "eks:DescribeUpdate",
                "eks:AccessKubernetesApi",
                "eks:DescribeCluster",
                "eks:DescribeAddonVersions",
                "eks:ListIdentityProviderConfigs",
                "tag:GetResources"
            ],
            "Resource": "arn:aws:eks:${var.region}:${var.account_id}:cluster/*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "${var.region}"
                }
            }
        }
    ]
  })
}


resource "aws_iam_role" "${local.cluster_name}Dev" {
  name = "${local.cluster_name}Dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.account_id}:root",
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
      }
    ]
  })

}