#Clearing any old modules

Remove-Module Microsoft.Graph.* -Force -ErrorAction SilentlyContinue

=====================================================================

#Loading the required new modules
#Authentication — handles logging in
#Users — gives access to the Get-MgUser command to fetch user data

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users

=====================================================================


#Connecting to Azure

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

=====================================================================

#setting the 90 day cutoff period

$cutoff = (Get-Date).AddDays(-90)

=====================================================================

#Grabs all accounts for search
#Get-MgUser -All — pulls every user from your Azure AD tenant
#-Property — only fetches the specific fields needed (keeps it fast)
#Where-Object { $_.AccountEnabled -eq $true } — filters out disabled accounts so only active users are checked

$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AccountEnabled,LastPasswordChangeDateTime,AssignedLicenses" `
         | Where-Object { $_.AccountEnabled -eq $true }

=====================================================================

#finding all inactive users
#$_.LastPasswordChangeDateTime -and — the user has a password change date recorded
#-lt $cutoff — that date is older than 90 days (-lt means "less than")

$inactive = $users | Where-Object {
    $_.LastPasswordChangeDateTime -and
    [datetime]$_.LastPasswordChangeDateTime -lt $cutoff
=====================================================================    

#Formatting the results
#DisplayName — the user's name
#UserPrincipalName — their email address
#LastPasswordChange — renames LastPasswordChangeDateTime to something shorter
#LicenceAssigned — checks if AssignedLicenses has anything in it and returns True or False

} | Select-Object DisplayName, UserPrincipalName,
    @{N="LastPasswordChange"; E={ $_.LastPasswordChangeDateTime }},
    @{N="LicenceAssigned"; E={ $_.AssignedLicenses.Count -gt 0 }}

=====================================================================

#showing results in the terminal and printing a summary

$inactive | Format-Table -AutoSize
$inactive | Export-Csv "$HOME/inactive-users.csv" -NoTypeInformation
Write-Host "Found $($inactive.Count) potentially inactive users." -ForegroundColor Yellow

=====================================================================

#logs out of mcgraph

Disconnect-MgGraph | Out-Null
