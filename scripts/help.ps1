# ========================================
# AYUDA / CATÁLOGO DE COMANDOS
# ========================================

function commands {
    $commandsTable = @{
        "Navigation"         = @(
            "e        - Open current directory in Explorer"
            "c        - Open current directory in VS Code"
            "dps      - Open new tab in current Terminal window"
            "core     - Go to core directory"
            "dev      - Go to dev directory"
            "uni      - Go to university directory"
            "work     - Go to work directory"
            "learn    - Go to learn directory"
        )
        "Package Management" = @(
            "nclean   - Clean node_modules and lock files"
            "ncheck   - Check Node versions and project info"
            "nscripts - List available npm scripts"
        )
        "System"             = @(
            "ti       - Load Terminal-Icons module"
            "essh     - Enable SSH Agent"
            "size     - Shows the size of the dir"
        )
    }

    Write-Host "Commands:" -ForegroundColor DarkGreen
    foreach ($category in $commandsTable.Keys | Sort-Object) {
        Write-Host "`n$($category):" -ForegroundColor Yellow
        $commandsTable[$category] | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    }
    Write-Host ""
}
