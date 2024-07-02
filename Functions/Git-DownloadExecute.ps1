function Git-DownloadExecute {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryUrl,
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    function Initialize-Git {
        # Check if Git is installed
        $gitVersion = git --version 2>&1
        if ($gitVersion -match "git version") {
            Write-Output "Git is already installed: $gitVersion"
        } else {
            # Download Git installer
            $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.41.0-64-bit.exe"
            $installerPath = "$env:TEMP\git-installer.exe"
            Write-Output "Downloading Git installer..."
            Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath

            # Execute the installer silently
            Write-Output "Installing Git..."
            Start-Process -FilePath $installerPath -ArgumentList "/SILENT", "/NORESTART" -Wait

            # Verify installation
            $gitVersion = git --version 2>&1
            if ($gitVersion -match "git version") {
                Write-Output "Git successfully installed: $gitVersion"
            } else {
                Write-Output "Git installation failed."
                exit 1
            }
        }
    }

    function Clone-Repository {
        param (
            [Parameter(Mandatory = $true)]
            [string]$RepositoryUrl
        )

        $repoName = $RepositoryUrl.Split('/')[-1].Replace('.git', '')
        $clonePath = Join-Path -Path $env:USERPROFILE -ChildPath $repoName

        # Clone the repository
        Write-Output "Cloning repository $RepositoryUrl to $clonePath"
        git clone $RepositoryUrl $clonePath

        if (Test-Path $clonePath) {
            Write-Output "Repository cloned successfully."
        } else {
            Write-Output "Repository cloning failed."
            exit 1
        }
    }

    # Initialize Git
    Initialize-Git

    # Clone the repository
    Clone-Repository -RepositoryUrl $RepositoryUrl

    # Execute the command
    Write-Output "Executing command: $Command"
    Invoke-Expression $Command
}

# Example usage
# Git-DownloadExecute -RepositoryUrl "https://github.com/your/repository.git" -Command "cd $(Join-Path $env:USERPROFILE 'repository') && ./your-script.sh"
