resource "aws_ssm_parameter" "travelbuddy_image_tag" {
  name = "/application/travelbuddy/container/image/main/tag"
  type = "String"
  description = "TravelBuddy application main branch image tag"
  value = "latest"
  tier = "Standard"
}

resource "aws_ssm_parameter" "riches_image_tag" {
    name = "/application/riches/container/image/main/tag"
    type = "String"
    description = "Riches application main branch image tag"
    value = "latest"
    tier = "Standard"
}
