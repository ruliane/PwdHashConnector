$obj = New-Object -Type PSCustomObject

@(
	@{ Name="objectClass"; 			Type="String"; Value="person" }
    @{ Name="Anchor-objectGUID"; 	Type="Binary"; Value="" }
	@{ Name="ImportOnly-samAccountName"; 		Type="String"; Value="" }
	@{ Name="ImportOnly-objectSid"; 			Type="Binary"; Value="" }
	@{ Name="nTHash"; 				Type="Binary"; Value="" }
) | foreach { `
	$obj | Add-Member -Type NoteProperty -Name "$($_.Name)|$($_.Type)" -Value $_.Value
}
$obj
