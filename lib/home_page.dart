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

  final List<Widget> _pages = [
    const HistoryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openNewDocument(BuildContext context) {
    final isWebLayout = MediaQuery.of(context).size.width > 900;

    if (isWebLayout) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),

              Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 900,
                    height: MediaQuery.of(context).size.height * 0.95,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const CreateReceiptPage(),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateReceiptPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4C86D9);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWebLayout = constraints.maxWidth > 900;
        const double sidebarWidth = 80.0;

        return Scaffold(
          backgroundColor: scaffoldColor,

          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: isWebLayout ? surfaceColor : scaffoldColor,
            elevation: isWebLayout ? 1 : 0,
            shadowColor: Colors.black12,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.only(left: isWebLayout ? sidebarWidth : 0),
              child: Image.asset(
                'assets/images/quantovaidartittle.png',
                height: 50,
                fit: BoxFit.contain,
                color: isDark ? Colors.white : null,
              ),
            ),
          ),

          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWebLayout)
                Container(
                  width: sidebarWidth,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1))),
                  ),
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    backgroundColor: Colors.transparent,
                    indicatorColor: primaryColor.withOpacity(0.1),
                    minWidth: sidebarWidth,
                    labelType: NavigationRailLabelType.all,

                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: primaryColor,
                        heroTag: "btnWeb",
                        child: const Icon(Icons.add, color: Colors.white),

                        onPressed: () => _openNewDocument(context),
                      ),
                    ),

                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long_rounded, color: primaryColor),
                        label: Text("Histórico", style: TextStyle(
                            color: _selectedIndex == 0 ? primaryColor : Colors.grey,
                            fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal
                        )),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings_rounded, color: primaryColor),
                        label: Text("Ajustes", style: TextStyle(
                            color: _selectedIndex == 1 ? primaryColor : Colors.grey,
                            fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal
                        )),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),

          floatingActionButton: isWebLayout
              ? null
              : SizedBox(
            height: 65, width: 65,
            child: FloatingActionButton(
              heroTag: "btnMobile",
              onPressed: () => _openNewDocument(context),
              backgroundColor: primaryColor,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: isWebLayout
              ? null
              : BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            height: 70,
            color: surfaceColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shadowColor: Colors.black12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMobileNavItem(Icons.receipt_long_rounded, "Histórico", 0, isDark),
                const SizedBox(width: 40),
                _buildMobileNavItem(Icons.settings_rounded, "Ajustes", 1, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF4C86D9) : (isDark ? Colors.grey[600] : Colors.grey[400]);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected)
              Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}