function New-Administrators {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Arctic Monkeys")]
        [string]$Group,
        
        [Parameter(Mandatory=$true)]
        [string]$Password
    )

    function Check-LocalAdmin {
        try {
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
            $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
            
            if ($isAdmin) {
                Write-Host "[*] You are Local Admin" -ForegroundColor Green -BackgroundColor Black
            } else {
                Write-Host "[*] You are not local admin, elevate to Local Admin before using this script" -ForegroundColor Red -BackgroundColor Black
                exit
            }
        } catch {
            Write-Host "[*] An error occurred while checking local admin status: $_" -ForegroundColor Red -BackgroundColor Black
            exit
        }
    }

    function Create-UserGroup {
        param (
            [string]$Group,
            [string]$Password
        )

        $users = @()

        switch ($Group) {
            "Arctic Monkeys" {
                $users = @(
                    @{Username="Alex Turner"; Description="Lead singer of the Arctic Monkeys"; Password=$Password},
                    @{Username="Matt Helders"; Description="Drummer of the Arctic Monkeys"; Password=$Password},
                    @{Username="Jamie Cook"; Description="Lead Guitarist of the Arctic Monkeys"; Password=$Password},
                    @{Username="Nick O'Malley"; Description="Bass Guitarist of the Arctic Monkeys"; Password=$Password}
                )
            }
            default {
                Write-Host "[*] Unknown group specified" -ForegroundColor Red -BackgroundColor Black
                exit
            }
        }

        foreach ($user in $users) {
            try {
                $username = $user.Username
                $description = $user.Description
                $password = $user.Password

                # Checks if the user doesn't already exist
                # -------------------------------------- #
                if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
                    # Creates local user 
                    New-LocalUser -Name $username -Password (ConvertTo-SecureString $password -AsPlainText -Force) -Description $description -FullName $username -UserMayNotChangePassword -PasswordNeverExpires
                    # Adds local user to Administrators
                    Add-LocalGroupMember -Group "Administrators" -Member $username
                    # Enables local user
                    Enable-LocalUser -Name $username

                    # try/catch
                    Write-Host "[*] User $username created and added to Administrators group" -ForegroundColor Green -BackgroundColor Black
                } else {
                    Write-Host "[*] User $username already exists" -ForegroundColor Yellow -BackgroundColor Black
                }
            } catch {
                Write-Host "[*] Failed to create user $username: $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }


    # Since we're adding local admins to the administrator's group, it only 
    # makes sense checking if we first have these privileges ourselves,
    # otherwise it won't work.
    Check-LocalAdmin

    # Upon successful privileges, the new local admin group is created,
    # all from whichever group you picked, and they'll all have the same passwords.
    Create-UserGroup -Group $Group -Password $Password
}


# Example usage:
# New-Administrators -Group "Arctic Monkeys" -Password "Arctic123!@#"
