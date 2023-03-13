New-ADOrganizationalUnit "Casca" -Description "Casca OU"

# Opprette en OU-struktur for bedriften Casca
# Vi har følgende OU'er - Casca_Users, Casca_Groups og Casca_Computers
$users = "Casca_Users"
$groups = "Casca_Groups"
$computers = "Casca_Computers"         

$topOUs = @($users,$groups,$computers)
$depts = @('finance', 'hr', 'consultants', 'marketing', 'it') 


foreach ($ou in $topOUs) {
    New-ADOrganizationalUnit $ou `
    -ProtectedFromAccidentalDeletion:$false `
    -Path "OU=Casca,DC=casca,DC=com" `
    -Description "Top OU for Casca" `

    $topOU = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.name -eq "$ou"}


    if ($ou -eq "Casca_Groups") {
        $casca_group_ous = @('local', 'global')
        $casca_group_ous  | ForEach-Object { 
         New-ADOrganizationalUnit "$_" -Path "OU=Casca_Groups,OU=Casca,DC=casca,DC=com" -Description "OU for $_ groups" -ProtectedFromAccidentalDeletion:$false
        }
    } else{
        foreach ($dept in $depts) {
            New-ADOrganizationalUnit $dept  `
            -Path $topOU.DistinguishedName  `
            -Description "Department OU for $dept in topOU $depts" `
            -ProtectedFromAccidentalDeletion:$false
    
        }
    }

}
