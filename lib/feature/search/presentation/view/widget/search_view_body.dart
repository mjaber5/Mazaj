import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mazaj_radio/core/services/api_srvices.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SearchViewBody extends StatefulWidget {
  const SearchViewBody({super.key});

  @override
  State<SearchViewBody> createState() => _SearchViewBodyState();
}

class _SearchViewBodyState extends State<SearchViewBody> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _recentSearches = [];
  List<RadioStation> _searchResults = [];
  Timer? _debounce;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        setState(() => _isLoading = true);
        _apiService.fetchRadios(search: query).then((results) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  void _addToRecentSearches(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      });
      _saveRecentSearches();
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches = [];
    });
  }

  RadioItem _toRadioItem(RadioStation station) {
    return RadioItem(
      id: station.id,
      name: station.name,
      logo: station.logo,
      genres: station.genres,
      streamUrl: station.streamUrl,
      country: station.country,
      featured: station.featured,
      color: station.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestedSearches = ['Quran', 'Amman', 'Tarab', 'News'];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 16,
              bottom: 8,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search for stations...',
                prefixIcon: Icon(
                  Iconsax.search_normal_1,
                  color:
                      isDark
                          ? AppColors.textOnsecondaryColor
                          : AppColors.textOnPrimary,
                ),
                suffixIcon:
                    _controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () {
                            _controller.clear();
                            _focusNode.requestFocus();
                            setState(() => _searchResults = []);
                          },
                        )
                        : null,
                filled: true,
                fillColor:
                    isDark
                        ? const Color.fromRGBO(66, 66, 66, 0.2)
                        : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? const Color.fromRGBO(66, 66, 66, 0.2)
                            : AppColors.greyLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: _addToRecentSearches,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.text.isEmpty
                    ? _buildSuggestions(context, suggestedSearches)
                    : _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    List<String> suggestedSearches,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text('Clear'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _recentSearches
                      .map(
                        (search) => ActionChip(
                          label: Text(search),
                          onPressed: () {
                            _controller.text = search;
                            _addToRecentSearches(search);
                            _focusNode.requestFocus();
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Suggested Searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                suggestedSearches
                    .map(
                      (suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed: () {
                          _controller.text = suggestion;
                          _addToRecentSearches(suggestion);
                          _focusNode.requestFocus();
                        },
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final radioProvider = Provider.of<RadioProvider>(context);
    final cubit = context.read<AudioPlayerCubit>();
    return _searchResults.isEmpty
        ? const Center(child: Text('No results found'))
        : ListView.builder(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 8),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final station = _searchResults[index];
            return Card(
              margin: const EdgeInsetsDirectional.only(bottom: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: station.logo,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Iconsax.radio),
                  ),
                ),
                title: Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${station.genres} • ${station.country}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(
                    radioProvider.isFavorite(station)
                        ? Iconsax.heart
                        : Iconsax.heart_add,
                    color:
                        radioProvider.isFavorite(station) ? Colors.red : null,
                  ),
                  onPressed: () {
                    radioProvider.toggleFavorite(station);
                    cubit.playRadio(_toRadioItem(station), context);
                    _addToRecentSearches(_controller.text);
                  },
                ),
                onTap: () {
                  cubit.playRadio(_toRadioItem(station), context);
                  radioProvider.addRecentlyPlayed(station);
                  _addToRecentSearches(_controller.text);
                },
              ),
            );
          },
        );
  }
}
