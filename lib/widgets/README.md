# Estructura de Widgets

Esta carpeta contiene todos los widgets de la aplicación, organizados en subcarpetas por funcionalidad.

## 📁 Estructura de Carpetas

### `/recorder` - Widgets de la Grabadora
Contiene todos los widgets relacionados con la interfaz de grabación de audio:
- `recording_status_indicator.dart` - Indicador de estado (Grabando/Pausado)
- `recording_timer.dart` - Cronómetro de grabación
- `minimize_button.dart` - Botón para minimizar la grabadora
- `wave_visualizer.dart` - Visualizador de ondas de audio
- `recording_header.dart` - Encabezado completo de grabación
- `central_button.dart` - Botón central de grabar/pausar
- `stop_button.dart` - Botón de detener
- `left_action_button.dart` - Botón de acción izquierdo (marca/descartar)
- `recording_control_buttons.dart` - Controles completos de grabación

### `/marks` - Widgets de Marcas de Audio
Widgets para gestionar las marcas de tiempo en las grabaciones:
- `audio_mark_item.dart` - Item individual de marca de audio
- `empty_marks_placeholder.dart` - Placeholder cuando no hay marcas
- `audio_marks_grid.dart` - Grid de marcas en formato 2 columnas
- `audio_marks_list.dart` - Lista completa de marcas

### `/patient` - Widgets de Paciente
Widgets relacionados con la información del paciente:
- `patient_info_card.dart` - Tarjeta de información del paciente

### `/selectors` - Widgets de Selección y Diálogos
Widgets para selección de opciones y diálogos informativos:
- `patient_selector.dart` - Selector de paciente (dropdown)
- `recording_type_button.dart` - Botón individual de tipo de grabación
- `recording_type_selector.dart` - Selector de tipo de grabación
- `recordings_info_dialog.dart` - Diálogo informativo sobre grabaciones
- `no_recordings_dialog.dart` - Diálogo de "sin grabaciones"
- `recording_button.dart` - Botón de grabación principal
- `instruction_text.dart` - Texto de instrucciones

### `/common` - Widgets Comunes
Widgets reutilizables en toda la aplicación:
- `action_button.dart` - Botón de acción genérico

## 📦 Archivos de Exportación (Barrel Files)

Cada carpeta tiene un archivo barrel que exporta todos sus widgets:
- `recorder/recorder_widgets.dart`
- `marks/marks_widgets.dart`
- `patient/patient_widgets.dart`
- `selectors/selectors_widgets.dart`
- `common/common_widgets.dart`

## 🔧 Uso

Para importar widgets en tus pantallas, puedes usar:

```dart
// Importar todos los widgets de grabación
import 'package:tu_app/widgets/audio_recorder_widgets.dart';

// O importar solo una categoría específica
import 'package:tu_app/widgets/recorder/recorder_widgets.dart';
import 'package:tu_app/widgets/marks/marks_widgets.dart';
```

## ✨ Beneficios de esta Estructura

1. **Organización clara**: Cada widget está en su propio archivo
2. **Fácil navegación**: Los widgets están agrupados por funcionalidad
3. **Mantenibilidad**: Es más fácil encontrar y modificar widgets específicos
4. **Reutilización**: Los widgets comunes están claramente identificados
5. **Escalabilidad**: Agregar nuevos widgets es simple y organizado
