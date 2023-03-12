
#### - Leksjon 05 - Video 2 - Installer tjenester for DFS på SRV1 ####
Get-WindowsFeature -ComputerName srv1 
Get-WindowsFeature -ComputerName srv1 | Where-Object {$_. installstate -eq "installed"}

Install-WindowsFeature -Name FS-DFS-Namespace,FS-DFS-Replication,RSAT-DFS-Mgmt-Con `
                        -ComputerName srv1 `
                        -IncludeManagementTools

Remove-WindowsFeature -Name FS-DFS-Namespace,FS-DFS-Replication,RSAT-DFS-Mgmt-Con `
-ComputerName srv1

Get-WindowsFeature -ComputerName srv1 | Where-Object {$_. installstate -eq "installed"}



Invoke-Command -ComputerName srv1 -ScriptBlock {New-Item -Path "c:\" -Name 'dfsroots' -ItemType "directory"}
