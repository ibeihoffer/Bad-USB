function creds {

$creds = Get-Credential

$creds.username

$creds.Password | ConvertFrom-SecureString

$creds.GetNetworkCredential().username

$creds.GetNetworkCredential().password

}

$creds = creds

$output = @"
"@
