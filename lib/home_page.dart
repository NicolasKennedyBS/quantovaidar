import 'package:flutter/material.dart';
import 'create_receipt_page.dart';
import 'settings_page.dart';
import 'history_page.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HistoryPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openFloatingWindow(BuildContext context, Widget page) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12 * anim1.value, sigmaY: 12 * anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
              child: Center(
                child: Material(
                  elevation: 24,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(32),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 900,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: page,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
 Widget build(BuildContext context) {
   final isDark = Theme.of(context).brightness == Brightness.dark;
   final isWide = MediaQuery.of(context).size.width > 900;
   const primaryColor = Color(0xFF4C86D9);

   return Scaffold(
     body: RepaintBoundary(
       child: IndexedStack(
         index: _selectedIndex,
         children: _pages,
       ),
     ),
     appBar: isWide 
       ? null 
       : AppBar(
           title: Image.asset('assets/images/quantovaidartittle.png', 
             height: 55, color: isDark ? Colors.white : null),
           centerTitle: true, elevation: 0, backgroundColor: Colors.transparent,
         ),
     
     floatingActionButton: isWide 
       ? null 
       : FloatingActionButton(
           onPressed: () {
             if (isWide) {
               _openFloatingWindow(context, const CreateReceiptPage());
             } else {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReceiptPage()));
             }
           },
           backgroundColor: primaryColor,
           child: const Icon(Icons.add, color: Colors.white),
         ),
     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
     
     bottomNavigationBar: isWide ? null : BottomAppBar(
       shape: const CircularNotchedRectangle(),
       notchMargin: 8,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         children: [
           IconButton(
             icon: Icon(Icons.receipt_long, color: _selectedIndex == 0 ? primaryColor : Colors.grey), 
             onPressed: () => _onItemTapped(0)
           ),
           const SizedBox(width: 40),
           IconButton(
             icon: Icon(Icons.settings, color: _selectedIndex == 1 ? primaryColor : Colors.grey), 
             onPressed: () => _onItemTapped(1)
           ),
         ],
       ),
     ),
   );
 }
}