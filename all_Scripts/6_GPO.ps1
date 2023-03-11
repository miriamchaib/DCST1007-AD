# melde inn pcene i domene for remote access
Enter-PSSession -ComputerName dc1
$GPO = New-GPO -Name "Allow Remote Desktop for HR employees"
New-GPLink -Name "Allow Remote Desktop for HR employees" -Target "OU=hr,OU=Casca_Computers,OU=Casca,DC=casca,DC=com"

Add-GPORestrictedGroup -Name "Allow Remote Desktop for employees" -GPOPath $gpo.GPOFileSysPath -GroupName "Remote Desktop Users"

# Bestem passord policy for bedriftens ansatte
# ▪ Lengde, kompleksitet, varighet, historikk, etc
$GPOName = "Password policy"

#lage GPOen
New-GPO -name $GPOName -comment "Allows remote desktop"

#linke GPOen til de ulike departmentene
$OU = 'OU=Casca_Computers'
foreach ($item in $OU) {
    Get-GPO -Name $GPOName | New-GPLink -Target "$item,OU=Casca,DC=casca,DC=com"
}

$GPOName = "disable cmd, pwsh and control panel"

#Make the GPO    
New-GPO -name $GPOName -comment "Disables cmd, powershell and control panelfor users"

# link the GPO to the different departments
$OU = 'OU=finance', 'OU=consultants', 'OU=hr', 'OU=marketing', 'OU=it'
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

