# Phantom Blade Zero — HD CG Binding Fix

影之刃零高清剧情 CG 黑屏恢复 Mod。保留原始视频分辨率，不替换视频、不转码、不改存档。

**English documentation: [README.en.md](README.en.md)**

## 适用现象

实机正常，剧情播片只有声音和字幕。播放器已就绪并在播放，但对应媒体纹理卡在 2×2 占位大小。

本机实测环境：Steam **build 26266538**、RTX 4070 Ti、游戏画面 2560×1440，剧情视频 **3840×2160**。诊断版执行重绑后，用户确认恢复画面。精简版使用相同恢复操作并通过模拟行为测试，尚未完成精简版游戏内回归测试。

这是一项针对特定状态的恢复措施，不是官方补丁。不能保证修复其他视频路径、文件损坏、解码失败或所有机器的黑屏。

## 工作方式

每两秒在游戏线程检查 `/Game/Movies/Flow/FirstPlayer_VideoTexture`。仅当其绑定的播放器 `IsPlaying()` 和 `IsReady()` 均为真，纹理仍不大于 2×2 时，解绑后重新绑定**原播放器**。同一连续播放状态只尝试一次；观察到停止或未就绪后重新允许恢复。

不改变播放位置、音轨或视频源。正常尺寸的纹理和其他媒体纹理不处理。不再有诊断版的十分钟限制。

已观察到重绑后约十秒，纹理更新到 3840×2160，随后用户确认可见画面。这支持播放器与纹理更新链路存在问题，但未证明精确底层根因，也未完成同条件无 Mod 重复对照。开头仍可能有延迟。

## 安装

下载发布中的完整安装包，全部解压，关闭游戏后双击 `Install.cmd`，再正常从 Steam 启动。

安装器自动寻找 Steam 游戏库。若未找到，可手动指定：

```powershell
.\Manage.ps1 -Action Install -GameRoot 'X:\SteamLibrary\steamapps\common\PBZ'
```

构建检查仅允许 build 26266538。其他构建需先核对兼容性。完整包附带 PBZ 专用 UE4SS；已有加载器时保留原版本，不覆盖。不完整的加载器安装会报错。

有兼容 UE4SS 的用户也可手动复制 `ue4ss/Mods/HDCGBindingFix` 到游戏的 `platform/steam/ue4ss/Mods`，并在 `mods.txt` 增加：

```text
HDCGBindingFix : 1
```

直接下载源码不含加载器；请使用完整安装包，或先自行安装匹配版本的 UE4SS。

## 撤销

关闭游戏后双击 `Uninstall.cmd`，禁用本 Mod，保留加载器、其他 Mod 和日志。安装前的 Mod 列表备份为 `mods.txt.before-HD-CG-Fix`。安装器会关闭本项目之前使用的 `CGDiagnostics` 诊断 Mod。

发生恢复操作时，在 `platform/steam/ue4ss/UE4SS.log` 写入 `[HDCGBindingFix]` 记录。反馈问题时请提供构建版本、显卡和症状；不要公开上传存档、完整日志或个人信息。

## 构建与来源

运行 `Build.ps1` 生成完整包和仅 Mod 包；加载器从固定版本下载并校验 SHA256。

- [PBZ 专用 UE4SS 1188 分发](https://github.com/KintaroModding/ue4ss/releases/tag/v3.0.1-1188-gf885e8d2)
- [UE4SS 原项目](https://github.com/UE4SS-RE/RE-UE4SS)

本项目源码采用 MIT 许可证。加载器是独立第三方组件，其许可证保留在完整安装包中。仓库不包含游戏资源、存档或诊断日志。
