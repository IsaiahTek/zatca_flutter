import 'package:flutter/material.dart';
import 'package:zatca_flutter/qr_code/util.dart';

class QRCodePainter extends CustomPainter {
  final String data;
  late List<List<int>> qrMatrix;

  QRCodePainter(this.data) {
    qrMatrix = generateQRMatrix(data);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final double squareSize = size.width / qrMatrix.length;

    for (int y = 0; y < qrMatrix.length; y++) {
      for (int x = 0; x < qrMatrix.length; x++) {
        if (qrMatrix[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
