import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/services/local_storage/hive_service.dart';
import 'package:pockettrack/services/local_storage/transaction_repository.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'cubit/settings/settings_cubit.dart';
import 'cubit/settings/settings_state.dart';
import 'cubit/transaction/transaction_cubit.dart';
import 'screens/splash/splash_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const PocketTrackApp());
}

class PocketTrackApp extends StatelessWidget {
  const PocketTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionCubit>(
          create: (_) => TransactionCubit(
            repository: HiveTransactionRepository(),
          )..loadTransactions(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}