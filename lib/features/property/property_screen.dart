import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../home/map_screen.dart';
import '../messages/messages_screen.dart';
import '../tours/booking_screen.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key, required this.property});
  final Property property;
  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.property, store = AppScope.of(context);
    final saved = store.saved.contains(p.id);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: context.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        bottomNavigationBar: BottomAction(
          child: PrimaryButton(
            'Schedule a Tour',
            onPressed: () => openPage(context, BookingScreen(property: p)),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).width * .93,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/${p.image}.png',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RoundButton(
                                icon: Icons.arrow_back_rounded,
                                label: 'Back',
                                onTap: () => Navigator.pop(context),
                              ),
                              RoundButton(
                                key: const Key('save-property'),
                                icon: saved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: saved ? blue : null,
                                label: saved
                                    ? 'Unsave listing'
                                    : 'Save listing',
                                onTap: () {
                                  store.toggleSaved(p.id);
                                  toast(
                                    context,
                                    saved
                                        ? 'Removed from saved homes'
                                        : 'Added to saved homes',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              openPage(context, GalleryScreen(property: p)),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            '+2 Photos',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.paper,
                            foregroundColor: blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: aqua, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Viewed by 100+ Users Today',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: titleStyle(24)),
                              const SizedBox(height: 6),
                              Text(
                                p.priceLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: blue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(p.city, style: hintStyle),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          label: 'View estate location',
                          button: true,
                          child: GestureDetector(
                            onTap: () =>
                                openPage(context, MapScreen(property: p)),
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.paper,
                                  width: 3,
                                ),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/map.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ink.withValues(alpha: .07),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: blue,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () =>
                          openPage(context, EstateFactsScreen(property: p)),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Feature(Icons.bed_outlined, '${p.beds} Beds'),
                            _Feature(Icons.open_with_rounded, '${p.area} Sqft'),
                            const _Feature(
                              Icons.water_drop_outlined,
                              '2 Baths',
                            ),
                            const _Feature(
                              Icons.door_front_door_outlined,
                              '4 Rooms',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Avatar(owner: p.owner),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Listed by', style: hintStyle),
                              Text(
                                p.owner,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Message owner',
                          onPressed: () =>
                              openPage(context, ChatScreen(owner: p.owner)),
                          style: IconButton.styleFrom(
                            backgroundColor: context.soft,
                            foregroundColor: blue,
                          ),
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Upon entering the property, you’ll be greeted by a grand entrance with high ceilings, polished marble floors, and an elegant chandelier.${_expanded ? ' The sunlit living area opens onto a peaceful garden. Thoughtful finishes, a spacious kitchen and comfortable bedrooms make this a welcoming home for your next chapter.' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: muted,
                      ),
                      maxLines: _expanded ? null : 3,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(_expanded ? 'Read less' : 'Read more...'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: blue,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Estimated Value Comparison',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _Value(
                                  'This Home',
                                  p.priceLabel,
                                  '↑ 5.6%',
                                  const Color(0xFF2BC77C),
                                ),
                              ),
                              const Expanded(
                                child: _Value(
                                  'Avg Los Angeles',
                                  '\$3,200,000',
                                  '↓ 3.3%',
                                  Color(0xFFF05C68),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Illustrative market data',
                            style: TextStyle(fontSize: 9, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: blue, size: 21),
      const SizedBox(height: 10),
      Text(label, style: const TextStyle(fontSize: 11, color: muted)),
    ],
  );
}

class _Value extends StatelessWidget {
  const _Value(this.label, this.value, this.change, this.color);
  final String label, value, change;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: hintStyle),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 15)),
      const SizedBox(height: 5),
      Text(change, style: TextStyle(fontSize: 12, color: color)),
    ],
  );
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.property});
  final Property property;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        PageHeader('All Estate Photos', subtitle: property.name),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: property.photos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, i) => Semantics(
              label: 'Open photo ${i + 1}',
              button: true,
              child: GestureDetector(
                onTap: () => openPage(
                  context,
                  PhotoScreen(property: property, initialIndex: i),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/${property.photos[i]}.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({
    super.key,
    required this.property,
    required this.initialIndex,
  });
  final Property property;
  final int initialIndex;
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late int _index = widget.initialIndex;
  late final _controller = PageController(initialPage: widget.initialIndex);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101925),
    appBar: AppBar(
      backgroundColor: const Color(0xFF101925),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        '${_index + 1} / ${widget.property.photos.length}',
        style: const TextStyle(fontSize: 16),
      ),
    ),
    body: PageView.builder(
      controller: _controller,
      onPageChanged: (v) => setState(() => _index = v),
      itemCount: widget.property.photos.length,
      itemBuilder: (_, i) => InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.asset('assets/images/${widget.property.photos[i]}.png'),
        ),
      ),
    ),
  );
}

class EstateFactsScreen extends StatelessWidget {
  const EstateFactsScreen({super.key, required this.property});
  final Property property;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        PageHeader('Real Estate Detail', subtitle: property.name),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('A Home to Make Your Own', style: titleStyle()),
              const SizedBox(height: 20),
              ...{
                'Property type': property.type,
                'Bedrooms': '${property.beds}',
                'Bathrooms': '2',
                'Rooms': '4',
                'Living area': '${property.area} Sqft',
                'Year built': '2021',
                'Parking': '2 spaces',
                'Furnishing': 'Fully furnished',
                'Location': property.city,
              }.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(color: muted, fontSize: 13),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          e.value,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
