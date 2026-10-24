import 'package:flutter/material.dart';
import '../data/models.dart';
import 'theme.dart';

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
void toast(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 52)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
    return outlined
        ? OutlinedButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton(
            onPressed: onPressed,
            style: style.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.disabled) ? context.line : blue,
              ),
            ),
            child: Text(label),
          );
  }
}

class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.paper,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 36,
          offset: const Offset(0, -8),
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
    child: SafeArea(top: false, child: child),
  );
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: label,
    onPressed: onTap,
    icon: Icon(icon, size: 23),
    style: IconButton.styleFrom(
      backgroundColor: context.paper,
      foregroundColor: color ?? context.textColor,
      minimumSize: const Size(44, 44),
    ),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader(
    this.title, {
    super.key,
    this.back = true,
    this.subtitle,
    this.trailing,
    this.child,
    this.art = false,
    this.onBack,
  });
  final String title;
  final String? subtitle;
  final bool back, art;
  final Widget? trailing, child;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Container(
    color: context.header,
    child: Stack(
      children: [
        if (art)
          const Positioned(
            right: -8,
            bottom: -65,
            width: 125,
            child: CityArt(),
          ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (back)
                      RoundButton(
                        icon: Icons.arrow_back_rounded,
                        label: 'Back',
                        onTap: onBack ?? () => Navigator.maybePop(context),
                      ),
                    if (back) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: back
                            ? const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )
                            : titleStyle(28),
                        textAlign: back ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                    if (trailing != null)
                      trailing!
                    else if (back)
                      const SizedBox(width: 44),
                  ],
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(subtitle!, style: hintStyle),
                  ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: child!,
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class CityArt extends StatelessWidget {
  const CityArt({super.key});
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/city.png',
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 30});
  final double size;
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/brand.png', width: size, height: size);
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 44, this.owner = 'Angela Wani'});
  final double size;
  final String owner;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.header,
      border: Border.all(color: context.paper, width: 2),
    ),
    clipBehavior: Clip.antiAlias,
    child: owner == 'William Smith'
        ? Center(
            child: Text(
              'WS',
              style: TextStyle(
                color: blue,
                fontSize: size / 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hint = 'Search estate or owner',
    this.readOnly = false,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hint;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.paper,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: ink.withValues(alpha: .035),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: TextField(
      key: const Key('search-field'),
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.search_rounded, color: muted, size: 26),
        ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  controller!.clear();
                  onChanged?.call('');
                },
              )
            : null,
      ),
    ),
  );
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.labels = const ['All', 'House', 'Apartment'],
  });
  final String value;
  final List<String> labels;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: labels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final label = labels[i];
        final active = label == value;
        return OutlinedButton.icon(
          key: Key('category-$label'),
          onPressed: () => onChanged(label),
          icon: Icon(
            label == 'All' || label == 'Estate'
                ? Icons.holiday_village_outlined
                : label == 'House'
                ? Icons.home_outlined
                : label == 'Owner'
                ? Icons.person_outline_rounded
                : Icons.apartment_rounded,
            size: 22,
          ),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: active ? context.accent : muted,
            backgroundColor: active ? context.header : context.paper,
            side: BorderSide(color: active ? aqua : context.line),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: const StadiumBorder(),
          ),
        );
      },
    ),
  );
}

class PropertyTile extends StatelessWidget {
  const PropertyTile(this.property, {super.key, this.onTap});
  final Property property;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: context.isDark ? context.soft : context.paper,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: ink.withValues(alpha: .055),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/${property.image}.png',
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.priceLabel,
                      style: TextStyle(fontSize: 14, color: context.accent),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 3,
                      children: [
                        _Stat(Icons.bed_outlined, '${property.beds} Bedroom'),
                        _Stat(Icons.open_with_rounded, '${property.area} Sqft'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: muted),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: muted)),
    ],
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.search_off_rounded,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.header,
                ),
                child: Icon(icon, color: blue, size: 50),
              ),
              const SizedBox(height: 24),
              Text(title, style: titleStyle(23), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: muted, height: 1.8),
                textAlign: TextAlign.center,
              ),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: action!,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FormFieldBox extends StatelessWidget {
  const FormFieldBox({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
    this.suffix,
    this.keyboardType,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: context.paper,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: ink.withValues(alpha: .045),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Icon(icon, color: muted, size: 23),
        ),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    ),
  );
}

String? validateEmail(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
String? validatePassword(String? value) =>
    (value?.length ?? 0) >= 6 ? null : 'Use at least 6 characters';

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message, style: bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              action,
              style: const TextStyle(color: Color(0xFFED565E)),
            ),
          ),
        ],
      ),
    ) ??
    false;
