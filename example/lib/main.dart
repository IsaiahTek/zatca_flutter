import 'package:einvoice/invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:einvoice/setup.dart';
import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/zatca_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ZatcaFlutter.init(mode: Mode.developerPortal);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: const HomePage(),
      debugShowCheckedModeBanner: false, // Removes the debug banner.
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceView(),
                  ),
                );
              },
              label: const Text('Invoice'),
            ),
            const SizedBox(
              width: 10,
            ),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.receipt),
            //   onPressed: () {
            //     // Add functionality for the Invoice button here.
            //   },
            //   label: const Text('Invoice'),
            // ),
            // const SizedBox(
            //   width: 10,
            // ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Setup(),
                  ),
                );
              },
              label: const Text('Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
