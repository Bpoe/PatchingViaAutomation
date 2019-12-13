$updateDomainCount = 3

$vmsToPatch = @()
$vmsToPatch += "server01"
$vmsToPatch += "server02"
$vmsToPatch += "server03"
$vmsToPatch += "server04"
$vmsToPatch += "server05"
$vmsToPatch += "server06"
$vmsToPatch += "server07"
$vmsToPatch += "server08"
$vmsToPatch += "server09"
$vmsToPatch += "server10"


$vms = @{}
$vmsToPatch | foreach { 
    $vms.Add($_, $vms.Count % $updateDomainCount)
}

for ($ud = 0; $ud -lt $updateDomainCount; $ud++) {
   Write-Output "Starting UD:$ud"

   $currentUdVms = @()
   $vms.Keys | foreach {
      if ($vms[$_] -eq $ud) { $currentUdVms += $_ }
   }

   $jobs = @()
   $currentUdVms | foreach {
      Write-Output "Starting job to patch $_"
      $job = Start-Job -ScriptBlock { Start-Sleep -Seconds 10 }
      $jobs += $job
   }

   $jobs | Wait-Job
   Write-Output "Completed UD:$ud"
}
