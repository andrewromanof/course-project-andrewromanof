/*
  HomePage creates the page that contains the different features within the app
  TabController that populates the homepage with different features depending
  on the selected tab

  "model" contains an instance of post_model used to edit the sqlite database
  "lastInsertedId" contains a integer used to determine the last used id for the sqlite database

  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */

import 'package:flutter/material.dart';
import 'package:groupproject/views/HomePageTabs/PictureViewMode/PictureViewerBuilder.dart';
import 'package:groupproject/views/HomePageTabs/SearchPage/SearchPage.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePageBuilder.dart';
import 'DatabaseEditors.dart';
import 'HomePageTabs/OfflineDatabase/OfflineHomeScreenBuilder.dart';
import 'HomePageTabs/OfflineDatabase/post_model.dart';
import 'HomePageTabs/OnlineViewMode/OnlineHomeScreenBuilder.dart';

var model = PostModel();
int lastInsertedId = 0;

/*
  Creates the HomePage scaffold which contains the main UI elements
  for the app
 */
class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

/*
  Creates the DefaultTabController that allows changes the widget
  displayed in the body depending on the tab that is currently being
  selected
  "HomeScreen" tab creates a listview that contains all the posts
  found within the firebase database
  "PictureViewer" creates a gridview containing all the pictures
  found within the firebase database
  "Polls and Surveys" Work in Progress
  "Offline Viewer" tab creates a listview that contains all the posts
  found within the sqlite database
  "Profile" contains a gridview containing all of the posts that are linked
   to the current account
 */
class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  void initState() {
    super.initState();
    initializeOfflineDataBase(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
          actions: [
            IconButton(
                onPressed: () {
                  goToCreatePostPage(context);
                },
              tooltip: "Submit your article!",
                icon: const Icon(Icons.add),
            ),
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: SearchPage());
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  readOfflineDatabase();
                },
                icon: Icon(Icons.data_object)),
          ],
        ),
        body: TabBarView(
          children: [
            OnlineHomeScreen(),
            PictureViewerBuilder(),
            Text("work in progress"),
            OfflineHomeScreen(),
            ProfilePageBuilder(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.teal),
          child: const TabBar(
            tabs: [
              Tab(text: "HomeScreen", icon: Icon(Icons.home),),
              Tab(text: "PictureViewer", icon: Icon(Icons.photo)),
              Tab(text: "Polls and Surveys", icon: Icon(Icons.poll)),
              Tab(text: "Offline Viewer", icon: Icon(Icons.download)),
              Tab(text: "Profile", icon: Icon(Icons.account_box)),
            ],
          ),
        ),
      ),
    );
  }

  /*
   * goToCreatePostPage navigates onto to create post page and can be
   * done from any of the tabs within the HomePage navigator.
   */
  Future<void> goToCreatePostPage(context) async {
    var newPost = await Navigator.pushNamed(context, r'/createPostPage');
    if (newPost == null) {
      print("Nothing was inputed");
    } else {
      insertOnlineDatabase(newPost);
    }
  }
}
