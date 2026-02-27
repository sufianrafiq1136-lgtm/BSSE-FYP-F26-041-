class PoultryItem {
  final String id;
  final String name;
  final String quantity;
  final String location;
  final String imageUrl;
  final String category;

  PoultryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.location,
    this.imageUrl = '',
    required this.category,
  });

  static List<PoultryItem> getSampleItems() {
    return [
      PoultryItem(
        id: '1',
        name: 'Broiler Chickens',
        quantity: '500 birds',
        location: 'Farm A',
        category: 'Birds',
        imageUrl: 'https://images.unsplash.com/photo-1612170153139-6f881ff067e0?w=400&q=80',
      ),
      PoultryItem(
        id: '2',
        name: 'Layer Eggs',
        quantity: '2000 eggs',
        location: 'Farm B',
        category: 'Eggs',
        imageUrl: 'https://images.unsplash.com/photo-1569288052389-dac9b01c9c05?w=400&q=80',
      ),
      PoultryItem(
        id: '3',
        name: 'Day-old Chicks',
        quantity: '300 chicks',
        location: 'Farm A',
        category: 'Chicks',
        imageUrl: 'https://images.unsplash.com/photo-1589923188651-268a9765e432?w=400&q=80',
      ),
      PoultryItem(
        id: '4',
        name: 'Desi Chickens',
        quantity: '150 birds',
        location: 'Farm C',
        category: 'Birds',
        imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400&q=80',
      ),
    ];
  }
}
