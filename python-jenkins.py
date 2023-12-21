import requests


blazemeter_api_key = 'dd24e562a1c804ac55446bbd'


blazemeter_api_url = 'https://a.blazemeter.com/api/latest/accounts'

# Set up the headers with the BlazeMeter API key
headers = {
    'Authorization': blazemeter_api_key,
}

# Make a GET request to the BlazeMeter API with headers
response = requests.get(blazemeter_api_url, headers=headers)

if response.status_code == 200:
    # Print the response content (JSON data in this case)
    print(response.json())
else:
    print(f"Failed to fetch data. Status code: {response.status_code}")
