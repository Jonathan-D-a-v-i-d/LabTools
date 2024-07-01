function Transfer-OverPSSession {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [string]$LocalFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$RemoteFilePath,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    try {
        # Create a remote session to the target computer
        $session = New-PSSession -ComputerName $ComputerName -Credential $Credential

        # Copy the file to the remote session
        Copy-Item -Path $LocalFilePath -Destination $RemoteFilePath -ToSession $session

        # Confirm the file was copied
        $result = Invoke-Command -Session $session -ScriptBlock {
            param ($RemoteFilePath)
            Test-Path $RemoteFilePath
        } -ArgumentList $RemoteFilePath

        # Check the result
        if ($result) {
            Write-Output "File was successfully copied."
        } else {
            Write-Output "File copy failed."
        }
    } catch {
        Write-Error "An error occurred: $_"
    } finally {
        # Close the remote session
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}

# Example usage:
# $cred = Get-Credential
# Transfer-OverPSSession -ComputerName "172.16.25.65" -LocalFilePath "C:\path\to\local\file.txt" -RemoteFilePath "C:\path\to\remote\file.txt" -Credential $cred
