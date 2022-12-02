import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/Account.dart';
import '../../models/PostOnline.dart';
import 'OfflineDatabase/OfflineHomeScreenBuilder.dart';
import '../../views/DatabaseEditors.dart';

class ProfilePageBuilder extends StatefulWidget {
  const ProfilePageBuilder({Key? key}) : super(key: key);

  @override
  State<ProfilePageBuilder> createState() => _ProfilePageBuilderState();
}

class _ProfilePageBuilderState extends State<ProfilePageBuilder> {
  final fireBaseInstance = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print("Data is missing from buildGradeList");
            return CircularProgressIndicator();
          } else {
            print("Data Loaded!");
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          flex: 1,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Text("AA"),
                          )),
                      Flexible(
                          flex: 2,
                          child: Row(
                            children: [
                              Text("${mainaccount.numposts} Posts" ),
                              Text(" ${mainaccount.followers} Followers "),
                              Text(" ${mainaccount.following} Following"),
                            ],
                          )),
                    ],
                  ),
                  Text("${mainaccount.userName}"),
                  ElevatedButton.icon(
                    onPressed: () {}, //need to add page
                    icon: Icon(
                      // <-- Icon
                      Icons.edit,
                      size: 24.0,
                    ),
                    label: Text('edit profile'), // <-- Text
                  ),

                  //needs to be changed for only my posts

                  GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        PostOnline post = PostOnline.fromMap(
                            snapshot.data.docs[index].data(),
                            reference: snapshot.data.docs[index].reference);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          onDoubleTap: () async {
                            setState(() {
                              selectedIndex = index;
                            });
                            var updatedPost = await Navigator.pushNamed(
                                context, '/commentPage', arguments: {
                              'fireBaseInstance': fireBaseInstance
                            });
                            updateOnlineDatabase(index, updatedPost, fireBaseInstance);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedIndex != index
                                    ? Colors.white
                                    : Colors.black12),
                            padding: EdgeInsets.all(10),
                            child: Image.network(
                              "${post.imageURL}",
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      })
                ]);
          }
        });
  }
}

Future<void> goToCommentPage(context) async {
  var newPost = await Navigator.pushNamed(context, r'/commentPage');
}

