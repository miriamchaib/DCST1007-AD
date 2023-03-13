$depts = @('finance', 'hr', 'consultants', 'marketing', 'it') 

# Creating the local and global OUs under Casca_Groups

$casca_group_ous = @('local', 'global')
$casca_group_ous  | ForEach-Object { 
    New-ADOrganizationalUnit "$_" -Path "OU=Casca_Groups,OU=Casca,DC=casca,DC=com" -Description "OU for $_ groups" -ProtectedFromAccidentalDeletion:$false
}

$local = @('l_finance', 'l_hr', 'l_consultants', 'l_marketing', 'l_remoteaccess', 'l_it')
$global = @('g_finance', 'g_hr', 'g_consultants', 'g_marketing', 'g__it')

# Iterate through each of the OUs and put them in their respective OU.

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