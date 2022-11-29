# PwdHashConnector
Password Synchronization based on PowerShell MA and DSInternals PowerShell module


## Prerequisites

### PowerShell module
You must have [Søren Granfeldt's Powershell Management Agent](https://github.com/sorengranfeldt/psma/releases)

### Account permissions
The Management Agent account must have the "Replicate Directory Changes All" permission on the source and destination domains.

## Installation

* Copy source to a directory of your choice, for example C:\Scripts\PwdHashConnector

* Download and copy [Michael Grafnetter's DSInternals Powershell module](https://github.com/MichaelGrafnetter/DSInternals/releases) to the same directory. You now have the following content:

![image](https://user-images.githubusercontent.com/5471186/204508237-2d9c7785-0822-45c2-a29e-fd18bdea7ecf.png)

* Create event log source:
`New-EventLog -Source "PwdHashConnector" -LogName Application`

## Metaverse Schema
In the Metaverse Designer, add a binary attribute to the class "person".
![image](https://user-images.githubusercontent.com/5471186/204515327-e24a7f69-2313-4bec-88fa-6f664f6bb82f.png)

## Management agent
### Create a new PowerShell Management agent
![image](https://user-images.githubusercontent.com/5471186/204509077-65fc69dc-a745-4c98-b1a4-89d2fb829268.png)

### Create Management Agent screen
* Schema Script: Full path to pwdhash-schema.ps1
* Username: Domain\user account used to connect your Active Directory (see Prerequisites)
* Password: Password for this user account
* Configuration parameters :
  * DomainName: Name of your Active Directory domain
  * ServerName: FQDN of a domain controller

![image](https://user-images.githubusercontent.com/5471186/204509806-27a0c9c1-3a97-4a7e-9f7c-473a12333701.png)

### Global Parameters screen
* Import Script: Full path to pwdhash-import.ps1
* Export script: Full path to pwdhash-import.ps1
* Password Management Script: Full path to pwdhash-schema.ps1 [Mandatory]

![image](https://user-images.githubusercontent.com/5471186/204510433-4a1b3ac7-3d3b-4f16-94cc-685ed359cd08.png)

### Select Objet Types screen
Check "person"

![image](https://user-images.githubusercontent.com/5471186/204510564-89d9e83a-1386-4d90-aa9b-86dbddcf0167.png)

### Select Attributs screen
Select all attributes

![image](https://user-images.githubusercontent.com/5471186/204510623-de0b56de-3a49-4817-8e67-21c12932c8af.png)

### Configure Join and Projection Rules screen
Configure your join rule as needed. I recommend using a unique attribute, such as objectSid or objectGUID. You might prefer an indexed attribute.

![image](https://user-images.githubusercontent.com/5471186/204516025-273e15f6-33df-41de-878f-2c89746c4aad.png)

### Configure Attribute Flow screen
The only attribute needed `nTHash`. Import/export this attribute from/to the metaverse attribute created previously.

![image](https://user-images.githubusercontent.com/5471186/204515948-a2722764-25ce-4043-adc9-c09ff283d7ec.png)

### Configure Extensions screen
Disable password management

![image](https://user-images.githubusercontent.com/5471186/204515492-79f8bd3e-fbb6-4aac-a468-3bde66bdf9bd.png)


