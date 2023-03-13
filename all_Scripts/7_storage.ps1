
#### - Leksjon 05 - Video 2 - Installer tjenester for DFS på SRV1 ####
Get-WindowsFeature -ComputerName srv1 
Get-WindowsFeature -ComputerName srv1 | Where-Object {$_. installstate -eq "installed"}

Install-WindowsFeature -Name FS-DFS-Namespace,FS-DFS-Replication,RSAT-DFS-Mgmt-Con `
                        -ComputerName srv1 `
                        -IncludeManagementTools

Remove-WindowsFeature -Name FS-DFS-Namespace,FS-DFS-Replication,RSAT-DFS-Mgmt-Con `
-ComputerName srv1

Get-WindowsFeature -ComputerName srv1 | Where-Object {$_. installstate -eq "installed"}

$departments = @('hr','it','marketing','consultants','finance')


Invoke-Command -ComputerName srv1 -ScriptBlock {New-Item -Path "c:\" -Name 'dfsroots' -ItemType "directory"}
Invoke-Command -ComputerName srv1 -ScriptBlock {New-Item -Path "c:\" -Name 'shares' -ItemType "directory"}

# C:\dfsroots
# Ønsker å opprette fildelingsmapper for alle avdelingene
Enter-PSSession -ComputerName srv1
$folders = ('C:\dfsroots\files','C:\shares\finance','C:\shares\consultants','C:\shares\it','C:\shares\marketing','C:\shares\hr')
mkdir -path $folders
$folders | ForEach-Object {$sharename = (Get-Item $_).name; New-SMBShare -Name $shareName -Path $_ -FullAccess Everyone}

#på server1
New-DfsnRoot -TargetPath \\srv1\files -Path \\casca.com\files -Type DomainV2


# --- Create local group name l_fullaccess_......share --- #

foreach ($department in $departments)  {
    $path = Get-ADOrganizationalUnit -Filter * | 
            Where-Object {($_.name -eq "$department") `
            -and ($_.DistinguishedName -like "OU=$department,OU=local,OU=Casca_Groups,*")}
    New-ADGroup -Name "l_fullaccess_$department-share" `
            -SamAccountName "l_fullaccess_$department-share" `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "l_fullaccess_$department-share" `
            -Path $path.DistinguishedName `
            -Description "$department file sharing group"
}

foreach ($department in $departments) {
Add-ADPrincipalGroupMembership -Identity "g_$department" -MemberOf "l_fullaccess_$department-share"
}


$folders = ('C:\shares\dev')

foreach ($department in $departments) {
    $acl = Get-Acl \\casca\files\$department
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("casca\l_fullaccess_$department-share","FullControl","Allow")
    $acl.SetAccessRule($AccessRule)
    $ACL | Set-Acl -Path "\\casca\files\$department"
}
# Setter arvflagg - håndtering av arv
foreach ($department in $departments) {
    $ACL = Get-Acl -Path "\\casca\files\$department"
    $ACL.SetAccessRuleProtection($true,$true)
    $ACL | Set-Acl -Path "\\casca\files\$department"
}

foreach ($department in $departments) {
    $acl = Get-Acl "\\casca\files\$department"
    $acl.Access | Where-Object {$_.IdentityReference -eq "BUILTIN\Users" } | ForEach-Object { $acl.RemoveAccessRuleSpecific($_) }
    Set-Acl "\\casca\files\$department" $acl
    (Get-ACL -Path "\\casca\files\$department").Access | 
        Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
}

