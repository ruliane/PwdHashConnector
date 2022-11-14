# PwdHashConnector
Password Synchronization based on PSMA and DSInternals 


## Prerequisites
Søren Granfeldt's PowerShell module: https://github.com/sorengranfeldt/psma/releases

## Installation
Copy source to a directory

Download and copy Michael Grafnetter's DSInternals to the same directory : https://github.com/MichaelGrafnetter/DSInternals/releases

Create event log:
New-EventLog -Source "FIM.MARE" -LogName Application

## Management agent
Create a new PowerShell Management agent 

### Create Management Agent screen
* Schema Script: Full path to pwdhash-schema.ps1
* Configuration parameters :
  * DomainName: Name of your Active Directory domain
  * ServerName: FQDN of a domain controller

### Connectivity screen
* Import Script: Full path to pwdhash-import.ps1
* Export script: Full path to pwdhash-import.ps1
* Password Management Script: Full path to pwdhash-schema.ps1 [Mandatory]

### Select Attributs screen
Select all attributes
