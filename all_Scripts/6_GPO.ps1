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

