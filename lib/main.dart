// lib/main.dart (LIMPO E ORGANIZADO! 🎉)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/config/app_providers.dart'; // ✅ IMPORT ÚNICO
import 'package:wmsapp/wms_main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: AppProviders.providers, // ✅ UMA LINHA!
      child: const WmsMainApp(),
    ),
  );
}
