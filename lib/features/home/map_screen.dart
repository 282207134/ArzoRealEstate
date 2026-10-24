import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../property/property_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.property});
  final Property? property;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _category = 'All';
  Property? _selected;
  final _query = TextEditingController();
  @override
  void initState() {
    super.initState();
    _selected = widget.property;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homes = AppScope.of(context).search(_query.text, category: _category);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            widget.property == null ? 'Search on Map' : 'Estate Location',
            art: true,
            child: widget.property == null
                ? SearchBox(
                    controller: _query,
                    hint: 'Search by estate name',
                    onChanged: (_) => setState(() => _selected = null),
                  )
                : null,
          ),
          if (widget.property == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CategoryChips(
                value: _category,
                onChanged: (v) => setState(() {
                  _category = v;
                  _selected = null;
                }),
              ),
            ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: context.isDark ? .25 : 1,
                  child: Image.asset(
                    'assets/images/map.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned(
                  top: 14,
                  left: 24,
                  child: Text(
                    'LOS ANGELES',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: List.generate(homes.length, (i) {
                      const positions = [
                        Offset(.3, .12),
                        Offset(.65, .25),
                        Offset(.12, .42),
                        Offset(.78, .53),
                        Offset(.44, .65),
                      ];
                      final p = homes[i], offset = positions[i];
                      final active = _selected?.id == p.id;
                      return Positioned(
                        left: constraints.maxWidth * offset.dx,
                        top: constraints.maxHeight * offset.dy,
                        child: Semantics(
                          label: 'Map ${p.name}',
                          button: true,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = p),
                            child: Container(
                              width: 42,
                              height: 50,
                              decoration: BoxDecoration(
                                color: active ? blue : const Color(0xFFE5EDFF),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  topRight: Radius.circular(22),
                                  bottomLeft: Radius.circular(22),
                                  bottomRight: Radius.circular(4),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ink.withValues(alpha: .12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.home_outlined,
                                  color: active ? Colors.white : blue,
                                  size: 23,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (homes.isEmpty)
                  const EmptyState(
                    title: 'No Homes Found',
                    message: 'Try another search or property category.',
                  ),
                if (_selected != null)
                  Positioned(
                    bottom: 35,
                    left: 24,
                    right: 24,
                    child: PropertyTile(
                      _selected!,
                      onTap: () => openPage(
                        context,
                        PropertyScreen(property: _selected!),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.paper.withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Illustrated map · Preview locations',
                        style: TextStyle(fontSize: 10, color: muted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
