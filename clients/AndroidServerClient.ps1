param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Health", "Status", "Actions", "RunAction")]
    [string]$Mode,

    [Parameter(Mandatory = $false)]
    [ValidateSet("heartbeat", "collect-status", "list-logs", "trim-logs", "backup", "diagnose")]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$PhoneIp = "PHONE_IP",

    [Parameter(Mandatory = $false)]
    [int]$Port = 8080,

    [Parameter(Mandatory = $false)]
    [string]$TokenPath = "$env:USERPROFILE\.android-termux-server-token"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ServerBaseUrl {
    param([string]$PhoneIp, [int]$Port)
    return "http://$PhoneIp`:$Port"
}

function Get-ActionToken {
    param([string]$TokenPath)
    if (-not (Test-Path -LiteralPath $TokenPath)) {
        throw "Token file not found: $TokenPath"
    }
    $token = Get-Content -LiteralPath $TokenPath -Raw
    return $token.Trim()
}

function Invoke-ServerGet {
    param([string]$Url)
    Invoke-RestMethod -Method Get -Uri $Url -TimeoutSec 10
}

function Show-Result {
    param([object]$Data)
    $Data | ConvertTo-Json -Depth 10
}

$baseUrl = Get-ServerBaseUrl -PhoneIp $PhoneIp -Port $Port

switch ($Mode) {
    "Health" {
        $result = Invoke-ServerGet -Url "$baseUrl/health"
        Show-Result -Data $result
    }

    "Status" {
        $result = Invoke-ServerGet -Url "$baseUrl/status"
        Show-Result -Data $result
    }

    "Actions" {
        $token = Get-ActionToken -TokenPath $TokenPath
        $result = Invoke-ServerGet -Url "$baseUrl/actions?token=$token"
        Show-Result -Data $result
    }

    "RunAction" {
        if ([string]::IsNullOrWhiteSpace($Action)) {
            throw "Use -Action with -Mode RunAction."
        }
        $token = Get-ActionToken -TokenPath $TokenPath
        $result = Invoke-ServerGet -Url "$baseUrl/actions/$Action`?token=$token"
        Show-Result -Data $result
    }
}
