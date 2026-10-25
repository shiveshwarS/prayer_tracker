import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../models/saved_location.dart';
import '../services/location_service.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';
import 'primary_button.dart';

class LocationSheet extends StatefulWidget {
  const LocationSheet({super.key, required this.controller});

  final PrayerTimesController controller;

  static Future<void> show(
    BuildContext context,
    PrayerTimesController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return LocationSheet(controller: controller);
      },
    );
  }

  @override
  State<LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<LocationSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    final SavedLocation? location = widget.controller.location;
    _labelController = TextEditingController(
      text:
          location?.source == LocationSource.manual ? location!.label : 'Home',
    );
    _latitudeController = TextEditingController(
      text: location?.latitude.toStringAsFixed(5) ?? '',
    );
    _longitudeController = TextEditingController(
      text: location?.longitude.toStringAsFixed(5) ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final LocationFailure? failure =
        await widget.controller.useCurrentLocation();
    if (!mounted) {
      return;
    }
    if (failure == null) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveManualLocation() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final double latitude = double.parse(_latitudeController.text.trim());
    final double longitude = double.parse(_longitudeController.text.trim());
    final String label = _labelController.text.trim();
    final SavedLocation location = SavedLocation(
      latitude: latitude,
      longitude: longitude,
      label: label.isEmpty ? 'Manual location' : label,
      source: LocationSource.manual,
    );
    await widget.controller.setManualLocation(location);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _failureMessage(LocationFailure failure) {
    switch (failure) {
      case LocationFailure.serviceDisabled:
        return 'Location services are off. Turn them on, or enter coordinates manually.';
      case LocationFailure.permissionDenied:
        return 'Location permission was not granted. Try again, or enter coordinates manually.';
      case LocationFailure.permissionPermanentlyDenied:
        return 'Location permission is blocked. Open the app settings to allow access.';
      case LocationFailure.timeout:
        return 'Finding your location took too long. Try again near a window.';
      case LocationFailure.unavailable:
        return 'Your location could not be determined. Try again, or enter coordinates manually.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final bool isLocating = widget.controller.isLocating;
        final LocationFailure? failure = widget.controller.locationFailure;
        final SavedLocation? location = widget.controller.location;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
              maxWidth: 620,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'PRAYER LOCATION',
                                style: textTheme.labelSmall?.copyWith(
                                  color: palette.inkMuted,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Where are you praying?',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location is only used on this device to calculate prayer times and the Qibla direction.',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.inkMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (location != null) ...<Widget>[
                      _SavedLocationCard(location: location),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(
                      label:
                          isLocating
                              ? 'Finding your location…'
                              : location == null
                              ? 'Use my current location'
                              : 'Refresh current location',
                      icon: Icons.my_location_rounded,
                      isLoading: isLocating,
                      onPressed: _useCurrentLocation,
                    ),
                    if (failure != null) ...<Widget>[
                      const SizedBox(height: 12),
                      _LocationMessage(
                        message: _failureMessage(failure),
                        onOpenSettings:
                            failure == LocationFailure.serviceDisabled
                                ? widget.controller.openLocationSettings
                                : failure ==
                                    LocationFailure.permissionPermanentlyDenied
                                ? widget.controller.openAppSettings
                                : null,
                        settingsLabel:
                            failure == LocationFailure.serviceDisabled
                                ? 'Open location settings'
                                : 'Open app settings',
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: <Widget>[
                        Expanded(child: Divider(color: palette.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR ENTER COORDINATES',
                            style: textTheme.labelSmall?.copyWith(
                              color: palette.inkMuted,
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: palette.line)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _labelController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 40,
                      decoration: const InputDecoration(
                        labelText: 'Location name',
                        hintText: 'e.g. Home, London',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              hintText: '21.4225',
                            ),
                            validator: _validateLatitude,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveManualLocation(),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              hintText: '39.8262',
                            ),
                            validator: _validateLongitude,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Save this location',
                      icon: Icons.check_rounded,
                      onPressed: _saveManualLocation,
                    ),
                    if (location != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await widget.controller.clearLocation();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: palette.error,
                          ),
                          child: const Text('Remove saved location'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validateLatitude(String? value) {
    final double? latitude = double.tryParse((value ?? '').trim());
    if (latitude == null) {
      return 'Enter a number.';
    }
    if (latitude < -90 || latitude > 90) {
      return 'Use -90 to 90.';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    final double? longitude = double.tryParse((value ?? '').trim());
    if (longitude == null) {
      return 'Enter a number.';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Use -180 to 180.';
    }
    return null;
  }
}

class _SavedLocationCard extends StatelessWidget {
  const _SavedLocationCard({required this.location});

  final SavedLocation location;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String coordinateText = AppDate.formatCoordinates(
      location.latitude,
      location.longitude,
    );
    final String sourceText =
        location.source == LocationSource.device
            ? 'Current device location'
            : 'Manual coordinates';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 18,
              color: palette.ink,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coordinateText,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.inkMuted,
                    fontSize: 11,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                Text(
                  sourceText,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  const _LocationMessage({
    required this.message,
    this.onOpenSettings,
    required this.settingsLabel,
  });

  final String message;
  final Future<bool> Function()? onOpenSettings;
  final String settingsLabel;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline_rounded, size: 16, color: palette.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (onOpenSettings != null) ...<Widget>[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: TextButton(
                onPressed: () => onOpenSettings!(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(settingsLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
