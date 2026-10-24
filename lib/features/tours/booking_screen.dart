import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import 'tour_status_screen.dart';

const tourTimes = [
  '9:00 AM',
  '10:00 AM',
  '11:00 AM',
  '12:00 PM',
  '1:00 PM',
  '2:00 PM',
  '3:00 PM',
  '4:00 PM',
];

bool isFutureSlot(DateTime date, String time, DateTime now) {
  final hour =
      int.parse(time.split(':').first) % 12 + (time.endsWith('PM') ? 12 : 0);
  return DateTime(date.year, date.month, date.day, hour).isAfter(now);
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.property});
  final Property property;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = -1;
  bool? _video;
  String _contact = 'In-app video';
  DateTime _date = DateUtils.dateOnly(
    DateTime.now(),
  ).add(const Duration(days: 1));
  late DateTime _month = DateTime(_date.year, _date.month);
  String? _time;
  bool _busy = false;
  Tour? _booked;
  String get _tourName => _video == true ? 'Live Video Tour' : 'In Person Tour';

  void _back() {
    if (_step == -1) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step = _step == 1 && _video != true ? -1 : _step - 1);
  }

  Future<void> _next() async {
    if (_step < 3) {
      setState(() {
        _step = _step == -1 && _video != true ? 1 : _step + 1;
      });
      return;
    }
    if (_busy) return;
    if (!isFutureSlot(_date, _time!, DateTime.now())) {
      toast(context, 'This time has passed. Please choose another time.');
      setState(() {
        _step = 2;
        _time = null;
      });
      return;
    }
    final store = AppScope.of(context);
    setState(() => _busy = true);
    final tour = Tour(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      propertyId: widget.property.id,
      video: _video!,
      date: _date,
      time: _time!,
      contact: _video! ? _contact : 'In person',
    );
    final success = await store.book(tour);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (success) _booked = tour;
    });
    if (!success) {
      toast(
        context,
        'You already have a tour at this time. Choose another slot.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booked != null) return TourSuccessScreen(tour: _booked!);
    final enabled =
        !_busy &&
        (_step != -1 || _video != null) &&
        (_step != 2 || _time != null);
    return Scaffold(
      bottomNavigationBar: BottomAction(
        child: PrimaryButton(
          _busy
              ? 'Saving...'
              : _step == 3
              ? 'Confirm Schedule'
              : 'Continue',
          onPressed: enabled ? _next : null,
        ),
      ),
      body: Column(
        children: [
          PageHeader(
            _step == -1
                ? 'Choose Tour'
                : _step == 3
                ? 'Confirmation'
                : _tourName,
            onBack: _back,
            trailing: _step == 1 || _step == 2
                ? Text(
                    '${_step == 1 ? 1 : 2}/2',
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            child: _step >= 0 && _step < 3
                ? Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.paper,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/tour_${_video! ? 'video' : 'person'}.png',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            switch (_step) {
                              0 => 'How Would You Like to Connect?',
                              1 => 'Select One Date for $_tourName!',
                              _ => 'Select Your Preferred Tour Time',
                            },
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          Expanded(
            child: switch (_step) {
              -1 => _chooseType(),
              0 => _chooseContact(),
              1 => _calendar(),
              2 => _chooseTime(),
              _ => _confirmation(),
            },
          ),
        ],
      ),
    );
  }

  Widget _chooseType() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _ChoiceCard(
        key: const Key('tour-person'),
        selected: _video == false,
        icon: Icons.location_on_rounded,
        title: 'Schedule In Person Tour',
        description:
            'Step inside and discover the beauty of this stunning property in person.',
        onTap: () => setState(() => _video = false),
      ),
      const SizedBox(height: 16),
      _ChoiceCard(
        key: const Key('tour-video'),
        selected: _video == true,
        icon: Icons.smart_display_outlined,
        title: 'Schedule Live Video Tour',
        description:
            'Explore every room with the listing owner, wherever you are.',
        onTap: () => setState(() => _video = true),
      ),
    ],
  );

  Widget _chooseContact() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Text(
        'Preferred Contact Method',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 20),
      ...['In-app video', 'WhatsApp', 'Zoom'].map(
        (c) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ChoiceCard(
            selected: _contact == c,
            compact: true,
            icon: c == 'WhatsApp'
                ? Icons.chat_outlined
                : Icons.videocam_outlined,
            title: c,
            description: 'The owner will confirm contact details in chat.',
            onTap: () => setState(() => _contact = c),
          ),
        ),
      ),
      const Text(
        'Contact services are shown for preview. No external call is placed.',
        style: hintStyle,
      ),
    ],
  );

  Widget _calendar() {
    final today = DateUtils.dateOnly(DateTime.now());
    final offset = _month.weekday % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${months[_month.month - 1]} ${_month.year}',
                style: titleStyle(18),
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              onPressed: _month.isAfter(DateTime(today.year, today.month))
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    )
                  : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: _month.isBefore(DateTime(today.year + 1, today.month))
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    )
                  : null,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: blue,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('SUN', style: hintStyle),
            Text('MON', style: hintStyle),
            Text('TUE', style: hintStyle),
            Text('WED', style: hintStyle),
            Text('THU', style: hintStyle),
            Text('FRI', style: hintStyle),
            Text('SAT', style: hintStyle),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days + offset,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            if (i < offset) return const SizedBox();
            final date = DateTime(_month.year, _month.month, i - offset + 1),
                selected = DateUtils.isSameDay(
                  _date,
                  DateTime(_month.year, _month.month, i - offset + 1),
                );
            final available = !date.isBefore(today);
            return Center(
              child: Semantics(
                selected: selected,
                label: dateLabel(date),
                child: InkWell(
                  key: Key('date-${date.day}'),
                  borderRadius: BorderRadius.circular(30),
                  onTap: available
                      ? () => setState(() {
                          _date = date;
                          _time = null;
                        })
                      : null,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? blue : Colors.transparent,
                      border: selected
                          ? Border.all(
                              color: blue.withValues(alpha: .18),
                              width: 5,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )
                          : null,
                    ),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 13,
                        color: selected
                            ? Colors.white
                            : !available
                            ? muted.withValues(alpha: .3)
                            : i % 7 == 0
                            ? const Color(0xFFF05C68)
                            : context.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Selected: ${dateLabel(_date)}', style: hintStyle),
      ],
    );
  }

  Widget _chooseTime() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(dateLabel(_date), style: titleStyle(18)),
      const SizedBox(height: 8),
      const Text(
        'All times follow your device’s local time.',
        style: hintStyle,
      ),
      const SizedBox(height: 24),
      GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
        children: tourTimes
            .map(
              (t) => OutlinedButton(
                key: Key('time-$t'),
                onPressed: isFutureSlot(_date, t, DateTime.now())
                    ? () => setState(() => _time = t)
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _time == t ? context.header : context.paper,
                  foregroundColor: _time == t ? blue : context.textColor,
                  side: BorderSide(color: _time == t ? aqua : context.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(t, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _confirmation() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      PropertyTile(widget.property),
      const SizedBox(height: 16),
      Text('Your Tour Details', style: titleStyle(22)),
      const SizedBox(height: 20),
      TourInfo(
        icon: _video! ? Icons.videocam_outlined : Icons.home_outlined,
        value: _tourName,
      ),
      TourInfo(icon: Icons.calendar_today_outlined, value: dateLabel(_date)),
      TourInfo(icon: Icons.schedule_rounded, value: _time!),
      TourInfo(
        icon: Icons.location_on_outlined,
        value: _video! ? _contact : widget.property.address,
      ),
      const SizedBox(height: 20),
      const Text(
        'Your request will appear in Tour Status as pending confirmation. This preview saves the request on your device.',
        style: hintStyle,
      ),
    ],
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.compact = false,
  });
  final bool selected, compact;
  final IconData icon;
  final String title, description;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? context.header : context.paper,
          border: Border.all(color: selected ? aqua : context.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (compact)
                  Icon(icon, color: context.accent, size: 28)
                else
                  Image.asset(
                    'assets/images/tour_${icon == Icons.location_on_rounded ? 'person' : 'video'}.png',
                    width: 60,
                    height: 60,
                  ),
                const Spacer(),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: context.accent,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 13, height: 1.8, color: muted),
            ),
          ],
        ),
      ),
    ),
  );
}
