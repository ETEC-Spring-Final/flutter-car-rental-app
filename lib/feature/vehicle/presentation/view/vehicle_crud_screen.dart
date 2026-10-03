import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle_image.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';

class VehicleCrudScreen extends StatefulWidget {
  const VehicleCrudScreen({super.key});

  @override
  State<VehicleCrudScreen> createState() => _VehicleCrudScreenState();
}

class _VehicleCrudScreenState extends State<VehicleCrudScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load first page.
    context.read<VehicleBloc>().add(const GetVehicles(refresh: true));

    // Load brands for the vehicle form.
    context.read<BrandBloc>().add(const GetBrands(refresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // =====================================================================
  // PAGINATION
  // =====================================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    // Start loading the next page when the user is
    // approximately 300 pixels from the bottom.
    if (position.pixels >= position.maxScrollExtent - 300) {
      final state = context.read<VehicleBloc>().state;

      if (state is VehicleLoaded) {
        if (!state.hasReachedMax && !state.isLoadingMore) {
          context.read<VehicleBloc>().add(const GetVehicles());
        }
      }
    }
  }

  // =====================================================================
  // REFRESH
  // =====================================================================

  Future<void> _refresh() async {
    context.read<VehicleBloc>().add(const GetVehicles(refresh: true));

    context.read<BrandBloc>().add(const GetBrands(refresh: true));
  }

  // =====================================================================
  // OPEN FORM
  // =====================================================================

  Future<void> _openForm([Vehicle? vehicle]) async {
    final result = await Navigator.of(context).push<_VehicleFormResult>(
      MaterialPageRoute(builder: (_) => _VehicleFormScreen(vehicle: vehicle)),
    );

    if (result == null || !mounted) {
      return;
    }

    // CREATE
    if (vehicle == null) {
      context.read<VehicleBloc>().add(
        CreateVehicleEvent(
          vehicle: result.vehicle,
          imageEdits: result.imageEdits,
        ),
      );
    }
    // UPDATE
    else {
      context.read<VehicleBloc>().add(
        UpdateVehicleEvent(
          vehicle: result.vehicle,
          imageEdits: result.imageEdits,
        ),
      );
    }
  }

  // =====================================================================
  // DELETE CONFIRMATION
  // =====================================================================

  Future<void> _confirmDelete(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text(
            'Delete "${vehicle.brand} ${vehicle.model}" '
            '(ID: ${vehicle.id})? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    context.read<VehicleBloc>().add(DeleteVehicleEvent(vehicle.id));
  }

  // =====================================================================
  // BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        // ---------------------------------------------------------------
        // SUCCESS
        // ---------------------------------------------------------------

        if (state is VehicleSuccess) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.message)));

          // Refresh from page 0 after CRUD operation.
          context.read<VehicleBloc>().add(const GetVehicles(refresh: true));
        }

        // ---------------------------------------------------------------
        // ERROR
        // ---------------------------------------------------------------

        if (state is VehicleError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Vehicle CRUD (Test)')),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Vehicle'),
        ),

        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            // ===========================================================
            // INITIAL / FIRST PAGE LOADING
            // ===========================================================

            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ===========================================================
            // ERROR
            // ===========================================================

            if (state is VehicleError) {
              return _ErrorState(message: state.message, onRetry: _refresh);
            }

            // ===========================================================
            // INITIAL STATE
            // ===========================================================

            if (state is! VehicleLoaded) {
              return _ErrorState(
                message: 'No vehicles loaded.',
                onRetry: _refresh,
              );
            }

            // ===========================================================
            // EMPTY
            // ===========================================================

            if (state.vehicles.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64.r,
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        'No vehicles found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        'Tap "Add Vehicle" to create one.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ===========================================================
            // VEHICLE LIST
            // ===========================================================

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppDimensions.chipHorizontalPadding),

                // +1 for the bottom loading indicator.
                itemCount:
                    state.vehicles.length + (state.isLoadingMore ? 1 : 0),

                separatorBuilder: (_, _) {
                  return SizedBox(height: 12.h);
                },

                itemBuilder: (context, index) {
                  // -----------------------------------------------------
                  // LOADING MORE INDICATOR
                  // -----------------------------------------------------

                  if (index >= state.vehicles.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  // -----------------------------------------------------
                  // VEHICLE
                  // -----------------------------------------------------

                  final vehicle = state.vehicles[index];

                  return _VehicleCard(
                    vehicle: vehicle,
                    onEdit: () => _openForm(vehicle),
                    onDelete: () => _confirmDelete(vehicle),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR STATE
// =====================================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56.r,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// VEHICLE CARD
// =====================================================================

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            _Thumbnail(vehicle: vehicle),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    '${vehicle.yearOfManufacture} • '
                    '${vehicle.type} • '
                    '${vehicle.licensePlate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '\$${vehicle.pricePerDay.toStringAsFixed(0)}/day',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            context,
                            vehicle.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          vehicle.status.isEmpty ? '-' : vehicle.status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _statusColor(context, vehicle.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                ),

                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;

      case 'rented':
      case 'booked':
        return colorScheme.primary;

      case 'maintenance':
        return Colors.orange;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

// =====================================================================
// THUMBNAIL
// =====================================================================

class _Thumbnail extends StatelessWidget {
  final Vehicle vehicle;

  const _Thumbnail({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final url = vehicle.images.isNotEmpty ? vehicle.images.first.fileUrl : null;

    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? Icon(
              Icons.directions_car_outlined,
              size: 28.r,
              color: colorScheme.onSurfaceVariant,
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.broken_image_outlined,
                  size: 28.r,
                  color: colorScheme.onSurfaceVariant,
                );
              },
            ),
    );
  }
}

// =====================================================================
// FORM RESULT
// =====================================================================

class _VehicleFormResult {
  final Vehicle vehicle;
  final VehicleImageEdits imageEdits;

  const _VehicleFormResult({required this.vehicle, required this.imageEdits});
}

// =====================================================================
// VEHICLE FORM
// =====================================================================

class _VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const _VehicleFormScreen({this.vehicle});

  @override
  State<_VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<_VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<File> _pickedImages = [];
  final Set<int> _removedImageIds = {};

  /// Existing image ID -> replacement file.
  final Map<int, File> _replaceMap = {};

  /// Existing image ID that becomes the primary image.
  int? _primaryExistingId;

  /// New image index that becomes the primary image.
  int? _primaryNewImageIndex;

  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _licensePlate;
  late final TextEditingController _color;
  late final TextEditingController _seats;
  late final TextEditingController _doors;
  late final TextEditingController _luggages;
  late final TextEditingController _price;
  late final TextEditingController _mileAge;
  late final TextEditingController _description;

  late List<String> _types;
  late List<String> _transmissions;
  late List<String> _fuelTypes;
  late List<String> _statuses;

  late String _type;
  late String _transmission;
  late String _fuelType;
  late String _status;

  int _brandId = 0;

  static const List<String> _defaultTypes = [
    'SUV',
    'SEDAN',
    'PICKUP',
    'VAN',
    'LUXURY',
    'ELECTRIC',
  ];

  static const List<String> _defaultTransmissions = ['AUTOMATIC', 'MANUAL'];

  static const List<String> _defaultFuelTypes = [
    'PETROL',
    'DIESEL',
    'ELECTRIC',
    'HYBRID',
  ];

  static const List<String> _defaultStatuses = [
    'AVAILABLE',
    'BOOKED',
    'RENTED',
    'MAINTENANCE',
  ];

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();

    final v = widget.vehicle;

    _model = TextEditingController(text: v?.model ?? '');

    _year = TextEditingController(
      text: v != null ? v.yearOfManufacture.toString() : '',
    );

    _licensePlate = TextEditingController(text: v?.licensePlate ?? '');

    _color = TextEditingController(text: v?.color ?? '');

    _seats = TextEditingController(text: v != null ? v.seats.toString() : '');

    _doors = TextEditingController(text: v != null ? v.doors.toString() : '');

    _luggages = TextEditingController(
      text: v != null ? v.luggages.toString() : '',
    );

    _price = TextEditingController(
      text: v != null ? _dropTrailingZeros(v.pricePerDay) : '',
    );

    _mileAge = TextEditingController(
      text: v != null ? v.mileAge.toString() : '',
    );

    _description = TextEditingController(text: v?.description ?? '');

    _types = _withFallback(_defaultTypes, v?.type);

    _transmissions = _withFallback(_defaultTransmissions, v?.transmission);

    _fuelTypes = _withFallback(_defaultFuelTypes, v?.fuelType);

    _statuses = _withFallback(_defaultStatuses, v?.status);

    _type = _types.contains(v?.type) ? v!.type : _types.first;

    _transmission = _transmissions.contains(v?.transmission)
        ? v!.transmission
        : _transmissions.first;

    _fuelType = _fuelTypes.contains(v?.fuelType)
        ? v!.fuelType
        : _fuelTypes.first;

    _status = _statuses.contains(v?.status) ? v!.status : _statuses.first;

    _brandId = _resolveInitialBrandId(v);

    if (v != null) {
      for (final image in v.images) {
        if (image.isPrimary) {
          _primaryExistingId = image.id;
          break;
        }
      }
    }

    // Make sure brands are loaded.
    final state = context.read<BrandBloc>().state;

    if (state is! BrandsLoaded) {
      context.read<BrandBloc>().add(const GetBrands(refresh: true));
    }
  }

  // ===================================================================
  // BRAND ID
  // ===================================================================

  int _resolveInitialBrandId(Vehicle? v) {
    if (v == null) {
      return 0;
    }

    // Best case:
    // Backend already returned the brand ID.
    if (v.brandId != 0) {
      return v.brandId;
    }

    // Fallback:
    // Find the ID using brand name.
    final state = context.read<BrandBloc>().state;

    if (state is BrandsLoaded) {
      for (final brand in state.brands) {
        if (brand.name == v.brand) {
          return brand.id;
        }
      }
    }

    return 0;
  }

  // ===================================================================
  // BRAND NAME
  // ===================================================================

  String _resolveBrandName() {
    final state = context.read<BrandBloc>().state;

    if (state is BrandsLoaded) {
      for (final brand in state.brands) {
        if (brand.id == _brandId) {
          return brand.name;
        }
      }
    }

    return widget.vehicle?.brand ?? '';
  }

  // ===================================================================
  // HELPERS
  // ===================================================================

  static List<String> _withFallback(List<String> options, String? value) {
    if (value == null || value.isEmpty) {
      return options;
    }

    if (options.contains(value)) {
      return options;
    }

    return [value, ...options];
  }

  static String _dropTrailingZeros(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _model.dispose();
    _year.dispose();
    _licensePlate.dispose();
    _color.dispose();
    _seats.dispose();
    _doors.dispose();
    _luggages.dispose();
    _price.dispose();
    _mileAge.dispose();
    _description.dispose();

    super.dispose();
  }

  // ===================================================================
  // SUBMIT
  // ===================================================================

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final current = widget.vehicle;

    final vehicle = Vehicle(
      id: current?.id ?? 0,

      brandId: _brandId,

      brand: _resolveBrandName(),

      model: _model.text.trim(),

      yearOfManufacture: int.parse(_year.text.trim()),

      licensePlate: _licensePlate.text.trim(),

      color: _color.text.trim(),

      type: _type,

      transmission: _transmission,

      fuelType: _fuelType,

      seats: int.parse(_seats.text.trim()),

      doors: int.parse(_doors.text.trim()),

      luggages: int.parse(_luggages.text.trim()),

      pricePerDay: double.parse(_price.text.trim()),

      mileAge: int.parse(_mileAge.text.trim()),

      description: _description.text.trim(),

      status: _status,

      images: current?.images ?? const [],

      createdAt: current?.createdAt,

      updatedAt: current?.updatedAt,
    );

    Navigator.of(context).pop(
      _VehicleFormResult(
        vehicle: vehicle,
        imageEdits: VehicleImageEdits(
          newImages: List.unmodifiable(_pickedImages),
          removeImageIds: Set.unmodifiable(_removedImageIds).toList(),
          primaryImageId: _isEditing ? _primaryExistingId : null,
          primaryNewImageIndex: _primaryNewImageIndex,
        ),
      ),
    );
  }

  // ===================================================================
  // PICK IMAGES
  // ===================================================================

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();

    if (picked.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _pickedImages.addAll(picked.map((image) => File(image.path)));
    });
  }

  void _removePickedImage(int index) {
    final file = _pickedImages[index];

    setState(() {
      _pickedImages.removeAt(index);

      int? replacedId;

      for (final entry in _replaceMap.entries) {
        if (entry.value.path == file.path) {
          replacedId = entry.key;
          break;
        }
      }

      if (replacedId != null) {
        _replaceMap.remove(replacedId);
        _removedImageIds.remove(replacedId);
      }

      if (_primaryNewImageIndex == index) {
        _primaryNewImageIndex = null;
      } else if (_primaryNewImageIndex != null &&
          _primaryNewImageIndex! > index) {
        _primaryNewImageIndex = _primaryNewImageIndex! - 1;
      }
    });
  }

  // ===================================================================
  // EXISTING IMAGES
  // ===================================================================

  List<VehicleImage> get _visibleExistingImages {
    final current = widget.vehicle;

    if (current == null) {
      return const [];
    }

    return current.images
        .where((image) => !_removedImageIds.contains(image.id))
        .toList();
  }

  void _setPrimaryOnExisting(VehicleImage image) {
    setState(() {
      _primaryExistingId = image.id;
      _primaryNewImageIndex = null;
    });
  }

  void _setPrimaryOnNew(int index) {
    setState(() {
      _primaryNewImageIndex = index;
      _primaryExistingId = null;
    });
  }

  void _deleteExistingImage(VehicleImage image) {
    setState(() {
      _removedImageIds.add(image.id);
      _replaceMap.remove(image.id);

      if (_primaryExistingId == image.id) {
        _primaryExistingId = null;
      }
    });
  }

  Future<void> _replaceExistingImage(VehicleImage image) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _removedImageIds.add(image.id);

      _replaceMap[image.id] = File(picked.path);

      _pickedImages.add(File(picked.path));

      if (_primaryExistingId == image.id) {
        _primaryExistingId = null;

        _primaryNewImageIndex = _pickedImages.length - 1;
      }
    });
  }

  // ===================================================================
  // BUILD
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final existingImages = _visibleExistingImages;

    final brands = context.select<BrandBloc, List<Brand>>((bloc) {
      final state = bloc.state;

      return state is BrandsLoaded ? state.brands : const <Brand>[];
    });

    final selectedBrandId = _brandId != 0 && brands.any((b) => b.id == _brandId)
        ? _brandId
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppDimensions.chipHorizontalPadding),
          children: [
            Text(
              _isEditing
                  ? 'Updating vehicle ID '
                        '${widget.vehicle!.id}'
                  : 'Fill in the details below. '
                        'A new vehicle will be created '
                        'via POST /vehicles.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 16.h),

            // =========================================================
            // BRAND
            // =========================================================
            _BrandDropdown(
              brands: brands,
              value: selectedBrandId,
              onChanged: (value) {
                setState(() {
                  _brandId = value ?? 0;
                });
              },
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // MODEL
            // =========================================================
            _TextForm(
              controller: _model,
              label: 'Model',
              hint: 'e.g. Camry',
              validator: _required,
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // YEAR + LICENSE PLATE
            // =========================================================
            Row(
              children: [
                Expanded(
                  child: _TextForm(
                    controller: _year,
                    label: 'Year',
                    keyboardType: TextInputType.number,
                    validator: (value) => _requiredNumber(value),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _TextForm(
                    controller: _licensePlate,
                    label: 'License Plate',
                    hint: 'e.g. 2A-5588',
                    validator: _required,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // COLOR + TYPE
            // =========================================================
            Row(
              children: [
                Expanded(
                  child: _TextForm(
                    controller: _color,
                    label: 'Color',
                    hint: 'e.g. White',
                    validator: _required,
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _DropdownForm<String>(
                    label: 'Type',
                    value: _type,
                    items: _types,
                    onChanged: (value) {
                      setState(() {
                        _type = value ?? _types.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // TRANSMISSION + FUEL
            // =========================================================
            Row(
              children: [
                Expanded(
                  child: _DropdownForm<String>(
                    label: 'Transmission',
                    value: _transmission,
                    items: _transmissions,
                    onChanged: (value) {
                      setState(() {
                        _transmission = value ?? _transmissions.first;
                      });
                    },
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _DropdownForm<String>(
                    label: 'Fuel Type',
                    value: _fuelType,
                    items: _fuelTypes,
                    onChanged: (value) {
                      setState(() {
                        _fuelType = value ?? _fuelTypes.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // SEATS + DOORS + LUGGAGES
            // =========================================================
            Row(
              children: [
                Expanded(
                  child: _TextForm(
                    controller: _seats,
                    label: 'Seats',
                    keyboardType: TextInputType.number,
                    validator: (value) => _requiredNumber(value),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _TextForm(
                    controller: _doors,
                    label: 'Doors',
                    keyboardType: TextInputType.number,
                    validator: (value) => _requiredNumber(value),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _TextForm(
                    controller: _luggages,
                    label: 'Luggages',
                    keyboardType: TextInputType.number,
                    validator: (value) => _requiredNumber(value),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // PRICE + MILEAGE
            // =========================================================
            Row(
              children: [
                Expanded(
                  child: _TextForm(
                    controller: _price,
                    label: 'Price / Day',
                    hint: 'e.g. 60',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => _requiredNumber(value, decimal: true),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _TextForm(
                    controller: _mileAge,
                    label: 'Mileage (km)',
                    keyboardType: TextInputType.number,
                    validator: (value) => _requiredNumber(value),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // STATUS
            // =========================================================
            _DropdownForm<String>(
              label: 'Status',
              value: _status,
              items: _statuses,
              onChanged: (value) {
                setState(() {
                  _status = value ?? _statuses.first;
                });
              },
            ),

            SizedBox(height: 12.h),

            // =========================================================
            // DESCRIPTION
            // =========================================================
            _TextForm(
              controller: _description,
              label: 'Description (optional)',
              hint: 'Short description shown on the detail screen.',
              maxLines: 4,
            ),

            SizedBox(height: 20.h),

            // =========================================================
            // IMAGES
            // =========================================================
            Text(
              'Images',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              'Tap the star to set the cover photo. '
              'Use the trash icon to remove an existing '
              'photo, or the swap icon to replace it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 12.h),

            if (_isEditing && existingImages.isNotEmpty) ...[
              _EditableExistingImages(
                images: existingImages,
                primaryId: _primaryExistingId,
                onSetPrimary: _setPrimaryOnExisting,
                onDelete: _deleteExistingImage,
                onReplace: _replaceExistingImage,
              ),

              SizedBox(height: 12.h),
            ],

            if (_pickedImages.isNotEmpty) ...[
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8.w,
                crossAxisSpacing: 8.w,
                children: [
                  for (var i = 0; i < _pickedImages.length; i++)
                    _PickedImageTile(
                      file: _pickedImages[i],
                      isPrimary: _primaryNewImageIndex == i,
                      onSetPrimary: () => _setPrimaryOnNew(i),
                      onRemove: () => _removePickedImage(i),
                    ),
                ],
              ),

              SizedBox(height: 12.h),
            ],

            // =========================================================
            // ADD IMAGES
            // =========================================================
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _pickedImages.isEmpty
                    ? 'Add Images (multi-select)'
                    : 'Add More Images',
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              _pickedImages.isEmpty
                  ? 'No images selected.'
                  : '${_pickedImages.length} '
                        'image(s) selected.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 16.h),

            // =========================================================
            // SUBMIT
            // =========================================================
            FilledButton.icon(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              icon: Icon(_isEditing ? Icons.save_outlined : Icons.add_rounded),
              label: Text(
                _isEditing ? 'Save Changes' : 'Create Vehicle',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // VALIDATION
  // ===================================================================

  String? _required(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _requiredNumber(String? value, {bool decimal = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Required';
    }

    final number = decimal ? double.tryParse(text) : int.tryParse(text);

    if (number == null) {
      return 'Must be a number';
    }

    if (number < 0) {
      return 'Must be 0 or more';
    }

    return null;
  }
}

// =====================================================================
// TEXT FORM FIELD
// =====================================================================

class _TextForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _TextForm({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

// =====================================================================
// DROPDOWN FORM FIELD
// =====================================================================

class _DropdownForm<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownForm({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString(), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

// =====================================================================
// BRAND DROPDOWN
// =====================================================================

class _BrandDropdown extends StatelessWidget {
  final List<Brand> brands;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _BrandDropdown({
    required this.brands,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = brands.isNotEmpty;

    final selected = enabled && brands.any((b) => b.id == value) ? value : null;

    return DropdownButtonFormField<int>(
      initialValue: selected,
      items: [
        for (final brand in brands)
          DropdownMenuItem<int>(
            value: brand.id,
            child: Text(brand.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: 'Brand',
        hintText: brands.isEmpty ? 'Loading brands…' : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      validator: (value) => value == null ? 'Required' : null,
    );
  }
}

// =====================================================================
// EDITABLE EXISTING IMAGES
// =====================================================================

class _EditableExistingImages extends StatelessWidget {
  final List<VehicleImage> images;
  final int? primaryId;
  final ValueChanged<VehicleImage> onSetPrimary;
  final ValueChanged<VehicleImage> onDelete;
  final ValueChanged<VehicleImage> onReplace;

  const _EditableExistingImages({
    required this.images,
    required this.primaryId,
    required this.onSetPrimary,
    required this.onDelete,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final image in images)
          if (image.fileUrl.isNotEmpty)
            SizedBox(
              width: 76.r,
              height: 76.r,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      image.fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Icon(
                          Icons.broken_image_outlined,
                          size: 24.r,
                          color: colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
                  ),

                  // ---------------------------------------------------
                  // PRIMARY
                  // ---------------------------------------------------
                  Positioned(
                    top: 2,
                    left: 2,
                    child: _ImageActionButton(
                      icon: primaryId == image.id
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: primaryId == image.id
                          ? Colors.amber
                          : colorScheme.onSurfaceVariant,
                      background: Colors.black45,
                      tooltip: 'Set as cover photo',
                      onTap: () => onSetPrimary(image),
                    ),
                  ),

                  // ---------------------------------------------------
                  // DELETE
                  // ---------------------------------------------------
                  Positioned(
                    top: 2,
                    right: 2,
                    child: _ImageActionButton(
                      icon: Icons.close_rounded,
                      color: colorScheme.error,
                      background: Colors.black54,
                      tooltip: 'Remove photo',
                      onTap: () => onDelete(image),
                    ),
                  ),

                  // ---------------------------------------------------
                  // REPLACE
                  // ---------------------------------------------------
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: _ImageActionButton(
                      icon: Icons.swap_horiz_rounded,
                      color: colorScheme.onPrimary,
                      background: Colors.black45,
                      tooltip: 'Replace photo',
                      onTap: () => onReplace(image),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

// =====================================================================
// IMAGE ACTION BUTTON
// =====================================================================

class _ImageActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String tooltip;
  final VoidCallback onTap;

  const _ImageActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 14.r, color: color),
        ),
      ),
    );
  }
}

// =====================================================================
// PICKED IMAGE TILE
// =====================================================================

class _PickedImageTile extends StatelessWidget {
  final File file;
  final bool isPrimary;
  final VoidCallback? onSetPrimary;
  final VoidCallback onRemove;

  const _PickedImageTile({
    required this.file,
    required this.onRemove,
    this.isPrimary = false,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.file(file, fit: BoxFit.cover),
        ),

        // -------------------------------------------------------------
        // PRIMARY
        // -------------------------------------------------------------
        Positioned(
          top: 2,
          left: 2,
          child: _ImageActionButton(
            icon: isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isPrimary ? Colors.amber : colorScheme.onSurface,
            background: Colors.black45,
            tooltip: 'Set as cover photo',
            onTap: onSetPrimary ?? () {},
          ),
        ),

        // -------------------------------------------------------------
        // REMOVE
        // -------------------------------------------------------------
        Positioned(
          top: 2,
          right: 2,
          child: _ImageActionButton(
            icon: Icons.close_rounded,
            color: colorScheme.error,
            background: Colors.black54,
            tooltip: 'Remove',
            onTap: onRemove,
          ),
        ),
      ],
    );
  }
}
