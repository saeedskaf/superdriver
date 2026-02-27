import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class FullMapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const FullMapPickerScreen({super.key, this.initialLocation});

  @override
  State<FullMapPickerScreen> createState() => _FullMapPickerScreenState();
}

class _FullMapPickerScreenState extends State<FullMapPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoading = false;
  String? _addressText;

  static const LatLng _defaultLocation = LatLng(34.7324, 36.7137);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _reverseGeocode(_selectedLocation!);
    }
  }

  @override
  void dispose() {
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
    setState(() => _isLoading = true);
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
      });

      _reverseGeocode(_selectedLocation!);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 17),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.locationError, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _confirmLocation() {
    if (_selectedLocation == null) {
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.pleaseSelectLocation, isError: true);
      return;
    }
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: _selectedLocation != null ? 16 : 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
                _addressText = null;
              });
              _reverseGeocode(latLng);
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
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsCustom.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorsCustom.border),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorsCustom.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: ColorsCustom.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextCustom(
                        text: l10n.selectLocationOnMap,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorsCustom.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Address display
          if (_selectedLocation != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsCustom.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorsCustom.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 20,
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
                                height: 16,
                                width: 16,
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
              ),
            ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 170,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add_rounded,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.remove_rounded,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  isLoading: _isLoading,
                  isPrimary: true,
                ),
              ],
            ),
          ),

          // Bottom confirm
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: ColorsCustom.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: const Border(
                  top: BorderSide(color: ColorsCustom.border),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextCustom(
                    text: l10n.tapToSelectLocation,
                    fontSize: 14,
                    color: ColorsCustom.textSecondary,
                  ),
                  const SizedBox(height: 14),
                  ButtonCustom.primary(
                    text: l10n.confirmLocation,
                    onPressed: _selectedLocation != null
                        ? _confirmLocation
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary
                          ? ColorsCustom.primary
                          : ColorsCustom.textSecondary,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  color: isPrimary
                      ? ColorsCustom.primary
                      : ColorsCustom.textSecondary,
                ),
        ),
      ),
    );
  }
}
