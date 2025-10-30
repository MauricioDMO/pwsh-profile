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
