param (
    [Parameter(ValueFromPipeline=$true)]$exportentries,
	[Parameter(Mandatory)]$username,
	[Parameter(Mandatory)]$password,
    [Parameter(Mandatory)]$Credentials,
    $AuxUsername,
    $AuxPassword,
    $AuxCredentials,
    $ExportType,
    $ConfigurationParameter,
    $Schema
)

Begin {
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
}

Process {
	$identifier = $_."[Identifier]"
	$anchor = $_."[Anchor]"
	$dn = $_."[DN]"
	$objectmodificationtype = $_."[ObjectModificationType]"
	$samaccountname = $_.samaccountname
    #$sid = $_.objectSid
    $sid = New-Object System.Security.Principal.SecurityIdentifier($_.objectSid, 0)
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
                throw("operation-not-supported")
		    }
		    'Delete' {
			    $actioninfo = 'operation'
                throw("operation-not-supported")
		    }
		    'Replace' {
                $actioninfo = 'replace'
                Try {
                    Set-SamAccountPasswordHash `
                        -Sid $sid `
                        -NTHash $nTHash `
                        -Credential $Credentials `
                        -Server $ConfigurationParameter.ServerName
                }
                Catch [UnauthorizedAccessException] {
                    Write-Log -Message "Error while pushing password for $($samAccountName): $_" -EventId 2 -Level Warning
                    $errorstatus = "access-denied" 
		            $errordetail = $error[0]
                }
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

End {
}
