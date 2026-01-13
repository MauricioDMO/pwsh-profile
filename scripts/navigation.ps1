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

function core {
    param([string]$Path = "")
    Set-Location (Join-Path $script:QuickPaths.core $Path.TrimStart('\').TrimStart('/'))
}
function dev {
    param([string]$Path = "")
    Set-Location (Join-Path $script:QuickPaths.dev $Path.TrimStart('\').TrimStart('/'))
}
function uni {
    param([string]$Path = "")
    Set-Location (Join-Path $script:QuickPaths.uni $Path.TrimStart('\').TrimStart('/'))
}
function work {
    param([string]$Path = "")
    Set-Location (Join-Path $script:QuickPaths.work $Path.TrimStart('\').TrimStart('/'))
}
function learn {
    param([string]$Path = "")
    Set-Location (Join-Path $script:QuickPaths.learn $Path.TrimStart('\').TrimStart('/'))
}

# Autocompletado para rutas rápidas
$script:QuickPaths.Keys | ForEach-Object {
    $cmd = $_
    Register-ArgumentCompleter -CommandName $cmd -ParameterName Path -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        $base = $script:QuickPaths.$commandName
        
        $quote = if ($wordToComplete -match "^(['""])") { $matches[1] } else { "" }
        
        $cleanWord = ($wordToComplete -replace "^['""]|['""]$", "").Replace('/', '\').TrimStart('\')
        $fullPath = Join-Path $base $cleanWord
        
        $parent = if (Test-Path $fullPath -PathType Container) { $fullPath } else { Split-Path $fullPath -Parent }
        $filter = if (Test-Path $fullPath -PathType Container) { "*" } else { (Split-Path $fullPath -Leaf) + "*" }

        if (Test-Path $parent) {
            Get-ChildItem -Path $parent -Directory -Filter $filter | ForEach-Object {
                $rel = $_.FullName.Substring($base.Length).Replace('\', '/')
                $completionText = "/$($rel.Trim('/'))/"
                
                if ($quote) {
                    $completionText = $quote + $completionText + $quote
                }

                [System.Management.Automation.CompletionResult]::new($completionText, $_.Name, 'ParameterValue', $_.FullName)
            }
        }
    }
}

# Abre File Pilot en la ruta especificada
function e { 
    param([string]$Path = '.')
    FPilot.exe $Path
}

# Abre VS Code aquí o ruta especificada
function c {
    param([string]$Path = '.')
    code $Path
}
