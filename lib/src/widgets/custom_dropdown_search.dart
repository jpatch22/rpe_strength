import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';

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
  final ValueNotifier<List<String>> _filteredItemsNotifier = ValueNotifier<List<String>>([]);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _filteredItemsNotifier.value = widget.items; // Initialize with the original list of items
    _loadExerciseNames();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _filteredItemsNotifier.dispose();
    super.dispose();
  }

  void _filterItems() {
    final filter = _searchController.text.toLowerCase();
    if (filter.isEmpty) {
      _filteredItemsNotifier.value = widget.items; // Reset to the original list of items
    } else {
      final fuse = Fuzzy<String>(
        widget.items, // Use the original list of items for searching
        options: FuzzyOptions(
          findAllMatches: true,
          tokenize: true,
          threshold: 0.5, // Adjust the threshold as needed
        ),
      );
      final result = fuse.search(filter);
      _filteredItemsNotifier.value = result.map<String>((r) => r.item).toList();
    }
  }

  Future<void> _loadExerciseNames() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final options = Provider.of<HiveProvider>(context, listen: false).exerciseNames;
      _filteredItemsNotifier.value = options;
      _searchController.clear();
    } catch (e) {
      print('Error loading exercise names: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addExerciseName(String name) async {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    await hiveProvider.addExerciseName(name);
    await _loadExerciseNames();
  }

  Future<void> _removeExerciseName(String name) async {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    await hiveProvider.deleteExerciseName(name);
    await _loadExerciseNames();
  }

  void _showPopup() async {
    await _loadExerciseNames();
    final selectedItem = await showDialog<String>(
      context: context,
      builder: (context) {
        String newExerciseName = '';
        return Dialog(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: "Search",
                                hintText: "Search for an option",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              newExerciseName = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Add Exercise"),
                                    content: TextField(
                                      onChanged: (value) {
                                        newExerciseName = value;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Exercise name",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(newExerciseName);
                                        },
                                        child: Text("Add"),
                                      ),
                                    ],
                                  );
                                },
                              ) ?? '';
                              if (newExerciseName.isNotEmpty) {
                                await _addExerciseName(newExerciseName);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable: _filteredItemsNotifier,
                        builder: (context, filteredItems, child) {
                          return ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return ListTile(
                                title: Text(item),
                                trailing: IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () async {
                                    await _removeExerciseName(item);
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(item);
                                },
                              );
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
              style: widget.selectedItem == null
                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)
                  : Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
