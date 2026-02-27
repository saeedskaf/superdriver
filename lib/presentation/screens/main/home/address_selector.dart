import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================================
// DATA MODELS
// ============================================================

enum DeliveryLocationType { savedAddress, currentLocation, searchedLocation }

class DeliveryLocationResult {
  final DeliveryLocationType type;
  final AddressSummary? savedAddress;
  final CurrentLocationData? currentLocation;
  final SearchedLocationData? searchedLocation;
  final String displayName;
  final String? subtitle;
  final double? latitude;
  final double? longitude;

  const DeliveryLocationResult({
    required this.type,
    required this.displayName,
    this.savedAddress,
    this.currentLocation,
    this.searchedLocation,
    this.subtitle,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  // ---- Factories ----

  factory DeliveryLocationResult.fromCurrentLocation(CurrentLocationData data) {
    final subtitle =
        (data.area != null && data.city != null && data.area != data.city)
        ? data.city
        : null;

    return DeliveryLocationResult(
      type: DeliveryLocationType.currentLocation,
      currentLocation: data,
      displayName: data.address,
      subtitle: subtitle,
      latitude: data.latitude,
      longitude: data.longitude,
    );
  }

  factory DeliveryLocationResult.fromSavedAddress(AddressSummary address) {
    return DeliveryLocationResult(
      type: DeliveryLocationType.savedAddress,
      savedAddress: address,
      displayName: address.title,
      subtitle: '${address.governorateName} - ${address.areaName}',
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }

  factory DeliveryLocationResult.fromAddress(Address address) {
    return DeliveryLocationResult(
      type: DeliveryLocationType.savedAddress,
      savedAddress: address.toSummary(),
      displayName: address.title,
      subtitle: '${address.governorateName} - ${address.areaName}',
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }

  factory DeliveryLocationResult.fromSearchedLocation(
    SearchedLocationData data,
  ) {
    return DeliveryLocationResult(
      type: DeliveryLocationType.searchedLocation,
      searchedLocation: data,
      displayName: data.name,
      subtitle: data.fullAddress,
      latitude: data.latitude,
      longitude: data.longitude,
    );
  }
}

class CurrentLocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? area;
  final String? city;

  const CurrentLocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.area,
    this.city,
  });
}

class SearchedLocationData {
  final String name;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? type;

  const SearchedLocationData({
    required this.name,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.type,
  });
}

// ============================================================
// LOCATION HELPERS
// ============================================================

/// Try to get the device's current GPS location as a [DeliveryLocationResult].
/// Returns null when permissions are denied or the service is unavailable.
Future<DeliveryLocationResult?> getCurrentLocationAsDefault() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    final geo = await _reverseGeocode(position.latitude, position.longitude);

    return DeliveryLocationResult.fromCurrentLocation(
      CurrentLocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: geo.shortName,
        area: geo.area,
        city: geo.city,
      ),
    );
  } catch (e) {
    log('getCurrentLocationAsDefault: $e');
    return null;
  }
}

class _GeoResult {
  final String shortName;
  final String? area;
  final String? city;

  const _GeoResult({this.shortName = 'Current Location', this.area, this.city});
}

Future<_GeoResult> _reverseGeocode(double lat, double lng) async {
  try {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) return const _GeoResult();

    final p = placemarks.first;
    final area = p.subLocality?.isNotEmpty == true ? p.subLocality : null;
    final city = p.locality?.isNotEmpty == true ? p.locality : null;

    return _GeoResult(
      shortName: area ?? city ?? 'Current Location',
      area: area,
      city: city,
    );
  } catch (_) {
    return const _GeoResult();
  }
}

// ============================================================
// LOCATION SEARCH SERVICE
// ============================================================

class LocationSearchService {
  static const _userAgent = 'SuperDriverApp/1.0';
  static const _timeout = Duration(seconds: 10);

  /// Run parallel searches and return de-duplicated results.
  static Future<List<SearchedLocationData>> search(String query) async {
    if (query.length < 2) return [];

    final results = <SearchedLocationData>[];

    await Future.wait([
      _searchNominatim(query, results),
      _searchNominatimWithViewbox(query, results),
    ]);

    if (results.length < 3) {
      await _searchGeocoding(query, results);
    }

    return _deduplicate(results);
  }

  // ---- Nominatim ----

