param(
    [ValidateSet('Install','Uninstall')][string]$Action='Install',
    [string]$GameRoot=''
)
$ErrorActionPreference='Stop'
if(Get-Process -Name PBZ -ErrorAction SilentlyContinue){throw 'Close Phantom Blade Zero first.'}
if(!$GameRoot){
    $steam=(Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    $libraries=@()
    if($steam){
        $libraries+=$steam
        $vdf=Join-Path $steam 'steamapps\libraryfolders.vdf'
        if(Test-Path -LiteralPath $vdf){
            foreach($match in [regex]::Matches([IO.File]::ReadAllText($vdf),'"path"\s+"([^"]+)"')){
                $libraries+=$match.Groups[1].Value.Replace('\\','\')
            }
        }
    }
    foreach($drive in Get-PSDrive -PSProvider FileSystem){$libraries+=(Join-Path $drive.Root 'SteamLibrary')}
    foreach($library in ($libraries | Select-Object -Unique)){
        $candidate=Join-Path $library 'steamapps\appmanifest_4115450.acf'
        if(Test-Path -LiteralPath $candidate){
            $match=[regex]::Match([IO.File]::ReadAllText($candidate),'"installdir"\s+"([^"]+)"')
            if($match.Success){$GameRoot=Join-Path $library ('steamapps\common\'+$match.Groups[1].Value);break}
        }
    }
    if(!$GameRoot){throw 'Game not found. Run Manage.ps1 -GameRoot with the PBZ game directory.'}
}
$game=Get-Item -LiteralPath $GameRoot
$bin=Join-Path $game.FullName 'platform\steam'
if(!(Test-Path -LiteralPath (Join-Path $bin 'PBZ.exe'))){throw 'Select the PBZ game root directory.'}
$mods=Join-Path $bin 'ue4ss\Mods'
$mod=Join-Path $mods 'HDCGBindingFix'
$list=Join-Path $mods 'mods.txt'
$dll=Join-Path $bin 'dwmapi.dll'
$source=Join-Path $PSScriptRoot 'ue4ss\Mods\HDCGBindingFix'
if($Action -eq 'Install'){
    $manifest=Join-Path (Split-Path (Split-Path $game.FullName -Parent) -Parent) 'appmanifest_4115450.acf'
    if(!(Test-Path -LiteralPath $manifest) -or (Get-Content -LiteralPath $manifest -Raw) -notmatch '"buildid"\s+"26266538"'){
        throw 'This package was verified for Steam build 26266538 only. Review compatibility before using another build.'
    }
    if(!(Test-Path -LiteralPath $dll) -and !(Test-Path -LiteralPath (Join-Path $bin 'ue4ss'))){
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'loader\dwmapi.dll') -Destination $dll
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'loader\ue4ss') -Destination (Join-Path $bin 'ue4ss') -Recurse
    }elseif(!(Test-Path -LiteralPath $dll) -or !(Test-Path -LiteralPath $mods)){
        throw 'Incomplete loader installation. No existing files overwritten.'
    }
    if(Test-Path -LiteralPath $mod){
        $installed=Join-Path $mod 'Scripts\main.lua'
        if(!(Test-Path -LiteralPath $installed) -or (Get-FileHash -LiteralPath $installed).Hash -ne (Get-FileHash -LiteralPath (Join-Path $source 'Scripts\main.lua')).Hash){
            throw 'A different version of this mod exists. Back it up before updating.'
        }
    }else{Copy-Item -LiteralPath $source -Destination $mod -Recurse}
}
if(!(Test-Path -LiteralPath $list)){
    if($Action -eq 'Uninstall'){Write-Output 'No active mod list found.';return}
    $text=''
}else{
    $text=[IO.File]::ReadAllText($list)
    if($Action -eq 'Install'){
        $backup=$list+'.before-HD-CG-Fix'
        if(!(Test-Path -LiteralPath $backup)){Copy-Item -LiteralPath $list -Destination $backup}
    }
}
$text=[regex]::Replace($text,'(?m)^\s*HDCGBindingFix\s*:\s*\d+\s*\r?$','')
if($Action -eq 'Install'){
    $text=[regex]::Replace($text,'(?m)^(\s*CGDiagnostics\s*:)\s*\d+\s*\r?$','$1 0')
    $text=$text.TrimEnd()+"`r`nHDCGBindingFix : 1`r`n"
}else{$text=$text.TrimEnd()+"`r`nHDCGBindingFix : 0`r`n"}
[IO.File]::WriteAllText($list,$text,[Text.UTF8Encoding]::new($false))
Write-Output "$Action complete. The game must be restarted. Other mods and saves were preserved."
