# Pixso 设计读取与实现映射

设计源：当前连接的 Pixso 文件 **Arzo - Real Estate App UI Kit**。读取页面为 `🎉 User Interface`（`0:1`），同时读取了 `🎨 Color & Typography Guide`（`1:3`）。未修改原设计文件。

## 设计规范

| 项目 | 读取结果 / 实现方式 |
| --- | --- |
| 参考画板 | 375 × 812，详情长画板 375 × 1077 |
| 正文与标题字体 | Manrope，400 / 500 / 600 / 700 |
| 正文颜色 | `#27364E` |
| 主色 | `#1E58F1`，部分原稿按钮采用 `#236CEF`，实现统一使用主色 |
| 薄荷青底色 | `#E6FDFD` |
| 辅助青色 | `#08D9DF` |
| 页面横向留白 | 24 logical pixels |
| 主按钮 | 高 52，胶囊圆角 |
| 房源卡片 | 图片 84 × 84，圆角 20，图片与文字间距 16 |
| 导航 | Explore / Search / Messages / Saved / Profile 五个入口 |

## 主要画板映射

| Pixso 节点 | 原稿画板 | Flutter 实现 |
| --- | --- | --- |
| `4:1649`、`4:1711`、`4:1744` | 02–04 引导 | `OnboardingScreen`，三步共用模板 |
| `4:1781`、`4:1876` | 05–06 注册 | `AuthScreen(signUp)`，校验切换空值与错误状态 |
| `4:1986`、`4:2164` | 07–08 选择社区 | `LocationScreen`，含搜索空结果 |
| `4:2353`–`4:2797` | 09–15 登录与找回 | `AuthScreen` 的四种模式与确认弹窗 |
| `4:2843`、`4:3270` | 16–17 首页 | `HomeScreen`，分类筛选由状态驱动 |
| `4:3871`、`4:3430`、`4:3721` | 18–20 地区搜索 | `LocationScreen` 与首页地区状态 |
| `7:1054`、`7:1232`、`7:1482` | 21–23 地图 | `MapScreen`，地图选择卡片与搜索空结果 |
| `7:1888` | 24 房源详情 | `PropertyScreen`，长内容可滚动，底部预约固定 |
| `7:2231` | 25 房源相册 | `GalleryScreen`、`PhotoScreen`，支持双指缩放和左右翻页 |
| `7:2470`、`7:2698` | 26–27 位置与房源参数 | `MapScreen(property)`、`EstateFactsScreen` |
| `7:2867`–`8:4187` | 28–40 预约两条分支 | `BookingScreen`、`TourSuccessScreen`、`TourDetailScreen` |
| `15:2199`–`20:2789` | 41–44 房源与房东搜索 | `SearchScreen`，共享查询与结果组件 |
| `20:3027`–`20:4056` | 45–49 聊天 | `MessagesScreen`、`ChatScreen` |
| `26:2723`–`26:3100` | 50–53 收藏 | `SavedScreen`，空状态与滑动删除确认 |
| `27:3104`–`29:3517` | 54–60 个人信息 | `ProfileScreen`、`EditProfileScreen`，头像 / 首字母切换 |
| `29:3611`–`29:4211` | 61–65 预约状态 | `TourStatusScreen`、`TourDetailScreen` |
| `29:4606`–`29:4882` | 66–68 修改密码 | `ChangePasswordScreen`，表单校验与完成反馈 |

原稿里的空白、填写、错误、选中和弹窗画板被合并成对应页面的运行状态，没有为每个状态重复创建页面文件。暗色外观通过同一套组件和主题实现。

## 导出的本地资源

| 文件 | Pixso 来源节点 | 用途 |
| --- | --- | --- |
| `brand.png` | `4:2367` | 品牌图标，矢量源导出为 1024 PNG |
| `city.png` | `4:2886` | 首页与页面顶部插画 |
| `onboarding.png` | `32:4342` | 引导页中的手机效果图 |
| `onboarding_chat.png`、`onboarding_tour.png` | `32:4343`、`32:4344` | 聊天与预约引导效果图 |
| `onboarding_house.png`、`tree.png` | `32:3935`、`32:3988` | 引导页前景建筑与树木 |
| `terracota.png` | `7:2082` | 详情首图 |
| `scandina.png` | `I4:3094;4:3039` | 第二套房源 |
| `eso.png` | `I4:3112;4:3039` | 公寓房源 |
| `united.png` | `I26:2921;4:3039` | 补充房源 |
| `villa.png` | `I26:3083;4:3039` | 补充房源 |
| `interior.png`、`living.png` | `7:2364`、`7:2365` | 相册内景 |
| `avatar.png` | `I27:3396;4:708` | 示例人物头像 |
| `map.png` | `7:1171` | 地图示意底图 |
| `tour_person.png`、`tour_video.png` | `I7:3335;7:3139`、`I8:2804;7:3139` | 两种预约流程插画 |

以上图片直接来自用户提供的设计稿，保留原稿的视觉素材。`docs/reference/` 是读取时保存的原稿快照，`docs/screenshots/` 是 Flutter 应用运行截图，两者用途不同。

字体来源：[Google Fonts / Manrope](https://github.com/google/fonts/tree/main/ofl/manrope)，许可证随附于 `assets/fonts/OFL.txt`。应用无需在线下载字体。

## 为实际运行作出的调整

- 保留英文界面，便于对照原稿；项目说明使用中文。
- 使用 Android / iOS 的系统安全区，页面不绘制假的系统状态栏或 iPhone 外框。
- 日历使用当前日期，过去日期和已经过去的时间不可选择；预约时间以设备本地时间为准。
- 原稿首页与详情中的卧室数量不一致，统一以数据模型为准。
- 缺少后端的功能明确标注为本地预览，避免把演示消息、地图位置和预约请求当成真实服务。
- 相册、详情、表单可滚动，兼容较小屏幕和键盘弹出。
