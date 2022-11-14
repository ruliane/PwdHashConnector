# PwdHashConnector
Password Synchronization based on PSMA and DSInternals 


## Prerequisites
Søren Granfeldt's PowerShell module: https://github.com/sorengranfeldt/psma/releases

## Installation
Copy source to a directory

Download and copy Michael Grafnetter's DSInternals to the same directory : https://github.com/MichaelGrafnetter/DSInternals/releases

Create event log:
New-EventLog -Source "FIM.MARE" -LogName Application
