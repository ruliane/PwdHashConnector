param (
	[Parameter(Mandatory)]$username,
	[Parameter(Mandatory)]$password,
    [Parameter(Mandatory)]$Credentials,
    $ConfigurationParameter
)

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

begin
{
    $ErrorActionPreference = "Stop"

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "DSInternals_v4.7\DSInternals\DSInternals.psd1")
    Import-Module ActiveDirectory

    If ([string]::IsNullOrEmpty($Username) -or [string]::IsNullOrEmpty($Password) -or [string]::IsNullOrEmpty($ConfigurationParameter.DomainName) -or [string]::IsNullOrEmpty($ConfigurationParameter.ServerName)) {
        throw "Argument missing. Check that UserName, Password, Domain name and Server name are specified."
    }
}

process
{
	$identifier = $_."[Identifier]"
	$anchor = $_."[Anchor]"
	$dn = $_."[DN]"
	$objectmodificationtype = $_."[ObjectModificationType]"
	$samaccountname = $_.samaccountname
    $nTHash = $_.nTHash
	
	# used to return status to sync engine; we assume that no error will occur
	$actioninfo = 'script'
	$errorstatus = "success"
	$errordetail = ""
	
	$error.clear()

	try {
		$actioninfo = 'user-read'
		Switch ($objectmodificationtype) {
            'Add' {
			    $actioninfo = 'operation'
                log ("Add - " + $samaccountname + " - " + $nTHash)
                throw("operation-not-supported")
		    }
		    'Delete' {
			    $actioninfo = 'operation'
                log ("Delete - " + $samaccountname + " - " + $nTHash)
                throw("operation-not-supported")
		    }
		    'Replace' {
                $actioninfo = 'replace'
                Set-SamAccountPasswordHash `
                    -SamAccountName $samaccountname `
                    -Domain $ConfigurationParameter.DomainName `
                    -NTHash $nTHash `
                    -Credential $Credentials `
                    -Server $ConfigurationParameter.ServerName
		    }
	    }
    }
	catch
	{
		$errorstatus = ( "{0}-error" -f $actioninfo )
		$errordetail = $error[0]
	}

	# return status about export operation
	$status = @{}
	$status."[Identifier]" = $identifier
	$status."[ErrorName]" = $errorstatus
	$status."[ErrorDetail]" = $errordetail
	$status
}

end
{
}
