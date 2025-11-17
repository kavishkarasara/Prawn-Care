import 'package:flutter/material.dart';
import 'package:prawn__farm/models/user_type_model.dart';

class UserTypeCard extends StatelessWidget {
  final UserType userType;
  final bool isTablet;

  const UserTypeCard({
    super.key,
    required this.userType,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => userType.destination),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isTablet ? screenHeight * 0.12 : screenHeight * 0.08,
        width: double.infinity,
        decoration: BoxDecoration(
          color: userType.color,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => userType.destination),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width:
                          (isTablet ? screenWidth * 0.06 : screenWidth * 0.08) +
                              2 * screenWidth * 0.03,
                      height:
                          (isTablet ? screenWidth * 0.06 : screenWidth * 0.08) +
                              2 * screenWidth * 0.03,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          userType.icon,
                          size: isTablet
                              ? screenWidth * 0.06
                              : screenWidth * 0.08,
                          color: userType.textColor,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      userType.title,
                      style: TextStyle(
                        fontSize: isTablet
                            ? screenWidth * 0.035
                            : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: userType.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
