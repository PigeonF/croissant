
$alarm = New-Object System.Media.SoundPlayer "$env:windir\Media\notify.wav";

while ($true) {
    $minutes = (30 - ((Get-Date -Format "%m") % 30))
    Start-Sleep -Seconds ((60 * $minutes) - (Get-Date -Format "%s"))
    Write-Output "$(Get-Date)"
    $alarm.PlaySync();
}
