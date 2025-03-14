// // ignore_for_file: deprecated_member_use, avoid_print

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:outline_gradient_button/outline_gradient_button.dart';
// // import 'package:location/location.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:aarohan_app/util/inner_drawer.dart';
// import 'package:sizer/sizer.dart';

// import 'fullscreen_image.dart';

// ValueNotifier<bool> updateMap = ValueNotifier(false);

// class HomePage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   HomePage(this.user);

//   @override
//   _HomePageState createState() => _HomePageState(user);
// }

// String apiUrl = "interfecio.nitdgplug.org";

// bool header = false;
// bool intro = false;
// ValueNotifier<double> lat = ValueNotifier(0.0), long = ValueNotifier(0.0);
// List<Marker> _markers = [];
// int x = 0;
// double mapZoom = 15.0;
// Completer<GoogleMapController> mapController = Completer();

// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   final Map<String, dynamic> user;
//   _HomePageState(this.user);
//   // var currentLocation = LocationData;
//   // var location = Location();
//   var accuracy;
//   late SharedPreferences _sharedPrefs;
//   bool _finalAnswerGiven = false;
//   bool _isUp =
//       true; //to maintain state of the animation of leaderboard, instruction sheet
//   bool _isUpLeaderBoard = true;
//   bool _isUpInstructions = true;
//   List<LatLng> correctLocations = [];
//   Map<String, dynamic> levelData = {}; //stores data of current level of user
//   Map<String, dynamic> clueData = {};
//   Map<String, dynamic> unlockedClueData = {};
//   var mainQues;
//   var finalAns;

//   List<dynamic> leaderboard = []; //stores the current leaderboard

//   final _answerFieldController =
//       TextEditingController(); //to retrieve textfield value

//   final _fieldFocusNode = new FocusNode(); //to deselect answer textfield

//   bool _isLoading = true;

//   String getSpaces(int index) {
//     int noOfSpaces = 2 - ((index ~/ 10 > 0) ? 2 : 0);
//     String spaces = "";
//     for (int i = 0; i < noOfSpaces; i++) {
//       spaces += " ";
//     }
//     return spaces;
//   }

//   Future getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       print("Location Permision Denied");
//       LocationPermission askPermission = await Geolocator.requestPermission();
//     } else {
//       Position currentPosition = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       print("Longi" + currentPosition.longitude.toString());
//       setState(() {
//         lat!.value = currentPosition.latitude;
//         long!.value = currentPosition.longitude;
//       });
//       print("Latit" + currentPosition.latitude.toString());
//     }
//   }

// // this function retrieves the data of the current level of the user
//   Future getLevelData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     http.Response response = await http.get(
//         Uri.parse("https://$apiUrl/api/getlevel/"),
//         headers: {"Authorization": "Token ${user["token"]}"});
//     levelData = json.decode(response.body);
//     print("DATA LEVEL DATA : $levelData");

//     if (levelData["level"] == "ALLDONE")
//       clueData = {"data": "finished"};
//     else if (levelData["pause_bool"] == true) {
//       levelData["level"] = "More Levels Coming Soon";
//       clueData = {"data": "finished"};
//     } else {
//       dynamic level = levelData["level_no"];
//       print("LEVELNO:$level");
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString("currentLevel", "$level");
//       http.Response clues = await http.get(
//           Uri.parse("https://$apiUrl/api/getlevelclues/?level_no=$level"),
//           headers: {"Authorization": "Token ${user["token"]}"});
//       clueData = json.decode(clues.body);
//       print("DATA cluesData: $clueData");
//     }

