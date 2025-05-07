import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class RestrictedInquiryScreen extends StatefulWidget {
  const RestrictedInquiryScreen({Key? key}) : super(key: key);

  @override
  State<RestrictedInquiryScreen> createState() => _RestrictedInquiryScreenState();
}

class _RestrictedInquiryScreenState extends State<RestrictedInquiryScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, int> _keywordMap = {};
  List<String> _filteredSuggestions = [];
  bool _hasSearched = false;
  bool _isRestricted = false;
  String _searchedItem = '';

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    final jsonString = await rootBundle.loadString('assets/restricted_keywords.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      _keywordMap = jsonMap.map((key, value) => MapEntry(key.toLowerCase(), value as int));
    });
  }

  void _onChanged(String input) {
    final query = input.toLowerCase();
    setState(() {
      // Hide previous search result when user modifies input
      _hasSearched = false;
      if (query.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = _keywordMap.keys
            .where((k) => k.startsWith(query))
            .toList();
      }
    });
  }

  void _onSearch() {
    final input = _controller.text.trim().toLowerCase();
    final status = _keywordMap[input] ?? 0;
    setState(() {
      _hasSearched = true;
      _isRestricted = status == 1;
      _searchedItem = _controller.text.trim();
      _filteredSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Restricted Enquiry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Name', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      onChanged: _onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter item names',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    if (_filteredSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _filteredSuggestions[index];
                            return ListTile(
                              title: Text(suggestion),
                              onTap: () {
                                setState(() {
                                  _controller.text = suggestion;
                                  _controller.selection =
                                      TextSelection.collapsed(offset: suggestion.length);
                                  _filteredSuggestions = [];
                                  _hasSearched = false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSearch,
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _CommonEmbargoedSection(),
            const SizedBox(height: 24),
            const _DetailListSection(),
            if (_hasSearched) ...[
              const SizedBox(height: 24),
              _SearchResultCard(item: _searchedItem, isRestricted: _isRestricted),
              const SizedBox(height: 16),
              const Text(
                'The query result is for reference only. Please judge according to the actual situation. '
                'If you think the result is wrong or have questions about the result, you can adjust the name '
                'of the item to inquire again, or contact Cainiao CS.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommonEmbargoedSection extends StatelessWidget {
  const _CommonEmbargoedSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Map<String, String>>[
      {'asset': 'assets/images/embargo_living.png', 'label': 'Living animal'},
      {'asset': 'assets/images/embargo_frozen.png', 'label': 'Frozen products'},
      {'asset': 'assets/images/embargo_drugs.png', 'label': 'Embargoed drugs'},
      {'asset': 'assets/images/embargo_flammable.png', 'label': 'Flammable and explosive'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Common Embargoed Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(e['asset']!, fit: BoxFit.cover),
                          Container(
                            color: Colors.red.withOpacity(0.6),
                            child: const Center(
                              child: Icon(Icons.block, color: Colors.white, size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(e['label']!, style: theme.textTheme.bodySmall),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailListSection extends StatelessWidget {
  const _DetailListSection();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '1. Living animal\n'
      'Common in pet cats, dogs, hamsters, Shougong, ornamental fish, shrimp, insects, etc.\n\n'
      '2. Frozen products\n'
      'Common in chilled pork, cattle, sheep and other meat, chilled pre-prepared vegetables, fresh fruits and vegetables\n\n'
      '3. Embargoed drugs\n'
      'Common in large quantities of traditional Chinese medicine and raw materials, prescription drugs, antibiotics, stimulants, hypnotics, tranquilizers and sedatives, etc.\n\n'
      '4. Flammable and explosive\n'
      'Commonly used in lighters, alcohol, perfume, cigarettes, tobacco, pressure cans (contents include gas, liquid, etc.), glue, alcohol products',
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String item;
  final bool isRestricted;
  const _SearchResultCard({required this.item, required this.isRestricted});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text('To Singapore', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            isRestricted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cannot be delivered',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'The item you entered belongs to 动植物及制品Category',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Can be delivered',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'The item you entered is allowed.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}