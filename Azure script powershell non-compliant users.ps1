#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Reports
 
# Connect
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All", "Reports.Read.All" -NoWelcome
 
# Fetch all users
$users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AccountEnabled,AssignedLicenses,SignInActivity,PasswordPolicies"
 
# Fetch MFA registration data
$mfaData = @{}
try {
    Get-MgReportAuthenticationMethodUserRegistrationDetail -All | ForEach-Object { $mfaData[$_.Id] = $_ }
} catch {
    Write-Warning "Could not retrieve MFA data (requires Reports.Read.All and Azure AD P1/P2)."
}
 
$staleDate = (Get-Date).AddDays(-90)
$nonCompliant = [System.Collections.Generic.List[PSCustomObject]]::new()
 
foreach ($user in $users) {
    $issues = [System.Collections.Generic.List[string]]::new()
 
    if (-not $user.AccountEnabled)                                                          { $issues.Add("Sign-in disabled") }
    if ($user.AssignedLicenses.Count -eq 0)                                                { $issues.Add("No licence") }
    if ($user.PasswordPolicies -match "DisablePasswordExpiration")                         { $issues.Add("Password never expires") }
    if ($mfaData.ContainsKey($user.Id) -and -not $mfaData[$user.Id].IsMfaRegistered)      { $issues.Add("MFA not registered") }
 
    $lastSignIn = $user.SignInActivity?.LastSignInDateTime
    if ($lastSignIn -and [datetime]$lastSignIn -lt $staleDate)                             { $issues.Add("Stale (last sign-in: $([datetime]$lastSignIn | Get-Date -Format 'yyyy-MM-dd'))") }
    elseif (-not $lastSignIn)                                                              { $issues.Add("Never signed in") }
 
    if ($issues.Count -gt 0) {
        $nonCompliant.Add([PSCustomObject]@{
            Name   = $user.DisplayName
            UPN    = $user.UserPrincipalName
            Issues = $issues -join ", "
        })
    }
}
 
# Display results
if ($nonCompliant.Count -eq 0) {
    Write-Host "No non-compliant users found." -ForegroundColor Green
} else {
    Write-Host "`nNon-Compliant Users ($($nonCompliant.Count) found):`n" -ForegroundColor Red
    $nonCompliant | Format-Table Name, UPN, Issues -AutoSize -Wrap
}
 
Disconnect-MgGraph | Out-Null
