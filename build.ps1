$CakeVersion = "0.25.0"
$IsRunningOnUnix = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Unix
# Make sure tools folder exists
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$ToolPath = Join-Path $PSScriptRoot "tools"
if (!(Test-Path $ToolPath)) {
    Write-Verbose "Creating tools directory..."
    New-Item -Path $ToolPath -Type directory | out-null
}

###########################################################################
# INSTALL CAKE
###########################################################################
if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue))
{
    if ($PSVersionTable.PSVersion.Major -le 3)
    {
        & {
            function global:Expand-Archive
            {
                param([string]$Path, [string]$DestinationPath)
                $shell = New-Object -com shell.application
                $zip = $shell.NameSpace($Path)
                foreach($item in $zip.items())
                {
                    $shell.Namespace($DestinationPath).copyhere($item)
                }  
            }
        }      
    }
    else
    {
        & {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            function global:Expand-Archive
            {
                param([string]$Path, [string]$DestinationPath)
                [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $DestinationPath)
            }
        }
  }
}

# Make sure Cake has been installed.
$CakePath = Join-Path $ToolPath "Cake.$CakeVersion" 
$CakeExePath = Join-Path $CakePath "Cake.exe"
$CakeZipPath = Join-Path $ToolPath "Cake.zip"
$CakeUri = "https://www.nuget.org/api/v2/package/Cake/$CakeVersion"
if (!(Test-Path $CakeExePath)) {
    Write-Host "Installing Cake $CakeVersion..."
    (New-Object System.Net.WebClient).DownloadFile($CakeUri, $CakeZipPath)
    Expand-Archive $CakeZipPath $CakePath
    Remove-Item $CakeZipPath
}

###########################################################################
# RUN BUILD SCRIPT
###########################################################################
if ($IsRunningOnUnix)
{
    & mono "$CakeExePath" --bootstrap
    if ($LASTEXITCODE -eq 0)
    {
        & mono "$CakeExePath" $args
    }
}
else
{
    & "$CakeExePath" --bootstrap
    if ($LASTEXITCODE -eq 0)
    {
        & "$CakeExePath" $args
    }
}
exit $LASTEXITCODE