import 'json_helpers.dart';

class AnimalSaleListing {
  final String id;
  final String category;
  final String animalCode;
  final String animalName;
  final String breed;
  final int quantity;
  final double unitPrice;
  final double weightKg;
  final DateTime publishedDate;
  final String sellerId;
  final String sellerName;
  final String contact;
  final String location;
  final String status;
  final bool isPublished;
  final String description;
  final String imageBase64;

  const AnimalSaleListing({
    required this.id,
    required this.category,
    required this.animalCode,
    required this.animalName,
    required this.breed,
    required this.quantity,
    required this.unitPrice,
    this.weightKg = 0,
    required this.publishedDate,
    required this.sellerId,
    required this.sellerName,
    required this.contact,
    required this.location,
    this.status = 'Disponible',
    this.isPublished = true,
    this.description = '',
    this.imageBase64 = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'animalCode': animalCode,
      'animalName': animalName,
      'breed': breed,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'weightKg': weightKg,
      'publishedDate': publishedDate.toIso8601String(),
      'sellerId': sellerId,
      'sellerName': sellerName,
      'contact': contact,
      'location': location,
      'status': status,
      'isPublished': isPublished,
      'description': description,
      'imageBase64': imageBase64,
    };
  }

  static AnimalSaleListing? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final category = JsonHelpers.readString(json['category']).trim();
    final animalCode = JsonHelpers.readString(json['animalCode']).trim();
    final animalName = JsonHelpers.readString(json['animalName']).trim();
    final breed = JsonHelpers.readString(json['breed']).trim();
    final quantity = JsonHelpers.readInt(json['quantity']);
    final unitPrice = JsonHelpers.readDouble(json['unitPrice']);
    final publishedDate = JsonHelpers.parseDate(JsonHelpers.readString(json['publishedDate']));
    final sellerName = JsonHelpers.readString(json['sellerName']).trim();
    final status = JsonHelpers.readString(json['status']).trim();
    if (id.isEmpty || category.isEmpty || animalCode.isEmpty || animalName.isEmpty || quantity <= 0 || unitPrice <= 0 || publishedDate == null || sellerName.isEmpty || status.isEmpty) {
      return null;
    }
    final isPublishedRaw = JsonHelpers.readString(json['isPublished']).trim();
    return AnimalSaleListing(
      id: id,
      category: category,
      animalCode: animalCode,
      animalName: animalName,
      breed: breed,
      quantity: quantity,
      unitPrice: unitPrice,
      weightKg: JsonHelpers.readDouble(json['weightKg']),
      publishedDate: publishedDate,
      sellerId: JsonHelpers.readString(json['sellerId']).trim(),
      sellerName: sellerName,
      contact: JsonHelpers.readString(json['contact']).trim(),
      location: JsonHelpers.readString(json['location']).trim(),
      status: status,
      isPublished: isPublishedRaw.toLowerCase() != 'false',
      description: JsonHelpers.readString(json['description']).trim(),
      imageBase64: JsonHelpers.readString(json['imageBase64']).trim(),
    );
  }
}
