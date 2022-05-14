
##### SETUP #####

$FGFQDN = "10.20.30.40" #Used To Connect to API$Hostname = "FG-001" # Used in Filename of Config Backup
$Port = "4443"
$API_Key = "88888888nHsc33363mfHb3w7777777"
$SavePath = "C:\ConfigBackups" # Where backup files will be Stored
$RetentionDays = 30
$APIUrl = "https://$FGFQDN`:$Port/api/v2/monitor/system/config/backup?scope=global&access_token=$API_Key"

#If Certificate Trust Fails / Self Signed Certificate is used Set to True
$IgnoreCertCheck = $true
#################

#Create SavePath if needed
if (!(Test-path -path $SavePath)){md $SavePath}

$Header = "
##########################################################################
#
#   FortiOS Config Backup Utility
#   
#   Version: 1.1 / May 13 2022
#   Author: Dan Parr / dparr@granite-it.net
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
}