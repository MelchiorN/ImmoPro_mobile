import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Widget de saisie de localisation avec carte interactive OpenStreetMap.
///
/// Fonctionnalités :
///   - Saisie manuelle d'une adresse avec bouton de recherche (forward geocoding)
///   - Détection GPS automatique (reverse geocoding → adresse lisible)
///   - Saisie directe de coordonnées latitude,longitude
///   - Tap sur la carte pour repositionner le pin
class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final void Function(double lat, double lng) onLocationChanged;

  const LocationPickerWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late final MapController _mapController;
  late final TextEditingController _coordController;

  // Abidjan par défaut
  LatLng _pinPosition = const LatLng(5.3599, -4.0083);
  bool _hasPin = false;

  bool _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _coordController = TextEditingController();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pinPosition =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _hasPin = true;
      _coordController.text = '${widget.initialLatitude}, ${widget.initialLongitude}';
    }
  }

  @override
  void dispose() {
    _coordController.dispose();
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
      await _placePin(pos);
    } catch (e) {
      setState(
          () => _locationError = 'Impossible d\'obtenir la position. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Placement de pin manuel (reverse geocoding supprimé pour simplifier) ──

  Future<void> _placePin(LatLng pos) async {
    if (mounted) {
      setState(() {
        _pinPosition = pos;
        _hasPin = true;
        _coordController.text = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      });
      _mapController.move(pos, 15);
      widget.onLocationChanged(pos.latitude, pos.longitude);
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
            'LOCALISATION SUR LA CARTE (OPTIONNEL)',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFF424751),
            ),
          ),
        ),

        // Champ Coordonnées
        TextFormField(
          controller: _coordController,
          readOnly: true,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 15,
            color: Color(0xFF191C1E),
          ),
          decoration: InputDecoration(
            hintText: 'Coordonnées (Map ou GPS)',
            hintStyle: const TextStyle(
              color: Color(0xFFC2C6D3),
              fontFamily: 'HankenGrotesk',
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.pin_drop_rounded,
                color: Color(0xFF003E7E), size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF003E7E)),
            ),
          ),
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
                onTap: (_, point) => _placePin(point),
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

      ],
    );
  }
}
