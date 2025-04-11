variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
