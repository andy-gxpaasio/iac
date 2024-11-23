$projectName = ""
#$projectName = "gxpaas"

while($projectName -eq "") {
    $projectName = read-host "Enter the project name"    
}

write-host "Creating project structure for $projectName"

# Define the root directory
$rootDir = Join-Path $PSScriptRoot $projectName

# Create root directory
New-Item -Path $rootDir -ItemType Directory -Force

# Create root files
$rootFiles = @(
    "main.tf",
    "variables.tf",
    "outputs.tf",
    "providers.tf",
    "terraform.tfvars",
    "README.md"
)

foreach ($file in $rootFiles) {
    $content = switch ($file) {
        "main.tf" { "# resource 'aws_instance' 'example' {`n#   ami           = 'ami-0c55b159cbfafe1f0'`n#   instance_type = 'var.instance_type'`n# }" }
        "variables.tf" { "# variable 'instance_type' {`n#   description = 'EC2 instance type'`n#   type        = string`n#   default     = 't2.micro'`n# }" }
        "outputs.tf" { "# output 'instance_public_ip' {`n#   description = 'Public IP address of the EC2 instance'`n#   value       = aws_instance.example.public_ip`n# }" }
        "providers.tf" { "# terraform {`n#   required_providers {`n#     aws = {`n#       source  = 'hashicorp/aws'`n#       version = '~> 4.0'`n#     }`n#   }`n# }`n`n# provider 'aws' {`n#   region = 'us-west-2'`n# }" }
        "terraform.tfvars" { "# instance_type = 't2.micro'" }
        "README.md" { "# OpenTofu IaC Project`n`nThis repository contains Infrastructure as Code for our project using OpenTofu." }
    }
    New-Item -Path "$rootDir\$file" -ItemType File -Value $content -Force
}

# Create modules directory and subdirectories
$moduleDirs = @("networking", "compute", "storage")
foreach ($dir in $moduleDirs) {
    $moduleDir = "$rootDir\modules\$dir"
    New-Item -Path $moduleDir -ItemType Directory -Force
    
    # Create files in each module directory
    $moduleFiles = @("main.tf", "variables.tf", "outputs.tf")
    foreach ($file in $moduleFiles) {
        $content = switch ($file) {
            "main.tf" { "# resource 'aws_vpc' 'example' {`n#   cidr_block = var.vpc_cidr`n#   tags = {`n#     Name = 'example-vpc'`n#   }`n# }" }
            "variables.tf" { "# variable 'vpc_cidr' {`n#   description = 'CIDR block for the VPC'`n#   type        = string`n#   default     = '10.0.0.0/16'`n# }" }
            "outputs.tf" { "# output 'vpc_id' {`n#   description = 'ID of the created VPC'`n#   value       = aws_vpc.example.id`n# }" }
        }
        New-Item -Path "$moduleDir\$file" -ItemType File -Value $content -Force
    }
}

# Create environments directory and subdirectories
$envDirs = @("dev", "staging", "prod")
foreach ($dir in $envDirs) {
    $envDir = "$rootDir\environments\$dir"
    New-Item -Path $envDir -ItemType Directory -Force
    
    # Create files in each environment directory
    $envFiles = @("main.tf", "variables.tf", "terraform.tfvars")
    foreach ($file in $envFiles) {
        $content = switch ($file) {
            "main.tf" { "# module 'networking' {`n#   source = '../../modules/networking'`n#   vpc_cidr = var.vpc_cidr`n# }" }
            "variables.tf" { "# variable 'vpc_cidr' {`n#   description = 'CIDR block for the VPC'`n#   type        = string`n# }" }
            "terraform.tfvars" { "# vpc_cidr = '10.0.0.0/16'" }
        }
        New-Item -Path "$envDir\$file" -ItemType File -Value $content -Force
    }
}

Write-Host "OpenTofu project structure created successfully at $rootDir"