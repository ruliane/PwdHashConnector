param
(
	$Username = "",
	$Password = "",
    $Credentials,
	$OperationType = "Full",
	[bool] $UsePagedImport,
	$PageSize,
    $ConfigurationParameter
)

$ErrorActionPreference = "Stop"

Import-Module "C:\Temp\PwdHashConnector\DSInternals_v4.7\DSInternals\DSInternals.psd1"
Import-Module ActiveDirectory

	function log($message) {
		if ( $message ) {
			$message | Out-File -Append -FilePath "C:\Temp\pwdhash-import.log"
		}
	}

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

    log ("grab hash of " + $ADUser.samaccountname + " from " + $ConfigurationParameter.ServerName + " using " + $Credentials.UserName)
    $obj.nTHash = (Get-ADReplAccount -SamAccountName $ADUser.samaccountname -Server $ConfigurationParameter.ServerName -Credential $Credentials).NTHash

	$obj
}
