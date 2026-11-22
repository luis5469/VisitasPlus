import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../novedades/bloc/novedad_bloc.dart';
import '../../novedades/pages/novedades_list_page.dart';
import '../../visitas/pages/pdv_list_page.dart';
import 'home_page.dart';
import 'reportes_tab.dart';
import 'perfil_tab.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          PdvListPage(),
          NovedadesListPage(),
          ReportesTab(),
          PerfilTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE0F2F1), // Soft primary color tint
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF00695C)),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.storefront_rounded, color: Color(0xFF00695C)),
              label: 'PDV',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.assignment_rounded, color: Color(0xFF00695C)),
              label: 'Novedades',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF00695C)),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF00695C)),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
