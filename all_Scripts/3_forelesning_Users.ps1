Function New-UserPassword {
    $chars = [char[]](
        (33..47 | ForEach-Object {[char]$_}) +
        (58..64 | ForEach-Object {[char]$_}) +
        (91..96 | ForEach-Object {[char]$_}) +
        (123..126 | ForEach-Object {[char]$_}) +
        (48..57 | ForEach-Object {[char]$_}) +
        (65..90 | ForEach-Object {[char]$_}) +
        (97..122 | ForEach-Object {[char]$_})
    )

    -join (0..14 | ForEach-Object { $chars | Get-Random })
}

#Funksjon for å formatere csv-fil data til ønsket og godtatt format
function New-UserInfo {
    param (
        [Parameter(Mandatory=$true)][string] $fornavn,
        [Parameter(Mandatory=$true)][string] $etternavn
    )

    if ($fornavn -match $([char]32)) {
        $oppdelt = $fornavn.Split($([char]32))
        $fornavn = $oppdelt[0]

        for ( $index = 1 ; $index -lt $oppdelt.Length ; $index ++ ) {
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

$users = Import-Csv -Path 'users_advanced.csv' -Delimiter ";"
$csvfile = @()
$exportuserspath = 'users_final.csv'
$exportpathfinal = 'users_final-v2.csv'

foreach ($user in $users) {
    $password = New-UserPassword
    $line = New-Object -TypeName psobject

    Add-Member -InputObject $line -MemberType NoteProperty -Name GivenName -Value $User.GivenName
    Add-Member -InputObject $line -MemberType NoteProperty -Name SurName -Value $user.SurName
    Add-Member -InputObject $line -MemberType NoteProperty -Name UserPrincipalName -Value "$(New-UserInfo -Fornavn $user.GivenName -Etternavn $user.SurName)@casca.com"
    Add-Member -InputObject $line -MemberType NoteProperty -Name DisplayName -Value "$($user.GivenName) $($user.surname)" 
    Add-Member -InputObject $line -MemberType NoteProperty -Name department -Value $user.Department
    Add-Member -InputObject $line -MemberType NoteProperty -Name Password -Value $password
    $csvfile += $line
}

$csvfile | Export-Csv -Path $exportuserspath -NoTypeInformation -Encoding 'UTF8'
Import-Csv -Path $exportuserspath | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -Replace '"', ""} | Out-File $exportpathfinal -Encoding 'UTF8'


$users = Import-Csv -path 'users_final-v2.csv' -Delimiter ","

foreach ($user in $users) {
    $sam = $user.UserPrincipalName.Split("@")
        if ($sam[0].Length -gt 19) {
            "SAM for lang, bruker de 19 første tegnene i variabelen"
            $sam[0] = $sam[0].Substring(0, 19) 
        }
        $sam[0]
        [string] $samaccountname = $sam[0]

        [string] $department = $user.Department
        [string] $searchdn = "OU=$department,OU=Casca_Users,OU=Casca,*"
        $path = Get-ADOrganizationalUnit -Filter * | Where-Object {($_.name -eq $user.Department) -and ($_.DistinguishedName -like $searchdn)} 
        
        if (!(Get-ADUser -Filter "sAMAccountName -eq '$($samaccountname)'")) {
            Write-Host "$samaccountname does not exist." -ForegroundColor Green
            Write-Host "Creating User ....%" -ForegroundColor Green
            Write-Host $user.DisplayName -ForegroundColor Green

            New-ADUser `
            -SamAccountName $samaccountname `
            -UserPrincipalName $user.UserPrincipalName `
            -Name $user.DisplayName `
            -GivenName $user.GivenName `
            -Surname $user.SurName `
            -Enabled $True `
            -ChangePasswordAtLogon $false `
            -DisplayName $user.DisplayName `
            -Department $user.Department `
            -Path $path `
            -AccountPassword (convertto-securestring $user.Password -AsPlainText -Force)

        }
    }


$ADUsers = @()

foreach ($department in $departments) {
    $ADUsers = Get-ADUser -Filter {Department -eq $department} -Properties Department
    #Write-Host "$ADUsers som er funnet under $department"

    foreach ($aduser in $ADUsers) {
        Add-ADPrincipalGroupMembership -Identity $aduser.SamAccountName -MemberOf "g_$department"
    }

}

