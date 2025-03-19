import 'package:aarohan_app/widgets/splash-rotating-bg.dart';
import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:sizer/sizer.dart';
import 'package:aarohan_app/services/auth_services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;

  void _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();
    authService.gSignIn().then(
      (value) {
        setState(() {
          _isLoading = false;
        });

        if (value != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print("error in Signin");
        }
      },
    );
  }

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
                      image: AssetImage("assets/aarhn-splash2k25.png"),
                      colorFilter: ColorFilter.mode(
                          Color.fromARGB(40, 0, 5, 26), BlendMode.srcOver),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox(
                        height: 3.7.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // RotatingImage(
                            //   imagePath: 'assets/aarhn-logo-bg-new-outer.png',
                            // ),
                            // RotatingImage(
                            //   reverse: true,
                            //   imagePath: 'assets/aarhn-logo-bg-new-inner.png',
                            // ),
                            CircleAvatar(
                              radius: 28.5.w,
                              backgroundImage: AssetImage(
                                'assets/aarhn_logo2k25.png',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/aarhn25-text.png',
                          height: 50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'By Team Aavishkar',
                          style: TextStyle(
                            fontFamily: 'Bayon',
                            fontSize: 25,
                            color: Color(0xFFACB9C9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        width: 75.w,
                        height: 7.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(186, 47, 117, 138),
                              Color.fromARGB(181, 2, 54, 71),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: OutlineGradientButton(
                          onTap: _isLoading
                              ? null
                              : _handleSignIn, // Disable button if loading
                          strokeWidth: 2,
                          radius: Radius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white12,
                              Color.fromARGB(255, 251, 71, 10),
                            ],
                          ),
                          child: _isLoading
                              ? Center(
                                  child:
                                      LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.deepOrangeAccent,
                                    size: 40,
                                  ),
                                )
                              : Row(
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
