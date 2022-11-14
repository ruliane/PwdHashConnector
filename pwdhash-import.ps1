param
(
	$Username,
	$Password,
    $Credentials,
	$OperationType = "Full",
	[bool] $UsePagedImport,
	$PageSize,
    $ConfigurationParameter
)

$ErrorActionPreference = "Stop"

Function Write-Log {
    Param (
        [Parameter(Mandatory)][String]$Message,
        [int]$EventId = 0,
        [ValidateSet("Error", "Warning", "Information")]$Level = "Information"
    )

    Try {
        Write-EventLog `
             -LogName "Application" `
             -Source "PwdHashConnector" `
             -EntryType $Level `
             -EventId $EventId `
             -Message $Message
    }
    Catch {
        throw "Unable to write event. Please Check that source PwdHashConnector exists. (New-EventLog -Source ""PwdHashConnector"" -LogName Application)"
    }
}

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "DSInternals_v4.7\DSInternals\DSInternals.psd1")
Import-Module ActiveDirectory

If ([string]::IsNullOrEmpty($Username) -or [string]::IsNullOrEmpty($Password) -or [string]::IsNullOrEmpty($ConfigurationParameter.DomainName) -or [string]::IsNullOrEmpty($ConfigurationParameter.ServerName)) {
    throw "Argument missing. Check that UserName, Password, Domain name and Server name are specified."
}

Write-Log -Message "Querying directory..." -EventId 2
$ADUsers = Get-ADUser -Filter * -Server $ConfigurationParameter.ServerName -Credential $Credentials

foreach ($ADUser in $ADUsers)
{
	# we always add objectGuid and objectClass to all objects
	$obj = @{}
	$obj.objectClass = "person"
    $obj.objectGUID = $ADUser.ObjectGUID.ToByteArray()

    $obj."[DN]" = $ADUser.DistinguishedName

    $Bytes = [byte[]]::new($ADUser.SID.BinaryLength)
    $ADUser.SID.GetBinaryForm($Bytes, 0);
    $obj.objectSid = $Bytes

    $obj.samAccountName = $ADUser.samaccountname

    $obj.nTHash = (Get-ADReplAccount -SamAccountName $ADUser.samaccountname -Server $ConfigurationParameter.ServerName -Credential $Credentials).NTHash

	$obj
}
