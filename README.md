# 🎙️ Grabador de Audio - Flutter

Aplicación Flutter para grabación de audio con interfaz intuitiva, optimizada para Android e iOS.

## ✨ Características

- 🎤 **Grabación de audio AAC** de alta calidad
- 📁 **Almacenamiento accesible** en carpeta Descargas/Recordings
- 🔍 **Explorador de archivos nativo** integrado (Android)
- 📱 **UI responsive** con animaciones fluidas
- ⚡ **Código optimizado** para rendimiento y mantenibilidad
- 🔐 **Gestión de permisos** automática

## 📱 Capturas

```
┌──────────────────────┐
│  Grabacion de consulta  │ ← AppBar
├──────────────────────┤
│                      │
│                      │
│      🎤              │ ← Botón de grabación
│   [Circular]         │   (animado durante grabación)
│                      │
│ "Pulsa el botón..."  │ ← Texto instructivo
│                      │
│                      │
│  [Ver grabaciones] ─────→ Abre explorador de archivos
└──────────────────────┘
```

## 🚀 Instalación

### Requisitos
- Flutter SDK ≥ 3.7.2
- Android NDK 27.0.12077973
- Kotlin 2.2.0
- Android minSdk 24

### Pasos
1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/prueba_boton_grabar.git
cd prueba_boton_grabar
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Compilar para Android:
```bash
flutter build apk
```

4. Instalar en dispositivo:
```bash
flutter install
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                           # Pantalla principal
├── constants/
│   └── app_constants.dart              # Constantes de la app
├── services/
│   ├── audio_recorder_service.dart     # Servicio de grabación
│   └── file_manager_service.dart       # Gestor de archivos nativo
└── widgets/
    └── recording_widgets.dart          # Widgets reutilizables
```

## 🔧 Configuración

### Android
- **NDK Version**: 27.0.12077973
- **Min SDK**: 24
- **Compile SDK**: flutter.compileSdkVersion
- **Kotlin**: 2.2.0

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

## 🎯 Uso

1. **Grabar Audio**
   - Pulsa el botón circular central
   - El botón se anima y cambia de color durante la grabación
   - Pulsa nuevamente para detener

2. **Ver Grabaciones**
   - Pulsa el botón "Ver grabaciones" (esquina inferior derecha)
   - Se abre el explorador de archivos en la carpeta Recordings

3. **Acceder a archivos**
   - Android: `/storage/emulated/0/Download/Recordings/`
   - iOS: Directorio de documentos de la app

## 🔄 Optimizaciones Realizadas

Ver detalles completos en [OPTIMIZATIONS.md](OPTIMIZATIONS.md)

### Resumen de mejoras:
- ✅ Reducción de 46% en líneas de código del archivo principal
- ✅ Separación de responsabilidades (SoC)
- ✅ +300% de widgets const para mejor rendimiento
- ✅ Manejo robusto de errores con logs estructurados
- ✅ Eliminación del 80% de código duplicado
- ✅ Gestión optimizada de recursos y memoria

## 🐛 Solución de Problemas

### Error: "Permiso denegado"
- Asegúrate de que los permisos estén en AndroidManifest.xml
- Acepta los permisos cuando la app los solicite

### Error: "No se puede abrir gestor de archivos"
- Si falla la apertura automática, se mostrará un diálogo con instrucciones
- Abre manualmente: Archivos > Descargas > Recordings

### Error de compilación NDK
- Verifica que tengas NDK 27.0.12077973 instalado
- Revisa `android/app/build.gradle.kts`

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

Para preguntas o sugerencias, abre un issue en el repositorio.

---

**Desarrollado con ❤️ usando Flutter**

