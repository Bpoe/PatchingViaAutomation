enum OperationResultCode {
   NotStarted = 0
   InProgress = 1
   Succeeded = 2
   SuceededWithErrors = 3
   Failed = 4
   Aborted = 5
}

$criteria = "IsInstalled=0 AND IsHidden=0"

$session = New-Object -ComObject Microsoft.Update.Session;
$searcher = $session.CreateUpdateSearcher();
$searchResults = $searcher.Search($criteria);


if ($searchResults -eq [OperationResultCode]::Succeeded -and $searchResults.Updates.Count -gt 0)
{
   $searchResults.Updates | foreach { Write-Output $_.Title }
   return $true
}

return $false