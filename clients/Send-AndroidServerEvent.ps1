param(
    [Parameter(Mandatory = $true)]
    [string]$PhoneIp,

    [Parameter(Mandatory = $true)]
    [string]$EventType,

    [Parameter(Mandatory = $true)]
    [string]$Message,

    [Parameter(Mandatory = $false)]
    [int]$Port = 8080,

    [Parameter(Mandatory = $false)]
    [string]$TokenPath = "$env:USERPROFILE\.android-termux-server-token"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TokenPath)) {
    throw "Token file not found: $TokenPath"
}

$Token = (Get-Content -LiteralPath $TokenPath -Raw).Trim()
$Uri = "http://$PhoneIp`:$Port/webhook?token=$Token"

$Payload = [ordered]@{
    source     = $env:COMPUTERNAME
    event_type = $EventType
    message    = $Message
    sent_at    = (Get-Date).ToString("o")
}

Invoke-RestMethod `
    -Method Post `
    -Uri $Uri `
    -ContentType "application/json" `
    -Body ($Payload | ConvertTo-Json -Depth 5)
