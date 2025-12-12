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

      RatingModel newRating = RatingModel(
        id: '', // Will be auto-generated
        produkId: widget.produkId,
        userId: user.uid,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tulis Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _komentarController,
              decoration: InputDecoration(
                hintText: 'Tulis pengalaman Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              enabled: !isSubmitting,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitReview,
          child: isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Kirim'),
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
