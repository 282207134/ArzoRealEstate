import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../home/location_screen.dart';

enum AuthMode { signIn, signUp, forgot, reset }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.mode = AuthMode.signIn});
  final AuthMode mode;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _visible = false, _sent = false;
  bool get _signup => widget.mode == AuthMode.signUp;
  bool get _reset => widget.mode == AuthMode.reset;
  bool get _forgot => widget.mode == AuthMode.forgot;
  String get _title => switch (widget.mode) {
    AuthMode.signIn => 'Sign In',
    AuthMode.signUp => 'Sign Up',
    AuthMode.forgot => 'Forgot Password',
    AuthMode.reset => 'Reset Password',
  };
  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    switch (widget.mode) {
      case AuthMode.forgot:
        setState(() => _sent = true);
      case AuthMode.reset:
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('New Password Created'),
            content: const Text(
              'Your local demo password has been reset. You can now return to sign in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
      case AuthMode.signUp:
        final selected = await openPage<String>(
          context,
          const LocationScreen(selectNeighborhood: true),
        );
        if (selected == null || !mounted) return;
        await store.setLocation(selected);
        await store.signIn(userName: _name.text, userEmail: _email.text);
        if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
      case AuthMode.signIn:
        await store.signIn(userEmail: _email.text);
        if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: context.header,
            child: Stack(
              children: [
                const Positioned(
                  right: -30,
                  bottom: -100,
                  width: 200,
                  child: CityArt(),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.mode == AuthMode.signIn)
                            const BrandMark()
                          else
                            RoundButton(
                              icon: Icons.arrow_back_rounded,
                              label: 'Back',
                              onTap: () => Navigator.pop(context),
                            ),
                          const SizedBox(height: 12),
                          Text(_title, style: titleStyle(30)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _fields(context),
                  ),
                ),
              ),
              const Spacer(),
              if (!_sent)
                BottomAction(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                        _forgot
                            ? 'Send Reset Link'
                            : _reset
                            ? 'Create New Password'
                            : _title,
                        onPressed: _submit,
                      ),
                      if (widget.mode == AuthMode.signIn || _signup) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => _signup
                              ? Navigator.pop(context)
                              : openPage(
                                  context,
                                  const AuthScreen(mode: AuthMode.signUp),
                                ),
                          child: Text(
                            _signup
                                ? 'I Already Have an Account'
                                : 'I Don’t Have an Account',
                          ),
                        ),
                        if (!_signup)
                          TextButton(
                            key: const Key('guest-button'),
                            onPressed: () => AppScope.of(context).signIn(),
                            child: const Text(
                              'Explore as a Guest',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  List<Widget> _fields(BuildContext context) => _sent
      ? [
          const SizedBox(height: 28),
          const Icon(Icons.mark_email_read_outlined, color: blue, size: 64),
          const SizedBox(height: 20),
          Text(
            'Your Reset Link Is Ready',
            style: titleStyle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This demo keeps account recovery on this device. Continue below to preview creating a new password.',
            style: bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            'Create New Password',
            onPressed: () =>
                openPage(context, const AuthScreen(mode: AuthMode.reset)),
          ),
        ]
      : [
          if (_forgot)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Enter your email address to recover access to your account.',
                style: bodyStyle,
              ),
            ),
          if (_signup)
            FormFieldBox(
              controller: _name,
              hint: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v?.trim().length ?? 0) >= 2 ? null : 'Enter your full name',
            ),
          if (!_reset)
            FormFieldBox(
              controller: _email,
              hint: 'Email Address',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
          if (!_forgot)
            FormFieldBox(
              controller: _password,
              hint: _reset ? 'New Password' : 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: !_visible,
              validator: validatePassword,
              suffix: IconButton(
                tooltip: _visible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: muted,
                ),
              ),
            ),
          if (_reset)
            FormFieldBox(
              controller: _confirm,
              hint: 'Confirm New Password',
              icon: Icons.lock_outline_rounded,
              obscure: !_visible,
              validator: (v) =>
                  v == _password.text ? null : 'Passwords do not match',
            ),
          if (widget.mode == AuthMode.signIn)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    openPage(context, const AuthScreen(mode: AuthMode.forgot)),
                child: const Text('Forgot Password?'),
              ),
            ),
          if (_signup)
            const Text(
              'By continuing, you agree to use this preview with sample account details.',
              style: hintStyle,
            ),
        ];
}
