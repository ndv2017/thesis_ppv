import 'package:flutter/material.dart';
import 'motor_tracker_screen.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( // Apply the gradient to this top-level Container
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Start the gradient from the top
            end: Alignment.bottomCenter, // End the gradient at the bottom
            colors: [
              Colors.white, // Start color (white at the top)
              Color.fromARGB(255, 173, 216, 230), // A light blue color (adjust as needed)
              // You can add more colors here for a multi-stop gradient
            ],
          ),
        ),
        child: Row(
          children: [
            // Left side: Image (70%)
            Expanded(
              flex: 7,
              child: Container(
                // You might want to remove this color if you want the gradient to show through
                // or if this image already has a transparent background
                color: Colors.transparent, // Changed to transparent
                child: Image.asset(
                  'assets/testbench_overview.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            // Right side: Content (30%)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // This container will implicitly inherit the gradient background
                  // from its parent. If you want a solid color here, you can add it back.
                  Container(color: Colors.transparent), // Ensure this part is transparent to see the gradient

                  // VION logo at top right
                  Positioned(
                    top: -12,
                    right: 4,
                    child: Image.asset('assets/logo_vion_nobg.png', width: 80, height: 80),
                  ),

                  // Main content (title, button, logos)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DC MOTOR TRACKER',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 3, 43, 145),
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => MotorTrackerScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Color.fromARGB(255, 20, 136, 219),
                          ),
                          child: Text(
                            'START',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 220, 233, 241),
                            ),
                          ),
                        ),
                        SizedBox(height: 80),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/logobk.png', width: 150, height: 150),
                            SizedBox(width: 30),
                            Image.asset('assets/logo_ppv_nobg.png', width: 150, height: 150),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}