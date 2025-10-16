import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';

class ModernServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? price;
  final VoidCallback? onTap;
  final List<String>? images;

  const ModernServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.price,
    this.onTap,
    this.images,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images != null && images!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/loaders/loader2.gif'),
                  image: NetworkImage(images!.first),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 48,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (price != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                price!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27ae60),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
