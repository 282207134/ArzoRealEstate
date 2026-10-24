$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path -Parent $PSScriptRoot
$logo = [System.Drawing.Image]::FromFile((Join-Path $projectRoot 'assets/images/brand.png'))
function Write-AppIcon([string]$relativePath, [int]$size) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::FromArgb(230, 253, 253))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $margin = [int]($size * 0.22)
    $graphics.DrawImage($logo, $margin, $margin, $size - 2 * $margin, $size - 2 * $margin)
    $bitmap.Save((Join-Path $projectRoot $relativePath), [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}
try {
    foreach ($density in @{mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192}.GetEnumerator()) {
        Write-AppIcon "android/app/src/main/res/mipmap-$($density.Key)/ic_launcher.png" $density.Value
    }
    $iosContents = Get-Content (Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json') -Raw | ConvertFrom-Json
    foreach ($entry in $iosContents.images) {
        $size = [int]([double]$entry.size.Split('x')[0] * [double]$entry.scale.TrimEnd('x'))
        Write-AppIcon "ios/Runner/Assets.xcassets/AppIcon.appiconset/$($entry.filename)" $size
    }
    foreach ($size in @(192, 512)) {
        Write-AppIcon "web/icons/Icon-$size.png" $size
        Write-AppIcon "web/icons/Icon-maskable-$size.png" $size
    }
    Write-AppIcon 'web/favicon.png' 32
} finally { $logo.Dispose() }
