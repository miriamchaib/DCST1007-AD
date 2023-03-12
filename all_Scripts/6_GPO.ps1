# melde inn pcene i domene for remote access
Enter-PSSession -ComputerName dc1
$GPO = New-GPO -Name "Allow Remote Desktop for HR employees"
New-GPLink -Name "Allow Remote Desktop for HR employees" -Target "OU=hr,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"

Add-GPORestrictedGroup -Name "Allow Remote Desktop for employees" -GPOPath $gpo.GPOFileSysPath -GroupName "Remote Desktop Users"


# Tillater bedriftens ansatte å Remote Desktop til sine laptoper (cli1 til hr, cl2 til marketing og 3 for finance)
$GPOName = "Allow RDP"

#lage GPOen
New-GPO -name $GPOName -comment "Allows remote desktop"

#linke GPOen til de ulike departmentene
$OU = 'OU=Casca_Computers'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "OU=$item,OU=Casca,DC=casca,DC=com"
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






# første instillingen er at brukere som logger inn med remote desktop i denne OUen ikke
# " ikke får lov til å skru av maskiner eller restarte  maskiner fra deres remote session
# sikrer at maskinene ikke blir utilsiktet skrudd av og tjenestene som kjører på maskinen blir utilgjengelig

# 1. Casca_Computers får en casca computers gpo
# nå må vi konfigurere gpoen
# instillinger som blir gjeldende for alle maskiner under casca computers ouen
# setter instillingene som blir gjeldene

# skal gjelde brukerne som logger inn så vi legger til en bruker under casca users først og gjør brukeren om til it admin (legger til i it admins gruppa)
# får muligheten til å logge på remote desktop på maskinene i domentet

# 

