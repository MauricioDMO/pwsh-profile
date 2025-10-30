# ========================================
# NAVEGACIÓN RÁPIDA
# ========================================

# Rutas rápidas
$script:QuickPaths = @{
    core  = "$env:USERPROFILE\core"
    dev   = "$env:USERPROFILE\core\dev"
    uni   = "$env:USERPROFILE\core\university"
    work  = "$env:USERPROFILE\core\work"
    learn = "$env:USERPROFILE\core\learn"
}

function core  { Set-Location $script:QuickPaths.core }
function dev   { Set-Location $script:QuickPaths.dev }
function uni   { Set-Location $script:QuickPaths.uni }
function work  { Set-Location $script:QuickPaths.work }
function learn { Set-Location $script:QuickPaths.learn }

# Abre explorador en el dir actual
function e { Start-Process explorer . }

# Abre VS Code aquí o ruta especificada
function c {
    param([string]$Path = '.')
    code $Path
}
