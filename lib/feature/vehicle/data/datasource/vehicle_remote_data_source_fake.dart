import 'dart:io';

import 'package:vehicle_rental_system/feature/vehicle/data/datasource/vehicle_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/brand/data/model/brand_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_image_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';

class VehicleRemoteDataSourceFake implements VehicleRemoteDataSource {
  @override
  Future<List<BrandModel>> getBrands() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final names = _fakeVehicles
        .map((v) => v.brand)
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();

    return [
      for (var i = 0; i < names.length; i++)
        BrandModel(id: i + 1, name: names[i]),
    ];
  }

  @override
  Future<List<BookedDate>> getVehicleBookedDates(int vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Demo data: simulate an active reservation on the Fortuner (id 2).
    if (vehicleId == 2) {
      final now = DateTime.now();

      return [
        BookedDate(
          startDate: now.add(const Duration(days: 5)),
          endDate: now.add(const Duration(days: 8)),
        ),
        BookedDate(
          startDate: now.add(const Duration(days: 15)),
          endDate: now.add(const Duration(days: 17)),
        ),
      ];
    }

    return const [];
  }

  @override
  Future<List<VehicleModel>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _fakeVehicles;
  }

  @override
  Future<VehicleModel> getVehicleById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _fakeVehicles.firstWhere(
      (vehicle) => vehicle.id == id,
      orElse: () => throw Exception('Vehicle not found'),
    );
  }

  @override
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final nextId =
        _fakeVehicles.fold<int>(0, (maxId, v) => v.id > maxId ? v.id : maxId) +
        1;

    final created = _copy(vehicle, id: nextId);
    _fakeVehicles.add(created);

    return created;
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _fakeVehicles.indexWhere((v) => v.id == vehicle.id);

    if (index == -1) throw Exception('Vehicle not found');

    final updated = _copy(vehicle);
    _fakeVehicles[index] = updated;

    return updated;
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _fakeVehicles.removeWhere((vehicle) => vehicle.id == id);
  }

  @override
  Future<List<VehicleImageModel>> uploadVehicleImages(
    int vehicleId,
    List<File> images,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [];
  }

  @override
  Future<void> deleteVehicleImage(int vehicleImageId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateVehicleImage(
    int vehicleImageId, {
    required int vehicleId,
    required int attachmentId,
    required bool isPrimary,
    required int displayOrder,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  VehicleModel _copy(VehicleModel v, {int? id}) {
    return VehicleModel(
      id: id ?? v.id,
      brand: v.brand,
      model: v.model,
      yearOfManufacture: v.yearOfManufacture,
      licensePlate: v.licensePlate,
      color: v.color,
      type: v.type,
      transmission: v.transmission,
      fuelType: v.fuelType,
      seats: v.seats,
      doors: v.doors,
      luggages: v.luggages,
      pricePerDay: v.pricePerDay,
      mileAge: v.mileAge,
      description: v.description,
      status: v.status,
      images: v.images,
      createdAt: v.createdAt,
      updatedAt: v.updatedAt,
    );
  }
}

/* ================================================================
   FAKE VEHICLE DATA
   ================================================================ */

final List<VehicleModel> _fakeVehicles = [
  // ================================================================
  // MG D60
  // ================================================================
  VehicleModel(
    id: 11,
    brand: 'MG',
    model: 'D60',
    yearOfManufacture: 2026,
    licensePlate: '2L-6060',
    color: 'Black',
    type: 'SUV',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 60,
    mileAge: 5000,
    description:
        'The MG D60 is a modern SUV designed for comfortable everyday driving and longer journeys in Cambodia. Its spacious cabin, comfortable seating, strong air conditioning, and practical luggage capacity make it suitable for families, tourists, and business travelers. The 2026 model combines a modern exterior design with useful technology and a smooth automatic transmission, providing a comfortable driving experience around Phnom Penh and on trips to other provinces.',
    images: const [
      VehicleImageModel(
        id: 1,
        fileUrl:
            'https://i.pinimg.com/736x/59/ff/4e/59ff4ef36150760fb98823423cb63ae6.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 2,
        fileUrl:
            'https://i.pinimg.com/736x/4b/61/f8/4b61f865ea2a959daeb8947413aa9e34.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 3,
        fileUrl:
            'https://i.pinimg.com/736x/e5/f2/ff/e5f2ff1c9a87548034c51fc86493895b.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 4,
        fileUrl:
            'https://i.pinimg.com/736x/ef/08/86/ef08864b16f09a9b3d3a9601893aab2f.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // FORD TERRITORY
  // ================================================================
  VehicleModel(
    id: 9,
    brand: 'Ford',
    model: 'Territory',
    yearOfManufacture: 2024,
    licensePlate: '2J-6868',
    color: 'White',
    type: 'SUV',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 65,
    mileAge: 18000,
    description:
        'The Ford Territory is a modern compact SUV that provides a comfortable and practical driving experience for customers in Cambodia. Its spacious cabin, comfortable seats, strong air conditioning, and smooth automatic transmission make it suitable for daily driving in Phnom Penh and longer trips to destinations across the country. The Territory combines modern technology with a stylish exterior and practical interior space, making it a good choice for families, tourists, and business travelers.',
    images: const [
      VehicleImageModel(
        id: 5,
        fileUrl:
            'https://i.pinimg.com/736x/c5/82/de/c582de5f981a5d25d5e61ce4fc8aa435.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 6,
        fileUrl:
            'https://i.pinimg.com/736x/8e/c4/e8/8ec4e879a523691392e9cc9a5f8cb150.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 7,
        fileUrl:
            'https://i.pinimg.com/736x/e6/6c/e0/e66ce088c331a4b2eefe7d84287daf19.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 8,
        fileUrl:
            'https://i.pinimg.com/736x/16/c6/35/16c63596c71e242e3d9e0d50b7856fda.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 9,
        fileUrl:
            'https://i.pinimg.com/736x/1a/20/02/1a2002e6c9fdfb5307148132aa266fb1.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA CAMRY
  // ================================================================
  VehicleModel(
    id: 1,
    brand: 'Toyota',
    model: 'Camry',
    yearOfManufacture: 2022,
    licensePlate: '2A-5588',
    color: 'White',
    type: 'Sedan',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 55,
    mileAge: 42000,
    description:
        'The Toyota Camry is one of the most practical and comfortable sedans for driving in Cambodia. It offers a smooth ride, comfortable seating, excellent air conditioning, and good fuel efficiency for daily travel around Phnom Penh and longer trips between provinces. The spacious interior makes it suitable for families, business travelers, airport transfers, and city driving.',
    images: const [
      VehicleImageModel(
        id: 10,
        fileUrl:
            'https://i.pinimg.com/736x/c4/16/4f/c4164fc1e651a0b706ca37020941c44c.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 11,
        fileUrl:
            'https://i.pinimg.com/736x/75/f1/8a/75f18ad4ff629dee5d0a3711d12a924c.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 12,
        fileUrl:
            'https://i.pinimg.com/736x/00/24/5c/00245c53776334188c01c70bbea134dc.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 13,
        fileUrl:
            'https://i.pinimg.com/736x/5e/7d/b5/5e7db55e9315d6662821885dad66558a.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 14,
        fileUrl:
            'https://i.pinimg.com/736x/2c/42/62/2c426276343a92d711055493bfc65d44.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 15,
        fileUrl:
            'https://i.pinimg.com/736x/3d/73/22/3d732281e089f473548349b237339ce0.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 16,
        fileUrl:
            'https://i.pinimg.com/736x/0e/13/23/0e132360c48328566491f6bf70d7d0cf.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 17,
        fileUrl:
            'https://i.pinimg.com/736x/6b/35/39/6b35399c33e6bce7dfac420db5903d60.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA FORTUNER
  // ================================================================
  VehicleModel(
    id: 2,
    brand: 'Toyota',
    model: 'Fortuner',
    yearOfManufacture: 2023,
    licensePlate: '2B-7788',
    color: 'Black',
    type: 'SUV',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 7,
    doors: 5,
    luggages: 5,
    pricePerDay: 75,
    mileAge: 38000,
    description:
        'The Toyota Fortuner is a popular SUV choice for Cambodian roads because of its spacious interior, high driving position, strong performance, and excellent practicality. It is ideal for families and groups traveling around Phnom Penh or taking longer trips to Siem Reap, Kampot, Battambang, and other provinces. With seven seats, generous luggage space, strong air conditioning, and a comfortable automatic transmission, the Fortuner is well suited for both city driving and longer journeys.',
    images: const [
      VehicleImageModel(
        id: 18,
        fileUrl:
            'https://i.pinimg.com/736x/c5/35/d0/c535d0ce3a4b29811e7ea6e852bffc05.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 19,
        fileUrl:
            'https://i.pinimg.com/736x/17/0a/eb/170aeb25d8bd5f8a982549a5bdb8fb79.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 20,
        fileUrl:
            'https://i.pinimg.com/736x/67/66/13/676613b90102cc7cf63f5f859b09d368.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 21,
        fileUrl:
            'https://i.pinimg.com/736x/36/d7/66/36d7666ef56e4222228c1e2b4e6de5a4.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 22,
        fileUrl:
            'https://i.pinimg.com/736x/8d/b1/9e/8db19e885d5f3069923db571f9d2afba.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 23,
        fileUrl:
            'https://i.pinimg.com/736x/52/f9/6a/52f96a1ddcea255d43a2848d103101c3.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 24,
        fileUrl:
            'https://i.pinimg.com/736x/b6/96/dc/b696dc644b55ce633e4d67d9201c6362.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 25,
        fileUrl:
            'https://i.pinimg.com/736x/2e/81/4f/2e814f8a43634c38680967a17cd3b043.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
      VehicleImageModel(
        id: 26,
        fileUrl:
            'https://i.pinimg.com/736x/ec/69/28/ec6928759fe268b4b70ef87795a6e15f.jpg',
        isPrimary: false,
        displayOrder: 8,
      ),
      VehicleImageModel(
        id: 27,
        fileUrl:
            'https://i.pinimg.com/736x/29/0c/f4/290cf4eefe4fa5ac5d89af782972349c.jpg',
        isPrimary: false,
        displayOrder: 9,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // HONDA CR-V
  // ================================================================
  VehicleModel(
    id: 3,
    brand: 'Honda',
    model: 'CR-V',
    yearOfManufacture: 2023,
    licensePlate: '2C-2468',
    color: 'Silver',
    type: 'SUV',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 65,
    mileAge: 31000,
    description:
        'The Honda CR-V is a comfortable and practical SUV for everyday driving in Cambodia. Its compact size makes it easier to drive and park in busy Phnom Penh streets while still providing plenty of space for passengers and luggage. The CR-V offers good fuel efficiency, comfortable seating, strong air conditioning, and a smooth automatic transmission. It is an excellent choice for families, tourists, business travelers, and customers planning trips outside Phnom Penh.',
    images: const [
      VehicleImageModel(
        id: 28,
        fileUrl:
            'https://i.pinimg.com/736x/44/75/95/447595020930784f37d6fcb6ca763720.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 29,
        fileUrl:
            'https://i.pinimg.com/736x/ad/8e/b9/ad8eb9042fa65718cdf5b285c6f74022.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 30,
        fileUrl:
            'https://i.pinimg.com/736x/cb/84/9d/cb849d64939d72a43553f3d5700510da.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 31,
        fileUrl:
            'https://i.pinimg.com/736x/5c/5e/ce/5c5ece072c3b5fab6d587b4ad18b8272.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 32,
        fileUrl:
            'https://i.pinimg.com/736x/d6/5d/52/d65d52a3859aeaff6d234685d7c99939.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 33,
        fileUrl:
            'https://i.pinimg.com/736x/00/0c/37/000c37494517b0e3b510650f34b709ab.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 34,
        fileUrl:
            'https://i.pinimg.com/736x/eb/72/fb/eb72fb7909662371418eeaaaa3b1176e.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 35,
        fileUrl:
            'https://i.pinimg.com/736x/2e/8d/7b/2e8d7b4b67e702e660134694f42f3f3c.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // LEXUS RX 350
  // ================================================================
  VehicleModel(
    id: 4,
    brand: 'Lexus',
    model: 'RX 350',
    yearOfManufacture: 2022,
    licensePlate: '2D-8888',
    color: 'Black',
    type: 'Luxury',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 110,
    mileAge: 28000,
    description:
        'The Lexus RX 350 is a premium SUV designed for customers who want extra comfort, luxury, and a smooth driving experience. It is particularly suitable for business trips, weddings, airport transfers, family travel, and special occasions in Cambodia. The spacious cabin, premium leather interior, excellent air conditioning, quiet ride, and advanced safety features provide a high level of comfort for both driver and passengers.',
    images: const [
      VehicleImageModel(
        id: 36,
        fileUrl:
            'https://i.pinimg.com/736x/a5/06/c2/a506c276fd00fb1308262b1585708fb2.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 37,
        fileUrl:
            'https://i.pinimg.com/736x/2f/89/69/2f8969c92d7ef2f30ef39e8dce6550ac.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 38,
        fileUrl:
            'https://i.pinimg.com/736x/d4/b7/40/d4b740f9dde1240ec3288f4721bfe25d.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 39,
        fileUrl:
            'https://i.pinimg.com/736x/09/d6/53/09d653a2d3389abf1dacf3ccd2cbf797.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 40,
        fileUrl:
            'https://i.pinimg.com/736x/15/a6/97/15a69789795739e3ea6c14820aabbab7.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 41,
        fileUrl:
            'https://i.pinimg.com/736x/fb/54/72/fb547258c972fcb6cd7649e12ea242dc.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 42,
        fileUrl:
            'https://i.pinimg.com/736x/11/49/4e/11494e8e9e002b10ce990b1a22795265.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 43,
        fileUrl:
            'https://i.pinimg.com/736x/6c/5e/92/6c5e92a3f7f6805c791192b30b27a901.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
      VehicleImageModel(
        id: 44,
        fileUrl:
            'https://i.pinimg.com/736x/e6/3b/5a/e63b5abe72b8b3825b181025c4b4a93f.jpg',
        isPrimary: false,
        displayOrder: 8,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // FORD RANGER
  // ================================================================
  VehicleModel(
    id: 5,
    brand: 'Ford',
    model: 'Ranger',
    yearOfManufacture: 2023,
    licensePlate: '2E-4567',
    color: 'Blue',
    type: 'Pickup',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 70,
    mileAge: 45000,
    description:
        'The Ford Ranger is a versatile pickup truck suitable for both city driving and travel throughout Cambodia. Its strong engine, high ground clearance, and large cargo area make it useful for customers who need additional carrying capacity or plan to travel on less developed roads. The Ranger provides a comfortable modern cabin with strong air conditioning, Bluetooth connectivity, parking assistance, and a smooth automatic transmission.',
    images: const [
      VehicleImageModel(
        id: 45,
        fileUrl:
            'https://i.pinimg.com/736x/52/e4/dc/52e4dc1f99f3c79112c800e06bb57028.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 46,
        fileUrl:
            'https://i.pinimg.com/736x/99/e3/37/99e337b201a46cac40984fb9329528d8.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 47,
        fileUrl:
            'https://i.pinimg.com/736x/a3/3d/5c/a33d5c0643fda25deca8f435db68de0d.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 48,
        fileUrl:
            'https://i.pinimg.com/736x/67/4c/c4/674cc42ea8555a753f1768e96c41a82a.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // HYUNDAI STARIA
  // ================================================================
  VehicleModel(
    id: 6,
    brand: 'Hyundai',
    model: 'Staria',
    yearOfManufacture: 2023,
    licensePlate: '2F-7777',
    color: 'White',
    type: 'Van',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 9,
    doors: 5,
    luggages: 6,
    pricePerDay: 85,
    mileAge: 35000,
    description:
        'The Hyundai Staria is a spacious modern van designed for families, tour groups, airport transfers, and business travel in Cambodia. Its large interior provides comfortable seating for passengers and plenty of room for luggage, making it ideal for group trips to destinations such as Siem Reap, Kampot, Kep, Battambang, and Sihanoukville. The vehicle provides strong air conditioning, comfortable seats, modern entertainment technology, and a smooth automatic transmission for comfortable long-distance travel.',
    images: const [
      VehicleImageModel(
        id: 49,
        fileUrl:
            'https://i.pinimg.com/736x/6e/4a/b8/6e4ab84cce98bcb94e95bde4958c4f52.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 50,
        fileUrl:
            'https://i.pinimg.com/736x/b7/b7/76/b7b776e94f30aa6c896cd4156eebbd01.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 51,
        fileUrl:
            'https://i.pinimg.com/736x/59/7b/af/597bafdedc784adefdfeaa529c4c2c1e.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 52,
        fileUrl:
            'https://i.pinimg.com/736x/69/1c/ca/691ccaa5d88ee3f48e6f8cffebac141a.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 53,
        fileUrl:
            'https://i.pinimg.com/736x/f5/d3/0f/f5d30f280f93aded55cece12911ac022.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 54,
        fileUrl:
            'https://i.pinimg.com/736x/8e/8e/81/8e8e814a3c45ba08a09396ddd030118d.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA RAV4
  // ================================================================
  VehicleModel(
    id: 7,
    brand: 'Toyota',
    model: 'RAV4',
    yearOfManufacture: 2022,
    licensePlate: '2G-3333',
    color: 'Gray',
    type: 'SUV',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 60,
    mileAge: 33000,
    description:
        'The Toyota RAV4 is a practical compact SUV for customers who want a comfortable vehicle that is easy to drive around Phnom Penh while also being suitable for longer trips. It offers good fuel efficiency, comfortable seating, useful luggage capacity, and a smooth automatic transmission. The RAV4 is a good choice for couples, small families, tourists, and business travelers who want a reliable vehicle for exploring Cambodia.',
    images: const [
      VehicleImageModel(
        id: 55,
        fileUrl:
            'https://i.pinimg.com/736x/e2/70/bd/e270bd99e4e40bf43792aaf6332167eb.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 56,
        fileUrl:
            'https://i.pinimg.com/736x/ed/ef/25/edef2592ef0d708a5588ca2e787dc945.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 57,
        fileUrl:
            'https://i.pinimg.com/736x/85/d1/37/85d1376a5cb760b9599d4e5869bead01.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 58,
        fileUrl:
            'https://i.pinimg.com/736x/29/3d/31/293d31be7eb56cfc87b4d1e73f1684ef.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 59,
        fileUrl:
            'https://i.pinimg.com/736x/19/c0/7e/19c07e17b676cf80848f0cd9d2c15d91.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 60,
        fileUrl:
            'https://i.pinimg.com/736x/39/f1/44/39f144c20a7e036fc0f3699b5f131d50.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 61,
        fileUrl:
            'https://i.pinimg.com/736x/1d/66/39/1d6639d530b2bfadf01ac0469f729aa1.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 62,
        fileUrl:
            'https://i.pinimg.com/736x/22/45/b6/2245b602c7bee2c12592454f12210bdb.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
      VehicleImageModel(
        id: 63,
        fileUrl:
            'https://i.pinimg.com/736x/52/69/72/52697201d897a6a3091fdb05c6d7327b.jpg',
        isPrimary: false,
        displayOrder: 8,
      ),
      VehicleImageModel(
        id: 64,
        fileUrl:
            'https://i.pinimg.com/736x/29/de/a7/29dea7216e6540df74ec0dc0b1b86dc0.jpg',
        isPrimary: false,
        displayOrder: 9,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TESLA MODEL 3
  // ================================================================
  VehicleModel(
    id: 8,
    brand: 'Tesla',
    model: 'Model 3',
    yearOfManufacture: 2024,
    licensePlate: '2H-9999',
    color: 'Red',
    type: 'Electric',
    transmission: 'Automatic',
    fuelType: 'Electric',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 95,
    mileAge: 10000,
    description:
        'The Tesla Model 3 is a modern electric sedan for customers who want a quiet, technology-focused driving experience in Cambodia. Its electric powertrain provides smooth acceleration and eliminates the need for traditional petrol or diesel fuel. The minimalist interior features a large touchscreen, Bluetooth connectivity, premium audio, and advanced driver assistance technology.',
    images: const [
      VehicleImageModel(
        id: 65,
        fileUrl:
            'https://i.pinimg.com/736x/6f/7d/45/6f7d453c5a327f783e5391bcaf9805ae.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 66,
        fileUrl:
            'https://i.pinimg.com/736x/e2/bf/55/e2bf55ab899257ecf3f7ca069f5d3e23.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 67,
        fileUrl:
            'https://i.pinimg.com/736x/e9/ba/de/e9bade618d6d908d00384de5fcfb31aa.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 68,
        fileUrl:
            'https://i.pinimg.com/736x/60/de/3c/60de3cd2352a7386c92a89ac94289b3e.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
      VehicleImageModel(
        id: 69,
        fileUrl:
            'https://i.pinimg.com/736x/db/e7/1a/dbe71a4c9df5c64c7dc799ee915d7649.jpg',
        isPrimary: false,
        displayOrder: 4,
      ),
      VehicleImageModel(
        id: 70,
        fileUrl:
            'https://i.pinimg.com/736x/32/21/3d/32213d4db52bcf12b230e34dbe9a745d.jpg',
        isPrimary: false,
        displayOrder: 5,
      ),
      VehicleImageModel(
        id: 71,
        fileUrl:
            'https://i.pinimg.com/736x/61/b3/c1/61b3c1ab5564d61a8bc0505c06253258.jpg',
        isPrimary: false,
        displayOrder: 6,
      ),
      VehicleImageModel(
        id: 72,
        fileUrl:
            'https://i.pinimg.com/736x/41/55/fb/4155fb75cfb8d00cc41c9c7192ef236b.jpg',
        isPrimary: false,
        displayOrder: 7,
      ),
      VehicleImageModel(
        id: 73,
        fileUrl:
            'https://i.pinimg.com/736x/80/e7/12/80e712147067d70df3890df76d42f2c9.jpg',
        isPrimary: false,
        displayOrder: 8,
      ),
      VehicleImageModel(
        id: 74,
        fileUrl:
            'https://i.pinimg.com/736x/32/36/4c/32364cc4ee18480cba194fb1fd227e1d.jpg',
        isPrimary: false,
        displayOrder: 9,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA COROLLA
  // ================================================================
  VehicleModel(
    id: 12,
    brand: 'Toyota',
    model: 'Corolla',
    yearOfManufacture: 2023,
    licensePlate: '2J-1212',
    color: 'Silver',
    type: 'Sedan',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 45,
    mileAge: 25000,
    description:
        'The Toyota Corolla is a reliable and economical sedan suitable for city driving, business trips, and everyday travel around Cambodia. Its comfortable interior, excellent air conditioning, and fuel-efficient engine make it a practical rental choice.',
    images: const [
      VehicleImageModel(
        id: 75,
        fileUrl:
            'https://i.pinimg.com/736x/68/fd/65/68fd6521db1c9ef2ffd4eb0f901fa067.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 76,
        fileUrl:
            'https://i.pinimg.com/736x/5e/f7/a2/5ef7a2cc7110bf605388558bca415e9a.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 77,
        fileUrl:
            'https://i.pinimg.com/736x/69/2c/2c/692c2cfd95acbbd955095c8b27c60ffa.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 78,
        fileUrl:
            'https://i.pinimg.com/736x/40/b7/34/40b734da575b6441d8ee7ed91d2fb117.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // HONDA CIVIC
  // ================================================================
  VehicleModel(
    id: 13,
    brand: 'Honda',
    model: 'Civic',
    yearOfManufacture: 2024,
    licensePlate: '2K-3434',
    color: 'Black',
    type: 'Sedan',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 58,
    mileAge: 15000,
    description:
        'The Honda Civic is a stylish and comfortable sedan with excellent handling, modern technology, and efficient fuel consumption. It is ideal for city driving and longer journeys throughout Cambodia.',
    images: const [
      VehicleImageModel(
        id: 79,
        fileUrl:
            'https://i.pinimg.com/1200x/ab/d6/d1/abd6d12171dc9f62be05ee088a2ce90a.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // MERCEDES-BENZ E-CLASS
  // ================================================================
  VehicleModel(
    id: 14,
    brand: 'Mercedes-Benz',
    model: 'E-Class',
    yearOfManufacture: 2024,
    licensePlate: '2L-4545',
    color: 'Black',
    type: 'Luxury',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 4,
    luggages: 4,
    pricePerDay: 150,
    mileAge: 12000,
    description:
        'The Mercedes-Benz E-Class provides a premium driving experience with a luxurious interior, advanced technology, excellent comfort, and smooth performance. It is ideal for business trips, weddings, airport transfers, and special occasions.',
    images: const [
      VehicleImageModel(
        id: 80,
        fileUrl:
            'https://i.pinimg.com/736x/98/15/19/981519ccbdf7807f5d2283c367398b75.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // BMW X5
  // ================================================================
  VehicleModel(
    id: 15,
    brand: 'BMW',
    model: 'X5',
    yearOfManufacture: 2023,
    licensePlate: '2M-5656',
    color: 'White',
    type: 'Luxury',
    transmission: 'Automatic',
    fuelType: 'Petrol',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 140,
    mileAge: 22000,
    description:
        'The BMW X5 is a premium SUV combining luxury, comfort, powerful performance, and advanced technology. It is suitable for business travelers, families, airport transfers, and long-distance journeys.',
    images: const [
      VehicleImageModel(
        id: 81,
        fileUrl:
            'https://i.pinimg.com/1200x/f6/98/29/f69829f29b6fa6e7267dcffb612d9e42.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA HILUX
  // ================================================================
  VehicleModel(
    id: 16,
    brand: 'Toyota',
    model: 'Hilux',
    yearOfManufacture: 2024,
    licensePlate: '2N-6767',
    color: 'White',
    type: 'Pickup',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 72,
    mileAge: 28000,
    description:
        'The Toyota Hilux is a durable and practical pickup truck suitable for city driving, business activities, outdoor trips, and travel throughout Cambodia. Its high ground clearance and large cargo bed make it useful for longer journeys and carrying equipment.',
    images: const [
      VehicleImageModel(
        id: 82,
        fileUrl:
            'https://i.pinimg.com/736x/f9/c3/9b/f9c39ba3a3d040bc3433e849984fbed4.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 83,
        fileUrl:
            'https://i.pinimg.com/736x/45/d1/3d/45d13d20b47acdc995518fa4e469f18e.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 84,
        fileUrl:
            'https://i.pinimg.com/736x/8a/dd/2b/8add2b656baace1298dda11f3eb4d5d5.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 85,
        fileUrl:
            'https://i.pinimg.com/736x/2c/ea/bc/2ceabcc50e4bccde5ce9a8d2029f8404.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // MITSUBISHI TRITON
  // ================================================================
  VehicleModel(
    id: 17,
    brand: 'Mitsubishi',
    model: 'Triton',
    yearOfManufacture: 2023,
    licensePlate: '2P-7878',
    color: 'Gray',
    type: 'Pickup',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 5,
    doors: 4,
    luggages: 3,
    pricePerDay: 68,
    mileAge: 35000,
    description:
        'The Mitsubishi Triton is a practical pickup truck designed for both urban driving and provincial travel. It provides good ground clearance, useful cargo capacity, and strong performance for customers who need a versatile rental vehicle.',
    images: const [
      VehicleImageModel(
        id: 86,
        fileUrl:
            'https://i.pinimg.com/1200x/25/bf/c6/25bfc6f6d24d6adec450064a2eb4544a.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TOYOTA HIACE
  // ================================================================
  VehicleModel(
    id: 18,
    brand: 'Toyota',
    model: 'Hiace',
    yearOfManufacture: 2023,
    licensePlate: '2Q-8989',
    color: 'White',
    type: 'Van',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 12,
    doors: 4,
    luggages: 8,
    pricePerDay: 90,
    mileAge: 40000,
    description:
        'The Toyota Hiace is a spacious passenger van suitable for families, tour groups, airport transfers, and business travel. Its large cabin and luggage capacity make it ideal for group trips around Cambodia.',
    images: const [
      VehicleImageModel(
        id: 87,
        fileUrl:
            'https://i.pinimg.com/736x/fb/b8/ec/fbb8ecc369bd2da430271398e27fc03b.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 88,
        fileUrl:
            'https://i.pinimg.com/736x/8c/df/ac/8cdfac0aeaea961f142079d34fb98b05.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 89,
        fileUrl:
            'https://i.pinimg.com/736x/91/08/2a/91082a3722c167591c29f735382cb8e1.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 90,
        fileUrl:
            'https://i.pinimg.com/736x/d0/04/2b/d0042bf82b2578e9621e696abb6c7053.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // KIA CARNIVAL
  // ================================================================
  VehicleModel(
    id: 19,
    brand: 'Kia',
    model: 'Carnival',
    yearOfManufacture: 2024,
    licensePlate: '2R-9090',
    color: 'Black',
    type: 'Van',
    transmission: 'Automatic',
    fuelType: 'Diesel',
    seats: 8,
    doors: 5,
    luggages: 6,
    pricePerDay: 100,
    mileAge: 18000,
    description:
        'The Kia Carnival is a premium family van with a spacious interior, comfortable seating, modern technology, and excellent luggage capacity. It is ideal for families, tourists, business groups, and airport transfers.',
    images: const [
      VehicleImageModel(
        id: 91,
        fileUrl:
            'https://i.pinimg.com/736x/78/74/49/787449a9a98f6b597c7a12a30e6692bf.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
      VehicleImageModel(
        id: 92,
        fileUrl:
            'https://i.pinimg.com/736x/1e/5d/5a/1e5d5aaf87b59c0bb24a3a68a7a23d86.jpg',
        isPrimary: false,
        displayOrder: 1,
      ),
      VehicleImageModel(
        id: 93,
        fileUrl:
            'https://i.pinimg.com/736x/5d/8e/62/5d8e62320ecdffb81020f11afaa80b9a.jpg',
        isPrimary: false,
        displayOrder: 2,
      ),
      VehicleImageModel(
        id: 94,
        fileUrl:
            'https://i.pinimg.com/736x/21/d7/4c/21d74c8f5af2dbcb251b5b9d1d6263a4.jpg',
        isPrimary: false,
        displayOrder: 3,
      ),
    ],
    status: 'Available',
  ),

  // ================================================================
  // TESLA MODEL Y
  // ================================================================
  VehicleModel(
    id: 20,
    brand: 'Tesla',
    model: 'Model Y',
    yearOfManufacture: 2024,
    licensePlate: '2S-1111',
    color: 'White',
    type: 'Electric',
    transmission: 'Automatic',
    fuelType: 'Electric',
    seats: 5,
    doors: 5,
    luggages: 4,
    pricePerDay: 105,
    mileAge: 8000,
    description:
        'The Tesla Model Y is a modern electric SUV offering a quiet and technology-focused driving experience. It provides excellent interior space, fast charging, advanced driver assistance, and comfortable city driving.',
    images: const [
      VehicleImageModel(
        id: 95,
        fileUrl:
            'https://i.pinimg.com/1200x/01/e9/2c/01e92c7aae127cb3a051c0ee167e7238.jpg',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    status: 'Available',
  ),
];
