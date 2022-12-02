import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groupproject/views/CommentPage.dart';
import 'package:groupproject/views/HomePage.dart';
import 'package:groupproject/views/HomePageTabs/OnlineViewMode/CreateCommentPage.dart';
import 'package:groupproject/views/MakePostPage.dart';
import "package:provider/provider.dart";
import 'package:groupproject/notifications.dart';

import 'models/PostOffline.dart';

void main() {
  runApp(MultiProvider(
    child: const MyApp(),
    providers: [
      ChangeNotifierProvider(create: (value) => PostsListBLoC()),
    ],
  ));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error initializing Firebase");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print("Succesfully connected to Firebase");
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.teal,
              ),
              home: const LoginPage(title: 'Flutter Demo Home Page'),
              routes: {
                '/homePage': (context) =>
                    const HomePageWidget(title: "HomePage"),
                '/createPostPage': (context) =>
                    const CreatePostWidget(title: "Create a Post"),
                '/commentPage': (context) => CommentPage(),
                '/createCommentPage': (context) => const CreateCommentPage(),
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final notifications = Notifications();

  @override
  Widget build(BuildContext context) {
    PostsListBLoC postsListBLoC = context.watch<PostsListBLoC>();

    notifications.init();

    return Scaffold(
      body:
          buildLogin(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> goToHomePage() async {
    var snackBar = const SnackBar(
        duration: Duration(seconds: 1), content: Text("Logging In..."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await Future.delayed(Duration(seconds: 1));
    var loginStatus = await Navigator.pushNamed(context, r'/homePage');
  }

  void notificationNow() async {
    notifications.sendNotification("t", "body", "payload");
  }

  void notificationPeriodic() async {
    notifications.sendNotificationPeriodic("Time to BREEL",
        "send a post and see what your friends are up to!", "payload");
  }

  Widget buildLogin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            "B-REEL",
            style: TextStyle(
                color: Colors.teal,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontFamily: 'Raleway'),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            "Sign in",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.teal, width: 5.0),
                          borderRadius: BorderRadius.circular(50.0)),
                      label: Text("Username"),
                      hintText: "Username"),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius: BorderRadius.circular(50)),
                      label: Text("Password"),
                      hintText: "Password "),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    onPressed: () {
                      // notificationNow();
                      notificationPeriodic();
                      goToHomePage();
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(fontSize: 20),
                    )),
                TextButton(onPressed: () {}, child: Text('Forgot Password')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(onPressed: () {}, child: Text('Sign Up'))
                  ],
                )
              ]),
            )),
      ],
    );
  }
}
