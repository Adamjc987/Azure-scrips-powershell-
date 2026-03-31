#connect to the mcgraph "opens a browser to automaticlly sign in"

Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All", "Reports.Read.All" -NoWelcome



#Pulls every user from your Azure AD tenant, requesting only the specific fields needed for the compliance checks — keeping it efficient.

$users = Get-MgUser -All -Property "Id,DisplayName,..."



#Grabs MFA registration status for each user and stores it in a hashtable ($mfaData) keyed by user ID so it can be looked up quickly. Wrapped in a try/catch in case your tenant doesn't have the right licence.


Get-MgReportAuthenticationMethodUserRegistrationDetail -All



#Only users with at least one issue get added to the $nonCompliant list, with their name, UPN, and a comma-separated summary of their issues.

if ($issues.Count -gt 0) { $nonCompliant.Add(...) }



#If no issues are found, prints a green success message. Otherwise prints a red header with the count and displays the full list as a formatted table.

$nonCompliant | Format-Table Name, UPN, Issues -AutoSize -Wrap



#Disconnects graph when done

Disconnect-MgGraph | Out-Null
