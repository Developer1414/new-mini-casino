import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAgreement extends StatelessWidget {
  const UserAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 76.0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
                )),
          ),
          title: AutoSizeText(
            'Пользовательское соглашение',
            maxLines: 1,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'User Agreement',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10.0),
                text(
                  context: context,
                  title: '1. Introduction',
                  content:
                      'This user agreement is a legal agreement between you (the user) and the app developer (Mini Casino) that governs your use of the features available within the Application to purchase goods, services, currencies and other items ("In-App Purchases"). Please read this Agreement carefully.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '2. Terms of Use',
                  content:
                      '2.1. You agree to use the in-app Purchases only for lawful purposes and in compliance with this Agreement and applicable laws\n\n2.2. You agree not to transfer, sell or assign the rights to use the in-app Purchases to other users or third parties.\n\n2.3. You certify that all information you provide in connection with the Purchases in the app is true and complete.\n\n2.4. You are responsible for the security of your account and for any purchases made through your account.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '3. In-app purchases',
                  content:
                      '3.1. We can give you the opportunity to make in-app Purchases for additional fee or with virtual currency, which can be purchased with real money.\n\n3.2. We reserve the right to change the prices of products and services, as well as the virtual currency used in in-app Purchases, at any time and without notice to you.\n\n3.3. You understand and agree that any in-app purchases are final and non-refundable except as required by applicable law.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '4. Disclaimer',
                  content:
                      """4.1. We shall not be liable for any loss, expense or damage arising from the use of Purchases in the application.\n\n4.2. We are not responsible for the inability to make purchases in the application due to technical reasons, including errors on the side of payment system providers, or insufficient funds on your bank card or payment system account.\n\n4.3. We do not guarantee that in-app Purchases will be available at any time or place, and we reserve the right to change or discontinue access to in-app Purchases at any time and without notice to you.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '5. Intellectual Property',
                  content:
                      """5.1. All rights in the App Purchases, including all materials, images, text, graphics, logos, icons, audio and video, and other elements, are reserved by us or our partners and suppliers.\n\n5.2. You do not acquire any intellectual property rights associated with the Purchases in the Application, except for the rights to use them in accordance with this Agreement.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '6. Termination of the Agreement',
                  content:
                      """6.1. We may terminate this Agreement at any time in our sole discretion and without cause.\n\n6.2. You may terminate this Agreement by uninstalling the app from your device and ceasing use of in-app Purchases.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '7. Changes to the Agreement',
                  content:
                      """7.1. We reserve the right to change this Agreement at any time by posting an updated version of our User Agreement in the app.\n\n7.2. By continuing to use the in-app Purchases after a change to this Agreement, you agree to the updated version.""",
                ),
                const SizedBox(height: 30.0),
                Text('8. Contact Us',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 5.0),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text:
                        'If you have any questions about this Agreement, you may contact us at ',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri emailLaunchUri =
                            Uri.parse('mailto:develope14000@gmail.com');

                        if (!await launchUrl(emailLaunchUri,
                            mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $emailLaunchUri}');
                        }
                      },
                    text: 'develope14000@gmail.com.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.blue,
                        ),
                  )
                ])),
                const SizedBox(height: 30.0),
                Text(
                    """This User Agreement governs your use of the in-app Purchases. By using in-app Purchases, you agree to this Agreement and accept all of its terms. If you do not agree with any of the terms, do not use the in-app Purchases.""",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 15,
                        )),
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        ));
  }

  Widget text(
      {required BuildContext context,
      required String title,
      required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 5.0),
        Text(content,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                )),
      ],
    );
  }
}
