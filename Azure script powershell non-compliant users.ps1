#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users

# Connect
Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All" -NoWelcome

# Fetch all users (no Premium properties)
$users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AccountEnabled,AssignedLicenses,PasswordPolicies"

# Fetch MFA data per-user
$mfaData = @{}
foreach ($user in $users) {
    try {
        $methods = Get-MgUserAuthenticationMethod -UserId $user.Id
        $mfaData[$user.Id] = $methods.Count -gt 1
    } catch {
        $mfaData[$user.Id] = $false
    }
}

$nonCompliant = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($user in $users) {
    $issues = [System.Collections.Generic.List[string]]::new()

    if (-not $user.AccountEnabled)                                        { $issues.Add("Sign-in disabled") }
    if ($user.AssignedLicenses.Count -eq 0)                              { $issues.Add("No licence") }
    if ($user.PasswordPolicies -match "DisablePasswordExpiration")        { $issues.Add("Password never expires") }
    if ($mfaData.ContainsKey($user.Id) -and -not $mfaData[$user.Id])     { $issues.Add("MFA not registered") }

    if ($issues.Count -gt 0) {
        $nonCompliant.Add([PSCustomObject]@{
            Name   = $user.DisplayName
            UPN    = $user.UserPrincipalName
            Issues = $issues -join ", "
        })
    }
}

# Save and auto-open results
$nonCompliant | Export-Csv -Path "$HOME/non-compliant-users.csv" -NoTypeInformation
Write-Host "Found $($nonCompliant.Count) non-compliant users. Opening results..." -ForegroundColor Green
code "$HOME/non-compliant-users.csv"

Disconnect-MgGraph | Out-Null
