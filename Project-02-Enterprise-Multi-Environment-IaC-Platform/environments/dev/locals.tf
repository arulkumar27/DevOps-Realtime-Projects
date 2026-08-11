# Generates consistent names for development resources.
locals {
  normalized_project_name = replace(
    lower(trimspace(var.project_name)),
    " ",
    "-"
  )

  normalized_environment = lower(trimspace(var.environment))

  name_prefix = format(
    "%s-%s",
    local.normalized_project_name,
    local.normalized_environment
  )
}