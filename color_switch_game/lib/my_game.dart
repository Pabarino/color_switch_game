import 'package:color_switch_game/player.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class MyGame extends FlameGame with TapCallbacks {
  late Player myPlayer;

  MyGame()
      : super(
            camera:
                CameraComponent.withFixedResolution(width: 600, height: 1000));

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  void onMount() {
    world.add(myPlayer = Player());
    world.add(RectangleComponent(position: Vector2(15, 15), size: Vector2.all(20)));
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
}
