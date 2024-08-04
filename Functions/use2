# Ensure Python is installed and available in the PATH
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed or not found in PATH."
    exit 1
}

# Parameters for ldapdomaindump
$domainController = "dc.example.com"
$username = "user"
$password = "password"

# Base command to run ldapdomaindump
$baseCommand = "python -m ldapdomaindump -u $username -p $password $domainController"

# Run ldapdomaindump for different enumeration scenarios
$commands = @(
    "$baseCommand --all",
    "$baseCommand --dns-dump",
    "$baseCommand --verbose"
)

foreach ($command in $commands) {
    Invoke-Expression $command
}

# Optionally handle the output
# Move the output files to a specific location
$outputDirectory = "C:\path\to\output\directory"
Move-Item -Path .\*.json -Destination $outputDirectory -Force
