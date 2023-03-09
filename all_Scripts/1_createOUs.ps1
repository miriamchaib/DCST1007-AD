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

$ouPath = "OU=Groups,OU=Casca,DC=casca,DC=com"



$local = @('l_finance', 'l_hr', 'l_consultants', 'l_marketing')
$global = @('g_finance', 'g_hr', 'g_consultants', 'g_marketing') 

$casca_group_ous = @('local', 'global')
$casca_group_ous  | ForEach-Object { 
    New-ADOrganizationalUnit "$_" -Path "OU=Casca_Groups,OU=Casca,DC=casca,DC=com" -Description "OU for $_ groups" -ProtectedFromAccidentalDeletion:$false
}

$local = @('l_finance', 'l_hr', 'l_consultants', 'l_marketing')
$global = @('g_finance', 'g_hr', 'g_consultants', 'g_marketing')

$casca_group_ous = @('local', 'global')

# groups er definert som toppOUene
# casca_group_ous er ouene local og global under toppOUen Casca_Groups
foreach ($group in $casca_group_ous) {

    if ($group -eq 'local') {
        $path = Get-ADOrganizationalUnit -Filter * | 
                Where-Object {($_.name -eq "$group") `
                -and ($_.DistinguishedName -like "OU=$group,OU=$groups,*")}
        New-ADGroup -Name "g_$department" `
                -SamAccountName "g_$department" `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName "g_$department" `
                -Path $path.DistinguishedName `
                -Description "$department group"
        }
    }
    
    if ($group -eq 'global') {
        $path = Get-ADOrganizationalUnit -Filter * | 
        Where-Object {($_.name -eq "$group") `
            -and ($_.DistinguishedName -like "OU=$,OU=$groups,*")}
        New-ADGroup -Name "l_$department" `
            -SamAccountName "l_$department" `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "l_$department" `
            -Path $path.DistinguishedName `
            -Description "$department group"
    }





    


