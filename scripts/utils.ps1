# ========================================
# UTILIDADES GENERALES
# ========================================

# Convierte bytes a un formato legible (KB, MB, GB, TB)
function Convert-Size([long]$bytes) {
    if ($bytes -ge 1TB) { return ('{0:N2} TB' -f ($bytes / 1TB)) }
    if ($bytes -ge 1GB) { return ('{0:N2} GB' -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ('{0:N2} MB' -f ($bytes / 1MB)) }
    if ($bytes -ge 1KB) { return ('{0:N2} KB' -f ($bytes / 1KB)) }
    return ("{0} B" -f $bytes)
}

# Centra texto en la consola (usada por el banner)
function Write-HostCentered {
    param (
        [string]$Text,
        [ConsoleColor]$ForegroundColor = 'White'
    )
    try { $width = [Console]::WindowWidth } catch { $width = 80 }
    if (-not $width -or $width -lt 20) { $width = 80 }
    if ($Text.Length -ge $width) {
        Write-Host $Text -ForegroundColor $ForegroundColor
    } else {
        $padding = ' ' * [math]::Floor(($width - $Text.Length) / 2)
        Write-Host "$padding$Text" -ForegroundColor $ForegroundColor
    }
}

# Escribe un encabezado estilizado
function Write-Header {
    param ([string]$Title, [ConsoleColor]$Color = 'DarkCyan')
    Write-Host "`n  ╔$($null; '═' * ($Title.Length + 4))╗" -ForegroundColor $Color
    Write-Host "  ║  $Title  ║" -ForegroundColor $Color
    Write-Host "  ╚$($null; '═' * ($Title.Length + 4))╝" -ForegroundColor $Color
}

# Escribe una línea de item (Comando » Descripción)
function Write-Item {
    param (
        [string]$Label,
        [string]$Value,
        [int]$Padding = 12,
        [ConsoleColor]$LabelColor = 'Cyan',
        [ConsoleColor]$ValueColor = 'White'
    )
    Write-Host "    $($Label.PadRight($Padding))" -ForegroundColor $LabelColor -NoNewline
    Write-Host " » " -ForegroundColor Gray -NoNewline
    Write-Host $Value -ForegroundColor $ValueColor
}

# Escribe una sección de categoría
function Write-Category {
    param ([string]$Name, [ConsoleColor]$Color = 'Yellow')
    Write-Host "`n  $Name" -ForegroundColor $Color
    Write-Host "  $($null; '-' * $Name.Length)" -ForegroundColor $Color
}

# Escribe una línea divisoria
function Write-Divider {
    param ([ConsoleColor]$Color = 'DarkGray')
    try { $width = [Console]::WindowWidth } catch { $width = 60 }
    if ($width -lt 20) { $width = 60 }
    Write-Host "  $($null; '─' * ($width - 4))" -ForegroundColor $Color
}

