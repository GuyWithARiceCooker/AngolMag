// import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';
// import 'package:flutter_reactive_value/flutter_reactive_value.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyPageWidget(),
//     );
//   }
// }

// final customtext = ReactiveValueNotifier<String>('from clear to blurred');

// class MyPageWidget extends StatefulWidget {
//   const MyPageWidget({super.key});
//   @override
//   State<MyPageWidget> createState() => _MyPageWidgetState();
// }

// class _MyPageWidgetState extends State<MyPageWidget> {
//   final _random = Random();
//   final _listStrings = <String>[
//     'first',
//     'second',
//     'Third',
//     'Fourth',
//     'Fifth',
//   ];

//   void _onChange() {
//     customtext.value = _listStrings[_random.nextInt(_listStrings.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimationThingy(text: customtext.reactiveValue(context)),
//               OutlinedButton(
//                   onPressed: _onChange,
//                   child:
//                       const Text('new value', style: TextStyle(fontSize: 14))),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class AnimationThingy extends StatefulWidget {
  const AnimationThingy({super.key, required this.text});
  final String text;
  @override
  State<StatefulWidget> createState() => _AnimationThingyState();
}

class _AnimationThingyState extends State<AnimationThingy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3500));
    _animation = Tween<double>(begin: 20, end: 0).animate(_controller);
    _onAnimate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimationThingy oldWidget) {
    if (widget.text != oldWidget.text) {
      _onAnimate();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onAnimate() async {
    if (_controller.isDismissed) {
      await _controller.forward();
    } else {
      _controller.reset();
      await _controller.forward();
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, __) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: _animation.value,
            sigmaY: _animation.value,
          ),
          child: Text(widget.text, style: const TextStyle(fontSize: 30)),
        );
      },
    );
  }
}
