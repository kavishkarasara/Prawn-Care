import 'package:flutter/material.dart';

class SupplierMainHeader extends StatelessWidget {
  final int unreadNotificationCount;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSignOutPressed;

  const SupplierMainHeader({
    super.key,
    required this.unreadNotificationCount,
    required this.onNotificationsPressed,
    required this.onSignOutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Image.asset(
            'assets/images/prawncare.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 15,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 28,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onPressed: onSignOutPressed,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    IconButton(
                      iconSize: 28,
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.amber,
                      ),
                      onPressed: onNotificationsPressed,
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
