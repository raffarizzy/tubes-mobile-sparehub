import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkHandler {
  static late AppLinks _appLinks;
  static StreamSubscription? _sub;
  static bool _isInitialized = false;
  static bool _isHandling = false;

  static Future<void> initDeepLinks(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('Deep link already initialized, skipping...');
      return;
    }

    _appLinks = AppLinks();
    _isInitialized = true;

    // Handle deep link saat app dibuka dari background
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(context, uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle deep link saat app pertama kali dibuka (hanya sekali)
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null && !_isHandling) {
        debugPrint('Initial deep link: $uri');
        _handleDeepLink(context, uri);
      }
    } catch (err) {
      debugPrint('Failed to get initial link: $err');
    }
  }

  static void _handleDeepLink(BuildContext context, Uri uri) {
    if (_isHandling) {
      debugPrint('Already handling a deep link, ignoring...');
      return;
    }

    _isHandling = true;
    debugPrint('Deep link received: $uri');
    debugPrint('Path: ${uri.path}');
    debugPrint('Host: ${uri.host}');

    // sparehub://payment/success
    if (uri.host == 'payment' && uri.path == '/success') {
      // Tunggu sebentar biar tidak bentrok
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          Navigator.of(context).popUntil(
            (route) => route.isFirst || route.settings.name == '/home',
          );

          // Tampilkan snackbar sukses
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran berhasil!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }

        // Reset flag setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          _isHandling = false;
        });
      });
    }
    // sparehub://payment/failed
    else if (uri.host == 'payment' && uri.path == '/failed') {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          Navigator.of(context).popUntil(
            (route) => route.isFirst || route.settings.name == '/home',
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran gagal atau dibatalkan'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }

        // Reset flag setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          _isHandling = false;
        });
      });
    } else {
      // Reset flag jika bukan payment deep link
      _isHandling = false;
    }
  }

  static void dispose() {
    _sub?.cancel();
    _isInitialized = false;
    _isHandling = false;
  }
}
