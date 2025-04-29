
class Address {
  final String id;
  final String name;
  final String streetOne;
  final String? streetTwo;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String addressType; 
  final bool isDefault; 

  Address({
    required this.id,
    required this.name,
    required this.streetOne,
    this.streetTwo,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    required this.isDefault,
  });

  Address.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? '',
        name = map['name'] ?? '',
        streetOne = map['street1'] ?? '',
        streetTwo = map['street2'],
        city = map['city'] ?? '',
        state = map['state'] ?? '',
        postalCode = map['postal_code'] ?? '',
        country = map['country'] ?? '',
        addressType = map['address_type'] ?? '',
        isDefault = map['is_default'] ?? false;



  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      streetOne: json['street1'],
      streetTwo: json['street2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      addressType: json['address_type'],
      isDefault: json['is_default'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'street1': streetOne,
        'street2': streetTwo,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'address_type': addressType,
        'is_default': isDefault,
      };
}

class Shipment {
  final String id;
  final String trackingNumber;
  final String? courierTrackingNumber;
  final String? carrier;
  final String? service;
  final String status;
  final String? fromAddressId;
  final String? toAddressId;
  final double? weight;
  final Dimensions? dimensions;
  final String? packageType;
  final String? packageContents;
  final double? declaredValue;
  final double? shippingCost;
  final String? labelUrl;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final String? deliveryInstructions;
  final bool? signatureRequired;
  final int? deliveryAttempts;
  final String? priority;
  final List<String>? tags;
  final String? notes;
  final Address? fromAddress;
  final Address? toAddress;
  final dynamic origin;
  final dynamic destination;
  final int? quantity;
  final String? receiverName;

  Shipment({
    required this.id,
    required this.trackingNumber,
    this.courierTrackingNumber,
    this.carrier,
    this.service,
    required this.status,
    this.fromAddressId,
    this.toAddressId,
    this.weight,
    this.dimensions,
    this.packageType,
    this.packageContents,
    this.declaredValue,
    this.shippingCost,
    this.labelUrl,
    required this.createdAt,
    this.estimatedDelivery,
    this.actualDelivery,
    this.deliveryInstructions,
    this.signatureRequired,
    this.deliveryAttempts,
    this.priority,
    this.tags,
    this.notes,
    this.fromAddress,
    this.toAddress,
    this.destination,
    this.origin,
    this.quantity,
    this.receiverName
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'],
      trackingNumber: json['tracking_number'],
      courierTrackingNumber: json['courier_tracking_number'],
      carrier: json['carrier'],
      service: json['service'],
      status: json['status'],
      fromAddressId: json['from_address_id'],
      toAddressId: json['to_address_id'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'] != null ? Dimensions.fromJson(json['dimensions']) : null,
      packageType: json['package_type'],
      packageContents: json['package_contents'],
      declaredValue: json['declared_value']?.toDouble(),
      shippingCost: json['shipping_cost']?.toDouble(),
      labelUrl: json['label_url'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.tryParse(json['estimated_delivery'])
          : null,
      actualDelivery: json['actual_delivery'] != null ? DateTime.parse(json['actual_delivery']): null,
      deliveryInstructions: json['delivery_instructions'],
      signatureRequired: json['signature_required'],
      deliveryAttempts: json['delivery_attempts'],
      priority: json['priority'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      notes: json['notes'],
      fromAddress: json['from_address'] != null ? Address.fromJson(json['from_address']) : null,
      toAddress: json['to_address'] != null ? Address.fromJson(json['to_address']) : null,
      origin: json['origin'],
      destination: json['destination'],
      quantity: json['quantity'],
      receiverName: json['receiver_name']
    );
  }
}

class Dimensions {
  final double length;
  final double width;
  final double height;
  final String unit;

  Dimensions({
    required this.length,
    required this.width,
    required this.height,
    required this.unit,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      length: json['length'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      unit: json['unit'],
    );
  }
}

