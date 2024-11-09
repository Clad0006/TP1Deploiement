#install Windows Server Feature for IIS service
Add-WindowsFeature Web-Server -IncludeAllSubFeature
Add-WindowsFeature Web-Mgmt-Service

# Define the HTML content
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Welcome Page</title>
</head>
<body>
    <h1>Welcome to this Windows Web Server</h1>
</body>
</html>
"@

# Write the HTML content to index.html
Set-Content -Path "c:\inetpub\wwwroot\index.html" -Value $htmlContent