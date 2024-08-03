function Merge-ZipFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ZipFiles,

        [Parameter(Mandatory=$true)]
        [string]$OutputZip
    )

    function Write-PositiveOutput {
        param ([string]$message)
        Write-Host $message -BackgroundColor Black -ForegroundColor Green
    }

    function Write-NegativeOutput {
        param ([string]$message)
        Write-Host $message -BackgroundColor Black -ForegroundColor Red
    }

    # Validate the zip files
    foreach ($zipFile in $ZipFiles) {
        if (-Not (Test-Path -Path $zipFile -PathType Leaf)) {
            Write-NegativeOutput "Zip file '$zipFile' does not exist."
            return
        }
    }

    # Create a temporary directory for extracted files
    try {
        $tempDir = New-Item -ItemType Directory -Path (Join-Path -Path $env:TEMP -ChildPath (New-Guid).Guid)
    } catch {
        Write-NegativeOutput "Error creating temporary directory: $_"
        return
    }

    # Extract each zip file to the temporary directory
    foreach ($zipFile in $ZipFiles) {
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempDir.FullName)
        } catch {
            Write-NegativeOutput "Error extracting zip file '$zipFile': $_"
            return
        }
    }

    # Create the output zip file from the temporary directory
    try {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir.FullName, $OutputZip)
    } catch {
        Write-NegativeOutput "Error creating output zip file: $_"
        return
    } finally {
        # Clean up the temporary directory
        try {
            Remove-Item -Path $tempDir.FullName -Recurse -Force
        } catch {
            Write-NegativeOutput "Error cleaning up temporary directory: $_"
        }
    }

    Write-PositiveOutput "Zip files have been merged into '$OutputZip'."
}

# Example usage
Merge-ZipFiles -ZipFiles "C:\Path\To\FirstZip.zip", "C:\Path\To\SecondZip.zip" -OutputZip "C:\Path\To\MergedZip.zip"
