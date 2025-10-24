# 高德地图配置说明

本项目使用高德地图API来展示新都桥旅游地图。

## 获取高德地图API Key

1. **注册高德开放平台账号**
   - 访问：https://lbs.amap.com/
   - 点击"注册/登录"创建账号

2. **创建应用**
   - 登录后进入控制台：https://console.amap.com/dev/key/app
   - 点击"创建新应用"
   - 填写应用名称（如：新都桥旅行网站）

3. **添加Key**
   - 在应用下点击"添加"
   - Key名称：填写一个便于识别的名称
   - 服务平台：选择"Web端(JS API)"
   - 填写网站域名（本地开发可以填写 `localhost`）

4. **获取Key**
   - 创建成功后，复制显示的Key值

## 配置到项目中

打开 `index.html` 文件，找到以下代码（约第63行）：

```html
<script src="https://webapi.amap.com/maps?v=2.0&key=YOUR_AMAP_KEY"></script>
```

将 `YOUR_AMAP_KEY` 替换为你获取的Key值：

```html
<script src="https://webapi.amap.com/maps?v=2.0&key=你的Key值"></script>
```

## 地图功能

配置完成后，地图将显示：
- 🏔️ 新都桥位置标记
- 📍 塔公草原景点标记  
- 📍 木雅圣地景点标记
- 📍 折多山景点标记
- 🗺️ 地图缩放、比例尺等控件

## 地图样式

当前使用淡雅风格 (`amap://styles/whitesmoke`)，你可以在 `assets/js/main.js` 中修改 `mapStyle` 参数来更换地图样式：

- `amap://styles/normal` - 标准
- `amap://styles/dark` - 暗黑
- `amap://styles/light` - 月光银
- `amap://styles/whitesmoke` - 远山黛（当前使用）
- `amap://styles/fresh` - 草色青
- `amap://styles/grey` - 雅士灰
- `amap://styles/graffiti` - 涂鸦
- `amap://styles/macaron` - 马卡龙
- `amap://styles/blue` - 靛青蓝
- `amap://styles/darkblue` - 极夜蓝
- `amap://styles/wine` - 酱籽

## 注意事项

⚠️ 高德地图API有以下限制：
- 个人开发者：每日调用量配额 30万次
- 需要绑定有效域名（生产环境）
- 本地开发可以使用 `localhost` 或 `127.0.0.1`

## 故障排查

如果地图不显示：

1. **检查API Key是否正确配置**
2. **查看浏览器控制台是否有错误信息**
3. **确认域名是否在高德控制台中添加**
4. **检查网络连接是否正常**

## 本地测试

使用本地服务器打开项目：

```bash
# 使用Python 3
python -m http.server 8000

# 或使用Node.js的http-server
npx http-server

# 或使用PHP
php -S localhost:8000
```

然后访问：http://localhost:8000

---

💡 如果遇到问题，可以参考高德地图官方文档：https://lbs.amap.com/api/jsapi-v2/summary

