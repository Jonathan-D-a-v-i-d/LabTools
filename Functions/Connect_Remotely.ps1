# Function to create and store the session
function Connect-Remotely {
    param (
        [string]$TargetMachine,
        [string]$Username,
        [string]$Password,
        [scriptblock]$Command
    )

    $passwordSecure = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($Username, $passwordSecure)
    $session = Enter-PSSession -ComputerName $TargetMachine -Credential $credential
    
    # Store the session in a global variable
    $global:RemoteSession = $session

    Write-Output "Session created and stored in global variable."

    # If a command is provided, invoke it
    if ($Command) {
        Invoke-Command -Session $global:RemoteSession -ScriptBlock $Command
    }
}

# Function to run commands using the stored session
function Invoke-RemoteCommand {
    param (
        [scriptblock]$Command
    )

    if ($global:RemoteSession -eq $null) {
        Write-Error "No remote session found. Please create a session first using New-RemoteSession."
        return
    }

    Invoke-Command -Session $global:RemoteSession -ScriptBlock $Command
}

# Function to remove the session
function Remove-RemoteSession {
    if ($global:RemoteSession -ne $null) {
        Remove-PSSession -Session $global:RemoteSession
        $global:RemoteSession = $null
        Write-Output "Remote session removed."
    }
    else {
        Write-Output "No remote session to remove."
    }
}

# Example usage
# Creating a session and invoking a command immediately
Connect-Remotely -TargetMachine "target_machine" -Username "your_username" -Password "your_password" -Command { Get-Process }

# Creating a session without invoking a command
Connect-Remotely -TargetMachine "target_machine" -Username "your_username" -Password "your_password"

# Running a command using the existing session
Invoke-RemoteCommand -Command { Get-Service }

# Removing the session
Remove-RemoteSession
