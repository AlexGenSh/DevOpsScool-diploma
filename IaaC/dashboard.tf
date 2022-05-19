resource "time_sleep" "wait_600s" {
  create_duration = "600s"
  depends_on = [kubernetes_deployment.deployprod]
}

resource aws_cloudwatch_dashboard my-dashboard {
  dashboard_name = "tf-dashboard-1"
  depends_on = [time_sleep.wait_600s]
  dashboard_body = <<JSON
{
    "widgets": [
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeStorageSpace" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 300,
                "stat": "Average",
                "title": "RDS FreeStorageSpace"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", "${aws_eks_node_group.diploma-eks-node-group.resources}"]
                ],
                "view": "singleValue",
                "region":"${var.aws_region}",
                "title": "NodeGroup failed instances",
                "period": 300,
                "stat": "Average"
            }
        }
    ]
}
JSON
}