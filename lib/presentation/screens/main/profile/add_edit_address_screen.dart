// lib/presentation/screens/main/profile/add_edit_address_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/location_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/profile/full_map_picker_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  final int? addressId; // null for add, not null for edit

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
  bool _isSubmitting = false; // Prevent double submission

  // Map related
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  // Default location (Syria - Homs)
  static const LatLng _defaultLocation = LatLng(34.7324, 36.7137);

  bool get isEditMode => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
    if (isEditMode) {
      _loadAddressDetails();
    }
  }

  void _loadGovernorates() {
    context.read<AddressBloc>().add(const GovernoratesRequested());
  }

  void _loadAddressDetails() {
    setState(() => _isLoadingAddress = true);
    context.read<AddressBloc>().add(
      AddressDetailRequested(id: widget.addressId!),
    );
  }

  void _populateAddressData(Address address) {
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
    }

    // Find and set governorate
    if (_governorates.isNotEmpty) {
      _selectedGovernorate = _governorates.firstWhere(
        (g) => g.id == address.governorate,
        orElse: () => _governorates.first,
      );
      // Find and set area
      if (_selectedGovernorate != null) {
        _selectedArea = _selectedGovernorate!.areas.firstWhere(
          (a) => a.id == address.area,
          orElse: () => _selectedGovernorate!.areas.first,
        );
      }
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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('يرجى تفعيل خدمة الموقع');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('تم رفض إذن الموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('إذن الموقع مرفوض بشكل دائم');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
      );
    } catch (e) {
      _showLocationError('حدث خطأ في الحصول على الموقع');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Navigate to full screen map picker
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
      });

      // Animate the mini map to the new location
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(result, 16));
    }
  }

  void _saveAddress() {
    // Prevent double submission
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;

      if (_selectedGovernorate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectGovernorate),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectArea),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectLocation),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextCustom(
          text: isEditMode ? l10n.editAddress : l10n.addNewAddress,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        // Only listen to relevant states to prevent duplicate handling
        listenWhen: (previous, current) {
          // Prevent listening to the same state type twice in a row
          if (previous.runtimeType == current.runtimeType) {
            return false;
          }
          // Only listen to states relevant to this screen
          return current is GovernoratesLoaded ||
              current is AddressDetailLoaded ||
              current is AddressAddSuccess ||
              current is AddressUpdateSuccess ||
              current is AddressError;
        },
        listener: (context, state) {
          if (state is GovernoratesLoaded) {
            setState(() {
              _governorates = state.governorates;
              _isLoadingLocations = false;
            });
            // If editing, reload address details after governorates loaded
            if (isEditMode && _isLoadingAddress) {
              _loadAddressDetails();
            }
          } else if (state is AddressDetailLoaded && isEditMode) {
            _populateAddressData(state.address);
          } else if (state is AddressAddSuccess ||
              state is AddressUpdateSuccess) {
            // Pop with result to tell list screen to refresh
            Navigator.pop(context, true);
          } else if (state is AddressError) {
            setState(() {
              _isLoadingLocations = false;
              _isLoadingAddress = false;
              _isSubmitting = false; // Allow resubmission on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state is AddressOperationInProgress || _isSubmitting;

          if ((_isLoadingLocations && state is GovernoratesLoading) ||
              _isLoadingAddress) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Map Section
                  _buildMapSection(l10n),
                  const SizedBox(height: 16),

                  // Form Fields
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (optional)
                        _buildLabel(l10n.addressTitle),
                        _buildTextField(
                          controller: _titleController,
                          hint: l10n.addressTitleHint,
                        ),
                        const SizedBox(height: 16),

                        // Governorate (required)
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

                        // Area (required)
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
                                  setState(() {
                                    _selectedArea = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),

                        // Street (required)
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

                        // Building Number & Floor (numbers only)
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

                        // Apartment (number only)
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

                        // Landmark
                        _buildLabel(l10n.landmark),
                        _buildTextField(
                          controller: _landmarkController,
                          hint: l10n.landmarkHint,
                        ),
                        const SizedBox(height: 16),

                        // Additional Notes
                        _buildLabel(l10n.additionalNotes),
                        _buildTextField(
                          controller: _notesController,
                          hint: l10n.additionalNotesHint,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Set as Current
                        Row(
                          children: [
                            Switch(
                              value: _isCurrent,
                              onChanged: (value) {
                                setState(() {
                                  _isCurrent = value;
                                });
                              },
                              activeColor: const Color(0xFFD32F2F),
                            ),
                            const SizedBox(width: 8),
                            TextCustom(
                              text: l10n.setAsDefaultAddress,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : TextCustom(
                              text: isEditMode
                                  ? l10n.saveChanges
                                  : l10n.saveAddress,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                    ),
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

  Widget _buildMapSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.black87,
                ),
                Row(
                  children: [
                    // Current location button
                    IconButton(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: Color(0xFFD32F2F),
                      ),
                      tooltip: l10n.currentLocation,
                    ),
                    // Open full screen map button
                    IconButton(
                      onPressed: _openFullMapPicker,
                      icon: Icon(Icons.fullscreen, color: Colors.grey.shade700),
                      tooltip: l10n.openFullMap,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map (tap anywhere to open full screen)
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
                      // Prevent map interactions, tap opens full screen
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
                  // Overlay hint to tap for full screen
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
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.tapToSelectLocation,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
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
          // Selected coordinates display
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.latitude}: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                      '${l10n.longitude}: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextCustom(
        text: text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
