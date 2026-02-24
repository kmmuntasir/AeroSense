import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/location_controller.dart';
import '../../../core/models/geocoding_response.dart';
import '../../../core/widgets/common_icon.dart';

// Dummy location data matching the Figma "San" search simulation
final List<GeocodingResult> _defaultLocations = [
  GeocodingResult(
    name: 'San Francisco',
    country: 'United States',
    countryCode: 'US',
    state: 'California',
    latitude: 37.7749,
    longitude: -122.4194,
  ),
  GeocodingResult(
    name: 'San Diego',
    country: 'United States',
    countryCode: 'US',
    state: 'California',
    latitude: 32.7157,
    longitude: -117.1611,
  ),
  GeocodingResult(
    name: 'Santiago',
    country: 'Chile',
    countryCode: 'CL',
    state: 'Santiago Metropolitan',
    latitude: -33.4489,
    longitude: -70.6693,
  ),
  GeocodingResult(
    name: 'San Antonio',
    country: 'United States',
    countryCode: 'US',
    state: 'Texas',
    latitude: 29.4241,
    longitude: -98.4936,
  ),
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocationController _locationController = Get.find<LocationController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Initialised with dummy data so locations show on first load
  final RxList<GeocodingResult> _searchResults = RxList<GeocodingResult>(
    List.of(_defaultLocations),
  );
  final RxBool _isSearching = RxBool(false);
  final RxBool _hasText = RxBool(false);
  final RxBool _showingDefaults = RxBool(true);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _hasText.value = _searchController.text.isNotEmpty;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _searchResults.value = List.of(_defaultLocations);
      _isSearching.value = false;
      _showingDefaults.value = true;
      return;
    }

    _showingDefaults.value = false;

    // Filter local dummy data first (instant, no network)
    final q = query.toLowerCase().trim();
    final localResults = _defaultLocations
        .where(
          (loc) =>
              loc.name.toLowerCase().contains(q) ||
              (loc.state?.toLowerCase().contains(q) ?? false) ||
              loc.country.toLowerCase().contains(q),
        )
        .toList();

    if (localResults.isNotEmpty) {
      _searchResults.value = localResults;
      _isSearching.value = false;
      return;
    }

    // No local match — fall through to real API with cancellable debounce
    _isSearching.value = true;
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _fetchRemote(query),
    );
  }

  Future<void> _fetchRemote(String query) async {
    final results = await _locationController.searchLocation(query);
    if (!mounted || _searchController.text.trim() != query.trim()) return;
    _searchResults.value = results;
    _isSearching.value = false;
  }

  void _onLocationSelected(GeocodingResult location) {
    Get.offAllNamed('/dashboard', arguments: location);
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _searchResults.value = List.of(_defaultLocations);
    _isSearching.value = false;
    _showingDefaults.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Hero icon — ic_search_hero.svg, Figma node 11:1195 (128×136)
            const CommonIcon(
              path: AppAssets.icSearchHero,
              width: 104,
              height: 112,
            ),
            const SizedBox(height: 16),

            // Heading — exact Figma copy, 28px Bold
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Let's find your weather",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Body — exact Figma copy, 16px
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Search for a city to check the current forecast.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.625,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Search bar — pill shape, #EDEDED fill, 342×56
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(
                () => Container(
                  height: 56,
                  decoration: const ShapeDecoration(
                    color: AppColors.searchBarBackground,
                    shape: StadiumBorder(),
                  ),
                  child: Row(
                    children: [
                      // Leading search icon — 38px container
                      const SizedBox(
                        width: 38,
                        height: 56,
                        child: Center(
                          child: Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Text input
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.55,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Trailing clear button — visible when typing
                      if (_hasText.value)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            width: 33,
                            height: 56,
                            margin: const EdgeInsets.only(right: 6),
                            child: Center(
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results list
            Expanded(
              child: Obx(() {
                if (_isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.locationButton,
                      ),
                    ),
                  );
                }

                if (_searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No cities found',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return _SearchResultTile(
                      location: location,
                      onTap: () => _onLocationSelected(location),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final GeocodingResult location;
  final VoidCallback onTap;

  const _SearchResultTile({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final adminRegion = location.state?.isNotEmpty == true
        ? location.state!
        : location.country;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        padding: const EdgeInsets.fromLTRB(8, 16, 13, 16),
        child: Row(
          children: [
            // Leading location circle icon — 40×40
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.locationButton.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 20,
                color: AppColors.locationButton,
              ),
            ),
            const SizedBox(width: 12),

            // Text: city name + country code on one row, region below
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // City name + country code row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.55,
                        ),
                      ),
                      if (location.countryCode.isNotEmpty)
                        Text(
                          ', ${location.countryCode}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.countryCode,
                            height: 1.43,
                          ),
                        ),
                    ],
                  ),
                  if (adminRegion.isNotEmpty)
                    Text(
                      adminRegion,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.43,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Trailing arrow — 19×19 in Figma
            const SizedBox(
              width: 19,
              height: 19,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
