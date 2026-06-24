class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stockCount;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockCount,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockCount: json['stockCount'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stockCount': stockCount,
    };
    
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl;
    }
    
    return map;
  }
}
