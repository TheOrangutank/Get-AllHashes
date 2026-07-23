param(
    [string]$Path = '.',

    [string]$Algorithm = 'SHA256',

    [string[]]$Extension
)

function Test-HashAlgorithm {
    param(
        [string]$Algorithm
    )

    $tempFile = $null

    try {
        # Create a tiny temporary file so Get-FileHash validates the algorithm immediately
        $tempFile = New-TemporaryFile

        $null = Get-FileHash `
            -Path $tempFile.FullName `
            -Algorithm $Algorithm `
            -ErrorAction Stop
    }
    catch {
        throw "Invalid or unsupported hash algorithm '$Algorithm'. $($_.Exception.Message)"
    }
    finally {
        if ($tempFile -and (Test-Path -Path $tempFile.FullName)) {
            Remove-Item -Path $tempFile.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

# Validate hash algorithm before doing any directory scan or long-running work
Test-HashAlgorithm -Algorithm $Algorithm

# Build output filename
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'

if ($Extension) {
    $extensionText = (
        $Extension |
        ForEach-Object { $_.TrimStart('.').ToLower() } |
        Sort-Object -Unique
    ) -join ''
}
else {
    $extensionText = 'all'
}

$csvPath = ".\hashes-$timestamp-$($Algorithm.ToLower())-$extensionText.csv"

# Get files
$files = Get-ChildItem -Path $Path -Recurse -File

# Apply extension filter if specified
if ($Extension) {
    $extensions = $Extension |
        ForEach-Object { $_.TrimStart('.').ToLower() }

    $files = $files |
        Where-Object {
            $_.Extension.TrimStart('.').ToLower() -in $extensions
        }
}

$total = @($files).Count

if ($total -eq 0) {
    Write-Warning "No matching files found."
    return
}

# Create CSV header
"FileName,FullPath,$Algorithm,SizeBytes" |
    Set-Content -Path $csvPath -Encoding UTF8

$count = 0

foreach ($file in $files) {
    $count++

    Write-Progress `
        -Activity "Calculating hashes" `
        -Status "$count of $total : $($file.Name)" `
        -PercentComplete (($count / $total) * 100)

    Write-Host "[$count/$total] Processing: $($file.FullName)" -ForegroundColor Cyan

    $hash = (Get-FileHash -Path $file.FullName -Algorithm $Algorithm).Hash

    $name = $file.Name.Replace('"', '""')
    $fullPath = $file.FullName.Replace('"', '""')

    '"{0}","{1}","{2}",{3}' -f `
        $name,
        $fullPath,
        $hash,
        $file.Length |
        Add-Content -Path $csvPath -Encoding UTF8
}

Write-Progress -Activity "Calculating hashes" -Completed

Write-Host ""
Write-Host "Completed. Processed $total file(s)." -ForegroundColor Green
Write-Host "Algorithm       : $Algorithm" -ForegroundColor Green
Write-Host "Source path     : $Path" -ForegroundColor Green
Write-Host "Output file     : $csvPath" -ForegroundColor Green
