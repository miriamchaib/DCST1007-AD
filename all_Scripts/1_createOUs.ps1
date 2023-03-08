# Oprett OU-struktur i AD for brukere, maskinger og grupper

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

#liste ut alt
Get-ADOrganizationalUnit -Filter * | Select-Object name