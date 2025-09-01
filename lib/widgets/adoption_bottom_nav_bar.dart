import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdoptionBottomNavBar extends StatelessWidget {
  final int petCount;
  final int selectedIndex;
  final Function(int) onItemTapped;
  const AdoptionBottomNavBar({
    super.key,
    required this.petCount,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.primary,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        // Adopted Pets tab with the count badge
        BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              const Icon(Icons.favorite),
              if (petCount > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      petCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Adopted Pets',
        ),
      ],
    );
  }
}
