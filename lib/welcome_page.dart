import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:simplex/main.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252,235,211),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedTextKit(
              animatedTexts: [
              TyperAnimatedText('SOLVEPLEX',textStyle: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold), speed: const Duration(milliseconds: 200),),
            ],
            totalRepeatCount: 1,),
            const SizedBox(height: 10),
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('Resuelve problemas de programación lineal de manera eficiente con el método Simplex', textStyle: const TextStyle(fontSize: 18), speed: const Duration(milliseconds: 25),),
              ],
              totalRepeatCount: 1,  
            ),
            AnimatedTextKit(animatedTexts: [
              TyperAnimatedText(' '),
              TyperAnimatedText('Acelera tus resultados y maximiza tus recursos', textStyle: const TextStyle(fontSize: 18),speed: const Duration(milliseconds: 25),),
            ],
            totalRepeatCount: 1,
            pause: const Duration(seconds: 1),
            ),
            const SizedBox(height: 30),
            WidgetAnimator(
              incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(duration: const Duration(seconds: 2)),
              child: Image.asset('images/recursos.png', width: 200, height: 200)),
            const SizedBox(height: 40),
            WidgetAnimator(
              incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(duration: const Duration(seconds: 3)),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SimplexScreen()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 194,110,49)),
                  fixedSize: MaterialStateProperty.all<Size>(const Size(300, 40)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                  ),
              
                ),
                child: const Text('Iniciar', style: TextStyle(color: Colors.white, fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}