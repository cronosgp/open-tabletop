param(
	[string]$PythonExecutable = "",
	[string]$InstallPath = ""
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$buildRoot = Join-Path $projectRoot (".tools\forceorg-bundle-build-" + [DateTime]::UtcNow.ToString("yyyyMMddTHHmmssfffZ"))
$venvPath = Join-Path $buildRoot "venv"
$distPath = Join-Path $buildRoot "dist"
$workPath = Join-Path $buildRoot "work"
$entryPoint = Join-Path $PSScriptRoot "forceorg_bundle_to_obj.py"
$requirements = Join-Path $PSScriptRoot "forceorg_bundle_converter_requirements.txt"

New-Item -ItemType Directory -Path $buildRoot | Out-Null

if ([string]::IsNullOrWhiteSpace($PythonExecutable)) {
	$launcher = Get-Command py.exe -ErrorAction SilentlyContinue
	if ($null -eq $launcher) { throw "Python 3.12 is required. Install it or pass -PythonExecutable with its full path." }
	$pythonCommand = $launcher.Source
	$pythonPrefix = @("-3.12")
	& $pythonCommand @pythonPrefix --version
	if ($LASTEXITCODE -ne 0) { throw "Python 3.12 is required. Python 3.15 currently lacks compatible UnityPy native wheels on this machine." }
} else {
	$pythonCommand = (Resolve-Path -LiteralPath $PythonExecutable).Path
	$pythonPrefix = @()
	& $pythonCommand --version
	if ($LASTEXITCODE -ne 0) { throw "The selected Python interpreter could not start." }
}

& $pythonCommand @pythonPrefix -m venv $venvPath
if ($LASTEXITCODE -ne 0) { throw "Could not create the isolated converter environment." }

$venvPython = Join-Path $venvPath "Scripts\python.exe"
& $venvPython -m pip install --disable-pip-version-check -r $requirements
if ($LASTEXITCODE -ne 0) { throw "Could not install the pinned converter requirements." }

New-Item -ItemType Directory -Path $distPath,$workPath | Out-Null
& $venvPython -m PyInstaller --noconfirm --clean --onefile --console --name forceorg-bundle-converter --specpath $buildRoot --distpath $distPath --workpath $workPath --collect-all UnityPy --collect-all archspec --collect-all fmod_toolkit $entryPoint
if ($LASTEXITCODE -ne 0) { throw "Could not package the converter executable." }

$executable = Join-Path $distPath "forceorg-bundle-converter.exe"
if (-not (Test-Path -LiteralPath $executable)) { throw "The converter executable was not produced." }

if (-not [string]::IsNullOrWhiteSpace($InstallPath)) {
	$installDirectory = Split-Path -Parent $InstallPath
	New-Item -ItemType Directory -Force -Path $installDirectory | Out-Null
	Copy-Item -LiteralPath $executable -Destination $InstallPath -Force
	Write-Output "Installed converter: $InstallPath"
} else {
	Write-Output "Converter built: $executable"
}