//     print(clueData);
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future getUnclockedClues() async {
//     setState(() {
//       _isLoading = true;
//     });
//     print("start");
//     print("byee");
//     http.Response response = await http
//         .get(Uri.parse("https://$apiUrl/api/getclues/"), headers: {
//       "Authorization": "Token ${user["token"]}",
//       "Content-type": "application/json"
//     });
//     print(response);
//     print("done");

//     setState(() {
//       unlockedClueData = json.decode(response.body);
//       _isLoading = false;
//     });

//     print("DATA unlockedClue $unlockedClueData");
//   }

//   Future getMainQuestion() async {
//     setState(() {
//       _isLoading = true;
//     });
//     print("main");
//     http.Response response = await http
//         .get(Uri.parse("https://$apiUrl/api/finaltext/"), headers: {
//       "Authorization": "Token ${user["token"]}",
//       "Content-type": "application/json"
//     });
//     mainQues = json.decode(response.body);
//     print("DATA Main Questions : $mainQues");

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future getCorrectLocations() async {
//     print("getting CORRECT LOCATIONS");
//     http.Response response = await http
//         .get(Uri.parse("https://$apiUrl/api/getanswers/"), headers: {
//       "Authorization": "Token ${user["token"]}",
//       "Content-type": "application/json"
//     });
//     print("CLLOC----------${response.body}");
//     var clocations = {"data": []};
//     if (response.statusCode == 200) clocations = json.decode(response.body);
//     print("DATA Correct Locations : $clocations");
//     if (clocations['data']!.length == 0) {
//       print("NO CORRECT LOCATIONS");
//       setState(() {
//         correctLocations = [];
//         updateMap.value = true;
//       });
//       return;
//     }
//     setState(() {
//       correctLocations = List<LatLng>.from(
//         clocations['data']!.map(
//           (json) =>
//               LatLng(double.parse(json['lat']), double.parse(json['long'])),
//         ),
//       );
//       updateMap.value = true;
//     });
//   }

//   Future submitFinalAnswer(answer) async {
//     setState(() {
//       _isLoading = true;
//     });
//     http.Response response = await http.post(
//         Uri.parse("https://$apiUrl/api/finaltext/"),
//         headers: {
//           "Authorization": "Token ${user["token"]}",
//           "Content-type": "application/json"
//         },
//         body: json.encode({"ans": answer}));
//     print(response.body);
//     finalAns = json.decode(response.body);
//     if (finalAns["success"] == false)
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           duration: Duration(seconds: 1),
//           content: Text(
//             "Answer already submitted once",
//             style: TextStyle(color: Colors.black),
//           )));
//     // else if (finalAns["success"] == true) {
//     //   SharedPreferences prefs = await SharedPreferences.getInstance();
//     //   prefs.setString("success", "true");
//     // }
//     setState(() {
//       _sharedPrefs.setBool("finalAnswerGiven", true);
//       _finalAnswerGiven = true;
//       _isLoading = false;
//     });
//   }

// //this function retrieves the current leaderboard
//   Future getScoreboard() async {
//     print("___________________GETTING_LEADERBOARD_________________________");
//     setState(() {
//       _isLoading = true;
//     });
//     http.Response response = await http.get(
//         Uri.parse("https://$apiUrl/api/scoreboard/"),
//         headers: {"Authorization": "Token ${user["token"]}"});
//     leaderboard = json.decode(response.body);
//     print("DATA LEADERBOARD $leaderboard");
//     setState(() {
//       _isLoading = false;
//       leaderboard = leaderboard;
//     });
//   }

//   Future unlockClue(clueNo) async {
//     setState(() {
//       _isLoading = true;
//     });

//     http.Response response = await http.get(
//         Uri.parse(
//             "https://$apiUrl/api/unlockclue/?level_no=${levelData["level_no"]}&clue_no=$clueNo"),
//         // ignore: missing_return
//         headers: {"Authorization": "Token ${user["token"]}"}).then((onValue) {
//       print(onValue.body);
//       var euresponse = json.decode(onValue.body);
//       if (euresponse['data'] == null) {
//         print("EURE NULL");
//         showDialog(
//             context: context,
//             builder: (context) => Dialog(
//                   backgroundColor: Colors.white.withOpacity(0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF6f2603),
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.all(15),
//                     height: 130,
//                     width: MediaQuery.of(context).size.width / 1.5,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: <Widget>[
//                         Text(
//                           "${euresponse['msg']}",
//                           style: TextStyle(
//                               fontSize: 20,
//                               color: Colors.white,
//                               fontFamily: "Gotham"),
//                         ),
//                         TextButton(
//                           style: ButtonStyle(
//                             side: MaterialStateProperty.all(
//                               BorderSide(
//                                 color: Colors.white, //Color of the border
//                                 style: BorderStyle.solid, //Style of the border
//                                 width: 1, //width of the border
//                               ),
//                             ),
//                             backgroundColor:
//                                 MaterialStateProperty.all(Color(0xFF420000)),
//                           ),
//                           child: Text(
//                             "GO BACK",
//                             style: TextStyle(
//                                 color: Colors.white, fontFamily: 'Gotham'),
//                           ),
//                           onPressed: () {
//                             Navigator.of(context, rootNavigator: true)
//                                 .pop(true);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ));
//       }
//       getLevelData();
//       getUnclockedClues();
//       throw ();
//     });

//     print(json.decode(response.body));

//     setState(() {
//       _isLoading = false;
//     });
//   }

// //this function submits the current location of the user
//   Future submitLocation() async {
//     setState(() {
//       _isLoading = true;
//     });

//     http.Response response = await http.post(
//       Uri.parse("https://$apiUrl/api/submit/location/"),
//       headers: {
//         "Authorization": "Token ${user["token"]}",
//         "Content-Type": "application/json"
//       },
//       body: json.encode({
//         "lat": lat.value,
//         "long": long.value,
//         "level_no": levelData["level_no"],
//       }),
//     );
//     var data = json.decode(response.body);

//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         duration: Duration(seconds: 1),
//         content:
//             Text(data["success"] == true ? "correct location" : "try again")));
//     // }
//     setState(() {
//       getLevelData().then((onValue) {
//         getUnclockedClues();
//       });
//     });
//   }

//   void setIntro() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("intro", "true");
//   }

//   void getIntro() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var temp = prefs.getString("intro");
//     if (temp == "true") intro = true;
//   }

//   Widget _answerTextField() {
//     return TextFormField(
//       controller: _answerFieldController,
//       style: TextStyle(
//         color: Colors.white.withOpacity(0.7),
//       ),
//       decoration: InputDecoration(
//         suffixIcon: Icon(
//           Icons.question_answer,
//           color: Colors.white.withOpacity(0.7),
//         ),
//         // filled: true,
//         // fillColor: Colors.white.withOpacity(0.7),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(
//             color: Color(0xC0FF9e02), //Color of the border
//             style: BorderStyle.solid, //Style of the border
//             width: 1, //width of the border
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(
//             color: Color(0xC0FF9e02), //Color of the border
//             style: BorderStyle.solid, //Style of the border
//             width: 1, //width of the border
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         labelText: "answer",
//         labelStyle: TextStyle(
//           color: Colors.white.withOpacity(0.7),
//         ),
//       ),
//       validator: (String? value) {
//         if (value!.trim().isEmpty) {
//           return "Please enter a valid answer";
//         }
//         return null;
//       },
//       onSaved: (String? value) {},
//     );
//   }

//   @override
//   void dispose() {
//     _answerFieldController.dispose();
//     _animationController?.dispose();
//     super.dispose();
//   }

//   @override
//   void setState(fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }

//   AnimationController? _animationController;

//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((value) {
//       setState(() {
//         _sharedPrefs = value;
//         _finalAnswerGiven =
//             (_sharedPrefs.get("finalAnswerGiven") ?? false) as bool;
//         print("DATA FINAL ANSWER GIVEN : $_finalAnswerGiven");
//       });
//     });
//     getIntro();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     // getLocation();
//     // getMainQuestion();
//     lat = ValueNotifier<double>(0.0);
//     long = ValueNotifier<double>(0.0);
//     lat.addListener(() {
//       setState(() {});
//     });
//     long.addListener(() {
//       setState(() {});
//     });
//     getLevelData().then((val) {
//       getScoreboard().then((onValue) {
//         print(onValue);
//         getUnclockedClues().then((onValue) {
//           getMainQuestion().then((onValue) {
//             getCorrectLocations();
//           });
//         });
//       });
//     });
//     print("PRINTING CLUE DATA ________________________________$clueData");
//     print(clueData);
//     // getMainQuestion();
//   }

//   final LabeledGlobalKey<InnerDrawerState> _innerDrawerKey =
//       LabeledGlobalKey<InnerDrawerState>("label");

//   void _toggle() {
//     _innerDrawerKey.currentState?.toggle(
//         // direction is optional
//         // if not set, the last direction will be used
//         //InnerDrawerDirection.start OR InnerDrawerDirection.end
//         direction: InnerDrawerDirection.start);
//   }

//   bool _isOpen = false; //to maintain animation of question, answer box

//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   //for bottomsnackbar

//   Widget drawerClues() {
//     return _isLoading
//         ? Container(
//             child: const CircularProgressIndicator(
//               color: Color(0xFFFF9e02),
//             ),
//           )
//         : Material(
//             color: Colors.white.withOpacity(0),
//             child: Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: 5.h,
//                 ),
//                 Container(
//                   color: Colors.black,
//                   alignment: Alignment.topLeft,
//                   padding: const EdgeInsets.all(10),
//                   child: const FittedBox(
//                     child: Text(
//                       "CURRENT CLUES",
//                       style: TextStyle(
//                           fontFamily: "Gotham",
//                           color: Color(0xFFFF9e02),
//                           fontSize: 35,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 clueData["data"] == "finished"
//                     ? Container(
//                         child: Text(
//                           "No Clues Available",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontFamily: "Montserrat"),
//                         ),
//                       )
//                     : Expanded(
//                         child: (clueData["data"].length == 0)
//                             ? Container(
//                                 child: Text("No Clues Available"),
//                               )
//                             : Container(
//                                 // height: MediaQuery.of(context).size.height / 3,
//                                 padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
//                                 color: Colors.black,
//                                 child: ListView.builder(
//                                   physics: const ScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: clueData["data"].length ?? 0,
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     return Container(
//                                       decoration: const BoxDecoration(
//                                           color: Color(0xFF000000),
//                                           boxShadow: [
//                                             BoxShadow(
//                                                 color: Colors.black,
//                                                 offset: Offset(2.0, 2.0),
//                                                 blurRadius: 10.0,
//                                                 spreadRadius: 1.0),
//                                             //   BoxShadow(
//                                             //       color: Colors.white,
//                                             //       offset: Offset(-2.0, -2.0),
//                                             //       blurRadius: 10.0,
//                                             //       spreadRadius: 1.0),
//                                           ],
//                                           borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(20),
//                                               bottomRight:
//                                                   const Radius.circular(20))),
//                                       margin: const EdgeInsets.fromLTRB(
//                                           0, 15, 30, 15),
//                                       // padding: EdgeInsets.all(10),
//                                       child: ClipRRect(
//                                         borderRadius: const BorderRadius.only(
//                                           topRight: Radius.circular(15.0),
//                                           bottomRight:
//                                               const Radius.circular(15.0),
//                                         ),
//                                         child: ListTile(
//                                           tileColor:
//                                               Colors.white.withOpacity(0.2),
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                   vertical: 5.0,
//                                                   horizontal: 15),
//                                           leading: IconButton(
//                                             iconSize: 25.0,
//                                             color: Colors.white,
//                                             onPressed:
//                                                 clueData["data"][index][2] ==
//                                                         null
//                                                     ? () {
//                                                         showDialog(
//                                                           context: context,
//                                                           builder: (context) =>
//                                                               Dialog(
//                                                             backgroundColor:
//                                                                 Colors.white
//                                                                     .withOpacity(
//                                                                         0),
//                                                             child: Container(
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: const Color
//                                                                     .fromARGB(
//                                                                     255,
//                                                                     4,
//                                                                     133,
//                                                                     156),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             30),
//                                                               ),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(15),
//                                                               height: 170,
//                                                               width: MediaQuery.of(
//                                                                           context)
//                                                                       .size
//                                                                       .width /
//                                                                   1.5,
//                                                               child: Column(
//                                                                 children: <Widget>[
//                                                                   const Text(
//                                                                     "Are you sure you want to unlock this clue?",
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           20,
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontFamily:
//                                                                           "Montserrat",
//                                                                     ),
//                                                                   ),
//                                                                   ButtonBar(
//                                                                     children: <Widget>[
//                                                                       TextButton(
//                                                                         style:
//                                                                             ButtonStyle(
//                                                                           side:
//                                                                               MaterialStateProperty.all(
//                                                                             BorderSide(
//                                                                               color: Colors.white, //Color of the border
//                                                                               style: BorderStyle.solid, //Style of the border
//                                                                               width: 1, //width of the border
//                                                                             ),
//                                                                           ),
//                                                                           backgroundColor:
//                                                                               MaterialStateProperty.all(Color(0xFF420000)),
//                                                                         ),
//                                                                         child:
//                                                                             Text(
//                                                                           "UNLOCK",
//                                                                           style: TextStyle(
//                                                                               color: Colors.white,
//                                                                               fontFamily: "Gotham"),
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {
//                                                                           setState(
//                                                                               () {
//                                                                             unlockClue(clueData["data"][index][0]);
//                                                                             Navigator.of(context, rootNavigator: true).pop(true);
//                                                                           });
//                                                                         },
//                                                                       ),
//                                                                       TextButton(
//                                                                         style:
//                                                                             ButtonStyle(
//                                                                           side:
//                                                                               MaterialStateProperty.all(
//                                                                             BorderSide(
//                                                                               color: Colors.white, //Color of the border
//                                                                               style: BorderStyle.solid, //Style of the border
//                                                                               width: 1, //width of the border
//                                                                             ),
//                                                                           ),
//                                                                           backgroundColor:
//                                                                               MaterialStateProperty.all(Color(0xFF420000)),
//                                                                         ),
//                                                                         child:
//                                                                             Text(
//                                                                           "GO BACK",
//                                                                           style: TextStyle(
//                                                                               color: Colors.white,
//                                                                               fontFamily: "Gotham"),
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {
//                                                                           Navigator.of(context, rootNavigator: true)
//                                                                               .pop(true);
//                                                                         },
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         );
//                                                       }
//                                                     : () {},
//                                             icon: Icon(
//                                                 clueData["data"][index][2] !=
//                                                         null
//                                                     ? Icons.lock_open
//                                                     : Icons.lock,
//                                                 color: clueData["data"][index]
//                                                             [2] !=
//                                                         null
//                                                     ? Color(0xFF03A062)
//                                                     : Color(0xFFe1bc9c)),
//                                           ),
//                                           title: clueData["data"][index][2] !=
//                                                   null
//                                               ? Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: <Widget>[
//                                                     Text(
//                                                       "${clueData["data"][index][1]}",
//                                                       style: TextStyle(
//                                                         color: clueData["data"]
//                                                                         [index]
//                                                                     [2] !=
//                                                                 null
//                                                             ? Color(0xFF03A062)
//                                                             : Color(0xFFe1bc9c),
//                                                         fontSize: 20.0,
//                                                         fontFamily: 'Norwester',
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       "${clueData["data"][index][2]}",
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 20.0,
//                                                         fontFamily:
//                                                             'Montserrat',
//                                                       ),
//                                                     ),
//                                                     const SizedBox(
//                                                       height: 15.0,
//                                                     ),
//                                                     clueData["data"][index]
//                                                                 [4] !=
//                                                             null
//                                                         ? GestureDetector(
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                 context,
//                                                                 MaterialPageRoute(
//                                                                   builder:
//                                                                       (context) =>
//                                                                           FullScreenImage(
//                                                                     "https://${apiUrl}${clueData["data"][index][4]}",
//                                                                   ),
//                                                                 ),
//                                                               );
//                                                             },
//                                                             child:
//                                                                 Image.network(
//                                                               "https://${apiUrl}${clueData["data"][index][4]}",
//                                                               height: 200.0,
//                                                               fit: BoxFit.cover,
//                                                               loadingBuilder:
//                                                                   (BuildContext
//                                                                           context,
//                                                                       Widget
//                                                                           child,
//                                                                       ImageChunkEvent?
//                                                                           loadingProgress) {
//                                                                 if (loadingProgress ==
//                                                                     null) {
//                                                                   return child;
//                                                                 }
//                                                                 return Center(
//                                                                   child:
//                                                                       CircularProgressIndicator(
//                                                                     color: Color(
//                                                                         0xFFFF9e02),
//                                                                     value: loadingProgress.expectedTotalBytes !=
//                                                                             null
//                                                                         ? loadingProgress.cumulativeBytesLoaded /
//                                                                             loadingProgress.expectedTotalBytes!
//                                                                         : null,
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                                           )
//                                                         : Container(),
//                                                   ],
//                                                 )
//                                               : Text(
//                                                   clueData["data"][index][1],
//                                                   style: TextStyle(
//                                                       fontFamily: 'Norwester',
//                                                       color: clueData["data"]
//                                                                   [index][2] !=
//                                                               null
//                                                           ? Color(0xFF03A062)
//                                                           : Color(0xFFe1bc9c),
//                                                       fontSize: 20),
//                                                 ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                       ),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   color: Colors.black,
//                   child: const FittedBox(
//                     child: Text(
//                       "UNLOCKED CLUES",
//                       style: TextStyle(
//                           fontFamily: "Gotham",
//                           color: Color(0xFFFF9e02),
//                           fontSize: 35,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     // height: MediaQuery.of(context).size.height / 2.5,
//                     padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
//                     color: Colors.black,
//                     child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: const ScrollPhysics(),
//                         itemCount: unlockedClueData.length != null
//                             ? unlockedClueData["data"].length
//                             : 0,
//                         itemBuilder: (BuildContext context, int index) {
//                           if (unlockedClueData["data"][index][2] != null) {
//                             return Container(
//                               decoration: const BoxDecoration(
//                                   color: Color(0xFF000000),
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: Colors.black,
//                                         offset: Offset(2.0, 2.0),
//                                         blurRadius: 10.0,
//                                         spreadRadius: 1.0),
//                                     // BoxShadow(
//                                     //     color: Colors.white,
//                                     //     offset: Offset(-2.0, -2.0),
//                                     //     blurRadius: 10.0,
//                                     //     spreadRadius: 1.0),
//                                   ],
//                                   borderRadius: BorderRadius.only(
//                                       topRight: Radius.circular(20),
//                                       bottomRight: Radius.circular(20))),
//                               margin: const EdgeInsets.fromLTRB(0, 15, 30, 15),
//                               // padding: EdgeInsets.all(10),
//                               child: ClipRRect(
//                                 borderRadius: const BorderRadius.only(
//                                   topRight: Radius.circular(15.0),
//                                   bottomRight: Radius.circular(15.0),
//                                 ),
//                                 child: ListTile(
//                                   tileColor: Colors.white.withOpacity(0.2),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 5.0, horizontal: 15),
//                                   // leading: IconButton(
//                                   //   color: Color(0xFFa94064),
//                                   //   onPressed: () {},
//                                   //   icon: Icon(Icons.vpn_key),
//                                   // ),
//                                   title: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       Text(
//                                         "${unlockedClueData["data"][index][1]} \n",
//                                         style: TextStyle(
//                                             color: unlockedClueData["data"]
//                                                         [index][2] !=
//                                                     null
//                                                 ? Color(0xFF03A062)
//                                                 : Color(0xFFe1bc9c),
//                                             fontSize: 20,
//                                             fontFamily: 'Norwester'),
//                                       ),
//                                       Text(
//                                         "${unlockedClueData["data"][index][2]}",
//                                         style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 17,
//                                             fontFamily: 'Montserrat'),
//                                       ),
//                                       const SizedBox(
//                                         height: 15.0,
//                                       ),
//                                       unlockedClueData["data"][index][4] != null
//                                           ? GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         FullScreenImage(
//                                                       "https://${apiUrl}${unlockedClueData["data"][index][4]}",
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               child: Image.network(
//                                                 "https://${apiUrl}${unlockedClueData["data"][index][4]}",
//                                                 height: 200.0,
//                                                 fit: BoxFit.cover,
//                                                 loadingBuilder:
//                                                     (BuildContext context,
//                                                         Widget child,
//                                                         ImageChunkEvent?
//                                                             loadingProgress) {
//                                                   if (loadingProgress == null) {
//                                                     return child;
//                                                   }
//                                                   return Center(
//                                                     child:
//                                                         CircularProgressIndicator(
//                                                       color: Color(0xFFFF9e02),
//                                                       value: loadingProgress
//                                                                   .expectedTotalBytes !=
//                                                               null
//                                                           ? loadingProgress
//                                                                   .cumulativeBytesLoaded /
//                                                               loadingProgress
//                                                                   .expectedTotalBytes!
//                                                           : null,
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             )
//                                           : Container(),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           } else {
//                             return Container();
//                           }
//                         }),
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future getCurrentLocation() async {
//       while (true) {
//         LocationPermission permission = await Geolocator.checkPermission();
//         if (permission == LocationPermission.denied ||
//             permission == LocationPermission.deniedForever) {
//           print("Location Permision Denied");
//           LocationPermission askPermission =
//               await Geolocator.requestPermission();
//         } else {
//           Position currentPosition = await Geolocator.getCurrentPosition(
//               desiredAccuracy: LocationAccuracy.high);
//           lat?.value = currentPosition.latitude;
//           long?.value = currentPosition.longitude;
//           for (int i = 0; i < _markers.length; i++) {
//             if (_markers[i].markerId == MarkerId("start")) {
//               _markers.removeAt(i);
//             }
//           }
//           BitmapDescriptor.fromAssetImage(
//                   ImageConfiguration(devicePixelRatio: 2.5),
//                   'assets/detective.png')
//               .then((pin) {
//             _markers.add(
//               Marker(
//                   markerId: MarkerId(
//                     "start",
//                   ),
//                   position: LatLng(lat!.value, long!.value),
//                   consumeTapEvents: true,
//                   infoWindow: InfoWindow(
//                       title:
//                           "${LatLng(lat!.value, long!.value).latitude}°N,  ${LatLng(lat!.value, long!.value).longitude}°E"),
//                   icon: pin),
//             );
//           });
//         }
//         print("MARKER ${_markers.length}");
//         await Future.delayed(Duration(seconds: 15));
//       }
//     }

//     getCurrentLocation();
//     print(lat!.value.toString() + "sjjssgds");
//     var deviceSize = MediaQuery.of(context).size;

// //animation using animatedpositioned. mean position toggle values
//     double bottom = _isUp ? 30.0 : (deviceSize.height / 2);
//     double top = _isUp
//         ? (_isOpen ? deviceSize.height / 4 : (deviceSize.height * 7 / 9))
//         : bottom;
//     double top2 =
//         _isUpLeaderBoard ? (deviceSize.height) : ((deviceSize.height) / 2) + 10;
//     var bottom3 =
//         _isUpInstructions ? deviceSize.height : ((deviceSize.height) / 2) + 10;
//     var bottom4 = _isUp ? 10.0 : deviceSize.height - 110;
//     var right4 = 20.0;

//     return levelData["level_no"] == 1 && intro == false
//         ? _isLoading
//             ? Container(
//                 color: Colors.white,
//                 height: MediaQuery.of(context).size.height,
//                 child: Image.asset("assets/loader1.gif"),
//               )
//             : Scaffold(
//                 body: Container(
//                   padding: const EdgeInsets.all(30),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF000000),
//                   ),
//                   child: Center(
//                     child: SafeArea(
//                       child: ListView(
//                         children: <Widget>[
//                           const Center(
//                             child: Text(
//                               "The Mystery",
//                               style: TextStyle(
//                                   fontFamily: 'Gotham',
//                                   color: Color.fromARGB(255, 255, 2, 2),
//                                   fontSize: 35),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           Text(
//                             mainQues["data"],
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontFamily: 'Montserrat',
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           // FlatButton(
//                           //   padding: const EdgeInsets.symmetric(vertical: 10.0),
//                           //   color: const Color(0xFFFF9e02),
//                           //   child: const Text(
//                           //     "PROCEED",
//                           //     style: TextStyle(
//                           //       fontFamily: 'Norwester',
//                           //       fontSize: 25.0,
//                           //       fontWeight: FontWeight.bold,
//                           //     ),
//                           //   ),
//                           //   onPressed: () {
//                           //     setState(() {
//                           //       intro = true;
//                           //       setIntro();
//                           //     });
//                           //   },
//                           // ),
//                           ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color.fromARGB(255, 255, 2, 2),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 10.0),
//                               ),
//                               child: const Text(
//                                 "PROCEED",
//                                 style: TextStyle(
//                                   fontFamily: 'Norwester',
//                                   fontSize: 25.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   intro = true;
//                                   setIntro();
//                                 });
//                               })
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//         : WillPopScope(
//             // ignore: missing_return
//             onWillPop: () {
//               SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//                   statusBarColor: Colors.transparent,
//                   statusBarIconBrightness: Brightness.light,
//                   systemNavigationBarIconBrightness: Brightness.dark));
//               Navigator.pop(context);
//               throw ();
//             },
//             child: SafeArea(
//               child: InnerDrawer(
//                 key: _innerDrawerKey,
//                 onTapClose: true, // default false
//                 swipe: true, // default true
//                 colorTransition:
//                     const Color(0xFF87ceeb), // default Color.black54

//                 // DEPRECATED: use offset
//                 leftOffset: 0.3, // Will be removed in 0.6.0 version
//                 // rightOffset: 0.6, // Will be removed in 0.6.0 version

//                 //When setting the vertical offset, be sure to use only top or bottom
//                 offset: IDOffset.only(bottom: 0.2, right: 0.5, left: 0.5),

//                 // DEPRECATED:  use scale
//                 leftScale: 0.9, // Will be removed in 0.6.0 version
//                 rightScale: 0.9, // Will be removed in 0.6.0 version

//                 scale: IDOffset.horizontal(
//                     0.8), // set the offset in both directions

//                 proportionalChildArea: true, // default true
//                 borderRadius: 50, // default 0
//                 leftAnimationType:
//                     InnerDrawerAnimation.static, // default static
//                 rightAnimationType: InnerDrawerAnimation.quadratic,

//                 // Color(0xFFa94064).withOpacity(0.8),
//                 // Color(0xFF191970).withOpacity(0.7)
//                 backgroundColor: const Color(0xFF000000),

//                 onDragUpdate: (double val, InnerDrawerDirection direction) {
//                   print(val);
//                   print(direction == InnerDrawerDirection.start);
//                 },
//                 innerDrawerCallback: (a) {
//                   _animationController!.value == 0
//                       ? _animationController!.forward()
//                       : _animationController!.reverse();
//                 },
//                 leftChild: Container(
//                   color: Colors.white.withOpacity(0),
//                   child: _isLoading ? Container() : drawerClues(),
//                 ),

//                 scaffold: Scaffold(
//                   key: _scaffoldKey,
//                   resizeToAvoidBottomInset: false,

//                   // drawer: AppBar(automaticallyImplyLeading: false,),
//                   body: Stack(
//                     children: <Widget>[
//                       GameMap(
//                         isUp: _isUp,
//                         correctLocations: [],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(15),
//                         child: IconButton(
//                           iconSize: 35,
//                           onPressed: () {
//                             _toggle();
//                             _animationController!.value == 1
//                                 ? _animationController!.forward()
//                                 : _animationController!.reverse();
//                           },
//                           icon: AnimatedIcon(
//                               color: Color(0xFF420000),
//                               progress: _animationController!.view,
//                               icon: AnimatedIcons.menu_close),
//                         ),
//                       ), //google map as main background of the app
//                       AnimatedPositioned(
//                         //top instructions panel
//                         bottom: bottom3,
//                         right: 0.0,
//                         left: 0.0,
//                         top: -15.0,
//                         duration: const Duration(milliseconds: 900),
//                         curve: Curves.easeOutQuart,
//                         child: Center(
//                           child: AnimatedOpacity(
//                             duration: const Duration(milliseconds: 900),
//                             curve: Curves.easeOutQuart,
//                             opacity: _isUpInstructions ? 0.5 : 0.8,
//                             child: Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: Color.fromARGB(255, 0, 47, 65)
//                                     .withOpacity(0.99),
//                                 // boxShadow: [
//                                 //   BoxShadow(
//                                 //       color: Colors.black.withOpacity(0.5),
//                                 //       offset: Offset.zero,
//                                 //       blurRadius: 10,
//                                 //       spreadRadius: 5),
//                                 // ],
//                                 // gradient: LinearGradient(
//                                 //   begin: Alignment.topCenter,
//                                 //   end: Alignment.bottomCenter,
//                                 //   stops: [0.5, 0.8, 1.0],
//                                 //   colors: [
//                                 //     Colors.grey[900],
//                                 //     Colors.grey[600],
//                                 //     Colors.grey
//                                 //   ],
//                                 // ),
//                                 borderRadius: BorderRadius.circular(17),
//                               ),
//                               child: Container(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(10, 25, 10, 10),
//                                 alignment: Alignment.topLeft,
//                                 child: ListView(
//                                   children: <Widget>[
//                                     FittedBox(
//                                       child: const Text(
//                                         "INSTRUCTIONS",
//                                         style: const TextStyle(
//                                             fontFamily: 'Gotham',
//                                             color: Color(0xFFFF9e02),
//                                             fontSize: 40,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 15,
//                                     ),
//                                     Text(
//                                       "The rules of Journo Detective are as follows: \n\n\n 1) Participants need to solve a murder mystery with the help of an available storyline and clues provided to them.\n\n 2) Each level comprises of a clue to the identity of the killer, after which participant can move to the next level.\n\n 3) The location can be selected by dragging on the corresponding region on the map, following which a Marker is placed there. Once the Marker is placed, click on submit. If you are at the right location, you progress to the next level.\n\n 4) At every level, there will be a set of clues. You can unlock clues as you desire at a particular location.\n\n  5) The final level requires you to write the name of the criminal with a justification for the same.\n\n 6) The dynamic scoreboard will be based on the level a participant is at and the time he/she takes to reach there.\n\n 7) The final standing will be subjected to three parameters: The correct answer and justification, time taken and number of clues unlocked to come to a conclusion.",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: "Montserrat",
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 15,
//                                     ),
//                                     const Text(
//                                       "The Mystery",
//                                       style: TextStyle(
//                                           fontFamily: 'Gotham',
//                                           color: Color(0xFFFF9e02),
//                                           fontSize: 32.0),
//                                     ),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                                     _isLoading || mainQues == null
//                                         ? Container()
//                                         : Text(
//                                             mainQues["data"].toString(),
//                                             style: TextStyle(fontSize: 19),
//                                           ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       AnimatedPositioned(
//                         //level box displayed on home page
//                         bottom: bottom,
//                         right: 10.0,
//                         left: 10.0,
//                         top: top,
//                         duration: const Duration(milliseconds: 900),
//                         curve: Curves.bounceOut,
//                         child: Center(
//                           child: AnimatedOpacity(
//                             duration: const Duration(milliseconds: 900),
//                             curve: Curves.easeOutQuart,
//                             opacity: _isUp ? (_isOpen ? 1 : 0.8) : 0.0,
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _isOpen = !_isOpen;
//                                 });
//                               },
//                               child: OutlineGradientButton(
//                                 gradient: LinearGradient(colors: [
//                                   Colors.orange,
//                                   Colors.transparent,
//                                 ]),
//                                 padding: EdgeInsets.all(1.5),
//                                 corners: Corners(
//                                   bottomLeft: Radius.circular(17),
//                                   bottomRight: Radius.circular(17),
//                                   topLeft: Radius.circular(17),
//                                   topRight: Radius.circular(17),
//                                 ),
//                                 strokeWidth: 3,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(20),
//                                   decoration: BoxDecoration(
//                                     boxShadow: [
//                                       BoxShadow(
//                                           color: Colors.black.withOpacity(0.5),
//                                           offset: Offset.zero,
//                                           blurRadius: 10,
//                                           spreadRadius: 5),
//                                     ],
//                                     color: Color.fromRGBO(51, 130, 154, 0.75),
//                                     borderRadius: BorderRadius.circular(17),
//                                   ),
//                                   child: Stack(
//                                     children: <Widget>[
//                                       Positioned(
//                                         top: 0.0,
//                                         left: 0.0,
//                                         right: 0.0,
//                                         child: _isLoading
//                                             ? Container(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 20),
//                                                 child: const Center(
//                                                     child:
//                                                         CircularProgressIndicator(
//                                                   color: Color(0xFFFF9e02),
//                                                 )))
//                                             : levelData["level"] == "ALLDONE"
//                                                 ? const Center(
//                                                     child: Text(
//                                                       "Solve the mystery",
//                                                       style: TextStyle(
//                                                         fontFamily:
//                                                             'Mysterious',
//                                                         // fontWeight:
//                                                         //     FontWeight.bold,
//                                                         fontSize: 25.0,
//                                                       ),
//                                                     ),
//                                                   )
//                                                 : levelData["level"] ==
//                                                         "More Levels Coming Soon"
//                                                     ? const Center(
//                                                         child: Text(
//                                                             "More Levels Coming Soon"))
//                                                     : Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceEvenly,
//                                                         children: <Widget>[
//                                                           SingleChildScrollView(
//                                                             child: Text(
//                                                               "${levelData["title"]}  🚩",
//                                                               style: TextStyle(
//                                                                 fontFamily:
//                                                                     'Gotham',
//                                                                 color: _isOpen
//                                                                     ? const Color(
//                                                                         0xFFFF9e02)
//                                                                     : Colors
//                                                                         .white,
//                                                                 fontSize: 30.0,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 15,
//                                                           ),
//                                                           Text(
//                                                             "Level: ${levelData["level_no"]}",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize: 17,
//                                                               fontFamily:
//                                                                   "LemonMilk",
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           )
//                                                         ],
//                                                       ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       _isLoading
//                           ? Container(
//                               // padding: EdgeInsets.only(right: 20),
//                               // child: CircularProgressIndicator(),
//                               )
//                           : AnimatedPositioned(
//                               //question along with textfield for answer and submit button
//                               top: _isOpen && _isUp
//                                   ? deviceSize.height / 2.5
//                                   : deviceSize.height + 5.0,
//                               bottom: _isOpen && _isUp ? 75.0 : -5.0,
//                               left: 20.0,
//                               right: 20.0,
//                               duration: const Duration(milliseconds: 900),
//                               curve: Curves.easeOutQuart,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   FocusScope.of(context)
//                                       .requestFocus(FocusNode());
//                                 },
//                                 child: Center(
//                                   child: ScrollConfiguration(
//                                     behavior: MyBehavior(),
//                                     child: levelData["level"] == "ALLDONE"
//                                         ? ListView(
//                                             children: <Widget>[
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       const Color(0xC0FF9e02),
//                                                   borderRadius:
//                                                       BorderRadius.circular(20),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 7,
//                                                         horizontal: 15),
//                                                 margin:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 10,
//                                                         horizontal: 10),
//                                                 child: Text(
//                                                   mainQues["data"].toString(),
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 17,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ),
//                                               _finalAnswerGiven != null &&
//                                                       _finalAnswerGiven
//                                                   ? Container()
//                                                   : _answerTextField(),
//                                               const SizedBox(
//                                                 height: 10,
//                                               ),
//                                               _finalAnswerGiven != null &&
//                                                       _finalAnswerGiven
//                                                   ? Center(
//                                                       child: Container(
//                                                         child: Text(
//                                                           "Final Answer Submitted",
//                                                           style: TextStyle(
//                                                             fontSize: 22.0,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   :
//                                                   // OutlineButton(
//                                                   //         borderSide:
//                                                   //             const BorderSide(
//                                                   //           color: Color(
//                                                   //               0xFFa94064), //Color of the border
//                                                   //           style: BorderStyle
//                                                   //               .solid, //Style of the border
//                                                   //           width:
//                                                   //               1, //width of the border
//                                                   //         ),
//                                                   //         color: const Color(
//                                                   //             0xFF0059B3),
//                                                   //         child: const Text(
//                                                   //           "SUBMIT ANSWER",
//                                                   //           style: TextStyle(
//                                                   //             fontFamily:
//                                                   //                 'Mysterious',
//                                                   //             // fontWeight:
//                                                   //             //     FontWeight.bold,
//                                                   //             fontSize: 20.0,
//                                                   //           ),
//                                                   //         ),
//                                                   //         onPressed: () {
//                                                   //           submitFinalAnswer(
//                                                   //               _answerFieldController
//                                                   //                   .value.text);
//                                                   //           _answerFieldController
//                                                   //               .clear();
//                                                   //         },
//                                                   //       ),
//                                                   OutlinedButton(
//                                                       onPressed: () {
//                                                         submitFinalAnswer(
//                                                             _answerFieldController
//                                                                 .value.text);
//                                                         _answerFieldController
//                                                             .clear();
//                                                       },
//                                                       child: const Text(
//                                                         "SUBMIT ANSWER",
//                                                         style: TextStyle(
//                                                           fontFamily:
//                                                               'Mysterious',
//                                                           // fontWeight:
//                                                           //     FontWeight.bold,
//                                                           fontSize: 20.0,
//                                                         ),
//                                                       ),
//                                                       style: OutlinedButton
//                                                           .styleFrom(
//                                                         foregroundColor:
//                                                             const Color(
//                                                                 0xFF0059B3),
//                                                         side: const BorderSide(
//                                                           color: Color(
//                                                               0xFFa94064), //Color of the border
//                                                           style: BorderStyle
//                                                               .solid, //Style of the border
//                                                           width:
//                                                               1, //width of the border
//                                                         ),
//                                                       ),
//                                                     )
//                                             ],
//                                           )
//                                         : ListView(
//                                             children: <Widget>[
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       const Color(0x3FFF9e02),
//                                                   borderRadius:
//                                                       BorderRadius.circular(20),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 7,
//                                                         horizontal: 15),
//                                                 margin:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 5,
//                                                         horizontal: 10),
//                                                 child: Text(
//                                                   '${levelData["ques"]}',
//                                                   style: TextStyle(
//                                                     color: _isOpen
//                                                         ? Colors.white
//                                                         : Colors.white,
//                                                     fontSize: 17,
//                                                     fontFamily: 'Montserrat',
//                                                   ),
//                                                 ),
//                                               ),
//                                               ListTile(
//                                                 // title: levelData["map_hint"]
//                                                 //     ?
//                                                 title: Center(
//                                                   child: Column(
//                                                     children: <Widget>[
//                                                       const SizedBox(
//                                                         height: 20,
//                                                       ),
//                                                       const FittedBox(
//                                                         child: Text(
//                                                           "YOUR CURRENT LOCATION",
//                                                           maxLines: 1,
//                                                           style: TextStyle(
//                                                             fontFamily:
//                                                                 'Gotham',
//                                                             color: Colors.white,
//                                                             fontSize: 300,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       const SizedBox(
//                                                         height: 20,
//                                                       ),
//                                                       ListTile(
//                                                         leading: const Icon(
//                                                           Icons
//                                                               .subdirectory_arrow_left,
//                                                           color:
//                                                               Color(0xFFff80a4),
//                                                         ),
//                                                         title: FittedBox(
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               const Text(
//                                                                 "LATITUDE:  ",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Color(
//                                                                       0xFFff80a4),
//                                                                   fontFamily:
//                                                                       "LemonMilk",
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 "${lat!.value == 0.0 ? 'Loading..' : lat!.value.toStringAsFixed(5) + ' °N'}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontFamily:
//                                                                       "LemonMilk",
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       ListTile(
//                                                         leading: const Icon(
//                                                           Icons
//                                                               .subdirectory_arrow_right,
//                                                           color:
//                                                               Color(0xFFff80a4),
//                                                         ),
//                                                         title: FittedBox(
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               const Text(
//                                                                 "LONGITUDE: ",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Color(
//                                                                       0xFFff80a4),
//                                                                   fontFamily:
//                                                                       "LemonMilk",
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 "${long!.value == 0.0 ? 'Loading..' : long!.value.toStringAsFixed(5) + ' °E'}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontFamily:
//                                                                       "LemonMilk",
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 20.0),
//                                                 child: ButtonBar(
//                                                   alignment: MainAxisAlignment
//                                                       .spaceEvenly,
//                                                   children: [
//                                                     TextButton(
//                                                       style: ButtonStyle(
//                                                           padding:
//                                                               MaterialStateProperty
//                                                                   .all(EdgeInsets
//                                                                       .all(12)),
//                                                           shape: MaterialStateProperty.all(
//                                                               RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                           12))),
//                                                           backgroundColor:
//                                                               MaterialStateProperty
//                                                                   .all(Color(
//                                                                       0xFF1178d8))),
//                                                       child: const Text(
//                                                         "GET CLUES",
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: 'Gotham',
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 22.0,
//                                                         ),
//                                                       ),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           _toggle();
//                                                         });
//                                                       },
//                                                     ),
//                                                     // borderSide:
//                                                     //       const BorderSide(
//                                                     //     color: Color(
//                                                     //         0xFF03A062), //Color of the border
//                                                     //     style: BorderStyle
//                                                     //         .solid, //Style of the border
//                                                     //     width:
//                                                     //         1, //width of the border
//                                                     //   ),
//                                                     TextButton(
//                                                       style: ButtonStyle(
//                                                           padding:
//                                                               MaterialStateProperty
//                                                                   .all(EdgeInsets
//                                                                       .all(12)),
//                                                           shape: MaterialStateProperty.all(
//                                                               RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                           12))),
//                                                           backgroundColor:
//                                                               MaterialStateProperty
//                                                                   .all(Color(
//                                                                       0xFF128000))),
//                                                       child: const Text(
//                                                         "SUBMIT",
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: 'Gotham',
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 22.0,
//                                                         ),
//                                                       ),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           submitLocation().then(
//                                                               (onValue) =>
//                                                                   getCorrectLocations());
//                                                         });
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       AnimatedPositioned(
//                         //leaderboard generated dynamically using listview.builder
//                         bottom: -15.0,
//                         right: 0.0,
//                         left: 0.0,
//                         top: top2,
//                         duration: const Duration(milliseconds: 900),
//                         curve: Curves.easeOutQuart,
//                         child: Center(
//                           child: AnimatedOpacity(
//                             duration: const Duration(milliseconds: 900),
//                             curve: Curves.easeOutQuart,
//                             opacity: _isUpLeaderBoard ? 0.8 : 1,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 15, horizontal: 20),
//                               decoration: BoxDecoration(
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: Colors.black.withOpacity(0.5),
//                                       offset: Offset.zero,
//                                       blurRadius: 10,
//                                       spreadRadius: 5),
//                                 ],
//                                 color: Color.fromARGB(255, 4, 133, 156)
//                                     .withOpacity(0.7),
//                                 // gradient: LinearGradient(
//                                 //   begin: Alignment.topCenter,
//                                 //   end: Alignment.bottomCenter,
//                                 //   stops: [0.3, 1.0],
//                                 //   // Color(0xFFa94064).withOpacity(0.8),
//                                 //   // Color(0xFF191970).withOpacity(0.7)
//                                 //   // Color(0xFF0091FF), Color(0xFF0059FF)
//                                 //   colors: [
//                                 //     Color(0xFF191970),
//                                 //     Color(0xFFa94064),
//                                 //   ],
//                                 // ),
//                                 borderRadius: BorderRadius.circular(17),
//                               ),
//                               child: ListView.builder(
//                                 itemCount: leaderboard == null
//                                     ? 0
//                                     : leaderboard.length + 2,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   if (index == 0) {
//                                     return Center(
//                                       child: FittedBox(
//                                         child: Text(
//                                           "LEADERBOARD",
//                                           style: TextStyle(
//                                             fontFamily: "Gotham",
//                                             fontSize: 36.0,
//                                             color: _isUp
//                                                 ? Colors.white
//                                                 : const Color(0xFFFF9e02),
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   } else if (index == 1) {
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 10.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: const <Widget>[
//                                           // SizedBox(width: 40),

//                                           Text(
//                                             "NAME",
//                                             style: TextStyle(
//                                                 fontFamily: 'Gotham',
//                                                 fontSize: 23,
//                                                 color: Color(0xFFe1bc9c)),
//                                           ),
//                                           Text(
//                                             "LEVEL",
//                                             style: TextStyle(
//                                                 fontFamily: 'Gotham',
//                                                 fontSize: 23,
//                                                 color: Color(0xFFe1bc9c)),
//                                           )
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     return Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         FittedBox(
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: <Widget>[
//                                               Text(
//                                                 "${index - 1}." +
//                                                     getSpaces(index - 1),
//                                                 style: TextStyle(
//                                                   fontSize: 23,
//                                                   fontFamily: 'Bebas',
//                                                 ),
//                                               ),
//                                               const SizedBox(
//                                                 width: 20,
//                                               ),
//                                               Text(
//                                                 leaderboard[index - 2]["name"],
//                                                 style: TextStyle(
//                                                   fontSize: 23,
//                                                   fontFamily: "Bebas",
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Text(
//                                           "${leaderboard[index - 2]["current_level"]}         ",
//                                           style: TextStyle(
//                                             fontSize: 23,
//                                             fontFamily: 'Bebas',
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // AnimatedPositioned(
//                       //   //leaderboard icon that triggers animation
//                       //   bottom: deviceSize.height - top2 - 25,
//                       //   left: 20,
//                       //   top: top2 - 35,
//                       //   duration: Duration(milliseconds: 1200),
//                       //   curve: Curves.easeOutQuart,
//                       //   child: GestureDetector(
//                       //     onVerticalDragStart: (context) {
//                       //       setState(() {
//                       //         _isUp = !_isUp;
//                       //         // getScoreboard();
//                       //       });
//                       //     },
//                       //     child: Icon(
//                       //       Icons.assessment,
//                       //       color: Colors.white,
//                       //       size: 50,
//                       //     ),
//                       //   ),
//                       // ),
//                       // AnimatedPositioned(
//                       //   //info icon that triggers animation
//                       //   bottom: bottom4,
//                       //   right: right4,
//                       //   duration: Duration(milliseconds: 1200),
//                       //   curve: Curves.easeOutQuart,
//                       //   child: GestureDetector(
//                       //     onTap: () {
//                       //       setState(() {
//                       //         print("he");
//                       //         _isUp = !_isUp;
//                       //         // getScoreboard();
//                       //       });
//                       //     },
//                       //     // onVerticalDragStart: (context) {
//                       //     //   setState(() {
//                       //     //     print("he");
//                       //     //     _isUp = !_isUp;
//                       //     //     getScoreboard();
//                       //     //   });
//                       //     // },
//                       //     child: Icon(
//                       //       Icons.info,
//                       //       color: Colors.white,
//                       //       size: 50,
//                       //     ),
//                       //   ),
//                       // ),
//                       Positioned(
//                         top: 25.0,
//                         right: 15.0,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 2.5),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF420000).withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           // height: 100.0,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     print("he");
//                                     _isUpInstructions = !_isUpInstructions;
//                                     getScoreboard();
//                                   });
//                                 },
//                                 child: Icon(
//                                   Icons.info,
//                                   color: Colors.white,
//                                   size: 40,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 20.0,
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     print("he");
//                                     _isUpLeaderBoard = !_isUpLeaderBoard;
//                                     getScoreboard();
//                                   });
//                                 },
//                                 child: const Icon(
//                                   Icons.assessment,
//                                   color: Colors.white,
//                                   size: 40,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//   }
// }

// class GameMap extends StatefulWidget {
//   bool isUp;
//   List<LatLng> correctLocations;

//   GameMap({Key? key, required this.isUp, required this.correctLocations})
//       : super(key: key);

//   @override
//   _GameMapState createState() => _GameMapState();
// }

// class _GameMapState extends State<GameMap> {
//   late BitmapDescriptor pinLocationIcon;
//   Completer<GoogleMapController> mapController = Completer();
//   final LatLng initialPosition = const LatLng(28.8283, 87.5795);

//   void updateCorrectLocationsMarkers() {
//     print("UPDATE");
//     print(widget.correctLocations);
//     BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
//             'assets/correct_detective.png')
//         .then((pin) {
//       for (int i = 0; i < widget.correctLocations.length; i++) {
//         _markers.add(Marker(
//             markerId: MarkerId(
//               "Correct Location $i",
//             ),
//             position: widget.correctLocations[i],
//             icon: pin));
//       }
//     });
//   }

//   void initState() {
//     updateCorrectLocationsMarkers();
//     updateMap.addListener(listenerFunction);
//     super.initState();
//   }

//   void listenerFunction() async {
//     print("Listener Working");
//     if (updateMap.value) {
//       print("Listener true");
//       (await mapController.future).animateCamera(CameraUpdate.newCameraPosition(
//           CameraPosition(target: initialPosition, zoom: mapZoom)));
//       updateMap.value = false;
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("LOCATIONS PASSED");
//     print(widget.correctLocations);

//     return Stack(
//       children: [
//         GoogleMap(
//           myLocationButtonEnabled: true,
//           initialCameraPosition: CameraPosition(
//             target: initialPosition,
//             zoom: mapZoom,
//           ),
//           markers: Set.from(_markers),
//           onMapCreated: _onMapCreated,
//           myLocationEnabled: false,
//           compassEnabled: false,
//           zoomControlsEnabled: true,
//         ),
//         AnimatedPositioned(
//           duration: Duration(milliseconds: 500),
//           width: 0.5 * MediaQuery.of(context).size.width,
//           height: 0.15 * MediaQuery.of(context).size.width,
//           left: 0.25 * (MediaQuery.of(context).size.width),
//           top: (!widget.isUp)
//               ? -0.3 * MediaQuery.of(context).size.width
//               : 0.1 * (MediaQuery.of(context).size.height),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(
//                   0.15 * MediaQuery.of(context).size.width),
//               color: Color(0xFF420000).withOpacity(0.7),
//             ),
//             child: Center(
//               child: FittedBox(
//                 child: Text(
//                   "${lat!.value.toStringAsFixed(3)}°N,  ${long!.value.toStringAsFixed(3)}°E",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         AnimatedPositioned(
//           duration: Duration(milliseconds: 500),
//           right: (!widget.isUp)
//               ? -0.2 * MediaQuery.of(context).size.width
//               : MediaQuery.of(context).size.width * 0.01,
//           bottom: MediaQuery.of(context).size.height * 0.5,
//           width: 0.15 * MediaQuery.of(context).size.width,
//           height: 0.15 * MediaQuery.of(context).size.width,
//           child: GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: () async {
//               (await mapController.future).animateCamera(
//                 CameraUpdate.newCameraPosition(
//                   CameraPosition(
//                       target: LatLng(lat!.value, long!.value), zoom: mapZoom),
//                 ),
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(
//                     0.15 * MediaQuery.of(context).size.width),
//                 color: Color(0xFF420000).withOpacity(0.7),
//               ),
//               child: const Center(
//                 child: Text(
//                   "R",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   void _setStyle(GoogleMapController controller) async {
//     String value = await DefaultAssetBundle.of(context)
//         .loadString('assets/maps_style.json');
//     controller.setMapStyle(value);
//   }

//   _onMapCreated(GoogleMapController controller) {
//     setState(() {
//       _setStyle(controller);
//       mapController.complete(controller);
//     });
//   }
// }

// class MyBehavior extends ScrollBehavior {
//   @override
//   Widget buildViewportChrome(
//       BuildContext context, Widget child, AxisDirection axisDirection) {
//     return child;
//   }
// }
