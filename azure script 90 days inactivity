from azure.identity import DefaultAzureCredential

======================================================================

#Authenticate with credentials
#TENANT_ID = Domain
#CLIENT_ID = USERNAME
#CLIENT_SECRET = PASSWORD

credential = ClientSecretCredential(
  tenant_id=TENANT_ID,
  client_id=CLIENT_ID
  client_secret=CLIENT_SECRET
)

resource_client = ResourceManagementClient(credential, subscription_id)

=======================================================================

#Inactivity rule for 90 days
#Gets todays date and subtracts 90 days

INACTIVE_DAYS = 90
cutoff_date = datetime.utcnow() - timedelta(days=INACTIVE_DAYS)

======================================================================

#Set request headers (proof you are authenticated)

headers = {
    "authorization": f"Bearer {token}"
}

======================================================================

#Request the graph to give only the name, email and last sign-in

url = "https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,signInActiviy"

======================================================================

#Graph returns users in pages (keeps requesting data until it has gone through all pages)

while url:

======================================================================

#Make the api request
#response is made in JSON (data format)

response = requests.get(url, headers=headers)
data = response.json()

======================================================================

#loops through every user returned

for user in data.get("value", []):

======================================================================

#Gets users details name, email and last sign in date

name = user.get("displayName")
email + user.get("userPrincipalName")
sign_in = user.get("signInActivity", {}).get("LastSignInDateTime")

======================================================================

#check for users who have never signed in but had accounts created

else:
    inactive _users.append((name, email, "Never signed in"))

======================================================================

#Allows script to go though mutliple pages of users 

url = data.get("@odata.nextLink")

======================================================================

#print results 

for user in inactive_users:
    print(user)

print(f"\nTotal inactive users: {Len(inactive_users)}")

======================================================================
