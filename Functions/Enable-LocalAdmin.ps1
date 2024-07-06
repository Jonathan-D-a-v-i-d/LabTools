function Enable-LocalAdmin {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Password
    )

    # Define the local admin username
    $adminUser = "Administrator"

    try {
        # Enable the local admin account
        Write-Host "Enabling the local administrator account..."
        $adminAccount = Get-LocalUser -Name $adminUser
        if ($adminAccount.Enabled -eq $false) {
            Enable-LocalUser -Name $adminUser
            Write-Host "Local administrator account enabled."
        } else {
            Write-Host "Local administrator account is already enabled."
        }

        # Set the password for the local admin account
        Write-Host "Setting the password for the local administrator account..."
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        Set-LocalUser -Name $adminUser -Password $securePassword
        Write-Host "Password has been set for the local administrator account."

    } catch {
        Write-Error "An error occurred: $_"
    }
}

# Example usage: Enable-LocalAdmin -Password "Password123!"

