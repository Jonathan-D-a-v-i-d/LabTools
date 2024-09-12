<#
.SYNOPSIS
    Installs and configures OpenDLP on a Windows host.
.DESCRIPTION
    This script will install and configure the OpenDLP application on a Windows host.
    It installs necessary components like Apache, MySQL, and PHP, creates the MySQL database,
    and sets up OpenDLP.
.PARAMETER DBPassword
    The password to use for the MySQL root user and the OpenDLP database user.
.EXAMPLE
    ./Install-OpenDLP.ps1 -DBPassword 'YourStrongPassword'

    This will install OpenDLP with 'YourStrongPassword' as the MySQL root and OpenDLP user password.
.NOTES
    Script must be run as Administrator.
#>

param (
    [Parameter(Mandatory=$true, HelpMessage="Password for MySQL root and OpenDLP user")]
    [string]$DBPassword
)

function Install-Chocolatey {
    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
}

function Install-Dependencies {
    Write-Host "Installing Apache, MySQL, PHP, and Git using Chocolatey..." -ForegroundColor Green
    choco install apache-httpd mysql php git -y
}

function Configure-MySQL {
    Write-Host "Configuring MySQL..." -ForegroundColor Green
    # Secure MySQL installation
    & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqladmin.exe" -u root password "$DBPassword"
    
    # Create the OpenDLP database and user
    & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p"$DBPassword" -e "CREATE DATABASE opendlp;"
    & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p"$DBPassword" -e "CREATE USER 'opendlpuser'@'localhost' IDENTIFIED BY '$DBPassword';"
    & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p"$DBPassword" -e "GRANT ALL PRIVILEGES ON opendlp.* TO 'opendlpuser'@'localhost';"
    & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p"$DBPassword" -e "FLUSH PRIVILEGES;"
}

function Install-OpenDLP {
    Write-Host "Downloading and installing OpenDLP..." -ForegroundColor Green
    # Change to Apache web root
    cd 'C:\tools\Apache24\htdocs'
    
    # Clone the OpenDLP repository
    git clone https://github.com/digitalsleuth/opendlp.git

    # Move to the opendlp directory
    cd opendlp

    # Set up the OpenDLP configuration
    $configPath = 'C:\tools\Apache24\htdocs\opendlp\config.php'
    $configContent = Get-Content $configPath
    $configContent = $configContent -replace 'db_password', $DBPassword
    Set-Content -Path $configPath -Value $configContent

    Write-Host "OpenDLP setup complete!" -ForegroundColor Green
}

function Restart-Apache {
    Write-Host "Restarting Apache service..." -ForegroundColor Green
    Start-Process -FilePath "C:\tools\Apache24\bin\httpd.exe" -ArgumentList "-k restart"
}

# Main Script Execution
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Install-Chocolatey
}

Install-Dependencies
Configure-MySQL
Install-OpenDLP
Restart-Apache

Write-Host "OpenDLP installation and configuration complete. You can access it via your web browser." -ForegroundColor Green
