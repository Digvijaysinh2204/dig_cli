import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AutoLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AutoLinkText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  static final RegExp _linkRegex = RegExp(
    r'((http|https):\/\/[^\s]+|tel:[^\s]+|mailto:[^\s]+|wa\.me[^\s]+|whatsapp:\/\/[^\s]+)',
    caseSensitive: false,
  );

  Future<void> _handleLinkTap(String url) async {
    final uri = Uri.parse(url);

    // Phone
    if (url.startsWith('tel:')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // Email
    if (url.startsWith('mailto:')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // WhatsApp
    if (url.startsWith('whatsapp://') || url.contains('wa.me')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // Maps
    if (url.startsWith('geo:') ||
        url.contains('maps.google.com') ||
        url.contains('google.com/maps')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // PDF
    if (url.toLowerCase().endsWith('.pdf')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // Normal links → Browser
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = [];
    final matches = _linkRegex.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }

      final link = match.group(0)!;

      spans.add(
        TextSpan(
          text: link,
          style: style?.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleLinkTap(link),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return Text.rich(TextSpan(children: spans), textAlign: textAlign);
  }
}
