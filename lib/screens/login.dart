import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:aarohan_app/services/auth_services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/login-bg-new.png"),
                        colorFilter: new ColorFilter.mode(
                            Color.fromARGB(61, 48, 17, 6), BlendMode.srcOver),
                        fit: BoxFit.fill),
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 140,
                              backgroundImage:
                                  AssetImage('assets/aarhn-logo-bg-new.png'),
                            ),
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: AssetImage(
                                'assets/aarohan-logo.png',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Aarohan',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 60,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'By Team Aavishkar',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      GestureDetector(
                        onTap: () async {
                          AuthService authService = AuthService();
                          authService.gSignIn().then(
                            (value) {
                              if (value != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                print("error in Signin");
                              }
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                          child: Container(
                            width: 65.w,
                            height: 7.h,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 101, 170,
                                      254), // rgba(101, 171, 254, 0.32),
                                  width: 1,
                                ),
                                color: Color.fromRGBO(
                                  101,
                                  171,
                                  254,
                                  0.32,
                                ),
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Image(
                                      image: AssetImage(
                                        'assets/google-new-1.png',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Sign In With Google',
                                    style: TextStyle(
                                      fontFamily: 'Staat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 21,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
