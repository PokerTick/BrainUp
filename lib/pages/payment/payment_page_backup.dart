import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brainup/services/api_service.dart';
import 'package:brainup/pages/course/CoursePurchase.dart';
import 'package:brainup/pages/my_courses_page.dart';

// ─── Payment State Enum ───────────────────────────────────────────────────────

enum _PayState { ready, paymentOpened, polling, success, failed, timeout }

// ─── Page ─────────────────────────────────────────────────────────────────────

class PaymentPage extends StatefulWidget {
  final int orderId;
  final String snapRedirectUrl;
  final List<Map<String, dynamic>> orderItems; // items from POST /orders response
  final double total;
  final double discountAmt;
  final double serviceFee;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.snapRedirectUrl,
    required this.orderItems,
    required this.total,
    this.discountAmt = 0,
    this.serviceFee = 0,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // ─── State ───────────────────────────────────────────────────────────────
  _PayState _state = _PayState.ready;
  int _pollCount = 0;
  static const int _maxPolls = 12; // 12 × 3s = 36 seconds
  bool _enrolling = false;

  // ─── Animations ──────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;
  late final AnimationController _dotCtrl;
  late final Animation<int> _dotAnim;

  // ─── Palette ─────────────────────────────────────────────────────────────
  static const Color _bg        = Color(0xFF12102A);
  static const Color _card      = Color(0xFF1E1B3A);
  static const Color _purple    = Color(0xFF6B58E6);
  static const Color _purpleL   = Color(0xFF8B72FF);
  static const Color _green     = Color(0xFF4ADE80);
  static const Color _red       = Color(0xFFFF5E5E);
  static const Color _textW     = Colors.white;
  static const Color _textMuted = Color(0xFF9090B0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Pulse animation for polling indicator
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Success checkmark scale animation
    _successCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);

    // Dot count animation for "Menunggu..." text
    _dotCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _dotAnim = IntTween(begin: 1, end: 3).animate(_dotCtrl);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  // ─── Lifecycle Observer ───────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-start polling when user returns from browser
    if (state == AppLifecycleState.resumed &&
        _state == _PayState.paymentOpened) {
      _startPolling();
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _openPaymentBrowser() async {
    final uri = Uri.parse(widget.snapRedirectUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched && mounted) {
        setState(() => _state = _PayState.paymentOpened);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal membuka halaman pembayaran. Coba lagi.');
    }
  }

  Future<void> _startPolling() async {
    if (_state == _PayState.polling) return;
    if (!mounted) return;
    setState(() {
      _state  = _PayState.polling;
      _pollCount = 0;
    });
    await _runPollLoop();
  }

  Future<void> _runPollLoop() async {
    while (_pollCount < _maxPolls && mounted && _state == _PayState.polling) {
      // Wait 3 seconds between each poll
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || _state != _PayState.polling) return;

      final order = await ApiService.getOrderPaymentStatus(widget.orderId);
      if (!mounted) return;

      _pollCount++;
      final rawStatus = (order?['status'] as String?)?.toUpperCase() ?? '';

      if (_isPaid(rawStatus)) {
        await _handleSuccess(order!);
        return;
      }
      if (_isFailed(rawStatus)) {
        setState(() => _state = _PayState.failed);
        return;
      }

      // Still PENDING — refresh to update dot animation / progress
      if (mounted) setState(() {});
    }

    // Timeout
    if (mounted && _state == _PayState.polling) {
      setState(() => _state = _PayState.timeout);
    }
  }

  bool _isPaid(String s) =>
      s == 'PAID' || s == 'SETTLEMENT' || s == 'CAPTURE' ||
      s == 'COMPLETED' || s == 'SUCCESS';

  bool _isFailed(String s) =>
      s == 'CANCELLED' || s == 'CANCEL' || s == 'EXPIRED' ||
      s == 'EXPIRE' || s == 'DENY' || s == 'DENIED' || s == 'FAILED';

