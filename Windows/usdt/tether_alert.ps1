# --- CONFIGURATION ---
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"
$PROXY = "socks5://127.0.0.1:10808"
$BUY_ZONE_MIN = 180000
$BUY_ZONE_MAX = 200000
$STATE_FILE = "$HOME\tether_alert_state.txt"
# -----------------------

try {
    $apiUrl = "https://api.ramzinex.com/v1/ticker/usdt-irr"
    if ($PROXY) {
        $webClient = New-Object System.Net.WebClient
        $webClient.Proxy = New-Object System.Net.WebProxy($PROXY)
        $response = $webClient.DownloadString($apiUrl)
    } else {
        $response = Invoke-RestMethod -Uri $apiUrl
    }

    $data = $response | ConvertFrom-Json
    $currentPrice = [double]$data.buy
    
    # Read previous state
    $prevState = if (Test-Path $STATE_FILE) { Get-Content $STATE_FILE } else { "OUTSIDE" }

    $isInZone = ($currentPrice -ge $BUY_ZONE_MIN) -and ($currentPrice -le $BUY_ZONE_MAX)
    $currentState = if ($isInZone) { "INSIDE" } else { "OUTSIDE" }

    if ($currentState -ne $prevState) {
        if ($isInZone) {
            $msg = "🚨 *BUY ZONE ALERT!*`n`nPrice: $currentPrice`nStatus: Entered Buy Zone ✅"
        } else {
            $msg = "⚪ *EXIT ALERT*`n`nPrice: $currentPrice`nStatus: Left Buy Zone ❌"
        }

        # Send Telegram
        $tgUrl = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
        if ($PROXY) {
            $webClient = New-Object System.Net.WebClient
            $webClient.Proxy = New-Object System.Net.WebProxy($PROXY)
            $postData = "chat_id=$CHAT_ID&text=$([System.Web.HttpUtility]::UrlEncode($msg))&parse_mode=Markdown"
            $webClient.UploadString($tgUrl, "POST", [System.Text.Encoding]::UTF8.GetBytes($postData))
        } else {
            Invoke-RestMethod -Uri $tgUrl -Method Post -Body @{ chat_id = $CHAT_ID; text = $msg; parse_mode = "Markdown" }
        }

        # Local Notification
        Add-Type -AssemblyName System.Windows.Forms
        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.Visible = $true
        $notification.ShowBalloonTip(10000, "Tether Alert", $msg, [System.Windows.Forms.ToolTipIcon]::Warning)

        # Save new state
        $currentState | Out-File $STATE_FILE
    }
} catch {
    Write-Host "Error: $_"
}
