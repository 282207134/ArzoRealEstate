import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.selectNeighborhood = false});
  final bool selectNeighborhood;
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _search = TextEditingController();
  String _query = '';
  static const locations = [
    'Los Angeles, California',
    'San Francisco, California',
    'San Diego, California',
    'Beverly Hills, California',
    'Santa Monica, California',
    'Pasadena, California',
  ];
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = locations
        .where((l) => l.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            widget.selectNeighborhood
                ? 'Select Neighborhood'
                : 'Choose Location',
            art: true,
            child: SearchBox(
              controller: _search,
              hint: 'Search your neighborhood',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (options.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('SUGGESTED LOCATIONS', style: hintStyle),
                  const SizedBox(height: 16),
                  ...options.map(
                    (l) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.header,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: blue,
                        ),
                      ),
                      title: Text(l, style: const TextStyle(fontSize: 14)),
                      subtitle: const Text('United States', style: hintStyle),
                      trailing: const Icon(Icons.chevron_right, color: muted),
                      onTap: () {
                        if (!widget.selectNeighborhood) {
                          AppScope.of(context).setLocation(l);
                        }
                        Navigator.pop(context, l);
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(
              child: EmptyState(
                title: 'Neighborhood Not Found',
                message: 'Try another city or neighborhood name.',
              ),
            ),
        ],
      ),
    );
  }
}
