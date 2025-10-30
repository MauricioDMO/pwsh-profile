# Tabla de contenidos

- [Tabla de contenidos](#tabla-de-contenidos)
- [🧩 PowerShell Profile Modular — `pwsh-profile`](#-powershell-profile-modular--pwsh-profile)
  - [🚀 Objetivo](#-objetivo)
  - [📁 Estructura de carpetas](#-estructura-de-carpetas)
  - [⚙️ Instalación](#️-instalación)
    - [1. Clonar el repositorio](#1-clonar-el-repositorio)
    - [2. Editar tu perfil de PowerShell](#2-editar-tu-perfil-de-powershell)
    - [3. (Solo la primera vez) permitir ejecución de scripts](#3-solo-la-primera-vez-permitir-ejecución-de-scripts)
  - [🧠 ¿Qué hace cada módulo?](#-qué-hace-cada-módulo)
    - [🧩 `init.ps1`](#-initps1)
    - [⚙️ `utils.ps1`](#️-utilsps1)
    - [📦 `size.ps1`](#-sizeps1)
    - [📂 `navigation.ps1`](#-navigationps1)
    - [🧰 `services.ps1`](#-servicesps1)
    - [🧑‍💻 `node.ps1`](#-nodeps1)
    - [📜 `help.ps1`](#-helpps1)
    - [🪩 `banner.ps1`](#-bannerps1)
  - [🔧 Cómo añadir más scripts](#-cómo-añadir-más-scripts)
  - [🧩 Recomendaciones](#-recomendaciones)
  - [🧭 Créditos y licencia](#-créditos-y-licencia)


# 🧩 PowerShell Profile Modular — `pwsh-profile`

Este repositorio contiene una configuración modular para **PowerShell 7+**, diseñada para mantener tu entorno limpio, reutilizable y fácil de versionar.

La idea es **separar toda la lógica del perfil** (`Microsoft.PowerShell_profile.ps1`) en archivos organizados dentro de este proyecto, que el perfil solo carga automáticamente al iniciar PowerShell.

---

## 🚀 Objetivo

* Mantener la configuración de la terminal **limpia y mantenible**.
* Permitir **portar el entorno** fácilmente a otra PC (clonando el repo).
* Evitar mezclar alias, funciones y módulos en un solo archivo gigante.
* Cargar cada parte en orden lógico y controlado.

---

## 📁 Estructura de carpetas

```
pwsh-profile/
├─ bootstrap.ps1          # Script principal que carga todos los módulos
├─ scripts/
│  ├─ init.ps1            # Configuración base: oh-my-posh, fnm, PSReadLine, etc.
│  ├─ utils.ps1           # Funciones utilitarias generales (Convert-Size, centrado de texto)
│  ├─ size.ps1            # Funciones Get-Size y size (calcular tamaño de carpetas)
│  ├─ navigation.ps1      # Atajos de rutas y comandos de navegación
│  ├─ services.ps1        # Configuración de servicios y módulos (SSH agent, Terminal-Icons, etc.)
│  ├─ node.ps1            # Comandos de desarrollo Node.js / pnpm / npm
│  ├─ help.ps1            # Comando “commands” que lista todos tus alias y funciones
│  └─ banner.ps1          # Banner ASCII mostrado al iniciar PowerShell
└─ README.md              # Este archivo
```

---

## ⚙️ Instalación

### 1. Clonar el repositorio

Por defecto, se asume que estará en:

```
C:\Users\<tu_usuario>\core\dev\pwsh-profile
```

Si querés usar otra ruta, podés definir una variable de entorno:

```powershell
[System.Environment]::SetEnvironmentVariable('PWSH_CONFIG_HOME', 'C:\Ruta\A\pwsh-profile', 'User')
```

### 2. Editar tu perfil de PowerShell

Abrí tu perfil de usuario:

```powershell
notepad $PROFILE
```

Y pegá esto:

```powershell
# Perfil mínimo: carga el bootstrap del repo
$ConfigHome = $env:PWSH_CONFIG_HOME
if ([string]::IsNullOrWhiteSpace($ConfigHome)) {
    $ConfigHome = Join-Path $HOME 'core\dev\pwsh-profile'
}

$Bootstrap = Join-Path $ConfigHome 'bootstrap.ps1'

if (Test-Path $Bootstrap) {
    . $Bootstrap
} else {
    Write-Warning "No se encontró el bootstrap en: $Bootstrap"
}
```

Guarda y cierra.

### 3. (Solo la primera vez) permitir ejecución de scripts

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

---

## 🧠 ¿Qué hace cada módulo?

### 🧩 `init.ps1`

Carga configuraciones iniciales:

* `CompletionPredictor` para autocompletado predictivo.
* `fnm` (Fast Node Manager) para manejo automático de versiones de Node.js.
* `oh-my-posh` con tema personalizado (`froczh.omp.json`).
* Configuración de `PSReadLine` para predicción desde historial.
* Alias `pg` → `pgcli` si está disponible.

---

### ⚙️ `utils.ps1`

Funciones auxiliares que otros módulos usan:

* `Convert-Size`: convierte bytes en KB, MB, GB, TB con formato.
* `Write-HostCentered`: centra texto en la consola (usado en el banner).

---

### 📦 `size.ps1`

Permite calcular el tamaño de carpetas y archivos.

Comandos:

* `Get-Size [ruta]`: devuelve objeto con tamaño, archivos y carpetas.
* `size [ruta]`: muestra una vista colorida y legible.

Admite rutas **relativas o absolutas**.
Si no se pasa argumento, usa la carpeta actual (`.`).

---

### 📂 `navigation.ps1`

Funciones de navegación rápida:

| Comando                               | Descripción                                            |
| ------------------------------------- | ------------------------------------------------------ |
| `e`                                   | Abre el explorador de archivos en el directorio actual |
| `c`                                   | Abre VS Code (por defecto en el directorio actual)     |
| `core`, `dev`, `uni`, `work`, `learn` | Atajos a carpetas definidas en `$script:QuickPaths`    |

---

### 🧰 `services.ps1`

Comandos del sistema:

* `essh`: habilita y arranca el servicio `ssh-agent`.
* `ti`: carga el módulo `Terminal-Icons` con feedback visual.
* `sexo`: abre CornHub (un easter egg 🌽).

---

### 🧑‍💻 `node.ps1`

Herramientas para desarrollo con Node.js:

| Comando  | Acción                                                                |
| -------- | --------------------------------------------------------------------- |
| `ndev`   | Inicia el servidor de desarrollo (`node --run dev`)                   |
| `nbuild` | Compila el proyecto                                                   |
| `nstart` | Arranca el servidor de producción                                     |
| `nclean` | Elimina `node_modules` y archivos de lock                             |
| `ncheck` | Muestra versiones de Node, npm, pnpm y detalles del proyecto          |
| `ninit`  | Inicializa un nuevo proyecto con `pnpm init`                          |
| `sdev`   | Abre VS Code, arranca el servidor y abre el navegador automáticamente |

---

### 📜 `help.ps1`

Define el comando:

```powershell
commands
```

Muestra todos los comandos personalizados clasificados por categoría.

---

### 🪩 `banner.ps1`

Muestra tu banner ASCII centrado con tu nombre o logo al abrir PowerShell.

---

## 🔧 Cómo añadir más scripts

1. Crea un nuevo archivo `.ps1` dentro de `scripts/`.
   Ejemplo:

   ```
   scripts/git.ps1
   ```

2. Escribe tus funciones o alias dentro de ese archivo.
   Ejemplo:

   ```powershell
   function gstat { git status }
   function gpush { git add .; git commit -m "update"; git push }
   ```

3. Abre `bootstrap.ps1` y **añade el nombre del archivo** en la lista `$scriptOrder`:

   ```powershell
   $scriptOrder = @(
       'init.ps1',
       'utils.ps1',
       'size.ps1',
       'navigation.ps1',
       'services.ps1',
       'node.ps1',
       'git.ps1',      # <── Nuevo script
       'help.ps1',
       'banner.ps1'
   )
   ```

4. Guarda los cambios y reinicia PowerShell.
   Tu script se cargará automáticamente al inicio.

---

## 🧩 Recomendaciones

* Guardá este repo en GitHub o GitLab para tener tu entorno siempre disponible.
* Podés mantener ramas separadas para configuraciones distintas (trabajo, personal, laptop, etc.).
* Si agregás scripts complejos, considerá agruparlos como módulos (`.psm1`).
* Podés personalizar `Show-Name` en `banner.ps1` para mostrar otro texto o arte ASCII.

---

## 🧭 Créditos y licencia

Creado para uso personal por **MauricioDMO**.
Inspirado en prácticas comunes de *dotfiles* y entornos de desarrollo profesional.
Licencia: MIT (libre de uso y modificación).
