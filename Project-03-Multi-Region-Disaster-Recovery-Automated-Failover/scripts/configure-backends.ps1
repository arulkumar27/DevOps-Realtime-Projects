$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$bootstrapPath = Join-Path $projectRoot "terraform\bootstrap"

$stateBucket = terraform -chdir="$bootstrapPath" output -raw terraform_state_bucket
$stateRegion = terraform -chdir="$bootstrapPath" output -raw terraform_state_region

if ([string]::IsNullOrWhiteSpace($stateBucket)) {
    throw "Terraform state bucket output was not found."
}

$environments = @{
    "primary" = "primary/terraform.tfstate"
    "dr"      = "dr/terraform.tfstate"
    "global"  = "global/terraform.tfstate"
}

foreach ($environment in $environments.GetEnumerator()) {
    $backendPath = Join-Path $projectRoot "terraform\$($environment.Key)\backend.hcl"

    @"
bucket       = "$stateBucket"
key          = "$($environment.Value)"
region       = "$stateRegion"
encrypt      = true
use_lockfile = true
"@ | Set-Content -Path $backendPath -Encoding utf8

    Write-Host "Created: $backendPath"
}

Write-Host "Backend configuration completed successfully."