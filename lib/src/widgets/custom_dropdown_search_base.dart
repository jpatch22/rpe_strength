import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';

class CustomDropdownSearchBase extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onChanged;
  final String labelText;
  final String hintText;

  CustomDropdownSearchBase({
    required this.items,
    required this.onChanged,
    required this.selectedItems,
    this.labelText = "",
    this.hintText = "Search and select options",
  });

  @override
  _CustomDropdownSearchBaseState createState() => _CustomDropdownSearchBaseState();
}

class _CustomDropdownSearchBaseState extends State<CustomDropdownSearchBase> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isLoading = false;
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    hiveProvider.fetchExerciseNames();
    _filteredItems = widget.items;
    _selectedItems = List.from(widget.selectedItems);
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
      final options = Provider.of<HiveProvider>(context, listen: false).exerciseNames;
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
    final selectedItems = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                              hintText: "Search for options",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = _selectedItems.contains(item);
                              return ListTile(
                                title: Text(item),
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedItems.add(item);
                                      } else {
                                        _selectedItems.remove(item);
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedItems.remove(item);
                                    } else {
                                      _selectedItems.add(item);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(_selectedItems);
                            },
                            child: Text("Done"),
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
    if (selectedItems != null) {
      setState(() {
        _selectedItems = selectedItems;
      });
      widget.onChanged(_selectedItems);
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
            Expanded(
              child: Text(
                _selectedItems.isEmpty
                    ? widget.hintText
                    : _selectedItems.join(', '),
                style: TextStyle(
                  color: _selectedItems.isEmpty ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
