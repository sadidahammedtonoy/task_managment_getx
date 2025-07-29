import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Const/assets.dart';

class background extends StatelessWidget {
  const background({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          AssetPaths.backgroundSvg,
          fit: BoxFit.cover,
          height: double.maxFinite,
          width: double.maxFinite,
        ),
        SafeArea(child: child),
      ],
    );
  }
}