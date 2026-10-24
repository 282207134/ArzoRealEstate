import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../home/map_screen.dart';
import '../messages/messages_screen.dart';

class TourInfo extends StatelessWidget {
  const TourInfo({super.key, required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: context.line)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: blue, size: 23),
        const SizedBox(width: 16),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, height: 1.8)),
        ),
      ],
    ),
  );
}

class TourSuccessScreen extends StatelessWidget {
  const TourSuccessScreen({super.key, required this.tour});
  final Tour tour;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 180,
          color: context.header,
          child: Stack(
            children: [
              const Positioned(
                right: -20,
                top: 20,
                width: 160,
                child: CityArt(),
              ),
              Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 43,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandMark(size: 22),
                  const SizedBox(width: 10),
                  Text(
                    tour.video ? 'LIVE VIDEO TOUR' : 'IN PERSON TOUR',
                    style: const TextStyle(color: blue, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Tour Successfully\nScheduled', style: titleStyle(30)),
              const SizedBox(height: 20),
              Text(
                'Here are your schedule details with ${tour.property.owner}, the listing owner:',
                style: const TextStyle(color: muted, fontSize: 15, height: 1.8),
              ),
              TourInfo(
                icon: Icons.calendar_today_outlined,
                value: dateLabel(tour.date),
              ),
              TourInfo(
                icon: Icons.schedule_rounded,
                value: '${tour.time} · Local time',
              ),
              TourInfo(
                icon: tour.video
                    ? Icons.videocam_outlined
                    : Icons.location_on_outlined,
                value: tour.video ? tour.contact : tour.property.address,
              ),
              const SizedBox(height: 20),
              const Text(
                'Request saved · Pending confirmation',
                style: TextStyle(
                  color: blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your tour request is saved on this device. No email or external invitation is sent in this preview.',
                style: hintStyle,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                'Explore More Listings',
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => openPage(context, const TourStatusScreen()),
                  child: const Text('View Tour Status'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class TourStatusScreen extends StatefulWidget {
  const TourStatusScreen({super.key});
  @override
  State<TourStatusScreen> createState() => _TourStatusScreenState();
}

class _TourStatusScreenState extends State<TourStatusScreen> {
  String _type = 'In Person';
  @override
  Widget build(BuildContext context) {
    final tours = AppScope.of(
      context,
    ).tours.where((t) => t.video == (_type == 'Live Video')).toList();
    return Scaffold(
      body: Column(
        children: [
          const PageHeader('Tour Status'),
          const SizedBox(height: 20),
          CategoryChips(
            value: _type,
            labels: const ['In Person', 'Live Video'],
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: tours.isEmpty
                ? const EmptyState(
                    title: 'No Tours Scheduled Yet',
                    message:
                        'Choose a home you love and schedule your first tour.',
                    icon: Icons.calendar_month_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: tours
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${t.date.day} ${months[t.date.month - 1]} · ${t.time}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                    _Status(t.status),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                PropertyTile(
                                  t.property,
                                  onTap: () => openPage(
                                    context,
                                    TourDetailScreen(id: t.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.status);
  final String status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: status == 'Cancelled' ? const Color(0xFFFDEEF0) : context.header,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status == 'Pending confirmation' ? 'Pending' : status,
      style: TextStyle(
        color: status == 'Cancelled' ? const Color(0xFFED565E) : blue,
        fontSize: 11,
      ),
    ),
  );
}

class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context),
        tour = AppScope.of(context).tours.firstWhere((t) => t.id == id);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            tour.video ? 'Live Video Tour Status' : 'In Person Tour Status',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Text('Tour Request', style: titleStyle(22)),
                    const Spacer(),
                    _Status(tour.status),
                  ],
                ),
                const SizedBox(height: 20),
                PropertyTile(
                  tour.property,
                  onTap: () =>
                      openPage(context, MapScreen(property: tour.property)),
                ),
                TourInfo(
                  icon: Icons.calendar_today_outlined,
                  value: dateLabel(tour.date),
                ),
                TourInfo(
                  icon: Icons.schedule_rounded,
                  value: '${tour.time} · Local time',
                ),
                TourInfo(
                  icon: tour.video
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  value: tour.video ? tour.contact : tour.property.address,
                ),
                const SizedBox(height: 24),
                Text(
                  tour.status == 'Cancelled'
                      ? 'This tour has been cancelled.'
                      : 'Waiting for ${tour.property.owner} to confirm your request.',
                  style: bodyStyle,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  'Message Listing Owner',
                  onPressed: () =>
                      openPage(context, ChatScreen(owner: tour.property.owner)),
                  outlined: true,
                ),
                if (!tour.video)
                  TextButton(
                    onPressed: () =>
                        openPage(context, MapScreen(property: tour.property)),
                    child: const Text('View Estate Location'),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: tour.status == 'Cancelled'
          ? null
          : BottomAction(
              child: PrimaryButton(
                'Cancel Tour',
                outlined: true,
                onPressed: () async {
                  final confirmed = await confirmAction(
                    context,
                    title: 'Cancel This Tour?',
                    message:
                        'Your ${tour.video ? 'live video' : 'in person'} tour request will be cancelled.',
                    action: 'Cancel Tour',
                  );
                  if (confirmed) await store.cancelTour(tour.id);
                },
              ),
            ),
    );
  }
}
