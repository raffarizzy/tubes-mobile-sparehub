import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/rating_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/rating_model.dart';

class ReviewDialog extends StatefulWidget {
  final String produkId;

  const ReviewDialog({super.key, required this.produkId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final RatingService _ratingService = RatingService();
  final AuthService _authService = AuthService();
  final TextEditingController _komentarController = TextEditingController();

  int rating = 5;
  bool isSubmitting = false;

  Future<void> _submitReview() async {
    if (_komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Komentar tidak boleh kosong')));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'Silakan login terlebih dahulu';
      }

      // Get userName from displayName or email
      String userName =
          user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

      RatingModel newRating = RatingModel(
        id: '', // Will be auto-generated
        produkId: widget.produkId,
        userId: user.uid,
        userName: userName, // ✅ Include userName
        rating: rating,
        komentar: _komentarController.text.trim(),
        tanggal: DateTime.now().toString().substring(0, 10),
      );

      await _ratingService.addRating(newRating);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Review berhasil ditambahkan!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan review: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Sangat Bagus';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tulis Review',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating Produk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Bintang Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber[700],
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 8),

            // Display rating number dan description
            Center(
              child: Column(
                children: [
                  Text(
                    '$rating / 5',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRatingDescription(rating),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Komentar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _komentarController,
              decoration: const InputDecoration(
                hintText: 'Ceritakan pengalaman Anda dengan produk ini...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 5,
              enabled: !isSubmitting,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF122C4F),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Kirim Review',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }
}
