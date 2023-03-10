#Spesifisere hvor brukerne ligger og hva departments er

$DomainUsers = Import-Csv -Path 'DomainAdmins.csv'-Delimiter ";"

$departments = @('hr', 'marketing', 'consultants', 'finance')



foreach ($user in $DomainUsers) {
    New-ADUser
    -SamAccountName $samaccountname `
        -UserPrincipalName $user.UserPrincipalName `
        -Name $user.DisplayName `
        -GivenName $user.GivenName `
        -Surname $user.SurName `
        -Enabled $True `
        -ChangePasswordAtLogon $false `
        -DisplayName $user.DisplayName `
        -Department "consultants" `
        -Path "OU=consultants,OU=LearnIT_Users,DC=casca,DC=local"
    -AccountPassword (convertto-securestring $user.Password -AsPlainText -Force)

}


Add-ADPrincipalGroupMembership -Identity New-ADUser $samaccountname  -MemberOf "Administrators" #må byttes ?
Add-ADPrincipalGroupMembership -Identity 'tor.i.melling' -MemberOf "Domain Admins"