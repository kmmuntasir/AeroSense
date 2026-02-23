import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/location_controller.dart';
import '../../../core/models/geocoding_response.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocationController _locationController = Get.find<LocationController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RxList<GeocodingResult> _searchResults = RxList<GeocodingResult>([]);
  final RxBool _isSearching = RxBool(false);
  final RxBool _hasText = RxBool(false);

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
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _isSearching.value = false;
      return;
    }

    _isSearching.value = true;
    final snapshot = query;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_searchController.text != snapshot) return;

    final results = await _locationController.searchLocation(query);
    _searchResults.value = results;
    _isSearching.value = false;
  }

  void _onLocationSelected(GeocodingResult location) {
    Get.offAllNamed('/dashboard', arguments: location);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchResults.clear();
    _isSearching.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 64),
            // Hero icon
            const Center(
              child: Icon(
                Icons.travel_explore_rounded,
                size: 80,
                color: AppColors.locationButton,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Let's find your weather",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Search for a city to check the current forecast.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
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
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_hasText.value)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
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
                  if (_searchController.text.isNotEmpty) {
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
                  return const SizedBox.shrink();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
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
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Leading icon
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
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City + country code row
                  Row(
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (location.countryCode.isNotEmpty)
                        Text(
                          ', ${location.countryCode}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: AppColors.countryCode,
                          ),
                        ),
                    ],
                  ),
                  if (adminRegion.isNotEmpty)
                    Text(
                      adminRegion,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Trailing arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
