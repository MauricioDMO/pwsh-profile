# ========================================
# AYUDA / CATÁLOGO DE COMANDOS
# ========================================

function commands {
    $commandsTable = @{
        "Navigation" = @(
            "e       - Open current directory in Explorer"
            "c       - Open current directory in VS Code"
            "core    - Go to core directory"
            "dev     - Go to dev directory"
            "uni     - Go to university directory"
            "work    - Go to work directory"
            "learn   - Go to learn directory"
        )
        "Development" = @(
            "sdev    - Open VS Code + start dev server + open browser"
            "ndev    - Start dev server"
            "nbuild  - Build project"
            "nstart  - Start production server"
        )
        "Package Management" = @(
            "nclean  - Clean node_modules and lock files"
            "ninit   - Initialize new Node.js project"
            "ncheck  - Check Node versions and project info"
        )
        "System" = @(
            "ti      - Load Terminal-Icons module"
            "essh    - Enable SSH Agent"
            "size    - Shows the size of the dir"
        )
    }

    Write-Host "Commands:" -ForegroundColor DarkGreen
    foreach ($category in $commandsTable.Keys | Sort-Object) {
        Write-Host "`n$($category):" -ForegroundColor Yellow
        $commandsTable[$category] | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    }
    Write-Host ""
}
