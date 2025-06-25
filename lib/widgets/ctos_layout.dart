import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'ctos_container.dart';

/// Layout responsif untuk mengatasi overflow
class CtOSResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool enableScroll;

  const CtOSResponsiveLayout({
    Key? key,
    required this.child,
    this.padding,
    this.enableScroll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );

    if (enableScroll) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Grid layout yang responsif untuk card
class CtOSResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const CtOSResponsiveGrid({
    Key? key,
    required this.children,
    this.maxCrossAxisExtent = 400.0,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// List item dengan styling ctOS
class CtOSListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget? leadingIcon;
  final VoidCallback? onTap;
  final bool showDivider;

  const CtOSListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: 12.0),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CtOSText(
                        title,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        maxLines: 2,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4.0),
                        CtOSText(
                          subtitle!,
                          fontSize: 12.0,
                          color: CtOSColors.textSecondary,
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12.0),
                  CtOSText(
                    trailing!,
                    fontSize: 12.0,
                    color: CtOSColors.textAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 8.0),
                  Icon(
                    Icons.chevron_right,
                    color: CtOSColors.textSecondary,
                    size: 18.0,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1.0,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            color: CtOSColors.divider,
          ),
      ],
    );
  }
}

/// Data row untuk menampilkan informasi
class CtOSDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const CtOSDataRow({
    Key? key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: CtOSText(
              "$label:",
              fontSize: 12.0,
              color: CtOSColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: CtOSText(
              value.isNotEmpty ? value : "N/A",
              fontSize: 12.0,
              color: isHighlighted
                  ? CtOSColors.textAccent
                  : (value.isNotEmpty
                      ? CtOSColors.textPrimary
                      : CtOSColors.textTertiary),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar dengan styling ctOS
class CtOSSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const CtOSSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onSearch,
    this.onChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.border),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: CtOSColors.shadow,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSearch != null ? (_) => onSearch!() : null,
        style: const TextStyle(
          color: CtOSColors.textPrimary,
          fontFamily: 'Courier',
          fontSize: 14.0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: CtOSColors.textTertiary,
            fontFamily: 'Courier',
            fontSize: 14.0,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: CtOSColors.textSecondary,
            size: 20.0,
          ),
          suffixIcon: isLoading
              ? Container(
                  width: 20.0,
                  height: 20.0,
                  padding: const EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CtOSColors.primary),
                  ),
                )
              : (onSearch != null
                  ? IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: CtOSColors.primary,
                        size: 20.0,
                      ),
                      onPressed: onSearch,
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
      ),
    );
  }
}

/// Terminal window dengan styling ctOS
class CtOSTerminal extends StatelessWidget {
  final String title;
  final List<String> messages;
  final bool isActive;
  final double? height;

  const CtOSTerminal({
    Key? key,
    required this.title,
    required this.messages,
    this.isActive = false,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CtOSContainer(
      backgroundColor: CtOSColors.background,
      borderColor: isActive ? CtOSColors.primary : CtOSColors.border,
      showGlow: isActive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CtOSHeader(
            title: title,
            trailing: CtOSStatusIndicator(
              isActive: isActive,
              label: isActive ? "ACTIVE" : "IDLE",
            ),
          ),
          Container(
            height: height ?? 200.0,
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: CtOSColors.background,
              border: Border.all(color: CtOSColors.border),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: CtOSText(
                    "> ${messages[index]}",
                    fontSize: 12.0,
                    color: CtOSColors.textAccent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
