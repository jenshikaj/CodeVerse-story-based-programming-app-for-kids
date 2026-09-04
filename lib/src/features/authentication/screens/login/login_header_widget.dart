import 'package:flutter/material.dart';
import '../../../../constants/image_strings.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: const AssetImage(CVLogoImage),
          height: size.height * 0.2,
        ),
        Text(
          CVLoginTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          CVLoginSubTitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: CVFormHeight,
        ),
      ],
    );
  }
}
