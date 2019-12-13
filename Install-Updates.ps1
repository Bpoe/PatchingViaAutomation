enum OperationResultCode {
   NotStarted = 0
   InProgress = 1
   Succeeded = 2
   SuceededWithErrors = 3
   Failed = 4
   Aborted = 5
}

$rebootNeededHResult = 2359301

$criteria = "IsInstalled=0 AND IsHidden=0"

$session = New-Object -ComObject Microsoft.Update.Session;

do {
   $searcher = $session.CreateUpdateSearcher();
   $searchResults = $searcher.Search($criteria);

   if ($searchResults.ResultCode -eq [OperationResultCode]::Succeeded -and $searchResults.Warnings.Count -ne 0 -and ($searchResults.Warnings | where { $_.HResult -eq 2359301 }).Count -gt 0) {
      Write-Output "Reboot needed before proceeding"
      Restart-Computer -Force
      Start-Sleep -Seconds 300
   }

   $updateCollection = New-Object -com "Microsoft.Update.UpdateColl"
   $searchResults.Updates | foreach {
      if ($_.InstallationBehavior.CanRequestUserInput -ne $true) {
         $updateCollection.Add($_) | Out-Null
         $updateCollection | foreach { $_.Title }
      }
   }

   if ($updateCollection.Count -eq 0) {
      Write-Output "No updates to install"
      exit 0
   }

   $installer = $session.CreateUpdateInstaller()
   $installer.Updates = $updateCollection
   $installResults = $installer.Install()

   if ($installResults.RebootRequired) {
      Restart-Computer -Force
      Start-Sleep -Seconds 300
   }
} while ($searchResults -eq [OperationResultCode]::Succeeded -and $searchResults.Updates.Count -gt 0)