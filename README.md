# 🎙️ Grabador de Audio - Flutter

Aplicación Flutter para grabación de audio con interfaz intuitiva, optimizada para Android e iOS.

## ✨ Características

- 🎤 **Grabación de audio AAC** 
- 📁 **Almacenamiento accesible** en carpeta Descargas/Recordings (en Android)
- 📱 **UI responsive** con animaciones fluidas
- 🔐 **Gestión de permisos** automática

## 📱 Capturas
![](Images_Screens/thumb-1760963345728.jpg)
![](Images_Screens/thumb-1760963345768.jpg)
![](Images_Screens/thumb-1760963345793.jpg)
![](Images_Screens/thumb-1760963345817.jpg)
![](Images_Screens/thumb-1760963377691.jpg)
![](Images_Screens/thumb-1760963377712.jpg)
![](Images_Screens/thumb-1760963377732.jpg)
![](Images_Screens/thumb-1760964300708.jpg)
![](Images_Screens/thumb-1760964300729.jpg)


### Permisos (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_sound: ^9.3.8
  permission_handler: ^12.0.1
  path_provider: ^2.0.16
  share_plus: ^12.0.0
```



