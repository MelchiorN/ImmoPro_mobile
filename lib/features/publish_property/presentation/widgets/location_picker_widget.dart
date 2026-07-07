import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Widget de saisie de localisation avec carte interactive OpenStreetMap.
///
/// Fonctionnalités :
///   - Saisie manuelle d'une adresse avec bouton de recherche (forward geocoding)
///   - Détection GPS automatique (reverse geocoding → adresse lisible)
///   - Saisie directe de coordonnées latitude,longitude
///   - Tap sur la carte pour repositionner le pin
class LocationPickerWidget extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final void Function(String address, double lat, double lng) onLocationChanged;

  const LocationPickerWidget({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late final TextEditingController _addressController;
  late final MapController _mapController;

  // Abidjan par défaut
  LatLng _pinPosition = const LatLng(5.3599, -4.0083);
  bool _hasPin = false;

  bool _isLocating = false;
  bool _isGeocoding = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _addressController =
        TextEditingController(text: widget.initialAddress ?? '');
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pinPosition =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _hasPin = true;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── GPS ─────────────────────────────────────────────────────────────────

  Future<void> _locateMe() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError =
            'Activez la localisation dans les paramètres de votre téléphone.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(
              () => _locationError = 'Permission de localisation refusée.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError =
            'Permission définitivement refusée. Modifiez les paramètres.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final pos = LatLng(position.latitude, position.longitude);
      await _reverseGeocode(pos);
    } catch (e) {
      setState(
          () => _locationError = 'Impossible d\'obtenir la position. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Reverse geocoding (coordonnées → adresse) ────────────────────────────

  Future<void> _reverseGeocode(LatLng pos) async {
    if (mounted) setState(() => _isGeocoding = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      String address;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.country != null && p.country!.isNotEmpty) p.country!,
        ];
        address = parts.join(', ');
      } else {
        address =
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      }
      if (mounted) {
        _addressController.text = address;
        setState(() {
          _pinPosition = pos;
          _hasPin = true;
        });
        _mapController.move(pos, 15);
        widget.onLocationChanged(address, pos.latitude, pos.longitude);
      }
    } catch (_) {
      // Géocoding échoué — on garde les coordonnées brutes
      final raw =
          '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      if (mounted) {
        _addressController.text = raw;
        setState(() {
          _pinPosition = pos;
          _hasPin = true;
        });
        _mapController.move(pos, 15);
        widget.onLocationChanged(raw, pos.latitude, pos.longitude);
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  // ── Forward geocoding (adresse/coords → coordonnées) ────────────────────

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isGeocoding = true;
      _locationError = null;
    });

    // Détection de format "lat, lng"
    final coordRegex = RegExp(
        r'^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$');
    final match = coordRegex.firstMatch(query.trim());
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        await _reverseGeocode(LatLng(lat, lng));
        return;
      }
    }

    try {
      final locations = await locationFromAddress(query.trim());
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final pos = LatLng(loc.latitude, loc.longitude);
        if (mounted) {
          setState(() {
            _pinPosition = pos;
            _hasPin = true;
          });
          _mapController.move(pos, 15);
          widget.onLocationChanged(query.trim(), loc.latitude, loc.longitude);
        }
      } else {
        if (mounted) {
          setState(() =>
              _locationError = 'Adresse introuvable. Essayez d\'être plus précis.');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            _locationError = 'Erreur de recherche. Vérifiez l\'adresse saisie.');
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'ADRESSE / LOCALISATION',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFF424751),
            ),
          ),
        ),

        // Champ de saisie
        TextFormField(
          controller: _addressController,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 15,
            color: Color(0xFF191C1E),
          ),
          decoration: InputDecoration(
            hintText:
                'Quartier, rue  —  ou  —  5.3599, -4.0083',
            hintStyle: const TextStyle(
              color: Color(0xFFC2C6D3),
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
            ),
            prefixIcon: const Icon(Icons.location_on_outlined,
                color: Color(0xFF003E7E), size: 22),
            suffixIcon: _isGeocoding
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Rechercher',
                    icon: const Icon(Icons.search_rounded,
                        color: Color(0xFF003E7E)),
                    onPressed: () =>
                        _searchAddress(_addressController.text),
                  ),
            filled: true,
            fillColor: const Color(0xFFF2F4F6),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC2C6D3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC2C6D3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF003E7E), width: 1.5),
            ),
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: _searchAddress,
        ),

        const SizedBox(height: 10),

        // Bouton GPS
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLocating ? null : _locateMe,
            icon: _isLocating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded,
                    size: 18, color: Color(0xFF003E7E)),
            label: Text(
              _isLocating
                  ? 'Localisation en cours…'
                  : 'Utiliser ma position GPS',
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w600,
                color: Color(0xFF003E7E),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A56A0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Erreur localisation
        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFBA1A1A), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationError!,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 12,
                      color: Color(0xFF93000A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Carte OpenStreetMap
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC2C6D3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pinPosition,
                initialZoom: 14,
                onTap: (_, point) => _reverseGeocode(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.immopro.mobile',
                ),
                if (_hasPin)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinPosition,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFFBA1A1A),
                          size: 40,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Coordonnées
        if (_hasPin)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              '${_pinPosition.latitude.toStringAsFixed(6)}, ${_pinPosition.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 11,
                color: Color(0xFF424751),
              ),
            ),
          ),
      ],
    );
  }
}
