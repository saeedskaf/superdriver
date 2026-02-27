import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/location_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/profile/full_map_picker_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class AddEditAddressScreen extends StatefulWidget {
  final int? addressId;

  const AddEditAddressScreen({super.key, this.addressId});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _notesController = TextEditingController();

  List<Governorate> _governorates = [];
  Governorate? _selectedGovernorate;
  Area? _selectedArea;
  bool _isCurrent = false;
  bool _isLoadingLocations = true;
  bool _isLoadingAddress = false;
  bool _isSubmitting = false;
  bool _addressDataPopulated = false;

  Address? _pendingAddressData;

  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  String? _addressText;

  static const LatLng _defaultLocation = LatLng(34.7324, 36.7137);

  bool get isEditMode => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  void _loadGovernorates() {
    setState(() => _isLoadingLocations = true);
    context.read<AddressBloc>().add(const GovernoratesRequested());
  }

  void _loadAddressDetails() {
    if (!isEditMode) return;
    setState(() => _isLoadingAddress = true);
    context.read<AddressBloc>().add(
      AddressDetailRequested(id: widget.addressId!),
    );
  }

  void _populateAddressData(Address address) {
    if (_governorates.isEmpty) {
      _pendingAddressData = address;
      return;
    }

    if (_addressDataPopulated) return;
    _addressDataPopulated = true;

    _titleController.text = address.title;
    _streetController.text = address.street;
    _buildingController.text = address.buildingNumber;
    _floorController.text = address.floor;
    _apartmentController.text = address.apartment;
    _landmarkController.text = address.landmark;
    _notesController.text = address.additionalNotes;
    _isCurrent = address.isCurrent;

    if (address.latitude != null && address.longitude != null) {
      _selectedLocation = LatLng(address.latitude!, address.longitude!);
      _reverseGeocode(_selectedLocation!);
    }

    try {
      _selectedGovernorate = _governorates.firstWhere(
        (g) => g.id == address.governorate,
      );
      if (_selectedGovernorate != null) {
        _selectedArea = _selectedGovernorate!.areas.firstWhere(
          (a) => a.id == address.area,
        );
      }
    } catch (e) {
      log('Could not find governorate/area: $e');
    }

    setState(() => _isLoadingAddress = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
        ];
        setState(() {
          _addressText = parts.isNotEmpty ? parts.join('، ') : null;
        });
      }
    } catch (e) {
      log('Reverse geocode failed: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(l10n.enableLocationService, isError: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(l10n.locationPermissionDenied, isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(l10n.locationPermissionPermanentlyDenied, isError: true);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _addressText = null;
      });

      _reverseGeocode(_selectedLocation!);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.locationError, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openFullMapPicker() async {
    final LatLng? result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullMapPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _addressText = null;
      });
      _reverseGeocode(result);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(result, 16));
    }
  }

  void _saveAddress() {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_selectedGovernorate == null) {
        _showSnackBar(l10n.pleaseSelectGovernorate, isError: true);
        return;
      }
      if (_selectedArea == null) {
        _showSnackBar(l10n.pleaseSelectArea, isError: true);
        return;
      }
      if (_selectedLocation == null) {
        _showSnackBar(l10n.pleaseSelectLocation, isError: true);
        return;
      }

      setState(() => _isSubmitting = true);

      if (isEditMode) {
        context.read<AddressBloc>().add(
          AddressUpdateRequested(
            id: widget.addressId!,
            title: _titleController.text.trim().isEmpty
                ? null
                : _titleController.text.trim(),
            governorate: _selectedGovernorate!.id,
            area: _selectedArea!.id,
            street: _streetController.text.trim(),
            buildingNumber: _buildingController.text.trim().isEmpty
                ? null
                : _buildingController.text.trim(),
            floor: _floorController.text.trim().isEmpty
                ? null
                : _floorController.text.trim(),
            apartment: _apartmentController.text.trim().isEmpty
                ? null
                : _apartmentController.text.trim(),
            landmark: _landmarkController.text.trim().isEmpty
                ? null
                : _landmarkController.text.trim(),
            additionalNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            isCurrent: _isCurrent,
          ),
        );
      } else {
        context.read<AddressBloc>().add(
          AddressAddRequested(
            title: _titleController.text.trim().isEmpty
                ? '${_selectedGovernorate!.name} - ${_selectedArea!.name}'
                : _titleController.text.trim(),
            governorate: _selectedGovernorate!.id,
            area: _selectedArea!.id,
            street: _streetController.text.trim(),
            buildingNumber: _buildingController.text.trim().isEmpty
                ? null
                : _buildingController.text.trim(),
            floor: _floorController.text.trim().isEmpty
                ? null
                : _floorController.text.trim(),
            apartment: _apartmentController.text.trim().isEmpty
                ? null
                : _apartmentController.text.trim(),
            landmark: _landmarkController.text.trim().isEmpty
                ? null
                : _landmarkController.text.trim(),
            additionalNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            isCurrent: _isCurrent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: AppBar(
        backgroundColor: ColorsCustom.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorsCustom.primary,
              ),
            ),
          ),
        ),
        title: TextCustom(
          text: isEditMode ? l10n.editAddress : l10n.addNewAddress,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is GovernoratesLoaded) {
            setState(() {
              _governorates = state.governorates;
              _isLoadingLocations = false;
            });

            if (isEditMode) {
              if (_pendingAddressData != null) {
                _populateAddressData(_pendingAddressData!);
                _pendingAddressData = null;
              } else if (!_addressDataPopulated && !_isLoadingAddress) {
                _loadAddressDetails();
              }
            }
          } else if (state is AddressDetailLoaded && isEditMode) {
            if (_governorates.isNotEmpty) {
              _populateAddressData(state.address);
            } else {
              _pendingAddressData = state.address;
              setState(() => _isLoadingAddress = false);
            }
          } else if (state is AddressAddSuccess ||
              state is AddressUpdateSuccess) {
            Navigator.pop(context, true);
          } else if (state is AddressError) {
            setState(() {
              _isLoadingLocations = false;
              _isLoadingAddress = false;
              _isSubmitting = false;
            });
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is AddressOperationInProgress || _isSubmitting;

          if (_isLoadingLocations ||
              (isEditMode && _isLoadingAddress && !_addressDataPopulated)) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Map
                  _buildMapSection(l10n),
                  const SizedBox(height: 16),

                  // Form
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: ColorsCustom.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorsCustom.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.addressTitle),
                        _buildTextField(
                          controller: _titleController,
                          hint: l10n.addressTitleHint,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('${l10n.governorate} *'),
                        DropdownButtonFormField<Governorate>(
                          value: _selectedGovernorate,
                          decoration: _dropdownDecoration(
                            l10n.selectGovernorate,
                          ),
                          isExpanded: true,
                          items: _governorates.map((gov) {
                            return DropdownMenuItem<Governorate>(
                              value: gov,
                              child: Text(gov.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGovernorate = value;
                              _selectedArea = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('${l10n.area} *'),
                        DropdownButtonFormField<Area>(
                          value: _selectedArea,
                          decoration: _dropdownDecoration(
                            _selectedGovernorate == null
                                ? l10n.selectGovernorateFirst
                                : l10n.selectArea,
                          ),
                          isExpanded: true,
                          items:
                              _selectedGovernorate?.areas.map((area) {
                                return DropdownMenuItem<Area>(
                                  value: area,
                                  child: Text(area.name),
                                );
                              }).toList() ??
                              [],
                          onChanged: _selectedGovernorate == null
                              ? null
                              : (value) {
                                  setState(() => _selectedArea = value);
                                },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('${l10n.street} *'),
                        _buildTextField(
                          controller: _streetController,
                          hint: l10n.streetName,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.streetRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.buildingNumber),
                                  _buildTextField(
                                    controller: _buildingController,
                                    hint: l10n.buildingNumber,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.floor),
                                  _buildTextField(
                                    controller: _floorController,
                                    hint: l10n.floorNumber,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildLabel(l10n.apartment),
                        _buildTextField(
                          controller: _apartmentController,
                          hint: l10n.apartmentNumber,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildLabel(l10n.landmark),
                        _buildTextField(
                          controller: _landmarkController,
                          hint: l10n.landmarkHint,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel(l10n.additionalNotes),
                        _buildTextField(
                          controller: _notesController,
                          hint: l10n.additionalNotesHint,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Set as current toggle
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isCurrent
                                ? ColorsCustom.primarySoft
                                : ColorsCustom.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isCurrent
                                  ? ColorsCustom.primary.withAlpha(77)
                                  : ColorsCustom.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 20,
                                color: ColorsCustom.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextCustom(
                                  text: l10n.setAsDefaultAddress,
                                  fontSize: 14,
                                  color: ColorsCustom.textPrimary,
                                ),
                              ),
                              Switch(
                                value: _isCurrent,
                                onChanged: (value) {
                                  setState(() => _isCurrent = value);
                                },
                                activeColor: ColorsCustom.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save
                  ButtonCustom.primary(
                    text: isEditMode ? l10n.saveChanges : l10n.saveAddress,
                    onPressed: isLoading ? null : _saveAddress,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsCustom.textOnPrimary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Map Section ──

  Widget _buildMapSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextCustom(
                  text: '${l10n.selectLocationOnMap} *',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.textPrimary,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorsCustom.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: ColorsCustom.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openFullMapPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorsCustom.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          color: ColorsCustom.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openFullMapPicker,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: AbsorbPointer(
                      absorbing: true,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? _defaultLocation,
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('selected'),
                                  position: _selectedLocation!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                ),
                              }
                            : {},
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsCustom.textPrimary.withAlpha(153),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 16,
                              color: ColorsCustom.textOnPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.tapToSelectLocation,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColorsCustom.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: ColorsCustom.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _addressText != null
                        ? TextCustom(
                            text: _addressText!,
                            fontSize: 13,
                            color: ColorsCustom.textPrimary,
                          )
                        : const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsCustom.textSecondary,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextCustom(
        text: text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ColorsCustom.textHint, fontSize: 14),
        filled: true,
        fillColor: ColorsCustom.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsCustom.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsCustom.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsCustom.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ColorsCustom.textHint, fontSize: 14),
      filled: true,
      fillColor: ColorsCustom.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsCustom.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsCustom.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsCustom.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
