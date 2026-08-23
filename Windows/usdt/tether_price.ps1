# --- CONFIGURATION ---
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"
$PROXY = "socks5://127.0.0.1:10808" # Leave empty if not needed
# -----------------------

try {
    # API Request
    $apiUrl = "https://api.ramzinex.com/v1/ticker/usdt-irr"
    if ($PROXY) {
        $webClient = New-Object System.Net.WebClient
        $webClient.Proxy = New-Object System.Net.WebProxy($PROXY)
        $response = $webClient.DownloadString($apiUrl)
    } else {
        $response = Invoke-RestMethod -Uri $apiUrl
    }

    # Parse JSON
    $data = $response | ConvertFrom-Json
    $buyPrice = $data.buy
    $sellPrice = $data.sell
    $change = $data.change_24h

    # Format Message
    $msg = "📊 *USDT/IRR Report*`n`n" +
           "💰 Buy: $buyPrice`n" +
           "💰 Sell: $sellPrice`n" +
           "📈 24h: $change%`n" +
           "⏰ $(Get-Date -Format 'HH:mm')"

    # Send to Telegram
    $tgUrl = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    $body = @{ chat_id = $CHAT_ID; text = $msg; parse_mode = "Markdown" }
    
    if ($PROXY) {
        $webClient = New-Object System.Net.WebClient
        $webClient.Proxy = New-Object System.Net.WebProxy($PROXY)
        $postData = "chat_id=$CHAT_ID&text=$([System.Web.HttpUtility]::UrlEncode($msg))&parse_mode=Markdown"
        $webClient.UploadString($tgUrl, "POST", [System.Text.Encoding]::UTF8.GetBytes($postData))
    } else {
        Invoke-RestMethod -Uri $tgUrl -Method Post -Body $body
    }

    # Local Windows Notification
    Add-Type -AssemblyName System.Windows.Forms
    $notification = New-Object System.Windows.Forms.NotifyIcon
    $notification.Icon = [System.Drawing.SystemIcons]::Information
    $notification.Visible = $true
    $notification.ShowBalloonTip(5000, "USDT Price Update", "Buy: $buyPrice | Sell: $sellPrice", [System.Windows.Forms.ToolTipIcon]::Info)

} catch {
    Write-Host "Error occurred: $_"
}
