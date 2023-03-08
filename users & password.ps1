#Funksjon for tilfeldig generert passord, enkelte tegn er tatt vekk

Function New-UserPassword {
    $chars = [char[]](
        (35..38 | ForEach-Object {[char]$_}) + # tatt vekk 39 = ' og 34 = "
        (40..43 | ForEach-Object {[char]$_}) + # tatt vekk 44 = ,
        (45..47 | ForEach-Object {[char]$_}) +
        (48..57 | ForEach-Object {[char]$_}) + #tatt vekk 58 = :
        (60..64 | ForEach-Object {[char]$_}) + #tatt vekk 59 = ;
        (65..90 | ForEach-Object {[char]$_}) +
        (91..96 | ForEach-Object {[char]$_}) +
        (97..122 | ForEach-Object {[char]$_}) +
        (123..126 | ForEach-Object {[char]$_}) 
    )

    -join (0..12 | ForEach-Object { $chars | Get-Random })
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
    $UserPrincipalName = $UserPrincipalName.Replace('æ','ae')
    $UserPrincipalName = $UserPrincipalName.Replace('ø','o')
    $UserPrincipalName = $UserPrincipalName.Replace('å','aa')
    $UserPrincipalName = $UserPrincipalName.Replace('é','e')

    Return $UserPrincipalName
}

#importer stier
$users = Import-Csv -Path 'users.csv' -Delimiter ";"
$csvfile = @()
$exportuserspath = 'userfnutter.csv ' 
$exportpathfinal = 'usersfinal.csv ' #vet ikke om denne er nødvendig


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

#tar vekk "" og bytter med mellomrom, kan beholde, men da må vi ha 3 csv filer
$csvfile | Export-Csv -Path $exportuserspath -NoTypeInformation -Encoding 'UTF8'
Import-Csv -Path $exportuserspath | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -Replace '"', ""} | Out-File $exportpathfinal -Encoding 'UTF8'


$users = Import-Csv -path 'final path uten fnutter ' -Delimiter "," #husk å skille infoen med , (den er tatt vekk fra passord, så er good)

#lager SamAccountName
foreach ($user in $users) {
    $sam = $user.UserPrincipalName.Split("@")
        if ($sam[0].Length -gt 19) {
            "SAM for lang, bruker de 19 første tegnene i variabelen"
            $sam[0] = $sam[0].Substring(0, 19) 
        }
        $sam[0]
        [string] $samaccountname = $sam[0]

        [string] $department = $user.Department
        [string] $searchdn = "OU=$department,OU=$lit_users,*"
        $path = Get-ADOrganizationalUnit -Filter * | Where-Object {($_.name -eq $user.Department) -and ($_.DistinguishedName -like $searchdn)} 
        
        #sjekke om bruker finnes allerede
        if (!(Get-ADUser -Filter "SamAccountName -eq '$($samaccountname)'")) {
            Write-Host "$samaccountname already exists." -ForegroundColor Red
        } else {
            Write-Host "$samaccountname does not exists." -ForegroundColor Green
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




#Create personal domain admin
$Password = Read-Host -AsSecureString
New-ADUser `
-SamAccountName "maren.landro" `
-UserPrincipalName "maren.landro@casca.com" `
-Name "Maren Landro" `
-GivenName "Maren" `
-Surname "Landro" `
-Enabled $True `
-ChangePasswordAtLogon $false `
-DisplayName "Maren Landro" `
-Department "it" `
-Path "OU=it,OU=LearnIT_Users,DC=core,DC=sec" ` #må byttes
-AccountPassword $Password



Add-ADPrincipalGroupMembership -Identity 'tor.i.melling' -MemberOf "Administrators" #må byttes ?
Add-ADPrincipalGroupMembership -Identity 'tor.i.melling' -MemberOf "Domain Admins" #må byttes ?


# ---- Move Computer to correct OU ---- #
Get-ADComputer -Filter * | ft
Move-ADObject -Identity "CN=CL1,CN=Computers,DC=core,DC=sec" ` #må byttes
            -TargetPath "OU=hr,OU=LearnIT_Computers,DC=core,DC=sec" #må byttes

New-ADOrganizationalUnit "Servers" ` #må byttes
                -Description "OU for Servers" ` #må byttes
                -Path "OU=LearnIT_Computers,DC=core,DC=sec" ` #må byttes
                -ProtectedFromAccidentalDeletion:$false
