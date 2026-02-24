import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/location_controller.dart';
import '../../../core/models/geocoding_response.dart';
import '../../../core/widgets/common_icon.dart';

const _kRecentSearchesKey = 'recent_searches';
const _kMaxRecentSearches = 5;

const _sectionLabelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
  letterSpacing: 0.8,
);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocationController _locationController = Get.find<LocationController>();
  final GetStorage _storage = GetStorage();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final RxList<GeocodingResult> _recentSearches = RxList<GeocodingResult>([]);
  final RxList<GeocodingResult> _searchResults = RxList<GeocodingResult>([]);
  final RxBool _isSearching = RxBool(false);
  final RxBool _hasText = RxBool(false);
  final RxBool _showingRecents = RxBool(true);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
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

  void _loadRecentSearches() {
    final raw = _storage.read<List>(_kRecentSearchesKey);
    if (raw == null) return;
    _recentSearches.value = raw
        .whereType<Map<String, dynamic>>()
        .map(GeocodingResult.fromJson)
        .toList();
  }

  void _saveToRecentSearches(GeocodingResult location) {
    // Deduplicate by coordinates
    _recentSearches.removeWhere(
      (r) =>
          r.latitude == location.latitude && r.longitude == location.longitude,
    );
    _recentSearches.insert(0, location);
    if (_recentSearches.length > _kMaxRecentSearches) {
      _recentSearches.removeRange(_kMaxRecentSearches, _recentSearches.length);
    }
    _storage.write(
      _kRecentSearchesKey,
      _recentSearches.map((r) => r.toJson()).toList(),
    );
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _searchResults.clear();
      _isSearching.value = false;
      _showingRecents.value = true;
      return;
    }

    _showingRecents.value = false;
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
    _saveToRecentSearches(location);
    Get.offAllNamed('/dashboard', arguments: location);
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _searchResults.clear();
    _isSearching.value = false;
    _showingRecents.value = true;
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

            const CommonIcon(
              path: AppAssets.icSearchHero,
              width: 104,
              height: 112,
            ),
            const SizedBox(height: 16),

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

            // Search bar
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

            // Results / recents list
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

                // Empty search → show recent searches
                if (_showingRecents.value) {
                  if (_recentSearches.isEmpty) {
                    return Center(
                      child: Text(
                        'No recent searches',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'RECENT SEARCHES',
                          style: _sectionLabelStyle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _recentSearches.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _SearchResultTile(
                            location: _recentSearches[i],
                            onTap: () =>
                                _onLocationSelected(_recentSearches[i]),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // API search results
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
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _SearchResultTile(
                    location: _searchResults[i],
                    onTap: () => _onLocationSelected(_searchResults[i]),
                  ),
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
    final adminRegion = location.admin1?.isNotEmpty == true
        ? location.admin1!
        : location.country;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        padding: const EdgeInsets.fromLTRB(8, 16, 13, 16),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          location.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.55,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
