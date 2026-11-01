import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  static Future<String?> scanBarcode(BuildContext context) async {
    String? barcode;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          width: 300,
          child: Column(
            children: [
              AppBar(
                title: Text('Scan Barcode'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcodeObj in barcodes) {
                      barcode = barcodeObj.rawValue;
                      if (barcode != null) {
                        Navigator.of(context).pop();
                        break;
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return barcode;
  }
}
