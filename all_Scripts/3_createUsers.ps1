# bulk user creation with group membership in active directory 

$users = Import-Csv -Path 'allUsers.csv' -Delimiter ";"
$csvfile = @()


#ender opp med denne
$exportuserspath = 'users_final.csv'
$exportuserspathfinal = 'users_uten_final.csv'
#må lage samaccountname som ikke inneholder norske særtegn, eks bruke brukernavn som samaccountname så det som eksporteres er den endelige
# lista med brukere hvor man har att hensyn til at feks samaccountname ikke kan ikkeholde æ ø og å + at passord inneholder spesialtegn oog tall

# generere rand pass
function New-UserPassword {
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
$password = New-UserPassword -length 14



function New-UserInfo {
    param(
        # givenname surname
        [Parameter(Mandatory=$true)][string] $fornavn,
        [Parameter(Mandatory=$true)][string] $etternavn
    )

    # flere har to navn mellomnavn også

    # char 32 representerer mellomrom
    # hvis fornavn inneholder mellomrom, altså eks "fornavn mellomnavn" som givenname så må vi gjøre noe med det
    if($fornavn -match $([char]32)) {
        $oppdelt = $fornavn.Split($([char]32)) # deler opp fornavnet i to, oppdelt[0]= fornavn oppdelt[1] mellomnavn
        $fornavn = $oppdelt[0]

        for ($index = 1; $index -lt $oppdelt.Length; $index ++) {
            $fornavn += ".$($oppdelt[$index][0])" # hele navnet med punktum i mellom

        }

    }

    # lage brukenavn og samaccountname lowercase

    $UserPrincipalName = $("$($fornavn).$etternavn").ToLower() 

    # kan ikke ha æ ø å og andre særtegn i samaccountname
    $UserPrincipalName = $UserPrincipalName.Replace('æ', 'e')
    $UserPrincipalName = $UserPrincipalName.Replace('ø', 'o')
    $UserPrincipalName = $UserPrincipalName.Replace('å', 'a')
    $UserPrincipalName = $UserPrincipalName.Replace('é', 'e')

    return $UserPrincipalName

}

# adder kolonner i excelfila

foreach($user in $users) {
    $password = New-UserPassword -Length 14 # passordet 
    $line = New-Object -TypeName PSObject 

    Add-Member -InputObject $line -MemberType NoteProperty -Name GivenName -Value $user.GivenName 
    Add-Member -InputObject $line -MemberType NoteProperty -Name SurName -Value $user.SurName
    Add-Member -InputObject $line -MemberType NoteProperty -Name UserPrincipalName -Value "$(New-UserInfo -Fornavn $user.GivenName -Etternavn $user.SurName)@casca.com" # sender fornavn og etternavn til funksjonen som krever det
    Add-Member -InputObject $line -MemberType NoteProperty -Name DisplayName -Value "$($user.GivenName) $($user.SurName)"
    Add-Member -InputObject $line -MemberType NoteProperty -Name Department -Value  $user.Department
    Add-Member -InputObject $line -MemberType NoteProperty -Name Password -Value $password
    $csvfile += $line
}

# hittil har vi fått givenname surname userprincipalname displayname department og password

$csvfile | Export-Csv -Path $exportuserspath -NoTypeInformation -Encoding 'UTF-8'

# fnutter
Import-Csv -Path $exportuserspath | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -Replace '"', ""} | Out-File $exportuserspathfinal -Encoding 'UTF-8'


# samaccountname er mandatory, hvilken verdi skal vi gi (20 characters or less)
$users = Import-Csv -path 'users_uten_final.csv' -Delimiter ","

foreach ($user in $users) {
    
    $sam = $user.UserPrincipalName.Split("@") 
    if ($sam[0].Length -gt 19) {
        "SAM for lan, bruker de 19 første tegnene i variabelen"
        $sam[0] = $sam[0].Substring(0,19)

    }
    $sam[0]
    [string]$samaccountname = $sam[0]

    # ouen den skal ligge i

    [string]$department = $user.Department
    [string] $searchdn = "OU=$department,OU=Casca_Users,*"
    $path = Get-ADOrganizationalUnit -Filter * | Where-Object {($_.name -eq $user.Department) -and ($_.DistinguishedName -like $searchdn)}

    New-ADUser `
    -SamAccountName $samaccountname `
    -UserPrincipalName $user.UserPrincipalName `
    -Name $samaccountname `
    -GivenName $user.GivenName `
    -Surname $user.SurName `
    -Enabled $True `
    -ChangePasswordAtLogon $false `
    -DisplayName $user.DisplayName `
    -Department $user.Department `
    -Path $path `
    -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force)
}

$depts = @('finance', 'hr', 'consultants', 'marketing', 'it') # må se hva vi gjør med IT og cyber security under consultants


# legg til i adgroup

# hvordan finne brukere med dept

# adusers må inneholde alle brukere som har en department satt
foreach ($ou in $topOUs) {
    New-ADOrganizationalUnit $ou `
    -ProtectedFromAccidentalDeletion:$false `
    -Path "OU=Casca,DC=casca,DC=com" `
    -Description "Top OU for Casca" `

    $topOU = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.name -eq "$ou"}


    foreach ($dept in $depts) {
        New-ADOrganizationalUnit $dept  `
        -Path $topOU.DistinguishedName  `
        -Description "Department OU for $dept in topOU $depts" `
        -ProtectedFromAccidentalDeletion:$false

    }
}

# NEW AD GROUP FOR NEW USERS 

function ADGroup {
    param (
        $OU
    )
    
    $users = Get-ADUser -Filter * -Properties department -SearchBase "OU=Casca_Users,OU=Casca,DC=casca,DC=com"

    foreach ($user in $users) {
        switch ($user.department) {
            "Finance" {
                $globalGroup = "g_finance"
                $localGroup = "l_finance"
            }
            "HR" {
                $globalGroup = "g_hr"
                $localGroup = "l_hr"
            }
            "Consultants" {
                $globalGroup = "g_consultants"
                $localGroup = "l_consultants"
            }
            "Marketing" {
                $globalGroup = "g_marketing"
                $localGroup = "l_marketing"
            }
            "it" {
                $globalGroup = "g_it"
                $localGroup = "l_it"
            }
            default { Write-Warning "Unknown department: $($user.department)" }
        }

        Add-ADGroupMember -Identity $globalGroup -Members $user
        Add-ADGroupMember -Identity $localGroup -Members $user

    }
}

ADGroup("finance")
ADGroup("hr")
ADGroup("consultants")
ADGroup("marketing")
ADGroup("it")


foreach ($dept in $depts) {
    $localgroup = Get-ADGroup -Filter * | Where-Object { $_.Name -match "^l_$dept"}
    $localgroup | Format-Table Name, samaccountname

    $remoteaccess = Get-ADGroup -Filter "Name -eq 'l_remoteaccess'"
    foreach ($member in (Get-ADGroupMember -Identity $localgroup)) {
        $membername = $member.samaccountname 
        if (!(Get-ADGroupMember -Identity $remoteaccess -Recursive | Where-Object { $_.samaccountname -eq $membername })) {
            Add-ADGroupMember -Identity $remoteaccess -Members $membername
            Write-Host " added $($membername) to $($remoteaccess.Name)"
        }
    }
}

