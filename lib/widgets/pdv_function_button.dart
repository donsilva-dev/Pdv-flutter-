import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PdvFunctionButton extends StatelessWidget {
  static const double _iconSize = 36;
  static const double _iconAreaHeight = 50;
  static const double _textAreaHeight = 30;

  final String label;
  final String imagePath;
  final VoidCallback onPressed;
  final IconData? icon;

  const PdvFunctionButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _iconAreaHeight,
                    child: Center(child: _buildImage()),
                  ),

                  const SizedBox(height: 4),

                  SizedBox(
                    height: _textAreaHeight,
                    child: Center(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (icon != null) {
      return Icon(icon, size: _iconSize, color: Colors.black);
    }

    final file = File(imagePath);

    if (!file.existsSync()) {
      return const Icon(
        Icons.image_not_supported_outlined,
        size: _iconSize,
        color: Colors.grey,
      );
    }

    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        file,
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      file,
      width: _iconSize,
      height: _iconSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.broken_image_outlined,
          size: _iconSize,
          color: Colors.white54,
        );
      },
    );
  }
}
