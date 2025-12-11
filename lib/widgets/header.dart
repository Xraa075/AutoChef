import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/data/user.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? child;
  final TextStyle? mainTitleStyle;
  final String? mainTitle;
  final TextStyle? titleStyle;

  const CustomHeader({
    super.key,
    required this.title,
    this.mainTitleStyle,
    this.mainTitle,
    this.child,
    this.titleStyle,
  });

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: getActiveUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(color: Color(0xFFFBC72A)),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainTitle ?? 'Halo, ${currentUser.name}',
                            style: mainTitleStyle ??
                                const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            title,
                            style:
                                titleStyle ??
                                const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: _getImageProvider(currentUser.userImage),
                      radius: 24,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
                if (child != null) ...[const SizedBox(height: 12), child!],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize {
    return child != null
        ? const Size.fromHeight(140)
        : const Size.fromHeight(80);
  }
}
