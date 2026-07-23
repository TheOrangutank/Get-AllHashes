\# Get-FileHashes



Recursively calculate file hashes and export the results to a CSV file.



\## Usage



Hash all files in the current directory:



```powershell

.\\Get-FileHashes.ps1

```



Hash files in a specific directory:



```powershell

.\\Get-FileHashes.ps1 -Path D:\\Evidence

```



Hash only specific file types:



```powershell

.\\Get-FileHashes.ps1 -Extension zip

```



```powershell

.\\Get-FileHashes.ps1 -Extension zip,txt,docx

```



Use a different hashing algorithm:



```powershell

.\\Get-FileHashes.ps1 -Algorithm SHA512

```



\## Parameters



| Parameter | Default | Description |

|------------|---------|-------------|

| `-Path` | `.` | Directory to scan recursively |

| `-Algorithm` | `SHA256` | Hashing algorithm to use |

| `-Extension` | All files | Optional list of file extensions to process |



\## Output



Creates a timestamped CSV containing:



\- File name

\- Full path

\- Hash value

\- File size (bytes)



Example output filename:



```text

hashes-2026-07-23-0730-sha256-all.csv

hashes-2026-07-23-0730-md5-zip.csv

hashes-2026-07-23-0730-sha256-txtzip.csv

```



The script displays progress while processing files and validates the selected hash algorithm before scanning begins.

