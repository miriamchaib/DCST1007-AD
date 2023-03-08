
# Hard way - Brukere MED særnorske tegn og vasking/formatering av data, randomgenerering av passord #
New-Item -Path '.\Documents' -ItemType Directory

$file = '.\users_advanced.csv'
$localpath = '.\Documents/' #<--Kan brukes ved import csv
#$session = New-PSSession -ComputerName 'dc1'
Copy-Item -Path $file -Destination $localpath  # <-- må kjøres fra lokal powershell, ikke tilkoblet DC1

$csvpath = $localpath + "users_advanced.csv"
$users = Import-Csv -Path $csvpath -Delimiter ";"


#Eksporterer brukere og passord som blir generert.
#Ikke beste praksis med passord i klartekst og fil, men vi trenger å logge på brukerne etterpå
$exportpath = $localpath + "export_users.csv"
$exportpathfinal = $localpath + "export_users_final.csv"
$csvfile = @()

function New-Password 
{
  param(
    [int]$Length = 12
  )

  $characterSet = 37..126 -as [char[]]
  $password = ''
  1..$Length | ForEach-Object {
    $password += $characterSet | Get-Random
  }

  return $password
}
$password = New-Password


Function Get-UserPrincipalName {
    Param(
        [Parameter(Mandatory=$True)][string] $fornavn,
        [Parameter(Mandatory=$True)][string] $etternavn
    )

    If ( $fornavn -match $([char]32) ) {
	    
        $oppdelt = $fornavn.Split($([char]32))
        $fornavn = $oppdelt[0]
        For ( $index = 1 ; $index -lt $oppdelt.Length ; $index ++ ) {
            $fornavn += ".$($oppdelt[$index][0])"
        }
    } 

    $UserPrincipalName = $("$($fornavn).$($etternavn)").ToLower()

    $UserPrincipalName = $UserPrincipalName.Replace('æ','e')
    $UserPrincipalName = $UserPrincipalName.Replace('ø','o')
    $UserPrincipalName = $UserPrincipalName.Replace('å','a')
    $UserPrincipalName = $UserPrincipalName.Replace('é','e')

    Return $UserPrincipalName
}

ForEach ( $user in $users ) {
    $password = New-Password
    $line = New-Object -TypeName PSObject

    Add-Member -InputObject $line -MemberType NoteProperty -Name GivenName -Value $user.GivenName
    Add-Member -InputObject $line -MemberType NoteProperty -Name SurName -Value $user.SurName
    Add-Member -InputObject $line -MemberType NoteProperty -Name UserPrincipalName -Value `
	                  "$(Get-UserPrincipalName -Fornavn $user.GivenName -Etternavn $user.SurName)@casca.com"
    Add-Member -InputObject $line -MemberType NoteProperty -Name DisplayName -Value "$($user.GivenName) $($user.SurName)"
    Add-Member -InputObject $line -MemberType NoteProperty -Name Department -Value $user.Department
    Add-Member -InputObject $line -MemberType NoteProperty -Name Password -Value $password
    $csvfile += $line
}
$csvfile | Export-Csv -Path $exportpath -NoTypeInformation -Encoding 'UTF8'
Import-CSV -Path $exportpath | ConvertTo-CSV -NoTypeInformation | Out-File $exportpathfinal -Encoding utf8

$users = Import-CSV -Path $exportpathfinal -Delimiter ","
$sam=@()
foreach ($user in $users) {
    $sam = $User.UserPrincipalName.Split("@")
        if ($sam[0].Length -gt 15) {
            "for lang"
            $sam[0] = $sam[0].Substring(0, 15)
        }
		'******'
    $sam[0]
    [string]$samaccountname = $sam[0]  
}

