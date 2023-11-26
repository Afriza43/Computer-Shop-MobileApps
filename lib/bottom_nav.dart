import 'package:bottom_bar/bottom_bar.dart';
import 'package:finalproject_mobile/cart.dart';
import 'package:finalproject_mobile/history.dart';
import 'package:finalproject_mobile/home.dart';
import 'package:finalproject_mobile/profil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late PageController _pageController;
  int _currentIndex = 0;
  String username = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    initial();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void initial() async {
    SharedPreferences logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            const HomePage(),
            const ProfilePage(),
            const CartPage(),
            HistoryPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF254DFF), Color(0xFF00C6FF)],
            ),
            color: Colors.blueAccent,
          ),
          child: BottomBar(
            selectedIndex: _currentIndex,
            mainAxisAlignment: MainAxisAlignment.center,
            onTap: (int index) {
              _pageController.jumpToPage(index);
              setState(() => _currentIndex = index);
            },
            items: <BottomBarItem>[
              BottomBarItem(
                icon: Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(
                    color: _currentIndex == 0 ? Colors.white : Colors.black,
                  ),
                ),
                activeColor: Colors.transparent,
              ),
              BottomBarItem(
                icon: Icon(
                  Icons.person,
                  color: _currentIndex == 1 ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Profile',
                  style: TextStyle(
                    color: _currentIndex == 1 ? Colors.white : Colors.black,
                  ),
                ),
                activeColor: Colors.transparent,
              ),
              BottomBarItem(
                icon: Icon(
                  Icons.shopping_cart,
                  color: _currentIndex == 2 ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Cart',
                  style: TextStyle(
                    color: _currentIndex == 2 ? Colors.white : Colors.black,
                  ),
                ),
                activeColor: Colors.transparent,
              ),
              BottomBarItem(
                icon: Icon(
                  Icons.history,
                  color: _currentIndex == 3 ? Colors.white : Colors.black,
                ),
                title: Text(
                  'History',
                  style: TextStyle(
                    color: _currentIndex == 3 ? Colors.white : Colors.black,
                  ),
                ),
                activeColor: Colors.transparent,
              ),
            ],
          ),
        ));
  }
}
