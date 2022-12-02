/*
 OnlineHomeScreen creates a list of post based from the data found within the firebase
 database.
 OnlineHomeScreen will be used to view the post and interact with the post through
 the things likes likes, dislikes, reposts, etc.
 @author Andre Alix
 @version Group Project Check-In
 @since 2022-11-11
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/PostOffline.dart';
import '../../../models/PostOnline.dart';
import '../../DatabaseEditors.dart';
import '../../HomePage.dart';
import '../OfflineDatabase/OfflineHomeScreenBuilder.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class OnlineHomeScreen extends StatefulWidget {
   OnlineHomeScreen({Key? key}) : super(key: key);

  @override
  State<OnlineHomeScreen> createState() => _OnlineHomeScreenState();
}

/*
 OnlineHomeScreen creates a listview using snapshot instances found within the firebase
 database.
 The data in the firebase database is turned into an OnlinePost which is sent to
 separate widget creates buildlongpost and buildshort post.
 The widget has two viewing modes which will change depending on which index is currently
 being selected.
 Clicking a post will select the post, expanding it
 Double clicking an object will bring up the comment page for the post
 Holding down will unselect the post turning it back to its default view
*/
class _OnlineHomeScreenState extends State<OnlineHomeScreen> {

  final fireBaseInstance = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: fireBaseInstance.snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          print("Data is missing from buildGradeList");
          return CircularProgressIndicator();
        }
        else{
          print("Data Loaded!");
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index){
                PostOnline post = PostOnline.fromMap(snapshot.data.docs[index].data(), reference: snapshot.data.docs[index].reference);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        // print("selected index $selectedIndex");
                      });
                    },
                    onLongPress: (){
                      setState(() {
                        selectedIndex = 1^1000;
                      });
                    },
                    onDoubleTap: ()async{
                      setState(() {
                        selectedIndex = index;
                      });
                      var updatedPost = await Navigator.pushNamed(
                        context, '/commentPage',
                        arguments: {'fireBaseInstance': fireBaseInstance}
                      );
                    },

                      child: Container(
                        decoration: BoxDecoration(color: selectedIndex != index ? Colors.white : Colors.black12 ),
                        padding: const EdgeInsets.all(15),
                        child: selectedIndex!= index ? buildOnlineShortPost(post, context, index, fireBaseInstance) : buildOnlineLongPost(post, context, index, fireBaseInstance),
                      )
                  )
                );
              }
          );
        }
      }
    );
  }
}

/*
* Navigates into a new page which returns a new OnlinePost which is than used
* to replace data stored within the firebase database
*/
Future<void> goToUpdatePostPage(context, index, fireBaseInstance) async{

  var newPost = await Navigator.pushNamed(context, r'/createPostPage');
  updateOnlineDatabase(index, newPost, fireBaseInstance);
}

/*
 buildOnlineLongPost is given a post which is used to display the information
 stored within the post. This will only be created when the selectedIndex
 is equal to the index of the post.
 Displays information with a larger font and displays the longDiscription
*/
Widget buildOnlineLongPost(post, context, index, fireBaseInstance){


  return Column(
    children: [
      //Username and settings button
      Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircleAvatar(
                radius: 20,
                child: Text("AA", textScaleFactor: 1),
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                      "${post.userName}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  IconButton(
                    onPressed: () {
                      selectedIndex = index;
                      _showPostOptions(context, index, fireBaseInstance, post);
                    },
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              )
            ],
          ),
        ],
      ),

      //time
      Row(
        children: [
          Text("${post.timeString}",
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 15)
          ),
        ],
      ),
      const SizedBox(height: 10),

      //Title
      Text(
        "${post.title}",
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 30),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),

      //Description
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "${post.longDescription}",
          style: const TextStyle(fontSize: 15),
        ),
      ),
      const SizedBox(height: 20),

      //Image
      Image.network("${post.imageURL}", fit: BoxFit.fill,),
      //image section
      const SizedBox(height: 20,),

      //likes, dislikes, etc
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 20,
            ),
          ),
          Text("  ${post.comments.length}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numReposts += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              print("Number of Reposts: ${post.numReposts}");
            },
            icon: const Icon(Icons.repeat, size: 20),
          ),
          Text(" ${post.numReposts}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numLikes += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              print("Number of Likes: ${post.numLikes}");
            },
            icon:
            const Icon(Icons.thumb_up_outlined, size: 20),
          ),
          Text("  ${post.numLikes}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numDislikes += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              print("Number of Dislikes: ${post.numDislikes}");
            },
            icon: const Icon(Icons.thumb_down_outlined,
                size: 20),
          ),
          Text("  ${post.numDislikes}"),
        ],
      ),
      // user's post location
      RichText(
        text: TextSpan(
          text: "Posted from: ",
          style: TextStyle(fontSize: 15, color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: "${post.location}",
            style: TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()..onTap = () {
              print("made it here");
            }),  
          ])),
    ],
  );
}

