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

Try {
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "DSInternals\DSInternals.psd1")
    Import-Module ActiveDirectory
}
Catch {
    Write-Log -Message $_ -EventId 0 -Level Error
    throw
}

If ([string]::IsNullOrEmpty($Username) -or [string]::IsNullOrEmpty($Password) -or [string]::IsNullOrEmpty($ConfigurationParameter.ServerName)) {
    $Message = "Argument missing. Check that UserName, Password and Server name are specified."
    Write-Log -Message $Message -EventId 1 -Level Error
    throw $Message
}

If (-not $BaseDN) {
    $BaseDN = (Get-ADDomain -Server $ConfigurationParameter.ServerName).distinguishedName
}
$ADUsers = $null
Foreach ($BaseDN in $ConfigurationParameter.BaseDN.SubString(1).Split($ConfigurationParameter.BaseDN[0])) {
    Try {
        # Querying all standard User accounts (filter out trusts and others non-user objects)
        $ADUsers += Get-ADUser `
                    -SearchBase $BaseDN `
                    -Filter { samAccountType -eq 0x30000000 } `
                    -Server $ConfigurationParameter.ServerName `
                    -Credential $Credentials
    }
    Catch {
        Write-Log -Message "Unable to query ${BaseDN}: $_" -EventId 3 -Level Error
        throw
    }
}

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

    Try {
        $obj.nTHash = (Get-ADReplAccount -SamAccountName $ADUser.samAccountName -Server $ConfigurationParameter.ServerName -Credential $Credentials).NTHash
    }
    Catch [UnauthorizedAccessException] {
        Write-Log -Message "Unable to replicate passwords: $_" -Level Error
        throw
    }
    Catch {
        Write-Log -Message "Unable to replicate password for user $($ADUser.samaccountname): $_" -Level Warning
        $obj."[ErrorName]" = "replication-error"
        $obj."[ErrorDetail]" = $_
        $obj.nTHash = $null
    }

	$obj
}
