import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  final String? initialValue;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  String? selectedValue;
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    filteredItems = List.from(widget.items);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      hint: Text(widget.hint),
      items: filteredItems
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      value: selectedValue,
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });
        widget.onChanged(value);
      },
      dropdownSearchData: DropdownSearchData(
        searchController: searchController,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search...'.tr(),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        searchInnerWidgetHeight: 60,
      ),
    );
  }
}




class GGGGGG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countries = ["Brazil", "Italia", "Tunisia", "Canada"];

    return Scaffold(
      appBar: AppBar(title: Text("Reusable Dropdown Example")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SearchableDropdown(
          items: countries,
          hint: "Select country",
          initialValue: null, // optional
          onChanged: (value) {
            print("Selected: $value");
          },
        ),
      ),
    );
  }
}