  static Future<void> _searchNominatim(
    String query,
    List<SearchedLocationData> out,
  ) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json&addressdetails=1&limit=15&dedupe=1'
      '&accept-language=ar,en',
    );
    await _fetchNominatim(url, out);
  }

  static Future<void> _searchNominatimWithViewbox(
    String query,
    List<SearchedLocationData> out,
  ) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json&addressdetails=1&limit=15&dedupe=1'
      '&accept-language=ar,en&viewbox=25,10,60,45&bounded=0',
    );
    await _fetchNominatim(url, out);
  }

  static Future<void> _fetchNominatim(
    Uri url,
    List<SearchedLocationData> out,
  ) async {
    try {
      final resp = await http
          .get(url, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        _parseNominatim(jsonDecode(resp.body) as List, out);
      }
    } catch (_) {}
  }

  static void _parseNominatim(
    List<dynamic> data,
    List<SearchedLocationData> out,
  ) {
    for (final item in data) {
      final addr = (item['address'] as Map<String, dynamic>?) ?? {};
      final name = _extractName(item, addr);
      if (name.isEmpty) continue;

      final lat = double.tryParse(item['lat']?.toString() ?? '');
      final lng = double.tryParse(item['lon']?.toString() ?? '');
      if (lat == null || lng == null) continue;

      out.add(
        SearchedLocationData(
          name: name,
          fullAddress: _buildFullAddress(item, addr),
          latitude: lat,
          longitude: lng,
          type: item['type'],
        ),
      );
    }
  }

  // ---- Geocoding fallback ----

  static Future<void> _searchGeocoding(
    String query,
    List<SearchedLocationData> out,
  ) async {
    try {
      final locations = await locationFromAddress(query);
      for (final loc in locations.take(5)) {
        if (_isDuplicate(out, loc.latitude, loc.longitude)) continue;
        try {
          final marks = await placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (marks.isNotEmpty) {
            final p = marks.first;
            out.add(
              SearchedLocationData(
                name:
                    p.name ?? p.street ?? p.subLocality ?? p.locality ?? query,
                fullAddress: _placemarkAddress(p),
                latitude: loc.latitude,
                longitude: loc.longitude,
              ),
            );
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  // ---- Helpers ----

  static String _extractName(
    Map<String, dynamic> item,
    Map<String, dynamic> addr,
  ) {
    const fields = [
      'name',
      'road',
      'neighbourhood',
      'suburb',
      'city',
      'town',
      'village',
      'county',
    ];
    for (final f in fields) {
      final v = item[f] ?? addr[f];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return item['display_name']?.split(',').first ?? '';
  }

  static String _buildFullAddress(
    Map<String, dynamic> item,
    Map<String, dynamic> addr,
  ) {
    const fields = [
      'road',
      'neighbourhood',
      'suburb',
      'city',
      'town',
      'village',
      'state',
      'country',
    ];
    final parts = <String>[];
    for (final f in fields) {
      final v = addr[f];
      if (v != null && v.toString().isNotEmpty && !parts.contains(v)) {
        parts.add(v.toString());
      }
    }
    return parts.isNotEmpty ? parts.join('، ') : item['display_name'] ?? '';
  }

  static String _placemarkAddress(Placemark p) {
    return [
      p.street,
      p.subLocality,
      p.locality,
      p.administrativeArea,
      p.country,
    ].where((s) => s != null && s.isNotEmpty).join('، ');
  }

  static bool _isDuplicate(
    List<SearchedLocationData> list,
    double lat,
    double lng,
  ) {
    return list.any(
      (r) =>
          (r.latitude - lat).abs() < 0.001 && (r.longitude - lng).abs() < 0.001,
    );
  }

  static List<SearchedLocationData> _deduplicate(
    List<SearchedLocationData> list,
  ) {
    final unique = <SearchedLocationData>[];
    for (final r in list) {
      if (!_isDuplicate(unique, r.latitude, r.longitude)) unique.add(r);
    }
    return unique;
  }
}

// ============================================================
// PUBLIC API
// ============================================================

Future<void> showAddressSelector(
  BuildContext context, {
  DeliveryLocationResult? currentLocation,
  required ValueChanged<DeliveryLocationResult> onLocationSelected,
  bool isAuthenticated = true,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => AddressBloc(),
      child: _AddressSelectorSheet(
        currentSelected: currentLocation,
        onSelected: onLocationSelected,
        isAuthenticated: isAuthenticated,
      ),
    ),
  );
}

// ============================================================
// ADDRESS SELECTOR SHEET
// ============================================================

class _AddressSelectorSheet extends StatefulWidget {
  final DeliveryLocationResult? currentSelected;
  final ValueChanged<DeliveryLocationResult> onSelected;
  final bool isAuthenticated;

  const _AddressSelectorSheet({
    this.currentSelected,
    required this.onSelected,
    this.isAuthenticated = true,
  });

  @override
  State<_AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<_AddressSelectorSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  bool _isSearchMode = false;
  bool _loadingGps = false;
  bool _loadingSearch = false;
  List<SearchedLocationData> _searchResults = [];
  String? _gpsError;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    // Only load saved addresses for authenticated users
    if (widget.isAuthenticated) {
      context.read<AddressBloc>().add(const AddressListRequested());
    }
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---- Search ----

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearchMode = true;
      _searchError = null;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;
    setState(() => _loadingSearch = true);

    try {
      final results = await LocationSearchService.search(query);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _searchResults = results;
        _loadingSearch = false;
        _searchError = results.isEmpty ? l10n.noResultsFound : null;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _searchResults = [];
        _loadingSearch = false;
        _searchError = l10n.searchFailed;
      });
    }
  }

  // ---- GPS ----

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingGps = true;
      _gpsError = null;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return _setGpsError(l10n.enableLocationService);
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          return _setGpsError(l10n.locationPermissionDenied);
        }
      }
      if (perm == LocationPermission.deniedForever) {
        return _setGpsError(l10n.locationPermissionPermanentlyDenied);
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final geo = await _reverseGeocode(pos.latitude, pos.longitude);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSelected(
        DeliveryLocationResult.fromCurrentLocation(
          CurrentLocationData(
            latitude: pos.latitude,
            longitude: pos.longitude,
            address: geo.shortName,
            area: geo.area,
            city: geo.city,
          ),
        ),
      );
    } catch (_) {
      _setGpsError(l10n.locationError);
    }
  }

  void _setGpsError(String msg) {
    if (!mounted) return;
    setState(() {
      _gpsError = msg;
      _loadingGps = false;
    });
  }

  // ---- Selection ----

  void _selectSaved(AddressSummary address) {
    Navigator.pop(context);
    widget.onSelected(DeliveryLocationResult.fromSavedAddress(address));
  }

  void _selectSearched(SearchedLocationData loc) {
    Navigator.pop(context);
    widget.onSelected(DeliveryLocationResult.fromSearchedLocation(loc));
  }

  void _goToManageAddresses() async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(builder: (_) => const AddressesScreen()),
    );
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildSearchField(context),
          const SizedBox(height: 12),
          Expanded(
            child: _isSearchMode ? _buildSearchResults() : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // ---- Handle ----

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: ColorsCustom.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ---- Header ----

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextCustom(
              text: l10n.selectDeliveryAddress,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ColorsCustom.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: ColorsCustom.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Search field ----

  Widget _buildSearchField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsCustom.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchForLocation,
            hintStyle: const TextStyle(
              color: ColorsCustom.textHint,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ColorsCustom.primary,
              size: 22,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchCtrl,
              builder: (_, value, __) => value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        _searchFocus.unfocus();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: ColorsCustom.textSecondary,
                        size: 20,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ---- Search results ----

  Widget _buildSearchResults() {
    if (_loadingSearch) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    if (_searchError != null && _searchResults.isEmpty) {
      return _buildEmptySearch();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextCustom(
            text:
                '${_searchResults.length} ${AppLocalizations.of(context)!.results}',
            fontSize: 12,
            color: ColorsCustom.textSecondary,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final loc = _searchResults[i];
              return _SearchResultTile(
                location: loc,
                onTap: () => _selectSearched(loc),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearch() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: ColorsCustom.textHint,
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.noResultsFound,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textSecondary,
          ),
          const SizedBox(height: 8),
          TextCustom(
            text: l10n.tryDifferentSearch,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  // ---- Main content (GPS + saved) ----

  Widget _buildMainContent() {
    final isGpsSelected =
        widget.currentSelected?.type == DeliveryLocationType.currentLocation;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _CurrentLocationTile(
          isLoading: _loadingGps,
          error: _gpsError,
          isSelected: isGpsSelected,
          onTap: _useCurrentLocation,
        ),
        // Only show saved addresses for authenticated users
        if (widget.isAuthenticated) ...[
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: ColorsCustom.border,
          ),
          _buildSavedHeader(),
          _buildSavedList(),
        ],
      ],
    );
  }

  Widget _buildSavedHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_outline_rounded,
            size: 18,
            color: ColorsCustom.primary,
          ),
          const SizedBox(width: 8),
          TextCustom(
            text: l10n.savedAddresses,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textPrimary,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _goToManageAddresses,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.settings_outlined,
                  size: 16,
                  color: ColorsCustom.primary,
                ),
                const SizedBox(width: 4),
                TextCustom(
                  text: l10n.manage,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedList() {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: ColorsCustom.primary),
            ),
          );
        }

        final addresses = state is AddressListLoaded
            ? state.addresses
            : context.read<AddressBloc>().cachedAddresses;

        if (addresses.isEmpty) {
          return _buildEmptyAddresses();
        }

        final selectedId = widget.currentSelected?.savedAddress?.id;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: addresses.length,
          itemBuilder: (_, i) {
            final addr = addresses[i];
            final isSelected =
                (selectedId != null && selectedId == addr.id) ||
                (selectedId == null &&
                    widget.currentSelected?.type ==
                        DeliveryLocationType.savedAddress &&
                    addr.isCurrent);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SavedAddressTile(
                address: addr,
                isSelected: isSelected,
                onTap: () => _selectSaved(addr),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyAddresses() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsCustom.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 48,
                color: ColorsCustom.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextCustom(
              text: l10n.noSavedAddresses,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textSecondary,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _goToManageAddresses,
              child: TextCustom(
                text: l10n.addNewAddress,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TILE WIDGETS
// ============================================================

class _CurrentLocationTile extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrentLocationTile({
    required this.isLoading,
    this.error,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: isSelected ? ColorsCustom.primary.withAlpha(20) : null,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColorsCustom.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: l10n.useCurrentLocation,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorsCustom.textPrimary,
                  ),
                  const SizedBox(height: 3),
                  TextCustom(
                    text: error ?? l10n.detectMyLocation,
                    fontSize: 12,
                    color: error != null
                        ? ColorsCustom.error
                        : ColorsCustom.textSecondary,
                  ),
                ],
              ),
            ),
            _selectionIndicator(isSelected, isLoading),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchedLocationData location;
  final VoidCallback onTap;

  const _SearchResultTile({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorsCustom.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ColorsCustom.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: ColorsCustom.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: location.name,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsCustom.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  TextCustom(
                    text: location.fullAddress,
                    fontSize: 12,
                    color: ColorsCustom.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: ColorsCustom.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedAddressTile extends StatelessWidget {
  final AddressSummary address;
  final bool isSelected;
  final VoidCallback onTap;

  const _SavedAddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsCustom.primary.withAlpha(20)
              : ColorsCustom.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ColorsCustom.primary : ColorsCustom.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsCustom.primary.withAlpha(26)
                    : ColorsCustom.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForTitle(address.title),
                color: isSelected
                    ? ColorsCustom.primary
                    : ColorsCustom.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextCustom(
                          text: address.title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorsCustom.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (address.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: ColorsCustom.success.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextCustom(
                            text: l10n.defaultLabel,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ColorsCustom.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextCustom(
                    text: '${address.governorateName} - ${address.areaName}',
                    fontSize: 13,
                    color: ColorsCustom.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _selectionIndicator(isSelected, false),
          ],
        ),
      ),
    );
  }

  static IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('home') || t.contains('منزل') || t.contains('بيت')) {
      return Icons.home_outlined;
    }
    if (t.contains('work') || t.contains('عمل') || t.contains('مكتب')) {
      return Icons.work_outline;
    }
    return Icons.location_on_outlined;
  }
}

// ---- Shared selection indicator ----

Widget _selectionIndicator(bool isSelected, bool isLoading) {
  if (isSelected) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: ColorsCustom.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
    );
  }
  if (!isLoading) {
    return const Icon(
      Icons.radio_button_unchecked_rounded,
      size: 22,
      color: ColorsCustom.textHint,
    );
  }
  return const SizedBox.shrink();
}
