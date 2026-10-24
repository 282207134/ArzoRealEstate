import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../property/property_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';
import 'location_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _tab,
      children: [
        HomeScreen(onSearch: () => setState(() => _tab = 1)),
        const SearchScreen(embedded: true),
        const MessagesScreen(),
        SavedScreen(onExplore: () => setState(() => _tab = 0)),
        const ProfileScreen(),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: context.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: .035),
            blurRadius: 28,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              5,
              (i) => Semantics(
                selected: _tab == i,
                child: IconButton(
                  key: Key('tab-$i'),
                  tooltip: [
                    'Explore',
                    'Search',
                    'Messages',
                    'Saved',
                    'Profile',
                  ][i],
                  onPressed: () => setState(() => _tab = i),
                  icon: Icon(
                    [
                      Icons.explore_outlined,
                      Icons.search_rounded,
                      Icons.chat_bubble_outline_rounded,
                      Icons.favorite_border_rounded,
                      Icons.person_outline_rounded,
                    ][i],
                    size: 27,
                    color: _tab == i
                        ? context.accent
                        : muted.withValues(alpha: .4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSearch});
  final VoidCallback onSearch;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final results = store
        .search('', category: _category)
        .where((p) => p.city == store.location)
        .toList();
    return Column(
      children: [
        Container(
          color: context.header,
          child: Stack(
            children: [
              const Positioned(
                right: -24,
                top: 48,
                width: 196,
                child: CityArt(),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let’s Find Your\nDream Home',
                        style: titleStyle(28),
                      ),
                      const SizedBox(height: 24),
                      SearchBox(
                        readOnly: true,
                        hint: 'Search a home you’ll love',
                        onTap: widget.onSearch,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                openPage(context, const MapScreen()),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.map_outlined, size: 24),
                            label: const Text(
                              'View on Map',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: InkWell(
                              onTap: () =>
                                  openPage(context, const LocationScreen()),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      store.location.split(',').first,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: blue,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.expand_more,
                                    color: blue,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 14),
          child: Row(
            children: [
              Text('Recommended', style: titleStyle(18)),
              const Spacer(),
              IconButton(
                tooltip: 'All listings',
                onPressed: widget.onSearch,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: blue,
                  size: 23,
                ),
              ),
            ],
          ),
        ),
        CategoryChips(
          value: _category,
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: results.isEmpty
              ? EmptyState(
                  title: 'New Homes Are on the Way',
                  message:
                      'There are no listings in this neighborhood yet. Explore Los Angeles to see available homes.',
                  action: PrimaryButton(
                    'Explore Los Angeles',
                    onPressed: () =>
                        store.setLocation('Los Angeles, California'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  children: results
                      .map(
                        (p) => PropertyTile(
                          p,
                          onTap: () =>
                              openPage(context, PropertyScreen(property: p)),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context),
        saved = AppScope.of(context)
            .search('')
            .where((p) => AppScope.of(context).saved.contains(p.id))
            .toList();
    return Column(
      children: [
        const PageHeader('Saved', back: false, art: true),
        Expanded(
          child: saved.isEmpty
              ? EmptyState(
                  title: 'Your Favorites Live Here',
                  message:
                      'Tap the heart on a home you love. Come back to compare your saved listings any time.',
                  icon: Icons.favorite_border_rounded,
                  action: PrimaryButton(
                    'Explore Listings',
                    onPressed: onExplore,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${saved.length} saved ${saved.length == 1 ? 'home' : 'homes'} · Swipe left to remove',
                        style: hintStyle,
                      ),
                    ),
                    ...saved.map(
                      (p) => Dismissible(
                        key: ValueKey('saved-${p.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => confirmAction(
                          context,
                          title: 'Delete Saved Listing?',
                          message: 'Remove ${p.name} from your saved homes?',
                          action: 'Remove',
                        ),
                        onDismissed: (_) => store.toggleSaved(p.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEEF0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                        child: PropertyTile(
                          p,
                          onTap: () =>
                              openPage(context, PropertyScreen(property: p)),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
