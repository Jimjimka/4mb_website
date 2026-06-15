# ═══════════════════════════════════════════════════════
#  Оптимізація зображень для 4mb.com.ua
#  Windows PowerShell скрипт
#  Вимоги: ImageMagick for Windows
#  Завантажити: https://imagemagick.org/script/download.php#windows
# ═══════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Оптимізація зображень 4mb.com.ua" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ── Перевірка ImageMagick ──
$magick = Get-Command "magick" -ErrorAction SilentlyContinue
if (-not $magick) {
    Write-Host "ПОМИЛКА: ImageMagick не встановлено!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Завантаж та встанови з:" -ForegroundColor Yellow
    Write-Host "https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "При встановленні постав галочку:" -ForegroundColor Yellow
    Write-Host "  [x] Add application directory to your system path" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Натисни Enter щоб вийти"
    exit 1
}
Write-Host "✓ ImageMagick знайдено" -ForegroundColor Green
Write-Host ""

# ── Перевірка що скрипт запущено з правильної папки ──
if (-not (Test-Path "assets\images")) {
    Write-Host "ПОМИЛКА: Запусти скрипт з кореневої папки сайту" -ForegroundColor Red
    Write-Host "Тобто там де лежить index.html" -ForegroundColor Yellow
    Read-Host "Натисни Enter щоб вийти"
    exit 1
}

# ── Створення бекапу ──
$backup = "assets\images\_backup_original"
New-Item -ItemType Directory -Force -Path "$backup\gallery" | Out-Null
New-Item -ItemType Directory -Force -Path "$backup\ui" | Out-Null
New-Item -ItemType Directory -Force -Path "$backup\hero" | Out-Null

Write-Host "Створюю бекап оригіналів..." -ForegroundColor Yellow
Copy-Item "assets\images\gallery\*.webp" "$backup\gallery\" -ErrorAction SilentlyContinue
Copy-Item "assets\images\ui\results.png" "$backup\ui\" -ErrorAction SilentlyContinue
Copy-Item "assets\images\hero\hero-bg.webp" "$backup\hero\" -ErrorAction SilentlyContinue
Write-Host "✓ Бекап збережено в: $backup" -ForegroundColor Green
Write-Host ""

# ════════════════════════════════════════════
#  1. ГАЛЕРЕЯ → 1200px, WebP 80%
# ════════════════════════════════════════════
Write-Host "Обробка галереї (gallery\*.webp) → 1200px, якість 80%..." -ForegroundColor Cyan
Write-Host ""

$galleryDir = "assets\images\gallery"
$count = 0
$totalSaved = 0

Get-ChildItem "$galleryDir\*.webp" | ForEach-Object {
    $img = $_.FullName
    $name = $_.Name
    $before = [math]::Round($_.Length / 1KB, 1)

    magick $img -resize "1200x>" -quality 80 -define webp:lossless=false -define webp:method=6 $img

    $after = [math]::Round((Get-Item $img).Length / 1KB, 1)
    $saved = [math]::Round($before - $after, 1)
    $totalSaved += $saved

    Write-Host "  ✓ $name`: ${before}KB → ${after}KB  (збережено ${saved}KB)" -ForegroundColor Green
    $count++
}

Write-Host ""
Write-Host "✓ Галерея: оброблено $count файлів, зекономлено $([math]::Round($totalSaved/1024,1)) МБ" -ForegroundColor Green
Write-Host ""

# ════════════════════════════════════════════
#  2. HERO → 1920px, WebP 75%
# ════════════════════════════════════════════
Write-Host "Обробка hero-bg.webp → 1920px, якість 75%..." -ForegroundColor Cyan

$hero = "assets\images\hero\hero-bg.webp"
if (Test-Path $hero) {
    $before = [math]::Round((Get-Item $hero).Length / 1KB, 1)
    magick $hero -resize "1920x>" -quality 75 -define webp:lossless=false $hero
    $after = [math]::Round((Get-Item $hero).Length / 1KB, 1)
    Write-Host "  ✓ hero-bg.webp: ${before}KB → ${after}KB" -ForegroundColor Green
} else {
    Write-Host "  ⚠ hero-bg.webp не знайдено, пропускаю" -ForegroundColor Yellow
}
Write-Host ""

# ════════════════════════════════════════════
#  3. results.png → results.webp 44x44px
# ════════════════════════════════════════════
Write-Host "Конвертація results.png → results.webp (44x44px)..." -ForegroundColor Cyan

$resultsPng  = "assets\images\ui\results.png"
$resultsWebp = "assets\images\ui\results.webp"

if (Test-Path $resultsPng) {
    $before = [math]::Round((Get-Item $resultsPng).Length / 1KB, 1)
    magick $resultsPng -resize "44x44" -quality 90 $resultsWebp
    $after = [math]::Round((Get-Item $resultsWebp).Length / 1KB, 1)
    Write-Host "  ✓ results.png (${before}KB) → results.webp (${after}KB)" -ForegroundColor Green
} else {
    Write-Host "  ⚠ results.png не знайдено, пропускаю" -ForegroundColor Yellow
}
Write-Host ""

# ════════════════════════════════════════════
#  4. Підсумок
# ════════════════════════════════════════════
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ГОТОВО!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Що зроблено:" -ForegroundColor White
Write-Host "  ✓ Всі фото галереї стиснуто до 1200px / WebP 80%" -ForegroundColor Green
Write-Host "  ✓ hero-bg.webp стиснуто до 1920px / WebP 75%" -ForegroundColor Green
Write-Host "  ✓ results.png конвертовано в results.webp 44x44px" -ForegroundColor Green
Write-Host ""
Write-Host "Наступні кроки:" -ForegroundColor Yellow
Write-Host "  1. Залий оновлені файли на сервер (замість старих)" -ForegroundColor White
Write-Host "  2. Залий оновлений index.html (results.png вже замінено на .webp)" -ForegroundColor White
Write-Host "  3. Перевір сайт і запусти PageSpeed знову" -ForegroundColor White
Write-Host ""
Write-Host "Оригінали збережено в: $backup" -ForegroundColor Gray
Write-Host ""
Read-Host "Натисни Enter щоб закрити"
