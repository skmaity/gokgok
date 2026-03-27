import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    """LoremIpsum360 ° is a free online generator false text. It provides a complete text simulator to generate replacement text or alternative text for your models. It features different random texts in Latin and Cyrillic to generate examples of texts in different languages.

LoremIpsum360 ° also gives you the ability to add punctuation marks, accents and special characters to be closer to the French or other languages. Also if you want to see the results in different fonts, you will find many features to set such as font-family, font-size, text-align or line-heigh.""",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
