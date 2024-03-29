import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

class topBar extends StatefulWidget {
  final String? pageName;

  const topBar({
    Key? key,
    this.pageName,
  }) : super(key: key);

  @override
  State<topBar> createState() => _topBarState();
}

class _topBarState extends State<topBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1.h,
        horizontal: 2.w,
      ),
      margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.5.w),
      alignment: Alignment.bottomCenter,
      height: 8.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Color.fromRGBO(25, 102, 154, 0.5),
        border: Border.all(
          color: Color.fromRGBO(101, 171, 254, 0.32),
          width: 0.5.w,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 1.h,
                  ),
                  child: Text(
                    widget.pageName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: Colors.white,
                      fontSize: 4.h,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: CircleAvatar(
                backgroundColor: Color.fromRGBO(142, 210, 255, 1),
                radius: 13.sp,
                // backgroundImage: AssetImage('assets/back.png'),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
