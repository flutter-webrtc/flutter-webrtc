import 'package:flutter/material.dart';

class CenterButton extends StatelessWidget {
  const CenterButton({
    Key? key,
    this.showing = true,
    this.active = false,
    required this.icon,
    required this.activeIcon,
    this.onPressed,
    this.size = const Size.square(50),
    this.backgroundColor = Colors.transparent,
    this.expand = false,
    this.expandScale = 1.5,
    this.borderWidth = 1.0,
    this.borderEnabled = true,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final bool showing, active;
  final Size size;
  final Widget icon, activeIcon;
  final bool expand;
  final double expandScale;
  final double borderWidth;
  final bool borderEnabled;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: showing ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: expand ? size.width * expandScale : size.width,
            height: expand ? size.height * expandScale : size.width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(
                color: Colors.white,
                width: borderWidth,
                style: borderEnabled ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: Center(
              child: active ? activeIcon : icon,
            ),
          ),
        ),
      ),
    );
  }

  factory CenterButton.ptz({
    bool active = false,
    bool showing = false,
    VoidCallback? onPressed,
    double iconSize = 30,
    Color iconColor = Colors.white,
    Size size = const Size.square(50),
    Color backgroundColor = Colors.transparent,
    bool expand = false,
    double expandScale = 1.5,
    double borderWidth = 1.0,
    bool borderEnabled = true,
  }) {
    return CenterButton(
      showing: showing,
      active: active,
      onPressed: onPressed,
      icon: Icon(
        Icons.control_camera,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      activeIcon: Icon(
        Icons.control_camera,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      size: size,
      expand: expand,
      expandScale: expandScale,
      borderWidth: borderWidth,
      borderEnabled: borderEnabled,
      backgroundColor: backgroundColor,
    );
  }

  factory CenterButton.playPause({
    bool active = false,
    bool showing = false,
    VoidCallback? onPressed,
    double iconSize = 30,
    Color iconColor = Colors.white,
    Size size = const Size.square(50),
    Color backgroundColor = Colors.transparent,
    bool expand = false,
    double expandScale = 1.5,
    double borderWidth = 1.0,
    bool borderEnabled = true,
  }) {
    return CenterButton(
      showing: showing,
      active: active,
      onPressed: onPressed,
      icon: Icon(
        Icons.play_arrow,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      activeIcon: Icon(
        Icons.pause,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      size: size,
      expand: expand,
      expandScale: expandScale,
      borderWidth: borderWidth,
      borderEnabled: borderEnabled,
      backgroundColor: backgroundColor,
    );
  }

  factory CenterButton.fullExist({
    bool active = false,
    bool showing = false,
    VoidCallback? onPressed,
    double iconSize = 30,
    Color iconColor = Colors.white,
    Size size = const Size.square(50),
    Color backgroundColor = Colors.transparent,
    bool expand = false,
    double expandScale = 1.5,
    double borderWidth = 1.0,
    bool borderEnabled = true,
  }) {
    return CenterButton(
      showing: showing,
      active: active,
      onPressed: onPressed,
      icon: Icon(
        Icons.fullscreen,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      activeIcon: Icon(
        Icons.fullscreen_exit,
        color: iconColor,
        size: expand ? iconSize * expandScale : iconSize,
      ),
      size: size,
      expand: expand,
      expandScale: expandScale,
      borderWidth: borderWidth,
      borderEnabled: borderEnabled,
      backgroundColor: backgroundColor,
    );
  }

  factory CenterButton.image({
    required Widget image,
    Widget? activeImage,
    bool active = false,
    bool showing = true,
    VoidCallback? onPressed,
    Size size = const Size.square(50),
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.transparent,
    bool expand = false,
    double expandScale = 1.5,
    double borderWidth = 1.0,
    bool borderEnabled = false,
  }) {
    return CenterButton(
      showing: showing,
      active: active,
      onPressed: onPressed,
      size: size,
      icon: image,
      activeIcon: activeImage ?? image,
      expand: expand,
      expandScale: expandScale,
      borderWidth: borderWidth,
      borderEnabled: borderEnabled,
      backgroundColor: backgroundColor,
    );
  }

  factory CenterButton.rectangle({
    required Widget text,
    bool active = false,
    bool showing = true,
    VoidCallback? onPressed,
    Size size = const Size.square(50),
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.transparent,
    bool expand = false,
    double expandScale = 1.5,
    double borderWidth = 1.0,
    bool borderEnabled = false,
  }) {
    return CenterButton(
      showing: showing,
      active: active,
      onPressed: onPressed,
      size: size,
      icon: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: iconColor,
        ),
        child: text,
      ),
      activeIcon: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: iconColor,
        ),
        child: text,
      ),
      expand: expand,
      expandScale: expandScale,
      borderWidth: borderWidth,
      borderEnabled: borderEnabled,
      backgroundColor: backgroundColor,
    );
  }
}
