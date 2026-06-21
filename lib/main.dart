import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/calculator/data/calculator_repository_impl.dart';
import 'features/calculator/domain/calculator_repository.dart';
import 'features/calculator/presentation/bloc/calculator_bloc.dart';
import 'features/calculator/presentation/bloc/calculator_event.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/history/presentation/bloc/history_event.dart';
import 'features/history/presentation/screens/history_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/instant/presentation/bloc/instant_bloc.dart';
import 'features/instant/presentation/bloc/instant_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFF8F8F8),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  final repository = CalculatorRepositoryImpl(prefs);

  runApp(ManiKanakkuApp(repository: repository));
}

class ManiKanakkuApp extends StatelessWidget {
  final CalculatorRepository repository;

  const ManiKanakkuApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalculatorBloc>(
          create: (_) => CalculatorBloc(repository: repository)
            ..add(const LoadInitialData()),
        ),
        BlocProvider<InstantBloc>(
          create: (_) => InstantBloc(repository: repository)
            ..add(const InstantLoadInitialData()),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Mani Kanakku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('ta'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/history':
              return MaterialPageRoute(
                builder: (context) {
                  context
                      .read<HistoryBloc>()
                      .add(const LoadHistory());
                  return const HistoryScreen();
                },
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
          }
        },
      ),
    );
  }
}
