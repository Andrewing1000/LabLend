import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pie del inicio: presentación del laboratorio y enlaces de la universidad.
class FooterWidget extends StatelessWidget {
  final bool compact;
  final double gutter;

  const FooterWidget({super.key, this.compact = false, this.gutter = 56});

  static const String about =
      'En el Laboratorio de la Universidad Católica Boliviana estamos comprometidos '
      'con la excelencia académica y la investigación. Ofrecemos materiales y '
      'recursos para apoyar el desarrollo de proyectos científicos y académicos.';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(gutter, compact ? AppSpacing.xl : 48, gutter, AppSpacing.xxl),
      child: Wrap(
        spacing: 64,
        runSpacing: AppSpacing.xl,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                  child: Image.asset('assets/images/ucb_logo.png',
                      height: 40, semanticLabel: 'Universidad Católica Boliviana'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(about,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary, height: 1.6)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SocialMediaIcon(
                icon: Icons.facebook,
                label: 'Facebook',
                url: 'https://www.facebook.com/UCB.BOLIVIA/',
              ),
              SocialMediaIcon(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                url: 'https://www.instagram.com/ucb.lapaz/?hl=en',
              ),
              SocialMediaIcon(
                icon: Icons.alternate_email,
                label: 'Twitter',
                url: 'https://x.com/UCBLaPaz/',
              ),
              SocialMediaIcon(
                icon: Icons.place_outlined,
                label: 'Ubicación',
                url: 'https://maps.app.goo.gl/gnNShhurjLcXhvCi8',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enlace con ícono a una red social o a la ubicación.
class SocialMediaIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;

  const SocialMediaIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<SocialMediaIcon> createState() => _SocialMediaIconState();
}

class _SocialMediaIconState extends State<SocialMediaIcon> {
  bool hovered = false;

  Future<void> _launchURL() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = hovered ? AppColors.primary : AppColors.textPrimary;
    return Semantics(
      link: true,
      label: widget.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: _launchURL,
        onHover: (value) => setState(() => hovered = value),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.md),
              Text(widget.label, style: TextStyle(color: color, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
