# Opprett OU-struktur i AD for brukere, maskinger og grupper

# OU=Casca,DC=casca,DC=com

New-ADOrganizationalUnit "Casca" -Description "Casca OU"


# Opprette en OU-struktur for bedriften Casca
# Vi har følgende OU'er - Casca_Users, Casca_Groups og Casca_Computers
$users = "Casca_Users"
$groups = "Casca_Groups"
$computers = "Casca_Computers"         

$topOUs = @($users,$groups,$computers)
$depts = @('finance', 'hr', 'consultants', 'marketing', 'it') # må se hva vi gjør med IT og cyber security under consultants


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

$local = @('l_finance', 'l_hr', 'l_consultants', 'l_marketing', 'l_remoteaccess', 'l_it')
$global = @('g_finance', 'g_hr', 'g_consultants', 'g_marketing', 'g__it')


# inefficient code - needs to change
foreach ($dept in $depts) {



    New-ADGroup -Name "l_$dept" `
    -SamAccountName "l_$dept" `
    -GroupCategory Security `
    -GroupScope DomainLocal `
    -DisplayName "l_$dept" `
    -Path "OU=local,OU=Casca_Groups,OU=Casca,DC=casca,DC=com" `
    -Description " local group for $dept group"

    New-ADGroup -Name "l_remoteaccess" `
    -SamAccountName "l_remoteaccess" `
    -GroupCategory Security `
    -GroupScope DomainLocal `
    -DisplayName "l_remoteaccess" `
    -Path "OU=local,OU=Casca_Groups,OU=Casca,DC=casca,DC=com" `
    -Description "remote access for local group"

    New-ADGroup -Name "g_$dept" `
    -SamAccountName "g_$dept" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "g_$dept" `
    -Path "OU=global,OU=Casca_Groups,OU=Casca,DC=casca,DC=com"  `
    -Description " global group for $dept group"


        
}

# ---- Move Computer to correct OU ---- #
Get-ADComputer -Filter * | ft
Move-ADObject -Identity "CN=MGR,CN=Computers,DC=casca,DC=com" `
            -TargetPath "OU=it,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"

Get-ADComputer -Filter * | ft
Move-ADObject -Identity "CN=CL1,CN=Computers,DC=casca,DC=com" `
            -TargetPath "OU=hr,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"

            
Get-ADComputer -Filter * | ft
Move-ADObject -Identity "CN=CL2,CN=Computers,DC=casca,DC=com" `
            -TargetPath "OU=marketing,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"
            

Get-ADComputer -Filter * | ft
Move-ADObject -Identity "CN=CL3,CN=Computers,DC=casca,DC=com" `
            -TargetPath "OU=finance,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"
                        
            

New-ADOrganizationalUnit "Servers" `
                -Description "OU for Servers" `
                -Path "OU=Casca_Computers,OU=Casca,DC=casca,DC=com" `
                -ProtectedFromAccidentalDeletion:$false
