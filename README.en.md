# Phantom Blade Zero — HD CG Binding Fix

A targeted recovery mod for black-screen story cutscenes. It keeps the original video resolution without replacing or re-encoding videos or modifying saves.

[中文说明](README.md)

## When this may help

Normal gameplay works, but story videos show a black screen while audio and subtitles continue. The media player reports that it is ready and playing, but its associated media texture remains at its 2×2 placeholder size.

Observed test environment: **Steam build 26266538**, NVIDIA RTX 4070 Ti, game display resolution 2560×1440, and a **3840×2160** story video. The user confirmed that picture returned after the diagnostic version performed a rebind. The streamlined version retains that recovery operation and passed mocked behavioral checks; an in-game regression test of the streamlined version is still pending.

This is an unofficial, condition-specific workaround. It does not claim to fix every black-screen cause, corrupted files, decoding failures, or other video playback paths.

## How it works

Every two seconds, on the game thread, the mod checks the story texture at `/Game/Movies/Flow/FirstPlayer_VideoTexture`.

If the associated media player is both `IsPlaying()` and `IsReady()`, while the texture remains no larger than 2×2, the mod detaches and reattaches **the same media player**. It attempts recovery once per observed continuous playback state. Observing a stopped or not-ready player rearms recovery for a subsequent playback.

It does not change the video source, resolution, playback position, or audio tracks. Healthy textures and unrelated media textures are left alone. Unlike the diagnostic version, it has no ten-minute monitoring limit.

In the observed diagnostic run, the texture changed to 3840×2160 approximately ten seconds after rebinding, and the user confirmed that the video became visible. This supports a problem somewhere in the player-to-texture update path, but does not establish an exact engine-level cause. No repeated, same-condition control test without the mod was performed. An initial black-screen delay may remain.

## Installation

1. Download the **full ZIP** from the release and extract the entire archive.
2. Close the game and double-click `Install.cmd`.
3. Launch the game normally through Steam.

The installer detects Steam libraries automatically. If needed, specify the game root manually:

```powershell
.\Manage.ps1 -Action Install -GameRoot 'X:\SteamLibrary\steamapps\common\PBZ'
```

The installer allows only **build 26266538**. Review compatibility before adapting it to another build. The full package includes a pinned PBZ-specific UE4SS loader. Existing loader installations are preserved rather than overwritten; incomplete installations cause an error.

If you already have a compatible UE4SS loader, you can instead use the **mod-only ZIP**. Copy `ue4ss/Mods/HDCGBindingFix` into the game's `platform/steam/ue4ss/Mods` directory, then add this line to `mods.txt`:

```text
HDCGBindingFix : 1
```

GitHub source archives do not include the loader. Use the full package or install a compatible UE4SS loader separately.

## Uninstall / disable

Close the game and double-click `Uninstall.cmd`. This disables the mod while keeping the loader, other mods, and logs. It does not delete saves.

The installer backs up the previous mod list as `mods.txt.before-HD-CG-Fix` and disables the earlier `CGDiagnostics` development probe if present.

Recovery attempts are logged with the `[HDCGBindingFix]` prefix in `platform/steam/ue4ss/UE4SS.log`. When reporting issues, include the game build, GPU, and symptom. Avoid publicly uploading saves, full logs, or personal information.

## Building and third-party components

Run `Build.ps1` to generate full and mod-only packages. It downloads the loader from a pinned release and verifies its SHA256 checksum.

- [PBZ-specific UE4SS 1188 distribution](https://github.com/KintaroModding/ue4ss/releases/tag/v3.0.1-1188-gf885e8d2)
- [Upstream UE4SS](https://github.com/UE4SS-RE/RE-UE4SS)

This project's source code is MIT-licensed. The loader is a separate third-party component; its license is retained in the full package. This repository contains no game assets, saves, or diagnostic logs.
