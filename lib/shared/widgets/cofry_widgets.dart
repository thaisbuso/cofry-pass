import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────
// Auth page centered layout
// ─────────────────────────────────────────────

class AuthLayout extends StatelessWidget {
  final List<Widget> children;

  const AuthLayout({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// App logo badge (shield icon)
// ─────────────────────────────────────────────

class AppLogoMark extends StatelessWidget {
  final double size;

  const AppLogoMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/cofry-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

// ─────────────────────────────────────────────
// Auth screen header block
// ─────────────────────────────────────────────

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;
  final bool horizontal;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal && showLogo) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AppLogoMark(size: 80),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.05,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          const AppLogoMark(),
          const SizedBox(height: 22),
        ],
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Loading spinner button replacement
// ─────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final String label;

  const PrimaryButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !loading && onPressed != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? const [AppColors.primaryLight, AppColors.primary]
                : [AppColors.primaryDim, AppColors.primaryDim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.white.withAlpha(25),
          highlightColor: Colors.white.withAlpha(15),
          child: SizedBox(
            height: 52,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Field with optional show/hide toggle
// ─────────────────────────────────────────────

class CofryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;

  const CofryTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  State<CofryTextField> createState() => _CofryTextFieldState();
}

class _CofryTextFieldState extends State<CofryTextField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      maxLines: _hidden ? 1 : widget.maxLines,
      style: const TextStyle(color: AppColors.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Vault item initial-letter avatar
// ─────────────────────────────────────────────

class VaultItemAvatar extends StatelessWidget {
  final String title;
  final double size;

  const VaultItemAvatar({super.key, required this.title, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final letter = title.isNotEmpty ? title[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Detail field row card (used in details page)
// ─────────────────────────────────────────────

class DetailFieldCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool canObscure;
  final bool canCopy;

  const DetailFieldCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.canObscure = false,
    this.canCopy = false,
  });

  @override
  State<DetailFieldCard> createState() => _DetailFieldCardState();
}

class _DetailFieldCardState extends State<DetailFieldCard> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.canObscure;
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.label} copiado')),
    );
  }

  String get _displayValue {
    if (widget.value.isEmpty) return '—';
    if (_hidden) return '•' * widget.value.length.clamp(8, 16);
    return widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.value.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayValue,
                  style: TextStyle(
                    color: isEmpty ? AppColors.subtle : AppColors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: _hidden ? 2 : 0,
                  ),
                ),
              ],
            ),
          ),
          if (!isEmpty) ...[
            if (widget.canObscure)
              _ActionIcon(
                icon: _hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onTap: () => setState(() => _hidden = !_hidden),
              ),
            if (widget.canCopy) ...[
              const SizedBox(width: 4),
              _ActionIcon(icon: Icons.copy_rounded, onTap: _copy),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.border.withAlpha(120),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: AppColors.muted),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Thin horizontal divider with label
// ─────────────────────────────────────────────

class SectionDivider extends StatelessWidget {
  final String? label;

  const SectionDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Divider(height: 32);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section label above a group of fields
// ─────────────────────────────────────────────

class FieldGroupLabel extends StatelessWidget {
  final String text;

  const FieldGroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state placeholder
// ─────────────────────────────────────────────

class EmptyVaultState extends StatelessWidget {
  const EmptyVaultState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cofre vazio',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione suas primeiras credenciais\npelo botão abaixo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
