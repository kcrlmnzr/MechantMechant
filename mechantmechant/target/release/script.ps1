# Créer le service
New-Service -Name "task-clipboard" -BinaryPathName "C:\Users\Carla\projects\MechantMechant\mechantmechant\target\releasemechantmechant.exe" -DisplayName "Task Clipboard Service" -Description "Service pour surveiller le presse-papiers" -StartupType Automatic

# Créer une tâche planifiée pour exécuter mechantmechant.exe toutes les 1/2 secondes
$action = New-ScheduledTaskAction -Execute "C:\Users\Carla\projects\MechantMechant\mechantmechant\target\release\mechantmechant.exe"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30) -RepetitionInterval (New-TimeSpan -Seconds 0.5) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "TaskClipboard" -Description "Exécute mechantmechant.exe toutes les 1/2 secondes"
