import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';

class UserLinkWidget extends StatelessWidget {
  final String? username;
  final String? fullname;
  final double? distance;
  final String? avatarUrl;

  const UserLinkWidget({
    Key? key,
    required this.username,
    this.distance,
    required this.fullname,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8;

    return InkWell(
      onTap: () {
        if (username != null) {
          VRouter.of(context).to('/user/$username');
        }
      },
      child: SizedBox(
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (avatarUrl != null)
                ? CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    foregroundImage: NetworkImage(
                        avatarUrl! // URL da imagem do Firebase Storage
                        ),
                  )
                : const CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, size: 30),
                  ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  fullname ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  '@$username',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Text(
              distance != null ? '${distance.toString()}m' : '',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
