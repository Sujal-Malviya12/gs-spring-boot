param (
    [string]$jtlPath,
    [string]$outPath
)

$results = Import-Csv $jtlPath

$avg = [int](($results | Measure-Object elapsed -Average).Average)

$sorted = $results.elapsed | Sort-Object
$p95Index = [int]([math]::Ceiling($sorted.Count * 0.95)) - 1
$p95 = [int]$sorted[$p95Index]

$errors = ($results | Where-Object { $_.success -eq "false" }).Count
$total = $results.Count
$errorRate = if ($total -eq 0) { 0 } else { [math]::Round(($errors / $total) * 100, 2) }

$data = @{
    avg = $avg
    p95 = $p95
    errorRate = $errorRate
    timestamp = (Get-Date).ToString("s")
    build = $env:BUILD_NUMBER
    branch = $env:BRANCH_NAME
}

$data | ConvertTo-Json -Depth 3 | Out-File $outPath -Encoding utf8
