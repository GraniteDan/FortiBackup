# ForitOS Backup Utility: FortiBackup.ps1

This is a Basic Script that will make a WebAPI call to a Fortigate firewall and Perform a Full backup of the Configuration.
The backup files stored in the destination save folder are maintained by the script using the RetentionDays variable, which makes this script work well as a schedule task to automate backups without the risk of consuming large amounts of disk space.  

## Setup Variables

- **$FGFQDN:** either the fully qualified domain name of the Fortigate or it's IP address
- **$Hostname:** System Hostname Used in Filename of Config Backup (Should Match the Hostname of the Fortigate)
- **$Port:** The TCP Port on Which the FortiOS API / WebUI are listening
- **$API_Key:** The API Key Generated for the API Administrator you Configure on the Fortigate
- **$SavePath:** The Folder Path where Backup Configs will be stored
- **$RetentionDays:** The number of days to retain configuration backup files
- **$IgnoreCertCheck:** If using a self-signed certificate for the management webui/API this will need to be set to $true

## File Naming Format

Backed up configuation files will be named in the following format: hostname_yyyyMMdd_HHmmss.conf.
This will allow for easy identification of the exact Date and Time that each backup was taken.

## Backup File Retention

Once the Current backup has been collected from the API and saved the script will remove any files from the SavePath folder that are older than the period of days specified in the RetentionDays variable.
