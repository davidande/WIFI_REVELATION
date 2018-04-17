# Lister tous les réseaux wifi donc la clé est enregistrée
# Le profil choisi est "Tous les utilisateurs"

$output = netsh.exe wlan show profiles
$profileRows = $output | Select-String -Pattern 'Profil Tous les utilisateurs'
$profileNames = New-Object System.Collections.ArrayList

# On trouve 
for($i = 0; $i -lt $profileRows.Count; $i++){
    $profileName = ($profileRows[$i] -split ":")[-1].Trim()
    
    $profileOutput = netsh.exe wlan show profiles name="$profileName" key=clear
    
    $SSIDSearchResult = $profileOutput| Select-String -Pattern 'Nom du SSID'
    $profileSSID = ($SSIDSearchResult -split ":")[-1].Trim() -replace '"'

    $passwordSearchResult = $profileOutput| Select-String -Pattern 'Contenu de la cl*'
    if($passwordSearchResult){
        $profilePw = ($passwordSearchResult -split ":")[-1].Trim()
    } else {
        $profilePw = ''
    }
    
    $networkObject = New-Object -TypeName psobject -Property @{
        ProfileName = $profileName
        SSID = $profileSSID
        Password = $profilePw
    }
    $profileNames.Add($networkObject)
}
# sauvegarde le résultat dans un fichier texte
$profileNames | Select-Object SSID, Password | Out-file wifi_et_pass.txt

# affiche le résultat à l'écran
# echo $profileNames | Select-Object SSID, Password
