import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/reservation_payment_session.dart';
import '../providers/reservation_payment_usecase_providers.dart';
import '../providers/reservation_provider.dart';
import '../../../ticket/presentation/providers/tickets_provider.dart';

class ReservationPaymentWebViewPage extends ConsumerStatefulWidget {
  static const name = 'ReservationPaymentWebViewPage';

  final ReservationPaymentSession session;

  const ReservationPaymentWebViewPage({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<ReservationPaymentWebViewPage> createState() =>
      _ReservationPaymentWebViewPageState();
}

class ReservationPaymentResult {
  final bool success;
  final String? message;

  const ReservationPaymentResult({required this.success, this.message});
}

class _ReservationPaymentWebViewPageState
    extends ConsumerState<ReservationPaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isHandlingSuccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            _handleUrlChange(url);
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _maybeHandleSuccessFromContent();
          },
          onNavigationRequest: (request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.session.paymentUrl));
  }

  void _handleUrlChange(String url) {
    if (_isHandlingSuccess) return;
    if (url.startsWith('about:blank')) return;
    if (_isSuccessUrl(url)) {
      _confirmPayment(successMessage: 'Pago confirmado con éxito.');
    }
  }

  bool _isSuccessUrl(String url) {
    final value = url.toLowerCase();
    // Detecta URLs de éxito comunes en pasarelas de pago
    return value.contains('success') ||
        value.contains('approved') ||
        value.contains('exito') ||
        value.contains('confirmado') ||
        value.contains('completado') ||
        (value.contains('pago') && value.contains('exitoso')) ||
        value.contains('status=success') ||
        value.contains('status=approved') ||
        value.contains('result=success') ||
        value.contains('response=success');
  }

  Future<void> _maybeHandleSuccessFromContent() async {
    if (_isHandlingSuccess) return;
    try {
      final raw = await _controller.runJavaScriptReturningResult(
        'document.body ? document.body.innerText : ""',
      );
      final content = raw?.toString() ?? '';
      final errorMessage = _extractErrorMessage(content);
      if (errorMessage != null) {
        _finishWithResult(
          ReservationPaymentResult(success: false, message: errorMessage),
        );
        return;
      }
      if (_looksLikePaymentSuccessPayload(content)) {
        _confirmPayment(successMessage: 'Pago confirmado con éxito.');
      }
    } catch (_) {
      // Ignorar errores de lectura del DOM.
    }
  }

  bool _looksLikePaymentSuccessPayload(String content) {
    final value = content.toLowerCase();
    // Detecta JSON de confirmación de pago (no es una página HTML)
    if (!value.contains('{') || !value.contains('}')) {
      return false;
    }

    // Verifica si tiene campos de transacción/reserva
    final hasReservaData = value.contains('"reserva"') ||
        value.contains('"id_reserva"') ||
        value.contains('"idreserva"');

    final hasPaymentData = value.contains('"idtransaccion"') ||
        value.contains('"id_transaccion"') ||
        value.contains('"transaccion"') ||
        value.contains('"webpaytoken"') ||
        value.contains('"idpago"') ||
        value.contains('"id_pago"');

    final hasStatusData = value.contains('"estado"') ||
        value.contains('"status"') ||
        value.contains('"idestadopago"');

    // Confirmación exitosa: tiene datos de reserva Y transacción
    return (hasReservaData || hasPaymentData) && hasStatusData;
  }

  String? _extractErrorMessage(String content) {
    final value = content.toLowerCase();
    // Solo trata como error si hay statusCode 400+ o campo error específico
    // NO si solo tiene "message" (que podría ser un mensaje de éxito)
    if (value.contains('"statuscode":"40') ||
        value.contains('"statuscode":40') ||
        value.contains('"statuscode":"5') ||
        value.contains('"statuscode":5')) {
      final messageMatch =
          RegExp(r'"message"\s*:\s*"([^"]+)"', caseSensitive: false)
              .firstMatch(content);
      if (messageMatch != null) {
        return messageMatch.group(1);
      }
      return 'No se pudo completar el pago.';
    }

    // Si tiene campo "error" con un valor, es error
    if (value.contains('"error"') &&
        !value.contains('"error":null') &&
        !value.contains('"error":""')) {
      return 'Error al procesar el pago.';
    }

    return null;
  }

  Future<void> _confirmPayment({required String successMessage}) async {
    if (_isHandlingSuccess) return;
    setState(() => _isHandlingSuccess = true);
    if (!mounted) return;
    try {
      await ref
          .read(confirmarReservaPagadaProvider(
            ReservationPaidConfirmationInput(reservation: widget.session.reservation),
          ).future);
      await ref.read(reservationProvider.notifier).getReservations();
      await ref.read(ticketsProvider.notifier).getTickets();
    } catch (_) {
      if (!mounted) return;
      _finishWithResult(
        const ReservationPaymentResult(
          success: false,
          message: 'No se pudo confirmar el pago. Intenta nuevamente.',
        ),
      );
      return;
    }
    _finishWithResult(
      ReservationPaymentResult(success: true, message: successMessage),
    );
  }

  void _finishWithResult(ReservationPaymentResult result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Pago'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finishWithResult(
            const ReservationPaymentResult(
              success: false,
              message: 'Pago cancelado.',
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || _isHandlingSuccess)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