  Future<void> _handleSuccess(Map<String, dynamic> order) async {
    if (!mounted) return;
    setState(() { _state = _PayState.success; _enrolling = true; });
    _successCtrl.forward();

    // Enroll in every course in the order
    final rawItems = order['items'] as List? ?? widget.orderItems;
    for (final item in rawItems) {
      final courseId = item['courseId'] as int?;
      if (courseId != null) {
        await ApiService.enrollInCourse(courseId);
      }
    }

    if (!mounted) return;
    setState(() => _enrolling = false);

    // Navigate after a moment so user can see the success state
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final items = rawItems.cast<Map<String, dynamic>>();
    if (items.length == 1) {
      final courseId = items.first['courseId'] as int;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Coursepurchase(courseId: courseId)),
        (r) => r.isFirst,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyCoursesPage()),
        (r) => r.isFirst,
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state != _PayState.polling, // prevent back during polling
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildOrderSummary(),
                      const SizedBox(height: 20),
                      _buildStateWidget(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_state != _PayState.polling)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: _textW, size: 20),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textW,
              ),
            ),
          ),
          // Order ID badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _purple.withValues(alpha: 0.4)),
            ),
            child: Text(
              '#${widget.orderId}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _purpleL,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Order Summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: _purpleL, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textW,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: _purple.withValues(alpha: 0.12)),
          // Course items
          ...widget.orderItems.map((item) => _buildCourseItem(item)),
          // Pricing breakdown
          Divider(height: 1, color: _purple.withValues(alpha: 0.12)),
          _buildPricingBreakdown(),
        ],
      ),
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> item) {
    final course = item['course'] as Map<String, dynamic>? ?? {};
    final title  = course['title'] as String? ?? 'Unknown Course';
    final price  = (item['price'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Course thumbnail placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: _purpleL, size: 22),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textW,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Price
          Text(
            _formatRp(price),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _purpleL,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    final subtotal = widget.orderItems.fold<double>(
      0, (sum, item) => sum + ((item['price'] as num?)?.toDouble() ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          if (widget.discountAmt > 0) ...[
            _buildPriceRow('Subtotal', _formatRp(subtotal)),
            const SizedBox(height: 6),
            _buildPriceRow(
              'Diskon Kupon',
              '- ${_formatRp(widget.discountAmt)}',
              color: _green,
            ),
            const SizedBox(height: 6),
          ],
          if (widget.serviceFee > 0) ...[
            _buildPriceRow('Service Fee', _formatRp(widget.serviceFee)),
            const SizedBox(height: 6),
          ],
          Divider(color: _purple.withValues(alpha: 0.2)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textW,
                ),
              ),
              Text(
                _formatRp(widget.total),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textW,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color ?? _textW,
          ),
        ),
      ],
    );
  }

  // ─── State-specific widget ────────────────────────────────────────────────

  Widget _buildStateWidget() {
    switch (_state) {
      case _PayState.ready:
        return _buildReadyCard();
      case _PayState.paymentOpened:
        return _buildPaymentOpenedCard();
      case _PayState.polling:
        return _buildPollingCard();
      case _PayState.success:
        return _buildSuccessCard();
      case _PayState.failed:
        return _buildFailedCard();
      case _PayState.timeout:
        return _buildTimeoutCard();
    }
  }

  Widget _buildReadyCard() {
    return _stateCard(
      icon: const Icon(Icons.lock_open_rounded, color: Color(0xFFFBBF24), size: 36),
      title: 'Siap Bayar',
      body: 'Klik tombol di bawah untuk melanjutkan ke halaman pembayaran Midtrans.',
      bg: const Color(0xFFFBBF24).withValues(alpha: 0.08),
      border: const Color(0xFFFBBF24).withValues(alpha: 0.25),
    );
  }

  Widget _buildPaymentOpenedCard() {
    return _stateCard(
      icon: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnim.value,
          child: const Icon(Icons.open_in_browser_rounded, color: _purpleL, size: 36),
        ),
      ),
      title: 'Halaman Pembayaran Dibuka',
      body: 'Selesaikan pembayaran di browser, lalu kembali ke aplikasi ini.\n'
            'Status akan dicek otomatis saat Anda kembali.',
      bg: _purple.withValues(alpha: 0.08),
      border: _purple.withValues(alpha: 0.25),
    );
  }

  Widget _buildPollingCard() {
    final progress = _pollCount / _maxPolls;
    return _stateCard(
      icon: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnim.value,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _purple.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.sync_rounded, color: _purpleL, size: 30),
          ),
        ),
      ),
      title: 'Mengecek Status Pembayaran',
      body: '',
      bg: _purple.withValues(alpha: 0.06),
      border: _purple.withValues(alpha: 0.2),
      extra: Column(
        children: [
          AnimatedBuilder(
            animation: _dotAnim,
            builder: (_, __) => Text(
              'Menunggu konfirmasi${'.' * _dotAnim.value}',
              style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: _purple.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(_purpleL),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Percobaan $_pollCount dari $_maxPolls',
            style: GoogleFonts.poppins(fontSize: 11, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return _stateCard(
      icon: ScaleTransition(
        scale: _successAnim,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _green.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.check_circle_rounded, color: _green, size: 40),
        ),
      ),
      title: 'Pembayaran Berhasil! 🎉',
      body: _enrolling
          ? 'Mendaftarkan akses course Anda...'
          : 'Akses course Anda sudah aktif. Mengarahkan...',
      bg: _green.withValues(alpha: 0.06),
      border: _green.withValues(alpha: 0.25),
    );
  }

  Widget _buildFailedCard() {
    return _stateCard(
      icon: const Icon(Icons.cancel_rounded, color: _red, size: 40),
      title: 'Pembayaran Dibatalkan',
      body: 'Sepertinya pembayaran tidak berhasil atau dibatalkan. Anda bisa mencoba lagi.',
      bg: _red.withValues(alpha: 0.06),
      border: _red.withValues(alpha: 0.25),
    );
  }

  Widget _buildTimeoutCard() {
    return _stateCard(
      icon: const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFFBBF24), size: 40),
      title: 'Waktu Pengecekan Habis',
      body: 'Kami belum menerima konfirmasi pembayaran. Jika sudah bayar, '
            'cek kembali status di halaman Riwayat Pembelian.',
      bg: const Color(0xFFFBBF24).withValues(alpha: 0.06),
      border: const Color(0xFFFBBF24).withValues(alpha: 0.25),
    );
  }

  Widget _stateCard({
    required Widget icon,
    required String title,
    required String body,
    required Color bg,
    required Color border,
    Widget? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textW,
            ),
            textAlign: TextAlign.center,
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: GoogleFonts.poppins(fontSize: 13, color: _textMuted, height: 1.55),
              textAlign: TextAlign.center,
            ),
          ],
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra,
          ],
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _purple.withValues(alpha: 0.12))),
      ),
      child: _buildBottomAction(),
    );
  }

  Widget _buildBottomAction() {
    switch (_state) {
      case _PayState.ready:
        return _mainButton(
          label: 'Bayar Sekarang',
          icon: Icons.payment_rounded,
          onTap: _openPaymentBrowser,
        );

      case _PayState.paymentOpened:
        return Column(
          children: [
            _mainButton(
              label: 'Saya Sudah Bayar',
              icon: Icons.check_circle_outline_rounded,
              onTap: _startPolling,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _openPaymentBrowser,
              child: Text(
                'Buka Kembali Halaman Bayar',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );

      case _PayState.polling:
        return _mainButton(
          label: 'Mengecek...',
          icon: Icons.sync_rounded,
          onTap: null, // disabled
        );

      case _PayState.success:
        return _mainButton(
          label: 'Mengarahkan ke Course...',
          icon: Icons.school_rounded,
          onTap: null,
          color: _green,
        );

      case _PayState.failed:
        return Column(
          children: [
            _mainButton(
              label: 'Coba Bayar Lagi',
              icon: Icons.refresh_rounded,
              onTap: () => setState(() {
                _state = _PayState.ready;
                _pollCount = 0;
              }),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kembali ke Detail Course',
                style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
              ),
            ),
          ],
        );

      case _PayState.timeout:
        return Column(
          children: [
            _mainButton(
              label: 'Cek Status Lagi',
              icon: Icons.refresh_rounded,
              onTap: _startPolling,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kembali',
                style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
              ),
            ),
          ],
        );
    }
  }

  Widget _mainButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    Color color = _purple,
  }) {
    final enabled = onTap != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : color.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          elevation: enabled ? 6 : 0,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatRp(double amount) {
    final n = amount.toInt();
    // Manual formatting: 249000 → "Rp249.000"
    final s = n.toString();
    final buf = StringBuffer('Rp');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
