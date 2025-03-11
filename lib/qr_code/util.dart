List<int> encodeQRData(String text) {
  List<int> binaryData = [];
  
  // Mode Indicator (Byte mode: 0100)
  binaryData.addAll([0, 1, 0, 0]);

  // Length Indicator (8-bit for small QR codes)
  String lengthBits = text.length.toRadixString(2).padLeft(8, '0');
  binaryData.addAll(lengthBits.split('').map((bit) => int.parse(bit)));

  // Convert Text to Binary
  for (int i = 0; i < text.length; i++) {
    int asciiValue = text.codeUnitAt(i);
    binaryData.addAll(asciiValue.toRadixString(2).padLeft(8, '0').split('').map(int.parse));
  }

  // Terminator (Pad to a multiple of 8 bits)
  while (binaryData.length % 8 != 0) {
    binaryData.add(0);
  }

  return binaryData;
}



List<int> reedSolomonEncode(List<int> data, int numParity) {
  List<int> message = List<int>.from(data);
  
  // Append zeros for parity symbols
  for (int i = 0; i < numParity; i++) {
    message.add(0);
  }

  // Generate Parity Symbols using Polynomial Division
  for (int i = 0; i < data.length; i++) {
    int coef = message[i];

    if (coef != 0) {
      for (int j = 0; j < numParity; j++) {
        message[i + j] ^= galoisMultiply(coef, generatorPolynomial[j]);
      }
    }
  }

  return message.sublist(data.length);
}



/// **Galois Field Multiplication (GF(256))**
int galoisMultiply(int a, int b) {
  int result = 0;
  
  while (b > 0) {
    if ((b & 1) != 0) {
      result ^= a;
    }
    
    a <<= 1;

    if (a & 0x100 != 0) {
      a ^= 0x11D; // Irreducible Polynomial
    }

    b >>= 1;
  }

  return result;
}



/// **Add Finder Pattern (3x3 Squares)**
void addFinderPattern(List<List<int>> matrix, int startX, int startY) {
  for (int i = 0; i < 7; i++) {
    for (int j = 0; j < 7; j++) {
      if (i == 0 || i == 6 || j == 0 || j == 6 || (i >= 2 && i <= 4 && j >= 2 && j <= 4)) {
        matrix[startY + i][startX + j] = 1;
      }
    }
  }
}

/// **Step 3: Encode Text to Binary**
List<int> encodeTextToBinary(String text) {
  List<int> binaryData = [];

  for (int i = 0; i < text.length; i++) {
    int asciiValue = text.codeUnitAt(i);
    for (int j = 7; j >= 0; j--) {
      binaryData.add((asciiValue >> j) & 1);
    }
  }

  return binaryData;
}

/// **Generator Polynomial (For Simplified RS)**
final List<int> generatorPolynomial = [0x1D, 0xF, 0xA, 0xF, 0x3];


List<List<int>> generateQRMatrix(String text) {
  int size = 25; // Adjust dynamically based on data length
  List<List<int>> matrix = List.generate(size, (_) => List.generate(size, (_) => 0));

  // Encode Data and Apply Error Correction
  List<int> encodedData = encodeQRData(text);
  List<int> parityData = reedSolomonEncode(encodedData, 5);
  List<int> finalData = encodedData + parityData;

  // Insert Finder Patterns
  addFinderPattern(matrix, 0, 0);
  addFinderPattern(matrix, size - 7, 0);
  addFinderPattern(matrix, 0, size - 7);

  // Insert Data in QR Matrix
  int index = 0;
  for (int y = 8; y < size - 8 && index < finalData.length; y++) {
    for (int x = 8; x < size - 8 && index < finalData.length; x++) {
      matrix[y][x] = finalData[index++];
    }
  }

  return matrix;
}
