import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../home/search_screen.dart';

const _sampleMessages = [
  ChatMessage('Hi Angela, how’s it going?'),
  ChatMessage(
    'Your latest house posting is interesting, can you tell me more about it?',
  ),
  ChatMessage('Hello, thanks for reaching out!', mine: false),
  ChatMessage(
    'The house is 200sqft with 3 bedrooms and scandinavian style fully furnished.',
    mine: false,
  ),
  ChatMessage(
    'If you are interested, feel free to schedule a tour.',
    mine: false,
  ),
];

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final owners = store.messages.keys.toList();
    return Column(
      children: [
        const PageHeader('Messages', back: false, art: true),
        Expanded(
          child: owners.isEmpty
              ? EmptyState(
                  title: 'Start a Conversation',
                  message:
                      'Get to know a home. Ask the listing owner about the details that matter to you.',
                  icon: Icons.chat_bubble_outline_rounded,
                  action: PrimaryButton(
                    'Find a Listing Owner',
                    onPressed: () =>
                        openPage(context, const SearchScreen(owners: true)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: owners.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final owner = owners[i],
                        messages = store.messages[owners[i]]!;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      leading: Avatar(owner: owner, size: 54),
                      title: Text(
                        owner,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        messages.isEmpty
                            ? 'Start a conversation'
                            : messages.last.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hintStyle,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: muted,
                      ),
                      onTap: () => openPage(context, ChatScreen(owner: owner)),
                    );
                  },
                ),
        ),
        if (owners.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: TextButton.icon(
              onPressed: () =>
                  openPage(context, const SearchScreen(owners: true)),
              icon: const Icon(Icons.add_comment_outlined, size: 20),
              label: const Text('New Conversation'),
            ),
          ),
      ],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.owner});
  final String owner;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    if (_input.text.trim().isEmpty) return;
    AppScope.of(context).send(widget.owner, _input.text);
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stored = AppScope.of(context).messages[widget.owner] ?? [];
    final messages = [
      if (widget.owner == 'Angela Wani') ..._sampleMessages,
      ...stored,
    ];
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: context.header,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
                child: Row(
                  children: [
                    RoundButton(
                      icon: Icons.arrow_back_rounded,
                      label: 'Back',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    Avatar(owner: widget.owner, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.owner,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Listing owner',
                            style: TextStyle(fontSize: 10, color: muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Contact information',
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        size: 22,
                        color: blue,
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Conversation Preview'),
                          content: const Text(
                            'Messages are saved on this device. Connect a messaging service to deliver messages or place calls to the listing owner.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Got It'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Text(
              'Sample conversation · Messages stay on this device',
              style: TextStyle(fontSize: 10, color: muted),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const EmptyState(
                    title: 'Say Hello',
                    message:
                        'Ask about the property, neighborhood or a viewing time.',
                    icon: Icons.waving_hand_outlined,
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      return Align(
                        alignment: m.mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * .79,
                          ),
                          margin: const EdgeInsets.only(bottom: 12, left: 0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: m.mine ? blue : context.header,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.8,
                              color: m.mine ? Colors.white : context.textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.paper,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: context.line),
                  boxShadow: [
                    BoxShadow(
                      color: ink.withValues(alpha: .035),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: TextField(
                  key: const Key('message-input'),
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: const TextStyle(fontSize: 13, color: muted),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      key: const Key('send-message'),
                      tooltip: 'Send message',
                      onPressed: _send,
                      icon: const Icon(
                        Icons.send_outlined,
                        color: blue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
