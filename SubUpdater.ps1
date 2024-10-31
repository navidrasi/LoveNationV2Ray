# Path to the file containing the list of configurations
$configFilePath = "config.txt"

# Initialize an empty array to hold parsed JSON entries
$jsonArray = @()

# Read each line and parse it based on the protocol
Get-Content -Path $configFilePath | ForEach-Object {
    $line = $_
    
    if ($line -match "^vless://(.+?)@(.+?):(\d+)\?(.*)#(.+)$") {
        # Parse VLESS configuration
        $jsonArray += @{
            v         = "2"
            ps        = $matches[5]
            add       = $matches[2]
            port      = $matches[3]
            id        = $matches[1]
            aid       = "0"
            net       = "ws"
            type      = "none"
            host      = $line -replace ".*host=([^&]+).*", '$1'
            path      = $line -replace ".*path=([^&]+).*", '$1'
            tls       = "tls"
            sni       = $line -replace ".*sni=([^&]+).*", '$1'
            alpn      = $line -replace ".*alpn=([^&]+).*", '$1'
            fp        = $line -replace ".*fp=([^&]+).*", '$1'
            encryption = "none"
        }
    } elseif ($line -match "^trojan://(.+?)@(.+?):(\d+)\?(.*)#(.+)$") {
        # Parse Trojan configuration
        $jsonArray += @{
            v         = "2"
            ps        = $matches[5]
            add       = $matches[2]
            port      = $matches[3]
            id        = $matches[1]
            aid       = "0"
            net       = "ws"
            type      = "none"
            host      = $line -replace ".*host=([^&]+).*", '$1'
            path      = $line -replace ".*path=([^&]+).*", '$1'
            tls       = "tls"
            sni       = $line -replace ".*sni=([^&]+).*", '$1'
            alpn      = $line -replace ".*alpn=([^&]+).*", '$1'
            fp        = $line -replace ".*fp=([^&]+).*", '$1'
            encryption = "none"
        }
    } elseif ($line -match "^ss://(.+?)@(.+?):(\d+)(.*)#(.+)$") {
        # Parse Shadowsocks configuration
        $jsonArray += @{
            v         = "2"
            ps        = $matches[5]
            add       = $matches[2]
            port      = $matches[3]
            id        = $matches[1]
            aid       = "0"
            net       = "ws"
            type      = "none"
            host      = ""
            path      = ""
            tls       = "none"
            sni       = ""
            alpn      = ""
            fp        = ""
            encryption = "none"
        }
    } elseif ($line -match "^vmess://(.+)$") {
        # Decode and parse VMess configuration
        $vmessJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($matches[1])) | ConvertFrom-Json
        $jsonArray += @{
            v         = $vmessJson.v
            ps        = $vmessJson.ps
            add       = $vmessJson.add
            port      = $vmessJson.port
            id        = $vmessJson.id
            aid       = $vmessJson.aid
            net       = $vmessJson.net
            type      = $vmessJson.type
            host      = $vmessJson.host
            path      = $vmessJson.path
            tls       = $vmessJson.tls
            sni       = $vmessJson.sni
            alpn      = $vmessJson.alpn
            fp        = $vmessJson.fp
            encryption = $vmessJson.sc
        }
    }
}

# Convert the array to JSON and save to a file
$jsonArray | ConvertTo-Json -Depth 3 | Out-File -Encoding utf8 subscription.json

# Encode the JSON file to Base64 and save to `encoded_subscription.txt`
$base64Encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Raw -Path "subscription.json")))
$base64Encoded | Out-File -Encoding utf8 encoded_subscription.txt

# Push to GitHub
git add subscription.json
git add encoded_subscription.txt
git commit -m "Updated V2Ray subscription and encoded file"
git push origin main  # Adjust branch if needed
