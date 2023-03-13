
# Tillater bedriftens ansatte å Remote Desktop til sine laptoper (cli1 til hr, cl2 til marketing og 3 for finance)
$GPOName = "Allow RDP"

#lage GPOen
New-GPO -name $GPOName -comment "Allows remote desktop"

#linke GPOen til de ulike departmentene
$OU = 'OU=Casca_Computers'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "OU=Casca_Computers,OU=Casca,DC=casca,DC=com"
}

# GPO for removable media, ex. turning off the ability for ur users to plug in USB drives,external hard drives or insert cds and dvds

$GPOName = "Disable connection to removable media"

#Make the GPO    
New-GPO -name $GPOName -comment "Turning off ability to plug in USB drives, external hard drives, insert cd and dvd"

# link the GPO to the different departments
$OU = 'OU=finance', 'OU=consultants', 'OU=hr', 'OU=marketing', 'OU=it'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "$item,OU=Casca_Users,OU=Casca,DC=casca,DC=com"
}



# Prevent access to the command prompt, \\ (could be used to elevate a user account)
# Disable PowerShell, Ubuntu and cmd prompt bc users can run malicious scripts and is often used to spread ransomware

$GPOName = "Disable access to control panel and PowerShell, CMD"

#Make the GPO    
New-GPO -name $GPOName -comment "Disables PowerShell, Command line and prevents access to the control panel"

# link the GPO to the different departments
$OU = 'OU=finance', 'OU=consultants', 'OU=hr', 'OU=marketing'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "$item,OU=Casca_Users,OU=Casca,DC=casca,DC=com"
}


# Ansatte kan ikke force restart fordi det kna gjøre at man mister data, og komprimerer integriteten til systemet

$GPOName = "Not allowed to force restart"


$OU = 'OU=Casca_Users'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "$item,OU=Casca_Users,OU=Casca,DC=casca,DC=com"
}

$GPOName = "No forced restart is allowed"



