# 各界面截图索引

本目录收录 **56 张 Flutter 实际运行截图**，覆盖主要页面、两种预约分支、浅深主题、空状态和确认弹窗。点击表格中的名称查看原始 PNG。截图由 `integration_test/app_test.dart` 在 Android 模拟器运行时生成，原始尺寸为 **1080 × 2340**。

`reference/` 为 Pixso 原稿快照；下方链接全部来自 `screenshots/`，不是设计稿。

## 引导、登录与注册

| 界面 | 截图 |
| --- | --- |
| 引导：发现房源 | [01-onboarding-discover](screenshots/01-onboarding-discover.png) |
| 引导：联系房东 | [02-onboarding-find](screenshots/02-onboarding-find.png) |
| 引导：预约看房 | [03-onboarding-start](screenshots/03-onboarding-start.png) |
| 登录 | [04-sign-in](screenshots/04-sign-in.png) |
| 登录表单错误 | [04a-sign-in-validation](screenshots/04a-sign-in-validation.png) |
| 找回密码 | [05-forgot-password](screenshots/05-forgot-password.png) |
| 本地重置入口反馈 | [06-reset-link](screenshots/06-reset-link.png) |
| 创建新密码 | [07-reset-password](screenshots/07-reset-password.png) |
| 注册 | [08-sign-up](screenshots/08-sign-up.png) |
| 选择社区 | [09-neighborhood](screenshots/09-neighborhood.png) |
| 社区搜索无结果 | [09a-neighborhood-empty](screenshots/09a-neighborhood-empty.png) |

## 首页、搜索与地图

| 界面 | 截图 |
| --- | --- |
| 首页推荐 | [10-home](screenshots/10-home.png) |
| 消息列表空状态 | [10a-messages-empty](screenshots/10a-messages-empty.png) |
| 收藏列表空状态 | [10b-saved-empty](screenshots/10b-saved-empty.png) |
| 公寓分类 | [11-apartments](screenshots/11-apartments.png) |
| 地图浏览 | [12-map](screenshots/12-map.png) |
| 地图搜索无结果 | [12a-map-empty](screenshots/12a-map-empty.png) |
| 地图选中房源 | [13-map-selected](screenshots/13-map-selected.png) |
| 搜索入口 | [26-search](screenshots/26-search.png) |
| 房源搜索结果 | [27-search-results](screenshots/27-search-results.png) |
| 房源搜索无结果 | [28-search-empty](screenshots/28-search-empty.png) |
| 房东搜索结果 | [29-search-owners](screenshots/29-search-owners.png) |

## 房源、聊天与收藏

| 界面 | 截图 |
| --- | --- |
| 房源详情 | [14-property](screenshots/14-property.png) |
| 展开的房源介绍与示例估值 | [14a-property-description](screenshots/14a-property-description.png) |
| 房源相册 | [15-gallery](screenshots/15-gallery.png) |
| 全屏照片 | [16-photo](screenshots/16-photo.png) |
| 房源详细参数 | [17-estate-facts](screenshots/17-estate-facts.png) |
| 房源位置 | [18-estate-location](screenshots/18-estate-location.png) |
| 示例聊天 | [19-chat](screenshots/19-chat.png) |
| 发送本地消息后 | [20-chat-sent](screenshots/20-chat-sent.png) |
| 已有会话列表 | [30-messages](screenshots/30-messages.png) |
| 已收藏房源 | [31-saved](screenshots/31-saved.png) |
| 删除收藏确认 | [31a-remove-saved](screenshots/31a-remove-saved.png) |

## 线下看房预约

| 界面 | 截图 |
| --- | --- |
| 选择预约类型 | [21-tour-type](screenshots/21-tour-type.png) |
| 选择日期 | [22-tour-date](screenshots/22-tour-date.png) |
| 选择时间 | [23-tour-time](screenshots/23-tour-time.png) |
| 预约信息确认 | [24-tour-confirm](screenshots/24-tour-confirm.png) |
| 预约成功 | [25-tour-success](screenshots/25-tour-success.png) |
| 预约列表 | [34-tour-list](screenshots/34-tour-list.png) |
| 待确认预约详情 | [35-tour-status](screenshots/35-tour-status.png) |

## 视频看房预约

以下分支在深色主题下拍摄。

| 界面 | 截图 |
| --- | --- |
| 选择联系渠道 | [41-video-contact](screenshots/41-video-contact.png) |
| 选择日期 | [41a-video-date](screenshots/41a-video-date.png) |
| 选择时间 | [41b-video-time](screenshots/41b-video-time.png) |
| 确认视频预约 | [41c-video-confirm](screenshots/41c-video-confirm.png) |
| 视频预约成功 | [41d-video-success](screenshots/41d-video-success.png) |
| 视频预约列表 | [42-video-tour-list](screenshots/42-video-tour-list.png) |
| 已取消预约 | [43-tour-cancelled](screenshots/43-tour-cancelled.png) |

## 个人中心与设置

| 界面 | 截图 |
| --- | --- |
| 个人中心 | [32-profile](screenshots/32-profile.png) |
| 编辑资料 | [33-edit-profile](screenshots/33-edit-profile.png) |
| 使用首字母头像 | [33a-profile-initials](screenshots/33a-profile-initials.png) |
| 修改密码表单 | [36-change-password](screenshots/36-change-password.png) |
| 显示与通知设置 | [37-settings](screenshots/37-settings.png) |
| 深色设置 | [38-settings-dark](screenshots/38-settings-dark.png) |
| 深色个人中心 | [39-profile-dark](screenshots/39-profile-dark.png) |
| 深色首页 | [40-home-dark](screenshots/40-home-dark.png) |
| 退出确认弹窗 | [44-logout-confirmation](screenshots/44-logout-confirmation.png) |

## 重新生成

```powershell
$env:ARZO_DEVICE='emulator-5556'
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5556 --no-dds
```

测试会清空 **本应用** 的演示数据，以固定起点执行注册、收藏、聊天、预约与主题切换。日期按测试当天计算，因此重新截图时日历内容可能不同。
