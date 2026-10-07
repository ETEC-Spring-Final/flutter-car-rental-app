import 'package:flutter/material.dart';

import 'package:vehicle_rental_system/feature/home/presentation/view/home_screen.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/app_bottom_navigation.dart';
import 'package:vehicle_rental_system/feature/profile/presentation/view/profile_screen.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/booking_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/explore_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/favorite_screen.dart';

class MainScreen extends StatefulWidget {
  final int index;

  const MainScreen({super.key, this.index = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ===========================================================================
  // STATE
  // ===========================================================================

  late int currentIndex;

  // ===========================================================================
  // EXPLORE KEY
  // ===========================================================================

  final GlobalKey<ExploreScreenState> exploreKey =
      GlobalKey<ExploreScreenState>();

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    currentIndex = widget.index;
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      setState(() {
        currentIndex = widget.index;
      });
    }
  }

  // ===========================================================================
  // CHANGE TAB
  // ===========================================================================

  void changeTab(int index) {
    if (currentIndex == index) {
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  // ===========================================================================
  // OPEN EXPLORE
  // ===========================================================================

  void openExplore({bool focus = false}) {
    setState(() {
      currentIndex = 1;
    });

    if (focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        exploreKey.currentState?.focusSearch();
      });
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,

        children: [
          // ===================================================================
          // HOME
          // ===================================================================
          HomeScreen(
            onExploreTap: (focus) {
              openExplore(focus: focus);
            },

            onBookingTap: () {
              changeTab(2);
            },

            onFavoriteTap: () {
              changeTab(3);
            },

            onProfileTap: () {
              changeTab(4);
            },
          ),

          // ===================================================================
          // EXPLORE
          // ===================================================================
          ExploreScreen(key: exploreKey),

          // ===================================================================
          // BOOKING
          // ===================================================================
          const BookingScreen(),

          // ===================================================================
          // FAVORITE
          // ===================================================================
          const FavoriteScreen(),

          // ===================================================================
          // PROFILE
          // ===================================================================
          ProfileScreen(
            onExploreTap: () {
              openExplore();
            },

            onBookingsTap: () {
              changeTab(2);
            },

            onFavoritesTap: () {
              changeTab(3);
            },

            onHomeTap: () {
              changeTab(0);
            },
          ),
        ],
      ),

      // =========================================================================
      // BOTTOM NAVIGATION
      // =========================================================================
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: changeTab,
      ),
    );
  }
}
