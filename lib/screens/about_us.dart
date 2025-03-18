import 'dart:ui';

import 'package:aarohan_app/widgets/bottomMenu.dart';
import 'package:aarohan_app/widgets/custom_gesture_detector.dart';
import 'package:aarohan_app/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:from_css_color/from_css_color.dart';
import 'package:flutter/services.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool showBottomMenu = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double threshold = 100;
    return Sizer(
      builder: (context, orientation, deviceType) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.8,
                image: AssetImage(
                  "assets/aarhn_new_bg2k25.png",
                ),
                // colorFilter: new ColorFilter.mode(
                //     Color.fromARGB(177, 48, 17, 6), BlendMode.srcOver),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        topBar(
                          pageName: 'About Us',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 0),
                          child: Stack(
                            children: [
                              /// Blurred Background Container
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Optional rounded corners
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5), // Adjust blur intensity
                                  child: Container(
                                    height: 85.h,
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 230, 74, 13),
                                          width: 2 // Light translucent effect
                                          ),
                                      // Light translucent effect
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),

                              /// Text Content (Outside the Blur Effect)
                              Container(
                                //height: 70.h,
                                padding: EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  physics: ClampingScrollPhysics(),
                                  child: Text(
                                    "The National Institute of Technology, Durgapur has been a premier educational institute nurturing students who have achieved par excellence in the field of academics and extra-curricular activities.\n\nAarohan is the Annual Techno-management fest of NIT Durgapur, the 2nd Largest of its kind in the whole of eastern India. Organised by Team Aavishkar, comprising the five biggest technical clubs of NIT Durgapur, this festival has never failed to uphold the banner of talent, innovation and a sense of responsibility.\n\nWith more than 50 events on varied domains, Aarohan is the biggest platform of our college that inculcates a sense of knowledge, science and technology—the building blocks for the future pillars of our nation.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                      fontFamily: 'Poppins',
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
