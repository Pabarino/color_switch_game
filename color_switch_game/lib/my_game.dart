import 'package:color_switch_game/circle_rotator.dart';
import 'package:color_switch_game/color_switcher.dart';
import 'package:color_switch_game/ground.dart';
import 'package:color_switch_game/player.dart';
import 'package:color_switch_game/star_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class MyGame extends FlameGame with TapCallbacks, HasCollisionDetection, HasDecorator, HasTimeScale {
  late Player myPlayer;

  final List<Color> GameColors;

  final ValueNotifier<int> currentScore = ValueNotifier(0);

  MyGame({this.GameColors = const [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.blueAccent
  ]})
      : super(
            camera:
                CameraComponent.withFixedResolution(width: 600, height: 1000));

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  void onLoad() {
    decorator = PaintDecorator.blur(0);
    super.onLoad();
  }

  @override
  void onMount() {
    _initializaGame();
    //debugMode = true;
    super.onMount();
  }

  @override
  void update(double dt) {
    final cameraY = camera.viewfinder.position.y;
    final playerY = myPlayer.position.y;

    if (playerY < cameraY) {
      camera.viewfinder.position = Vector2(0, playerY); 
    }

    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    print('onTapDown()');
    myPlayer.jump();
    super.onTapDown(event);
  }

  _initializaGame() {
    currentScore.value = 0;
    world.add(Ground(position: Vector2(0, 400)));
    world.add(myPlayer = Player(position: Vector2(0, 250)));
    camera.moveTo(Vector2(0, 0));
    _generateGameComponents() ;
  }

  void _generateGameComponents(){ 
    world.add(ColorSwitcher(position: Vector2(0, 200))); 
    world.add(CircleRotator(position: Vector2(0,0), size: Vector2.all(200)));
    world.add(StarComponent(position: Vector2(0, 0))); 

    world.add(ColorSwitcher(position: Vector2(0, -200))); 
    world.add(CircleRotator(position: Vector2(0,-400), size: Vector2.all(150)));
    world.add(CircleRotator(position: Vector2(0,-400), size: Vector2.all(180)));
    world.add(StarComponent(position: Vector2(0, -400))); 
  }

  void gameOver() {
    for (var element in world.children) {element.removeFromParent();}
    _initializaGame();
  }

  bool get isGamePaused => timeScale == 0.0;
  bool get isGamePlaying => !isGamePaused;

  void pauseGame() {
    (decorator as PaintDecorator).addBlur(8);
    timeScale = 0.0;
  }

  void resumeGame() {
    (decorator as PaintDecorator).addBlur(0);
    timeScale = 1.0;
  }
  
  void increaseScore() {
    currentScore.value++;
  }
}
