$Out = (Get-Item -Path env: -EA 0).GetEnumerator().foreach{ [PSCustomObject]@{ Name = $_.Key; Value = $_.Value }}
$Out | ConvertTo-Json -Compress