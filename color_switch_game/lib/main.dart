import 'package:color_switch_game/my_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const HomePage(),
    theme: ThemeData.dark()
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late MyGame _myGame;

  @override
  void initState() {
    _myGame = MyGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _myGame), 
          if(_myGame.isGamePlaying)
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _myGame.pauseGame();                    
                    });
                  }, 
                  icon: const Icon(Icons.pause)
                ),
              )
              ),            
            Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder(valueListenable: _myGame.currentScore, builder: (context, value, child) {
                  return 
                  Text(
                    value.toString(), style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ));
                })
            ),
          if(_myGame.isGamePaused)
            Container( 
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PAUSED!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: IconButton(onPressed: () {
                        setState(() {
                          _myGame.resumeGame();
                        });
                      }, icon: const Icon(Icons.play_arrow, size: 140))
                    )                    
                  ]
                )
              )
            )
        ],
      )
    );
  }
}




