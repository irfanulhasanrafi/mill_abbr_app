import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String email =
      "irfanulhasanrafi18@gmail.com"; // Replace with your real email

  void launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Correction for Mill Abbr App',
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About This App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mill Abbr', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text('Based on JSSDM 2022'),
            SizedBox(height: 16),
            Text('Developed by: BA 10911 Capt Rafi, Sigs'),
            SizedBox(height: 16),
            Text('For corrections or suggestions, please email:'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: launchEmail,
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
