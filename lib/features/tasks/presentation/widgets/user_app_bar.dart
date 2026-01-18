import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/user.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;
  const UserAppBar(BuildContext context, {super.key, required this.user});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            tooltip: 'Perfil',
            onPressed: () {
              context.push("/profile");
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username!,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  user.username!,
                  textAlign: TextAlign.start,

                  style: TextStyle(
                    color: Color.fromARGB(255, 109, 109, 109),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Búsqueda',
            onPressed: () {
              context.push("/search");
            },
          ),
        ],
      ),
      actions: [
        // Botón perfil para cerrar sesión
      ],
    );
  }
}
