import 'package:color_switch_game/circle_rotator.dart';
import 'package:color_switch_game/color_switcher.dart';
import 'package:color_switch_game/ground.dart';
import 'package:color_switch_game/player.dart';
import 'package:color_switch_game/star_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class MyGame extends FlameGame with TapCallbacks, HasCollisionDetection, HasDecorator, HasTimeScale {
  late Player myPlayer;

  final List<Color> GameColors;

  final ValueNotifier<int> currentScore = ValueNotifier(0);

  final List<PositionComponent> _gameComponents = [];

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
  Future<void> onLoad() async{
    await super.onLoad();
    decorator = PaintDecorator.blur(0);
    FlameAudio.bgm.initialize();
    await Flame.images.loadAll(['finger_tap.png','star_icon.png']);
    await FlameAudio.audioCache.loadAll(['background.mp3','collect.wav']);
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
    //print('onTapDown()');
    myPlayer.jump();
    super.onTapDown(event);
  }

  void _addComponentToTheGame(PositionComponent component) {
    _gameComponents.add(component);
    world.add(component);
  }

  _initializaGame() {
    currentScore.value = 0;
    world.add(Ground(position: Vector2(0, 400)));
    world.add(myPlayer = Player(position: Vector2(0, 250)));
    camera.moveTo(Vector2(0, 0));
    _generateGameComponents(Vector2(0, 20));
    FlameAudio.bgm.play('background.mp3');
  }

  void _generateGameComponents(Vector2 generateFromPosition) {
    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition + Vector2(0, 180))); 
    _addComponentToTheGame(CircleRotator(position: generateFromPosition + Vector2(0,0), size: Vector2.all(200)));
    _addComponentToTheGame(StarComponent(position: generateFromPosition + Vector2(0,0)));

    generateFromPosition -= Vector2(0, 370);  

    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition + Vector2(0, 180))); 
    _addComponentToTheGame(CircleRotator(position: generateFromPosition + Vector2(0,0), size: Vector2.all(200)));
    _addComponentToTheGame(StarComponent(position: generateFromPosition + Vector2(0,0))); 

    generateFromPosition -= Vector2(0, 240);  

    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition + Vector2(0, 0))); 
    _addComponentToTheGame(CircleRotator(position: generateFromPosition + Vector2(0,-200), size: Vector2.all(150)));
    _addComponentToTheGame(CircleRotator(position: generateFromPosition + Vector2(0,-200), size: Vector2.all(180)));
    _addComponentToTheGame(StarComponent(position: generateFromPosition + Vector2(0, -200)));    
  }

  // void _generateGameComponents(){ 
  //   world.add(ColorSwitcher(position: Vector2(0, 200))); 
  //   world.add(CircleRotator(position: Vector2(0,0), size: Vector2.all(200)));
  //   world.add(StarComponent(position: Vector2(0, 0))); 

  //   world.add(ColorSwitcher(position: Vector2(0, -200))); 
  //   world.add(CircleRotator(position: Vector2(0,-400), size: Vector2.all(150)));
  //   world.add(CircleRotator(position: Vector2(0,-400), size: Vector2.all(180)));
  //   world.add(StarComponent(position: Vector2(0, -400))); 
  // }

  void gameOver() {
    FlameAudio.bgm.stop();
    for (var element in world.children) {element.removeFromParent();}
    _initializaGame();
  }

  bool get isGamePaused => timeScale == 0.0;
  bool get isGamePlaying => !isGamePaused;

  void pauseGame() {
    (decorator as PaintDecorator).addBlur(8);
    timeScale = 0.0;
    FlameAudio.bgm.pause();
  }

  void resumeGame() {
    (decorator as PaintDecorator).addBlur(0);
    timeScale = 1.0;
    FlameAudio.bgm.resume();
  }
  
  void increaseScore() {
    currentScore.value++;
  }

  void checkToGenerateNextBatch(StarComponent starComponent) {
    final allStarComponents = _gameComponents.whereType<StarComponent>().toList();
    final length = allStarComponents.length;
    for (int i = 0; i<length; i++) {
      if (starComponent == allStarComponents[i] && i >= length-2) {
        //Generate the next batch
        final lastStar = allStarComponents.last;
        _generateGameComponents(lastStar.position - Vector2(0,400));
        _tryToGarbageCollect(starComponent);
      }
    }
  }
  
  void _tryToGarbageCollect(StarComponent starComponent) {
    final length = _gameComponents.length;
    for (int i = 0; i<length; i++) {
      if (starComponent == _gameComponents[i] && i >= 15) {
        _removeComponentsFromGame(i-7);
        break;
      }
    }
  }

  void _removeComponentsFromGame (int n) {
    for(int i = n; i>=0;i--) {
      _gameComponents[i].removeFromParent();
      _gameComponents.removeAt(i);
    }
  }
}
