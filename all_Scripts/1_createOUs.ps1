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


# CREATE GROUPS

# for each object inside the groups array, create the OU with the path and description where the description is Groups/$
# security groups
$groups = @('local', 'global')
$groups | ForEach-Object {
    New-ADOrganizationalUnit $_ -Path "OU=Casca_Groups,OU=Casca,DC=casca,DC=com" -Description "$_OU group"
}

# $depts = @('finance', 'hr', 'consultants', 'marketing')

# globale og lokale grupper som representerer alle avdelingene i depts
foreach ($dept in $depts) {

    # TODO: fix dynamic $path
    $local_Groups = "l_$_"
    $global_Groups = "g_$_"

    New-ADGroup -Name $local_Groups `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=local,OU=Casca_Groups,OU=Casca,DC=casca,DC=com" `
    -Description "Local Group for $_"

    # Create the global group in the Groups\global OU
    New-ADGroup -Name $global_Groups `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=global,OU=Casca_Groups,OU=Casca,DC=casca,DC=com" `
    -Description "Global Group for $_"

}


