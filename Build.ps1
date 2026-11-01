$ErrorActionPreference='Stop'
$dist=Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$staging=Join-Path $dist ('build-'+[guid]::NewGuid().ToString('N'))
$package=Join-Path $staging 'HD-CG-Binding-Fix'
New-Item -ItemType Directory -Path $package -Force | Out-Null
foreach($name in @('Manage.ps1','Install.cmd','Uninstall.cmd','README.md','LICENSE','ue4ss')){
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $package $name) -Recurse
}
$modArchive=Join-Path $dist 'HD-CG-Binding-Fix-1.0.0-mod-only.zip'
Compress-Archive -LiteralPath (Join-Path $package 'ue4ss') -DestinationPath $modArchive -Force
$archive=Join-Path $staging 'loader.zip'
$uri='https://github.com/KintaroModding/ue4ss/releases/download/v3.0.1-1188-gf885e8d2/phantombladezero_ue4ss_v3.0.1-1188-gf885e8d2.zip'
Invoke-WebRequest $uri -OutFile $archive
$expected='14ACC9A34D3B3278860B63513544AC3F6E4759A673E57D6C0B5D3992B2CA5F28'
if((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected){throw 'Loader SHA256 mismatch; stopping build.'}
$loader=Join-Path $package 'loader'
Expand-Archive -LiteralPath $archive -DestinationPath $loader
Set-Content -LiteralPath (Join-Path $loader 'ue4ss\Mods\mods.txt') -Value '; Enabled by Manage.ps1' -Encoding ASCII
$fullArchive=Join-Path $dist 'HD-CG-Binding-Fix-1.0.0-full.zip'
Compress-Archive -LiteralPath $package -DestinationPath $fullArchive -Force
$checksums=foreach($file in @($fullArchive,$modArchive)){
    $hash=Get-FileHash -LiteralPath $file -Algorithm SHA256
    "$($hash.Hash)  $([IO.Path]::GetFileName($file))"
}
$checksums | Set-Content -LiteralPath (Join-Path $dist 'SHA256SUMS.txt') -Encoding ASCII
Write-Output "Packages built in $dist"
