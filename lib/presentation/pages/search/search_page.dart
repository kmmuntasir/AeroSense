import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/location_controller.dart';
import '../../../core/models/geocoding_response.dart';

/// SearchPage is shown when location permission is denied or
/// when the user wants to search for a new city.
/// It provides a clean search interface with autocomplete suggestions.
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

  @override
  void initState() {
    super.initState();
    // Focus search field on load
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
      return;
    }

    // Debounce: wait 500ms before searching
    _isSearching.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    if (_searchController.text != query) return; // User typed more

    final results = await _locationController.searchLocation(query);
    _searchResults.value = results;
    _isSearching.value = false;
  }

  void _onLocationSelected(GeocodingResult location) {
    // Navigate to dashboard with selected location
    Get.offAllNamed('/dashboard', arguments: location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Search icon (optional visual)
                  Icon(Icons.search, size: 48, color: const Color(0xFF4A90E2)),
                  const SizedBox(height: 24),
                  // Headline
                  Text(
                    "Let's find your weather",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF121212),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtext
                  Text(
                    'Search for a city to check the current forecast.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Search Bar
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2D32)
                          : const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF4A90E2),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF121212),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: Obx(() {
                if (_isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A90E2),
                      ),
                    ),
                  );
                }

                if (_searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty ? '' : 'No cities found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A90E2,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_city,
                            color: Color(0xFF4A90E2),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          location.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF121212),
                          ),
                        ),
                        subtitle: Text(
                          location.formattedLocation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        onTap: () => _onLocationSelected(location),
                      ),
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
