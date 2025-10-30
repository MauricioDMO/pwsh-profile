# ========================================
# BANNER DE INICIO
# ========================================

function Show-Name {
    $asciiArt = @(
        '░█▄█░█▀█░█░█░█▀▄░▀█▀░█▀▀░▀█▀░█▀█░█▀▄░█▄█░█▀█'
        '░█░█░█▀█░█░█░█▀▄░░█░░█░░░░█░░█░█░█░█░█░█░█░█'
        '░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀░░▀░▀░▀▀▀'
    )
    $asciiArt | ForEach-Object { Write-HostCentered $_ -ForegroundColor DarkGreen }
}

Show-Name
