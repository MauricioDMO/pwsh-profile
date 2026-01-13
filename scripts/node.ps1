# ========================================
# NODE.JS Y DESARROLLO
# ========================================

function nclean {
    Clear-Host
    Write-Host "Cleaning node_modules and lock files..." -ForegroundColor Cyan
    @("node_modules", "package-lock.json", "pnpm-lock.yaml", "yarn.lock") | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Recurse -Force $_ -ErrorAction SilentlyContinue
            Write-Host "  Removed: $_" -ForegroundColor Green
        }
    }
}

function ncheck {
    Write-Category "Runtime Information" -Color Cyan
    
    $commands = @(
        @{ Name = "Node.js"; Cmd = "node --version" }
        @{ Name = "npm";     Cmd = "npm --version" }
        @{ Name = "pnpm";    Cmd = "pnpm --version" }
        @{ Name = "bun";     Cmd = "bun --version" }
    )

    foreach ($cmd in $commands) {
        try {
            $version = Invoke-Expression $cmd.Cmd 2>$null
            if ($null -eq $version -or $version -eq "") {
                Write-Item -Label $cmd.Name -Value "Not installed" -LabelColor Gray -ValueColor DarkGray
            } else {
                Write-Item -Label $cmd.Name -Value $version -LabelColor Cyan -ValueColor Green
            }
        }
        catch {
            Write-Item -Label $cmd.Name -Value "Not installed" -LabelColor Gray -ValueColor DarkGray
        }
    }

    if (Test-Path "package.json" -PathType Leaf) {
        Write-Category "Current Project" -Color Cyan
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        
        Write-Item -Label "Name"        -Value $pkg.name        -LabelColor Gray
        Write-Item -Label "Version"     -Value $pkg.version     -LabelColor Gray
        if ($pkg.description) { 
            Write-Item -Label "Description" -Value $pkg.description -LabelColor Gray 
        }
    }
    Write-Host ""
}

function nscripts {
    if (Test-Path "package.json" -PathType Leaf) {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        if ($pkg.scripts) {
            Write-Category "Available Scripts" -Color Cyan
            
            $scripts = $pkg.scripts.PSObject.Properties
            $maxLen = ($scripts | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
            if ($maxLen -lt 10) { $maxLen = 10 }

            foreach ($script in $scripts) {
                Write-Item -Label $script.Name -Value $script.Value -Padding $maxLen -LabelColor Green
            }
            Write-Host ""
        }
        else {
            Write-Host "`n  [!] No scripts found in package.json." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "`n  [!] package.json not found." -ForegroundColor Red
    }
}
