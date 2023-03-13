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

