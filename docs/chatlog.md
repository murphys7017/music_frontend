# user 1
目前我已经简单开发完成了音乐后台系统，下面我将系统的api接口描述给你，我需要你建立对应请求部分，为后续数据开发请求打下基础。
这是fastapi自动生成的接口文档地址：
http://127.0.0.1:8000/docs#/
这是接口说明文档：
#### 1. 列出音乐 (分页)

```http
GET /music/list?page=1&page_size=20
```

**响应:**

```json
{
  "total": 100,
  "page": 1,
  "page_size": 20,
  "items": [
    {
      "uuid": "123e4567-e89b-12d3-a456-426614174000",
      "name": "玉盘",
      "author": "葫芦童声",
      "album": "专辑名",
      "duration": 245,
      "size": 10485760,
      "bitrate": 320,
      "cover_uuid": "cover-uuid",
      "play_count": 10,
      "play_url": "/music/play/{uuid}",
      "cover_url": "/music/cover/{cover_uuid}"
    }
  ]
}
```

#### 2. 搜索音乐

```http
GET /music/search?keyword=玉盘&page=1&page_size=20
```

#### 3. 获取音乐详情

```http
GET /music/{music_uuid}
```

#### 4. 播放音乐

```http
GET /music/play/{music_uuid}
```

返回音频流,自动增加播放次数

#### 5. 获取封面

```http
GET /music/cover/{cover_uuid}
```

#### 6. 获取歌词

```http
GET /music/lyric/{music_uuid}
```

#### 7. 根据歌词搜索音乐

```http
GET /music/search/lyric?keyword=love&page=1&page_size=20
```

搜索歌词中包含关键词的音乐，返回完整歌词信息。

#### 8. 获取缩略图

```http
GET /music/thumbnail/{cover_uuid}
```

返回 200x200 JPEG 缩略图，体积约 20KB。

# user 2
我补充一个，所有对服务器的请求必须包含一个请求头，{"Authorization": "your_static_token_here"}目前token就是your_static_token_here，后续我会继续开发修改等，目前先用这个测试

# user 3
我正在用 Flutter 开发一个个人音乐播放器，需要为桌面端设计一个可折叠的左侧边栏。侧边栏默认收起只显示图标，鼠标悬停时展开显示完整菜单。菜单结构如下：

一级菜单共四项：

“首页” → 展开后显示动态二级菜单（根据侧边栏高度自动计算显示数量），内容是用户收藏/自建歌单名称（如“我的最爱”、“工作专注”、“周末放松”等），点击进入首页页面（展示收藏音乐+自建歌单）。
“音乐库” → 无二级菜单，点击进入“所有音乐”页面（展示服务器+本地全部音乐）。
“推荐” → 无二级菜单，点击进入“推荐页面”（展示服务器推荐音乐和歌单）。
“其他” → 展开后显示二级菜单：“播放历史”、“设置”等。
页面布局：

顶部偏左放置搜索框（SearchBar）。
底部固定播放控制栏（播放/暂停、进度条、音量等）。
主内容区在侧边栏右侧，随菜单切换显示不同页面。
要求：

使用 Drawer 或自定义 AnimatedContainer + GestureDetector 实现侧边栏折叠动画。
鼠标悬停展开（仅桌面端），触摸设备保持常开（可选）。
支持路由跳转或 IndexedStack / PageView 切换主内容。
二级菜单项动态渲染（从 List<String> 加载，支持滚动）。
图标使用 Icons，风格简洁现代。
响应式适配：桌面端宽屏，移动端底部导航栏（另设）。
不需要社交功能，下载音乐即归入本地库。
请生成完整的 Widget 结构代码，包括状态管理（可用 StatefulWidget 或 Provider 简化版），并注释关键部分。 
数据先使用模拟数据