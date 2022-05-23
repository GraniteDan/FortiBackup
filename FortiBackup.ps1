
##### SETUP #####

$FGFQDN = "172.16.200.254" #Used To Connect to API
$Hostname ="LabGate"
$Port = "4443"
$API_Key = "y3cfqgmwtyrxqpj0gz586Q1sj53z4c"
$SavePath = "C:\ConfigBackups" # Where backup files will be Stored
$RetentionDays = 30
$APIUrl = "https://$FGFQDN`:$Port/api/v2/monitor/system/config/backup?scope=global&access_token=$API_Key"
#If Certificate Trust Fails / Self Signed Certificate is used Set to True
$IgnoreCertCheck = $true
#################

##### Use Git for Version Control #####

# Setup Your Local and Remote Git Repos manually before Configuring here

$SaveToGit = $True #Set To True If you want to save to Local Git Repo defined below
$GitRemotePush = $True #Set To True if you want to push to a remote after saving to local repo
$GitRemoteName = "origin"
$LocalRepo = "C:\ConfigBackupRepo"
$GitFileName = "$Hostname.conf"

#######################################

#Create SavePath if needed
if (!(Test-path -path $SavePath)){md $SavePath}

$Header = "
##########################################################################
#
#   FortiOS Config Backup Utility
#   
#   Version: 1.2 / May 13 2022
#   Author: Dan Parr / dparr@granite-it.net
#   https://github.com/granitedan/Fortibackup
#
##########################################################################
"


if ($IgnoreCertCheck){
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}


clear-host
write-host -foregroundcolor yellow  $Header

# Make API Call to Fortigate
Try{
$Response = Invoke-RestMethod -Method Get -Uri $APIUrl -ContentType "application/json" -Timeoutsec 120
#

If ($Response.Length -gt 10){
    Write-host -foregroundcolor green "Config Successfully Collected"
    $d = (((get-date).ToString("yyyyMMdd_HHmmss")))
    $Response | Out-file "$SavePath\$Hostname`_$d.conf"

    #Remove Saved Configs Older than the Retention Period - Keep in If Statement to prevent Schedule from clearing saved files unless it added a new one.
    $limit = (get-date).adddays(-$RetentionDays)
    write-host "Clearing Aged Config Backups Older than $RetentionDays Days"
    Get-ChildItem -Path $SavePath | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
    if ($SavetoGit){
        write-host -foregroundcolor Magenta "Git Version Controlling..  Selected Writing to Local Repo:
        $LocalRepo
        "
        set-location  -path $LocalRepo
        $Response | Out-file $GitFileName -Force -Encoding ASCII
        git add $GitFileName
        git commit -m "Automated Config Backup $d"
        If ($GitRemotePush){
            write-host -foregroundcolor magenta "Pushing to Remote..
            " 
            git push $GitRemoteName main
        }
    
    }

}
}
Catch{
    write-error "
!!! Fortigate Backup Failed !!!

 $error[0]"
}
