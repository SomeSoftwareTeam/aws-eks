resource "aws_iam_role" "default-node-group" {
  name = "default-node-group"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.default-node-group.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.default-node-group.name
}

resource "aws_iam_role_policy_attachment" "eks-ecr-read-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.default-node-group.name
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.default.name
  instance_types  = ["t3.small"]
  node_group_name = "default"
  node_role_arn   = aws_iam_role.default-node-group.arn
  subnet_ids      = [aws_subnet.us-east-1a.id, aws_subnet.us-east-1b.id]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy-attachment,
    aws_iam_role_policy_attachment.eks-cni-policy-attachment,
    aws_iam_role_policy_attachment.eks-ecr-read-policy-attachment
  ]
}