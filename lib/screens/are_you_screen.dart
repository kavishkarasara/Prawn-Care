/// This file contains the AreYouScreen widget, which is the user type selection screen.
/// It allows users to choose their role (Customer, Supplier, or Worker) and navigate to the appropriate sign-in screen.

import 'package:flutter/material.dart';
import 'package:prawn__farm/models/user_type_model.dart';
import 'package:prawn__farm/screens/customers/customer_signin.dart';
import 'package:prawn__farm/screens/supplers/supplier_sign_in_screen.dart';
import 'package:prawn__farm/screens/workers/worker_sign_in_screen.dart';
import 'package:prawn__farm/widgets/usre_type_card.dart';

/// A screen that allows users to select their user type (Customer, Supplier, or Worker).
/// This screen displays user type cards in a responsive layout that adapts to different screen sizes and orientations.
class AreYouScreen extends StatelessWidget {
  /// Constructor for AreYouScreen.
  const AreYouScreen({super.key});

  /// Static list of available user types with their configurations.
  /// Each user type includes display properties and navigation destination.
  static const List<UserType> userTypes = [
    UserType(
      title: 'Customer',
      color: Color.fromARGB(255, 255, 204, 19),
      textColor: Colors.white,
      icon: Icons.person,
      destination: CustomerSignin(),
    ),
    UserType(
      title: 'Supplier',
      color: Color.fromARGB(255, 76, 175, 80),
      textColor: Colors.white,
      icon: Icons.local_shipping,
      destination: SupplierSigninScreen(),
    ),
    UserType(
      title: 'Worker',
      color: Color.fromARGB(255, 30, 118, 162),
      textColor: Colors.white,
      icon: Icons.engineering,
      destination: WorkerSignInScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isTablet = screenWidth > 600;
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            // Define breakpoints for mobile responsiveness
            // ignore: unused_local_variable
            double imageHeight;
            double titleFontSize;
            double cardSpacing;
            double horizontalPadding;

            if (screenWidth < 360) {
              // Small phones
              imageHeight = screenHeight * 0.25;
              titleFontSize = 18;
              cardSpacing = screenHeight * 0.02;
              horizontalPadding = screenWidth * 0.05;
            } else if (screenWidth < 480) {
              // Medium phones
              imageHeight = screenHeight * 0.3;
              titleFontSize = 20;
              cardSpacing = screenHeight * 0.025;
              horizontalPadding = screenWidth * 0.04;
            } else {
              // Large phones and tablets
              imageHeight = isLandscape
                  ? screenHeight * 0.3
                  : isTablet
                      ? screenHeight * 0.25
                      : screenHeight * 0.35;
              titleFontSize = isTablet ? 28 : 22;
              cardSpacing = screenHeight * 0.03;
              horizontalPadding = screenWidth * 0.04;
            }

            return Column(
              children: [
                // Top half: Image
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/prawncare.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Bottom half: Content
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            'Are You?',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: isTablet && !isLandscape
                              ? _buildTabletLayout(context)
                              : _buildMobileLayout(context, cardSpacing),
                        ),
                      ),
                      // Footer
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Powered by PrawnCare™',
                            style: TextStyle(
                              fontSize: titleFontSize * 0.6,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double cardSpacing) {
    return Column(
      children: userTypes
          .map((userType) => Padding(
                padding: EdgeInsets.only(bottom: cardSpacing),
                child: UserTypeCard(userType: userType),
              ))
          .toList(),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UserTypeCard(userType: userTypes[0], isTablet: true),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: UserTypeCard(userType: userTypes[1], isTablet: true),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: UserTypeCard(userType: userTypes[2], isTablet: true),
          ),
        ),
      ],
    );
  }
}
