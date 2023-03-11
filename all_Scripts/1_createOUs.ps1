# Opprett OU-struktur i AD for brukere, maskinger og grupper

# OU=Casca,DC=casca,DC=com

New-ADOrganizationalUnit "Casca" -Description "Casca OU"


# Opprette en OU-struktur for bedriften Casca
# Vi har følgende OU'er - Casca_Users, Casca_Groups og Casca_Computers
$users = "Casca_Users"
$groups = "Casca_Groups"
$computers = "Casca_Computers"         

$topOUs = @($users,$groups,$computers)
$depts = @('finance', 'hr', 'consultants', 'marketing') # må se hva vi gjør med IT og cyber security under consultants


# Oppretter alle OUene
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



$casca_group_ous = @('local', 'global')
$casca_group_ous  | ForEach-Object { 
    New-ADOrganizationalUnit "$_" -Path "OU=Casca_Groups,OU=Casca,DC=casca,DC=com" -Description "OU for $_ groups" -ProtectedFromAccidentalDeletion:$false
}

$local = @('l_finance', 'l_hr', 'l_consultants', 'l_marketing', 'l_remoteaccess')
$global = @('g_finance', 'g_hr', 'g_consultants', 'g_marketing')


$local | ForEach-Object {
    $dept = ($_ -split '_')[1]

    New-ADGroup -Name $_ `
    -GroupCategory Security `
    -GroupScope DomainLocal `
    -DisplayName $_ `
    -Path 'OU=local,OU=Casca_Groups,OU=Casca,DC=casca,DC=com' `
    -SamAccountName "$_"
    -Description " local group for $dept security group"

}
        


$global | ForEach-Object {
    $dept = ($_ -split '_')[1]

    New-ADGroup -Name "g_$dept" `
    -SamAccountName "g_$dept" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "g_$dept" `
    -Path "OU=global,OU=Casca_Groups,OU=Casca,DC=casca,DC=com"  `
    -Description " global group for $dept security group"

}

function Get-ADGroupByName($Name) {
    Get-ADGroup -Filter "Name -eq '$Name'"
}

# remoteaccess for local users

foreach ($dept in $depts) {
    $localgroup = Get-ADGroup -Filter "Name -like 'l_$dept'"
    $localgroup | Format-Table Name, samaccountname

    $remoteaccess =  Get-ADGroupByName 'l_remoteaccess'
    foreach ($locals in $localgroup) {
        $membername = $_.samaccountname 
        if (!($remoteaccess.$membername -contains $membername)) {
            Add-ADGroupMember -Identity $remoteaccess -Members $membername
            Write-Host " added $($membername) to $($remoteaccess.Name)"
        }
    }
}
