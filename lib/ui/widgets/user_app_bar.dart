import 'package:flutter/material.dart';
import 'package:mi_agenda/ui/screens/home/wip_screen.dart';

import '../screens/profile/profile_screen.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserAppBar(BuildContext context, {super.key});
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alan Steven Bajaña Granizo",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "allan@admin.com",
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WIPScreen()),
              );
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
