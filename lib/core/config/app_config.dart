// lib/core/config/app_config.dart
import 'package:flutter/foundation.dart';

/// URL base del backend. Cambia automáticamente según entorno.
const String baseUrl = kReleaseMode
    ? 'https://appdelpalacio.onrender.com'
    : 'https://appdelpalacio.onrender.com'; // o tu IP local en dev si lo prefieres
