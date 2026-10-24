import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../messages/messages_screen.dart';
import '../property/property_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.embedded = false, this.owners = false});
  final bool embedded, owners;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '', _category = 'Estate';
  @override
  void initState() {
    super.initState();
    if (widget.owners) _category = 'Owner';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context),
        results = AppScope.of(context).search(_query);
    final owners = ['Angela Wani', 'William Smith']
        .where((n) => n.toLowerCase().contains(_query.toLowerCase().trim()))
        .toList();
    final content = Column(
      children: [
        PageHeader(
          _query.isEmpty ? 'Search' : 'Search Results',
          back: !widget.embedded,
          art: true,
          child: SearchBox(
            controller: _controller,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 20),
        CategoryChips(
          value: _category,
          labels: const ['Estate', 'Owner'],
          onChanged: (v) => setState(() => _category = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_category == 'Estate' ? results.length : owners.length} Results Found',
              style: hintStyle,
            ),
          ),
        ),
        Expanded(
          child: (_category == 'Estate' ? results.isEmpty : owners.isEmpty)
              ? const EmptyState(
                  title: 'No Results Found',
                  message:
                      'Try a different estate name, city or listing owner.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: _category == 'Estate'
                      ? results
                            .map(
                              (p) => PropertyTile(
                                p,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  openPage(
                                    context,
                                    PropertyScreen(property: p),
                                  );
                                },
                              ),
                            )
                            .toList()
                      : owners
                            .map(
                              (n) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                leading: Avatar(owner: n, size: 52),
                                title: Text(
                                  n,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${store.search(n).length} listings · Los Angeles',
                                  style: hintStyle,
                                ),
                                trailing: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: blue,
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  openPage(context, ChatScreen(owner: n));
                                },
                              ),
                            )
                            .toList(),
                ),
        ),
      ],
    );
    return widget.embedded ? content : Scaffold(body: content);
  }
}
