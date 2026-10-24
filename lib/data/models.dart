class Property {
  const Property({
    required this.id,
    required this.name,
    required this.price,
    required this.beds,
    required this.area,
    required this.image,
    this.type = 'House',
    this.city = 'Los Angeles, California',
    this.owner = 'Angela Wani',
  });
  final String id, name, image, type, city, owner;
  final int price, beds, area;
  String get priceLabel =>
      '\$${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  String get address => '4268 Prospect Valley Road, $city, 90071';
  List<String> get photos => [image, 'interior', 'living'];
}

const properties = [
  Property(
    id: 'terracota',
    name: 'Terracota House',
    price: 2500000,
    beds: 3,
    area: 200,
    image: 'terracota',
  ),
  Property(
    id: 'scandina',
    name: 'Scandina House 101',
    price: 3500000,
    beds: 3,
    area: 350,
    image: 'scandina',
  ),
  Property(
    id: 'eso',
    name: 'Eso Studio Apartment',
    price: 1000000,
    beds: 1,
    area: 120,
    image: 'eso',
    type: 'Apartment',
  ),
  Property(
    id: 'united',
    name: 'United Condos',
    price: 1300000,
    beds: 1,
    area: 180,
    image: 'united',
    type: 'Apartment',
    owner: 'William Smith',
  ),
  Property(
    id: 'villa',
    name: 'Eha United Villa',
    price: 4000000,
    beds: 4,
    area: 420,
    image: 'villa',
    owner: 'William Smith',
  ),
];

Property propertyById(String id) =>
    properties.firstWhere((p) => p.id == id, orElse: () => properties.first);

class Tour {
  const Tour({
    required this.id,
    required this.propertyId,
    required this.video,
    required this.date,
    required this.time,
    this.contact = 'In-app video',
    this.status = 'Pending confirmation',
  });
  final String id, propertyId, time, contact, status;
  final bool video;
  final DateTime date;
  Property get property => propertyById(propertyId);
  Map<String, dynamic> toJson() => {
    'id': id,
    'propertyId': propertyId,
    'video': video,
    'date': date.toIso8601String(),
    'time': time,
    'contact': contact,
    'status': status,
  };
  factory Tour.fromJson(Map<String, dynamic> j) => Tour(
    id: j['id'],
    propertyId: j['propertyId'],
    video: j['video'],
    date: DateTime.parse(j['date']),
    time: j['time'],
    contact: j['contact'],
    status: j['status'],
  );
  Tour cancelled() => Tour(
    id: id,
    propertyId: propertyId,
    video: video,
    date: date,
    time: time,
    contact: contact,
    status: 'Cancelled',
  );
}

class ChatMessage {
  const ChatMessage(this.text, {this.mine = true});
  final String text;
  final bool mine;
  Map<String, dynamic> toJson() => {'text': text, 'mine': mine};
  factory ChatMessage.fromJson(Map<String, dynamic> j) =>
      ChatMessage(j['text'], mine: j['mine']);
}

String dateLabel(DateTime d) =>
    '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
const weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
