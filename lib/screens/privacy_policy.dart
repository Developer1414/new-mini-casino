import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
                  context.beamBack();
                },
                icon: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
                )),
          ),
          title: AutoSizeText(
            'Политика Конфиденциальности',
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
                  'Privacy Policy',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10.0),
                text(
                  context: context,
                  title: '1. Introduction',
                  content:
                      'This privacy policy describes the types of information we collect from players and how we use, share, and protect that information.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '2. Information We Collect',
                  content:
                      'We may collect certain information from players, including:\n\n• Device Information: We may collect information about the device you use to play the game, such as the model and operating system.\n\n• Usage Information: We may collect information about how you use the game, such as the time and date of access, the pages or screens viewed, and the actions taken.\n\n• Advertising Information: We may collect information about the advertisements you see and interact with while playing the game, such as the ad content, the advertiser\'s name, and the date and time the ad was shown.\n\n• Supabase Information: We may collect data stored in Supabase to track player progress and game data.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '3. How We Use Your Information',
                  content:
                      'We use the information we collect to provide and improve the game and to personalize the player experience. Specifically, we may use the information for the following purposes:\n\n• To operate, maintain, and improve the game;\n• To personalize the player experience;\n• To track player progress and game data;\n• To serve advertisements that are relevant to your interests;\n• To comply with legal obligations;\n• To protect the rights and safety of our players and the public.',
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '4. How We Share Your Information',
                  content:
                      """We may share the information we collect with third-party service providers that help us operate the game. For example, we may share information with Appodeal for the purpose of serving relevant advertisements. We may also share information with law enforcement agencies or other government authorities if we believe it is necessary to comply with a legal obligation or to protect the rights and safety of our players and the public.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '5. Data Retention and Security',
                  content:
                      """We will retain your information for as long as necessary to fulfill the purposes described in this privacy policy, unless a longer retention period is required or permitted by law. We take reasonable measures to protect the information we collect from unauthorized access, disclosure, alteration, or destruction.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '6. Contact Us',
                  content:
                      """If you have any questions or concerns about our privacy practices, please contact us at develope14000@gmail.com.""",
                ),
                const SizedBox(height: 30.0),
                text(
                  context: context,
                  title: '7. Changes to this Privacy Policy',
                  content:
                      """We may update this privacy policy from time to time. Any changes will be posted on this page. Your continued use of the game after any changes to this privacy policy will constitute your acceptance of such changes.""",
                ),
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