/*
 buildOnlineShortPost is given a post which is used to display the information
 stored within the post. This will only be the default widget used to display
 the post and will happened if the selected index is not equal to the post's index
 Displays information with a smaller font and displays the shortDescription
*/
Widget buildOnlineShortPost(post, context, index, fireBaseInstance){

  return Column(
    children: [
      //Username and settings button
      Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircleAvatar(
                radius: 15,
                child: Text("AA", textScaleFactor: 1),
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                      "${post.userName}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  IconButton(
                    onPressed: () {
                      selectedIndex = index;
                      _showPostOptions(context, index, fireBaseInstance, post);
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              )
            ],
          ),
        ],
      ),

      //time
      Row(
        children: [
          Text("${post.timeString}",
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 10)
          ),
        ],
      ),
      const SizedBox(height: 10),

      //Title
      Text(
        "${post.title}",
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),

      //Description
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "${post.shortDescription}",
          style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.black54
          ),
        ),
      ),
      const SizedBox(height: 20),

      //Image
      Image.network("${post.imageURL}"),
      //image section
      const SizedBox(height: 20,),
    ],
  );
}

/*
 _showPostOptions shows a dialog asking what the user would like to
 do with the post. They may delete, edit or save the post.
 Deleting a post will remove it from the firebase database
 Editing will prompt you to a new page where you can make anew post
 this post will replace the previous post
 Save post will add the post into the sqlite database
*/
_showPostOptions(context, index, fireBaseInstance, post){
  showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          title: const Text("What would you like to do"),
          children: [
            SimpleDialogOption(
                onPressed: (){
                  Navigator.of(context).pop();
                  goToUpdatePostPage(context, index, fireBaseInstance);
                },
                child: const Text("Edit post")
            ),
            SimpleDialogOption(
                onPressed: (){
                  Navigator.of(context).pop();
                  _showDeleteDialog(context, fireBaseInstance);
                },
                child: const Text("Delete post")
            ),
            SimpleDialogOption(
                onPressed: (){
                  Navigator.of(context).pop();
                  PostOffline downloadedPost = PostOffline(userName: post.userName, timeString: post.timeString, longDescription: post.longDescription, shortDescription: post.shortDescription, imageURL: post.imageURL, title: post.title, id: lastInsertedId+1);
                  addOfflineDatabase(downloadedPost, context);
                },
                child: const Text("Save post")
            ),
          ],
        );
      }
  );
}

//Asks the user if they would like to delete a the post from the online database
_showDeleteDialog(context, fireBaseInstance){
  showDialog(context: context,
      barrierDismissible: false,                              //doesn't allow user to click of alert pop up
      builder: (context){
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you would like to delete this post"),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: (){
                  deleteOnlineDatabase(selectedIndex, fireBaseInstance);
                  Navigator.of(context).pop();
                },
                child: Text("Delete")
            )
          ],
        );
      }
  );
}
