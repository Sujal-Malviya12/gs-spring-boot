param (
    [string]$current,
    [string]$baseline
)

$currentData = Get-Content $current | ConvertFrom-Json
$baselineData = Get-Content $baseline | ConvertFrom-Json

$allowedAvgIncrease = 10   # %
$allowedP95Increase = 15  # %

function exceeded($new, $old, $limit) {
    if ($old -eq 0) { return $false }
    return ((($new - $old) / $old) * 100) -gt $limit
}

if (
    exceeded $currentData.avg $baselineData.avg $allowedAvgIncrease -or
    exceeded $currentData.p95 $baselineData.p95 $allowedP95Increase -or
    $currentData.errorRate -gt 0
) {
    Write-Host "❌ Performance regression detected"
    Write-Host "Current:" ($currentData | ConvertTo-Json)
    Write-Host "Baseline:" ($baselineData | ConvertTo-Json)
    exit 1
}

Write-Host "✅ Performance within acceptable limits"
