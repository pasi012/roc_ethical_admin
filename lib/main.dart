import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roc_ethical_admin/screens/login_screen.dart';
import 'consts/theme_data.dart';
import 'controllers/MenuControllerr.dart';
import 'firebase_options.dart';
import 'inner_screens/add_prod.dart';
import 'providers/dark_theme_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuControllerr(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            return themeChangeProvider;
          },
        ),
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Roc Ethical Admin',
            theme: Styles.themeData(themeProvider.getDarkTheme, context),
            home: const LoginScreen(),
            routes: {
              UploadProductForm.routeName: (context) =>
                  const UploadProductForm(),
            },
          );
        },
      ),
    );
  }
}
