import 'package:flutter/material.dart';
import 'package:practice/pages/Account_Setup_Page.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020C0E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Logo with motto
            Center(
              child: Image.asset(
                'assets/images/Logo&motto.png',
                width: 280,
                height: 230,
              ),
            ),

            const Spacer(flex: 5),

            // Glowing Button with ElevatedButton
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetupAccountPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromRGBO(68, 202, 233, 1),
                  padding: const EdgeInsets.all(18),
                  elevation: 10,
                  shadowColor:
                      const Color.fromRGBO(43, 169, 198, 1).withOpacity(0.6),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
