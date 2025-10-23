class LauncherData {
  final Hotel hotel;
  final Room room;
  final List<BannerItem> banners;
  final List<MenuItem> menus;
  final Map<String, List<ContentItem>> contents;

  LauncherData({
    required this.hotel,
    required this.room,
    required this.banners,
    required this.menus,
    required this.contents,
  });

  factory LauncherData.fromJson(Map<String, dynamic> json) {
    return LauncherData(
      hotel: Hotel.fromJson(json['hotel']),
      room: Room.fromJson(json['room']),
      banners: (json['banners'] as List)
          .map((b) => BannerItem.fromJson(b))
          .toList(),
      menus: (json['menus'] as List).map((m) => MenuItem.fromJson(m)).toList(),
      contents: (json['contents'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((v) => ContentItem.fromJson(v)).toList(),
        ),
      ),
    );
  }
}

class Hotel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? logo;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.logo,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '-',
      phone: json['phone'] ?? '-',
      logo: json['logo'],
    );
  }
}

class Room {
  final String number;
  final String type;
  final String guestName;

  Room({required this.number, required this.type, required this.guestName});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      number: json['number'] ?? '-',
      type: json['type'] ?? '-',
      guestName: json['guest_name'] ?? '-',
    );
  }
}

class BannerItem {
  final int id;
  final String title;
  final String? image;

  BannerItem({required this.id, required this.title, this.image});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'],
    );
  }
}

class MenuItem {
  final String name;
  final String type;
  final String icon;

  MenuItem({required this.name, required this.type, required this.icon});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? 'info-circle',
    );
  }
}

class ContentItem {
  final String title;
  final String body;
  final String? image;

  ContentItem({required this.title, required this.body, this.image});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'],
    );
  }
}
