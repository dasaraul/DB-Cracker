import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import 'flexible_text.dart';

/// Widget tombol untuk navigasi ke layar pencarian program studi
class ProdiSearchButton extends StatelessWidget {
  final bool isCompact;
  
  const ProdiSearchButton({
    Key? key,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return InkWell(
      onTap: () {
        // Gunakan named routes untuk navigasi
        Navigator.pushNamed(context, '/prodi/search');
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: isCompact ? 4.0 : 16.0,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        decoration: BoxDecoration(
          color: HackerColors.surface,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: HackerColors.primary, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: HackerColors.primary.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              color: HackerColors.primary,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FlexibleText(
                    "PENCARIAN PROGRAM STUDI",
                    style: TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  if (!isCompact) 
                    const FlexibleText(
                      "Cari dan akses data seluruh program studi",
                      style: TextStyle(
                        color: HackerColors.text,
                        fontFamily: 'Courier',
                        fontSize: 12.0,
                      ),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.search,
              color: HackerColors.primary,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}