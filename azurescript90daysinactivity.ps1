Remove-Module Microsoft.Graph.* -Force -ErrorAction SilentlyContinue
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$cutoff = (Get-Date).AddDays(-90)

$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AccountEnabled,LastPasswordChangeDateTime,AssignedLicenses" `
         | Where-Object { $_.AccountEnabled -eq $true }

$inactive = $users | Where-Object {
    $_.LastPasswordChangeDateTime -and
    [datetime]$_.LastPasswordChangeDateTime -lt $cutoff
} | Select-Object DisplayName, UserPrincipalName,
    @{N="LastPasswordChange"; E={ $_.LastPasswordChangeDateTime }},
    @{N="LicenceAssigned"; E={ $_.AssignedLicenses.Count -gt 0 }}

$inactive | Format-Table -AutoSize
$inactive | Export-Csv "$HOME/inactive-users.csv" -NoTypeInformation
Write-Host "Found $($inactive.Count) potentially inactive users." -ForegroundColor Yellow

Disconnect-MgGraph | Out-Null
