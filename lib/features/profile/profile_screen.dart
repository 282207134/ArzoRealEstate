import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../tours/tour_status_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: context.header,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
              child: Column(
                children: [
                  Semantics(
                    label: 'Edit profile picture',
                    button: true,
                    child: GestureDetector(
                      onTap: () => openPage(context, const EditProfileScreen()),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.paper,
                              boxShadow: [
                                BoxShadow(
                                  color: aqua.withValues(alpha: .10),
                                  blurRadius: 35,
                                ),
                              ],
                            ),
                            child: store.usePhoto
                                ? const Avatar(size: 120)
                                : CircleAvatar(
                                    radius: 60,
                                    backgroundColor: context.soft,
                                    child: Text(
                                      store.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: blue,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: -5,
                            right: 38,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.paper,
                                  width: 5,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(store.name, style: titleStyle(24)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.paper,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      store.email,
                      style: const TextStyle(fontSize: 12, color: blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              _ProfileRow(
                Icons.edit_outlined,
                'Change Profile Details',
                () => openPage(context, const EditProfileScreen()),
              ),
              _ProfileRow(
                Icons.sensors_outlined,
                'See Tour Status',
                () => openPage(context, const TourStatusScreen()),
              ),
              _ProfileRow(
                Icons.lock_outline_rounded,
                'Change Password',
                () => openPage(context, const ChangePasswordScreen()),
              ),
              _ProfileRow(
                Icons.settings_outlined,
                'Display and Notification Settings',
                () => openPage(context, const SettingsScreen()),
              ),
              _ProfileRow(Icons.logout_rounded, 'Logout', () async {
                final confirmed = await confirmAction(
                  context,
                  title: 'Logout?',
                  message:
                      'Your saved homes and tour requests will stay on this device.',
                  action: 'Logout',
                );
                if (confirmed) await store.signOut();
              }, danger: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.title, this.onTap, {this.danger = false});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minVerticalPadding: 14,
    leading: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFBECEE) : context.header,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 23,
        color: danger ? const Color(0xFFED565E) : blue,
      ),
    ),
    title: Text(title, style: const TextStyle(fontSize: 13)),
    trailing: Icon(
      Icons.chevron_right_rounded,
      color: context.textColor,
      size: 22,
    ),
    onTap: onTap,
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _email;
  bool _initialized = false;
  late bool _usePhoto;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final store = AppScope.of(context);
      _name = TextEditingController(text: store.name);
      _email = TextEditingController(text: store.email);
      _usePhoto = store.usePhoto;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      body: Column(
        children: [
          const PageHeader('Edit Profile'),
          Expanded(
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: _usePhoto
                        ? const Avatar(size: 110)
                        : CircleAvatar(
                            radius: 55,
                            backgroundColor: context.header,
                            child: Text(
                              store.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 40, color: blue),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _usePhoto = !_usePhoto),
                    child: Text(
                      _usePhoto
                          ? 'Use Initials Instead'
                          : 'Use Sample Profile Photo',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FormFieldBox(
                    controller: _name,
                    hint: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v?.trim().length ?? 0) >= 2
                        ? null
                        : 'Enter your full name',
                  ),
                  FormFieldBox(
                    controller: _email,
                    hint: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: PrimaryButton(
          'Save Changes',
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            await store.updateProfile(
              _name.text,
              _email.text,
              usePhoto: _usePhoto,
            );
            if (context.mounted) {
              toast(context, 'Profile successfully updated');
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController(),
      _next = TextEditingController(),
      _confirm = TextEditingController();
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const PageHeader('Change Password'),
        Expanded(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Use sample values to preview this form. This demo does not store or authenticate passwords.',
                    style: hintStyle,
                  ),
                ),
                FormFieldBox(
                  controller: _current,
                  hint: 'Current Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: validatePassword,
                ),
                FormFieldBox(
                  controller: _next,
                  hint: 'New Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) =>
                      validatePassword(v) ??
                      (v == _current.text
                          ? 'Choose a different password'
                          : null),
                ),
                FormFieldBox(
                  controller: _confirm,
                  hint: 'Confirm New Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) =>
                      v == _next.text ? null : 'Passwords do not match',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomAction(
      child: PrimaryButton(
        'Update Password',
        onPressed: () async {
          if (!_form.currentState!.validate()) return;
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Password Form Complete'),
              content: const Text(
                'Your sample values passed validation. Connect an account service to update a real password.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      body: Column(
        children: [
          const PageHeader('Display and Notifications'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Make Arzo Feel Like Home', style: titleStyle(22)),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  key: const Key('dark-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Dark Appearance',
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: const Text(
                    'A softer view, day or night',
                    style: hintStyle,
                  ),
                  value: store.dark,
                  activeTrackColor: blue,
                  onChanged: store.setDark,
                ),
                const Divider(height: 36),
                SwitchListTile.adaptive(
                  key: const Key('notifications-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Tour Notifications',
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Remember my notification preference',
                    style: hintStyle,
                  ),
                  value: store.notifications,
                  activeTrackColor: blue,
                  onChanged: store.setNotifications,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Preferences are saved on this device. Push notifications are available when a notification service is connected.',
                  style: hintStyle,
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'ARZO · 1.0.0',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
