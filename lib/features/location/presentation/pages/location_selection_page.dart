import 'package:abdoul_express/model/address.dart';
import 'package:flutter/material.dart';

/// Location selection page with map (placeholder for actual map integration)
/// TODO: Integrate with Google Maps or other map provider
class LocationSelectionPage extends StatefulWidget {
  final Address? initialAddress;

  const LocationSelectionPage({super.key, this.initialAddress});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String _selectedLocation = 'Niamey, Niger';
  double _latitude = 13.5127; // Niamey coordinates
  double _longitude = 2.1128;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _selectedLocation = widget.initialAddress!.fullAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner la position'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map Placeholder
          Expanded(
            child: Stack(
              children: [
                // TODO: Replace with actual map widget (Google Maps, etc.)
                Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 80, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Carte interactive',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intégration Google Maps à venir',
                          style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center marker
                Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),

                // Current location button
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Location info card
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Position sélectionnée',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_latitude.toStringAsFixed(4)}, Long: ${_longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _confirmLocation,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer cette position'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() {
    // TODO: Implement actual geolocation
    setState(() {
      _selectedLocation = 'Ma position actuelle';
      _latitude = 13.5127;
      _longitude = 2.1128;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Position actuelle détectée'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmLocation() {
    // Return the selected location data
    Navigator.of(context).pop({
      'location': _selectedLocation,
      'latitude': _latitude,
      'longitude': _longitude,
    });
  }
}
