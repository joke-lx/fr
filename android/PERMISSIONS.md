# Android 权限配置说明

## 已配置的权限

### 1. 摄像头权限
```xml
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
<uses-permission android:name="android.permission.CAMERA" />
```

### 2. 存储权限
```xml
<!-- Android 12及以下 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### 3. 音频权限
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### 4. 网络权限
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 5. 其他权限
```xml
<!-- 振动权限 -->
<uses-permission android:name="android.permission.VIBRATE" />

<!-- 唤醒锁权限 -->
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- 通知权限 -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 运行时权限请求

在Android 6.0+（API 23+）中，以下权限需要在运行时请求：

1. **CAMERA** - 拍照时
2. **READ_EXTERNAL_STORAGE** / **READ_MEDIA_IMAGES** - 选择图片时
3. **RECORD_AUDIO** - 录制视频时

### 权限请求示例

```dart
import 'package:permission_handler/permission_handler.dart';

// 请求摄像头权限
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

// 请求存储权限（图片）
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      // Android 12及以下
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  return true;
}
```

## 权限声明位置

所有权限已在以下文件中声明：
- `android/app/src/main/AndroidManifest.xml`

## 应用配置

### Application ID
```
com.example.flutter_application_1
```

### 应用名称
```
聊天应用
```

### 最低SDK版本
```
21 (Android 5.0 Lollipop)
```

## 构建配置

### Debug构建
- 使用debug签名
- 启用调试模式

### Release构建
- 启用代码混淆
- 启用资源压缩
- 使用debug签名（需配置正式签名）

## 注意事项

1. **摄像头功能**: 如果应用不需要摄像头，可以将`android:required`设置为`false`，这样Google Play会过滤掉没有摄像头的设备

2. **存储权限**: Android 10（API 29）及以上使用分区存储，不需要WRITE_EXTERNAL_STORAGE权限

3. **Android 13变化**: 媒体权限从`READ_EXTERNAL_STORAGE`分离为：
   - `READ_MEDIA_IMAGES`
   - `READ_MEDIA_VIDEO`
   - `READ_MEDIA_AUDIO`

4. **权限最佳实践**:
   - 只请求必要的权限
   - 在需要时才请求（不要一启动就请求）
   - 解释为什么需要该权限
   - 处理权限被拒绝的情况

## 测试权限

在设备上测试权限功能：
1. 进入"媒体功能测试"页面
2. 点击各项功能按钮
3. 检查权限请求对话框
4. 允许/拒绝权限并观察行为
