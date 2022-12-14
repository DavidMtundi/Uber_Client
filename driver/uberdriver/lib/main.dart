import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:uberdriver/customWalkThrough.dart';
import 'package:uberdriver/helpers/locators/service_locator.dart';
import 'package:uberdriver/helpers/router.dart';
import 'package:uberdriver/otherauthscreens/unauthpage.dart';
import 'package:uberdriver/otherconstants/themedart.dart';
import 'package:uberdriver/providers/app_provider.dart';
import 'package:uberdriver/providers/user.dart';
import 'package:uberdriver/screens/splash.dart';
import 'package:flutter/material.dart';
import 'helpers/constants.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  setupLocator();

  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(
        value: AppStateProvider(),
      ),
      ChangeNotifierProvider.value(value: UserProvider.initialize()),
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //theme: ThemeData(primaryColor: Colors.deepOrange),
        title: "Flutter Driver",
        theme: ThemeScheme.light(),
        darkTheme: ThemeScheme.dark(),
        onGenerateRoute: onGenerateRoute,
        home: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider auth = Provider.of<UserProvider>(context);

    return FutureBuilder(
      // Initialize FlutterFire:
      future: initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text("Something went wrong")],
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          switch (auth.status) {
            case Status.Uninitialized:
              return Splash();
            case Status.Unauthenticated:
              //return MultiRegister();
              return WalkThrough();
            case Status.Authenticating:
              // return MultiRegister();
              return UnAuth();
            case Status.Authenticated:
              //return MultiRegister();
              return MyHomePage(
                title: "Home",
              );
            default:
              // return MultiRegister();
              return WalkThrough();
          }
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Colors.black,
                value: 20,
                semanticsLabel: "Please Wait",
              )
            ],
          ),
        );
      },
    );
  }
}
