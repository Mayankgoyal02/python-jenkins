pip install requests

import requests

# Replace 'your_blazemeter_api_key' with your actual BlazeMeter API key
blazemeter_api_key = 'dd24e562a1c804ac55446bbd'

# BlazeMeter API endpoint for getting information about your account
blazemeter_api_url = f'https://a.blazemeter.com/api/latest/accounts?api_key={blazemeter_api_key}'

# Make a GET request to the BlazeMeter API
response = requests.get(blazemeter_api_url)

# Check the response status
if response.status_code == 200:
    # Print the response content (JSON data in this case)
    print(response.json())
else:
    print(f"Failed to fetch data. Status code: {response.status_code}")
