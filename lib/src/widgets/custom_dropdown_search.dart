import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import '../database/hive_helper.dart';

class CustomDropdownSearch extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final void Function(String?) onChanged;
  final String labelText;
  final String hintText;

  CustomDropdownSearch({
    required this.items,
    required this.onChanged,
    this.selectedItem,
    this.labelText = "",
    this.hintText = "Search and select an option",
  });

  @override
  _CustomDropdownSearchState createState() => _CustomDropdownSearchState();
}

class _CustomDropdownSearchState extends State<CustomDropdownSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final filter = _searchController.text;
    if (filter.isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
    } else {
      final fuse = Fuzzy<String>(
        widget.items,
        options: FuzzyOptions(
          findAllMatches: true,
          tokenize: true,
          threshold: 0.5, // Adjust the threshold as needed
        ),
      );
      final result = fuse.search(filter);
      setState(() {
        _filteredItems = result.map<String>((r) => r.item).toList();
      });
    }
  }

  Future<void> _loadExerciseNames() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final options = await HiveHelper.getExerciseNames();
      setState(() {
        _filteredItems = options;
        _searchController.clear();
      });
    } catch (e) {
      print('Error loading exercise names: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPopup() async {
    await _loadExerciseNames();
    final selectedItem = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Search for an option",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
    if (selectedItem != null) {
      widget.onChanged(selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPopup,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.selectedItem ?? widget.hintText,
              style: TextStyle(
                color: widget.selectedItem == null ? Colors.grey : Colors.black,
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
