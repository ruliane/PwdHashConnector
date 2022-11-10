param (
	$username,
	$password,
    $Credentials,
    $ConfigurationParameter
)

begin
{
    $ErrorActionPreference = "Stop"

    Import-Module "C:\Temp\PwdHashConnector\DSInternals_v4.7\DSInternals\DSInternals.psd1"
    Import-Module ActiveDirectory
}

process
{
	function log($message) {
		if ( $message ) {
			$message | Out-File -Append -FilePath "C:\Temp\pwdhash-export.log"
		}
	}

	$identifier = $_."[Identifier]"
	$anchor = $_."[Anchor]"
	$dn = $_."[DN]"
	$objectmodificationtype = $_."[ObjectModificationType]"
	$samaccountname = $_.samaccountname
    $nTHash = $_.nTHash
	
	log "------"
	log $dn
	
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
                log ("replace - " + $samaccountname + " - " + $nTHash)
                Set-SamAccountPasswordHash -SamAccountName $samaccountname -Domain $ConfigurationParameter.DomainName -NTHash $nTHash -Credential $Credentials -Server $ConfigurationParameter.ServerName
		    }
	    }
    }
	catch
	{
		$errorstatus = ( "{0}-error" -f $actioninfo )
		$errordetail = $error[0]
        log $_
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
