import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'updates_page.dart';
import 'recommendation_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;


  // Função chamada quando um item é selecionado
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: _getBody(),
      bottomNavigationBar: 
        BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemSelected,
            selectedItemColor: Colors.black, 
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: AppLocalizations.of(context).home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: AppLocalizations.of(context).search,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.star_outline),
                label: AppLocalizations.of(context).recomendations,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.update_outlined),
                label: AppLocalizations.of(context).updates,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: AppLocalizations.of(context).profile,
              ),
            ],
        ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const Center(
          child: HomePage(),
        );
      case 1:
        return const Center(
          child: SearchPage(),
        );
      case 2:
        return const Center(
          child: RecommendationsPage(),
        );
      case 3:
        return const Center(
          child: UpdatesPage(),
        );
      case 4:
        return const Center(
          child: ProfilePage(),
        );
      default:
        return const Center(
          child: HomePage(),
        );
    }
  }
}



