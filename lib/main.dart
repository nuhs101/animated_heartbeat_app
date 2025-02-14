// Gabe Rawlings grawlings2@student.gsu.edu
// Nuh Shekhey nshekhey1@student.gsu.edu
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(HeartBeatApp());
}

// Main app widget
class HeartBeatApp extends StatelessWidget {
  const HeartBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeartbeatScreen(),
    );
  }
}

// Heartbeat screen widget
class HeartbeatScreen extends StatefulWidget {
  const HeartbeatScreen({super.key});

  @override
  State<HeartbeatScreen> createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final Random _random = Random();
  final List<Offset> _balloons = [];
  int _seconds = 25; // Timer set to 25 seconds
  late Timer _countdownTimer;
  bool _timerRunning = true;
  String _customMessage = "";
  int _greetingIndex = 0;
  final List<String> _greetings = [
    "Happy Valentine's Day!",
    "I ❤️ You!",
    "My favroite person! 😍",
    "Bee mine! 🐝",
    "I love you the most! 💕"
  ];

  @override
  void initState() {
    super.initState();

    // Heartbeat animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Balloon generation
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _balloons.add(Offset(_random.nextDouble() * 400, 600));
      });
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _countdownTimer.cancel();
        setState(() {
          _timerRunning = false;
          _controller.stop(); // Stop the heartbeat animation
        });
      }
    });

    // Rotate greetings every 3 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _greetingIndex = (_greetingIndex + 1) % _greetings.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  void _addCustomMessage(String message) {
    setState(() {
      _customMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heartbeat animation
                if (_timerRunning)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 100,
                        ),
                      );
                    },
                  )
                else
                  Icon(
                    Icons.favorite,
                    color: Colors.red.shade300,
                    size: 100,
                  ),
                SizedBox(height: 20),
                // Countdown timer display
                Text(
                  _timerRunning ? "Time Left: $_seconds sec" : "Time's up!",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Valentine's Day greeting
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(seconds: 1),
                  child: Text(
                    _customMessage.isNotEmpty
                        ? _customMessage
                        : _greetings[_greetingIndex],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                // Add Custom Message Button
                ElevatedButton(
                  onPressed: () {
                    _showGreetingSelectionDialog(context);
                  },
                  child: Text("Add a Custom Message"),
                ),
              ],
            ),
          ),
          // Floating balloons
          ..._balloons.map((position) => AnimatedBalloon(position)),
        ],
      ),
    );
  }

  void _showGreetingSelectionDialog(BuildContext context) {
    TextEditingController customMessageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Greeting"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // List of pre-written greetings
                ..._greetings.map((greeting) {
                  return ListTile(
                    title: Text(greeting),
                    onTap: () {
                      _addCustomMessage(greeting);
                      Navigator.pop(context);
                    },
                  );
                }),
                SizedBox(height: 10),
                // Custom message input
                TextField(
                  controller: customMessageController,
                  decoration: InputDecoration(
                    hintText: "Enter your own message...",
                  ),
                ),
                SizedBox(height: 10),
                // Button to add custom message
                ElevatedButton(
                  onPressed: () {
                    if (customMessageController.text.isNotEmpty) {
                      _addCustomMessage(customMessageController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add Custom Message"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Floating balloons widget
class AnimatedBalloon extends StatefulWidget {
  final Offset startPosition;
  const AnimatedBalloon(this.startPosition, {super.key});

  @override
  State<AnimatedBalloon> createState() => _AnimatedBalloonState();
}

class _AnimatedBalloonState extends State<AnimatedBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _moveAnimation = Tween<double>(begin: widget.startPosition.dy, end: 0)
        .animate(_controller);
    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    _controller.forward().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx,
          top: _moveAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 30,
            ),
          ),
        );
      },
    );
  }
}
