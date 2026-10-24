# 验证记录

验证日期：**2026-10-24（日本时间）**。

## 环境

| 项目 | 配置 |
| --- | --- |
| 系统 | Windows 11 |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| Android 测试设备 | 专用 AVD `arzo_review`，Pixel 7，Android 15 / API 35，x86_64 |
| 设备编号 | `emulator-5556` |
| 截图尺寸 | 1080 × 2340 PNG，密度 460 |
| 资料来源 | Pixso 原稿导出的图片与本地样例数据 |

原有模拟器空间不足时，新建了专用 AVD，保留原设备内的应用与数据。

## 自动检查

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | 通过，No issues found |
| 单元与组件测试 | 通过，10 / 10 |
| Android 端到端流程 | 通过，完整场景无 Flutter 异常 |
| 截图导出 | 通过，56 张，文件齐全 |
| Android release 分包 | 通过，ARMv7 / ARM64 / x64，主交付 ARM64 与 x64 |
| Release 安装与冷启动 | 通过，游客会话与收藏在强制结束进程后恢复 |

### 状态测试（7 项）

1. 演示会话、个人资料、地区、头像、主题、通知和收藏在重新构造状态仓储后恢复；退出保留收藏。
2. 连续保存操作按顺序落盘，取消收藏后的最终快照正确。
3. 查询支持大小写、首尾空格、房东以及分类组合。
4. 重复预约拦截；取消后状态保存并允许重新占用时段。
5. 空白消息不发送，正文去除首尾空白，多房东会话分别保存。
6. 损坏的 JSON 不阻断启动。
7. 过去时间、上午 / 中午 / 下午和跨日时间判断正确。

### 布局测试（3 项）

1. 空状态在仅剩 180 高度时可滚动。
2. 320 × 568 小屏、1.2 倍文字下，三步引导可滚动并完成。
3. 320 × 640 小屏、键盘占用 280 高度时，登录表单和按钮仍可操作。

组件测试使用小尺寸 PNG 占位，专门验证布局，避免 Windows 软件渲染测试器对大图解码的影响；模拟器流程使用完整原稿图片。

## 模拟器流程

自动操作覆盖：

- 三步引导 → 登录校验 → 找回 / 重置表单 → 注册 → 社区搜索 → 进入首页。
- 首页分类 → 地图搜索与空状态 → 地图标记选择 → 房源详情。
- 展开介绍 → 收藏 → 相册 → 全屏图片 → 参数与位置。
- 联系房东 → 发送本地消息 → 会话列表。
- 线下预约：类型 → 日期 → 时间 → 确认 → 成功。
- 房源搜索、房东搜索、无结果、清空搜索。
- 收藏空状态、收藏列表与滑动删除确认。
- 资料编辑、头像切换、预约状态、修改密码界面。
- 深色设置、个人中心与首页。
- 视频预约：联系渠道 → 日期 → 时间 → 确认 → 成功 → 列表 → 取消。
- 退出确认弹窗、取消退出、恢复浅色首页。
- 重新构造本地状态仓储，检查收藏、两条预约、消息与资料。

自动测试最后输出 `All tests passed.`。每张截图拍摄前会等待布局与动画稳定，并检查 Flutter 异常。

## 截图保存方式

Android 测试运行时逐张拍摄 PNG 并写入应用测试缓存，随即从测试 JSON 中移除图片字节。测试结束后，由宿主驱动读取缓存文件并保存到 `docs/screenshots/`，避免将 56 张图片同时编码成大体积 JSON 回传。

截图清单在 `build/integration-summary.json`，完整图片索引见 [SCREENSHOTS.md](SCREENSHOTS.md)。自动化测试结束时 Flutter 工具会卸载测试应用；日常体验应运行 `lib/main.dart` 或安装普通 release 包。

## 复现命令

依次执行；测试和打包应避免同时修改 Flutter 的生成文件。

```powershell
flutter pub get
flutter analyze
flutter test --reporter expanded

$env:ARZO_DEVICE='emulator-5556'
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5556 --no-dds

flutter build apk --release --split-per-abi
```

运行端到端测试会重置本应用的演示数据，设备编号同时通过 `-d` 和 `ARZO_DEVICE` 指定。Android SDK 优先从 `ANDROID_SDK_ROOT` / `ANDROID_HOME` 读取，Windows 下可回退到当前用户的本地 SDK 目录。

## 验证范围

Android 模拟器的 UI 和本地流程已验证。当前没有业务后端，因此没有真实认证、消息投递、推送、地图定位或远程房东确认测试。iOS 源工程已提供，当前 Windows 环境未执行 iOS 编译、签名及真机测试。
