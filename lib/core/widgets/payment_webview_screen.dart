import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum PaymentResult { success, cancelled, failed }

/// Full-screen in-app WebView for Paystack checkout.
///
/// Pass [checkoutUrl] and the [callbackUrlPrefix] that Paystack will redirect
/// to on completion (e.g. `https://api.opright.org/api/wallet/fund/verify`).
/// The screen pops with [PaymentResult.success] when the callback URL is hit,
/// [PaymentResult.cancelled] when the user closes manually.
class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String callbackUrlPrefix;
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.callbackUrlPrefix,
    this.title = 'Secure Payment',
  });

  static Future<PaymentResult?> show(
    BuildContext context, {
    required String checkoutUrl,
    required String callbackUrlPrefix,
    String title = 'Secure Payment',
  }) {
    return Navigator.of(context).push<PaymentResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaymentWebViewScreen(
          checkoutUrl: checkoutUrl,
          callbackUrlPrefix: callbackUrlPrefix,
          title: title,
        ),
      ),
    );
  }

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  double _progress = 0;
  bool _pageLoaded = false;

  void _onCallbackUrl(String url) {
    // Paystack appends ?trxref=...&reference=... on success
    final uri = Uri.tryParse(url);
    final hasRef = uri?.queryParameters.containsKey('reference') == true ||
        uri?.queryParameters.containsKey('trxref') == true;

    if (hasRef) {
      Navigator.of(context).pop(PaymentResult.success);
    } else {
      Navigator.of(context).pop(PaymentResult.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(PaymentResult.cancelled),
        ),
        title: Column(
          children: [
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 11, color: AppColors.success),
                const SizedBox(width: 3),
                Text(
                  'Secured by Paystack',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: AnimatedOpacity(
            opacity: _pageLoaded ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.separator,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 2,
            ),
          ),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
        initialSettings: InAppWebViewSettings(
          useShouldOverrideUrlLoading: true,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          // Prevent Paystack from opening external browser for 3DS redirects
          supportMultipleWindows: false,
          allowsInlineMediaPlayback: true,
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url?.toString() ?? '';
          if (url.startsWith(widget.callbackUrlPrefix)) {
            _onCallbackUrl(url);
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
        onProgressChanged: (_, progress) {
          setState(() => _progress = progress / 100);
        },
        onLoadStop: (_, __) {
          setState(() => _pageLoaded = true);
        },
        onLoadError: (_, __, ___, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load payment page: $message')),
          );
        },
      ),
    );
  }
}
