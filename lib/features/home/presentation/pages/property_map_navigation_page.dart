import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/property_entity.dart';

class PropertyMapNavigationPage extends StatefulWidget {
  final PropertyEntity property;

  const PropertyMapNavigationPage({
    super.key,
    required this.property,
  });

  @override
  State<PropertyMapNavigationPage> createState() => _PropertyMapNavigationPageState();
}

class _PropertyMapNavigationPageState extends State<PropertyMapNavigationPage> {
  final MapController _mapController = MapController();
  
  Position? _currentPosition;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String _distanceStr = '-- km';
  String _durationStr = '-- min';
  
  // Coordonnées du bien
  late final double _destLat;
  late final double _destLng;

  @override
  void initState() {
    super.initState();
    _destLat = (widget.property.latitude != null && widget.property.latitude != 0)
        ? widget.property.latitude!
        : 5.3599;
    _destLng = (widget.property.longitude != null && widget.property.longitude != 0)
        ? widget.property.longitude!
        : -4.0083;

    _checkPermissionAndStartTracking();
  }

  // Vérifier permissions et démarrer suivi temps réel
  Future<void> _checkPermissionAndStartTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez activer le GPS du téléphone.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Accès GPS refusé.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions GPS refusées définitivement.')),
        );
      }
      return;
    }

    // Récupérer première position
    final initialPos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = initialPos;
      });
      _fetchRoute();
    }

    // Suivi temps réel continu
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Réévaluer tous les 10 mètres
      ),
    ).listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _fetchRoute();
      }
    });
  }

  // Appeler l'API de routage OSRM
  Future<void> _fetchRoute() async {
    if (_currentPosition == null) return;
    
    // Éviter surcharge appels simultanés
    if (_isLoadingRoute) return;

    setState(() => _isLoadingRoute = true);

    try {
      final userLat = _currentPosition!.latitude;
      final userLng = _currentPosition!.longitude;

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$userLng,$userLat;$_destLng,$_destLat?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          final points = coordinates.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();

          final distance = route['distance'] as num; // en mètres
          final duration = route['duration'] as num; // en secondes

          setState(() {
            _routePoints = points;
            _distanceStr = '${(distance / 1000).toStringAsFixed(1)} km';
            _durationStr = '${(duration / 60).round()} min';
          });
        }
      }
    } catch (_) {
      // Ignorer silencieusement pour le mode offline
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  // Recentrer la carte sur la position de l'utilisateur
  void _recenterMap() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
    }
  }

  // Ajuster la caméra pour afficher à la fois l'utilisateur et la destination
  void _zoomToFitRoute() {
    if (_currentPosition == null) return;

    final bounds = LatLngBounds(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(_destLat, _destLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Itinéraire & Suivi GPS',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                widget.property.title,
                style: const TextStyle(
                  fontFamily: 'HankenGrotesk',
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Carte OpenStreetMap
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_destLat, _destLng),
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.immopro.app',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5.5,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Marqueur Destination (Bien immobilier)
                    Marker(
                      point: LatLng(_destLat, _destLng),
                      width: 50,
                      height: 50,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    // Marqueur Position Actuelle (Utilisateur)
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        width: 46,
                        height: 46,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Panneau d'informations de navigation en bas
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Temps estimé',
                                style: TextStyle(
                                  fontFamily: 'HankenGrotesk',
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _durationStr,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontFamily: 'HankenGrotesk',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _distanceStr,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Ajuster vue route
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _zoomToFitRoute,
                            icon: const Icon(Icons.zoom_out_map_rounded, size: 18),
                            label: const Text(
                              'Aperçu du trajet',
                              style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Recentrer sur utilisateur
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _recenterMap,
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text(
                              'Ma position',
                              style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
