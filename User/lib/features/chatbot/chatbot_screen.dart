import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatbot_service.dart';
import '../product/product_detail_screen.dart';
import '../../models/product.dart';

// ==================================================
// Data Model untuk pesan chat
// ==================================================
class ChatMessage {
  final String text;
  final bool isUser;
  final List<Map<String, dynamic>> products;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.products = const [],
  });
}

// ==================================================
// Quick reply options yang muncul di atas kotak ketik
// ==================================================
const _quickReplies = [
  '🌾 Cara tanam padi',
  '🐛 Hama wereng',
  '💊 Penyakit kresek',
  '💧 Irigasi sawah',
  '🌿 Pupuk padi',
  '🛒 Promo hari ini',
  '📦 Status pesanan',
];

// ==================================================
// Main screen
// ==================================================
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();

  // Menyimpan riwayat hanya teks user (untuk session memory)
  final List<String> _userHistory = [];

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Halo! Saya AgroBot 🌱. Ada yang bisa saya bantu terkait produk, pesanan, atau pertanian hari ini?',
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  // Animasi untuk typing indicator
  late AnimationController _typingAnimController;
  late Animation<double> _typingAnim;

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _typingAnim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(_typingAnimController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Jeda buatan agar terasa lebih natural
    await Future.delayed(const Duration(milliseconds: 1000));

    // Kirim beserta history untuk session memory
    final response = await _chatbotService.sendMessage(trimmed, _userHistory);

    // Simpan ke history (hanya pesan user, maks 6 pesan terakhir)
    _userHistory.add(trimmed);
    if (_userHistory.length > 6) _userHistory.removeAt(0);

    if (mounted) {
      final products =
          (response['products'] as List<dynamic>?)
              ?.map((p) => p as Map<String, dynamic>)
              .toList() ??
          [];

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: response['reply'] as String? ?? '',
            isUser: false,
            products: products,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  // ==================================================
  // BUILD
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AgroBot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  _isTyping ? 'Sedang mengetik...' : 'Asisten Pertanian',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isTyping ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 1,
      ),
      body: Column(
        children: [
          // ---- Daftar Pesan ----
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingBubble();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // ---- Quick Reply Buttons ----
          _buildQuickReplies(),

          // ---- Input Bar ----
          _buildInputBar(),
        ],
      ),
    );
  }

  // ==================================================
  // WIDGETS
  // ==================================================

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isUser ? Colors.green : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),

          // ---- Kartu Produk (Rich Cards) ----
          if (msg.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: msg.products.length,
                  itemBuilder: (context, i) =>
                      _buildProductCard(msg.products[i]),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _timeLabel(),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> p) {
    final price = (p['price'] as num?)?.toDouble() ?? 0;
    final discountPrice = (p['discountPrice'] as num?)?.toDouble();
    final displayPrice = (discountPrice != null && discountPrice < price)
        ? discountPrice
        : price;
    final hasDiscount = discountPrice != null && discountPrice < price;
    final imageUrl = p['imageUrl'] as String? ?? '';
    final name = p['name'] as String? ?? '';
    final unit = p['unit'] as String? ?? '';
    final stock = p['stock'] as int? ?? 0;
    final isAvailable = (p['isAvailable'] as bool?) ?? true;

    return GestureDetector(
      onTap: () {
        // Buat Product minimal untuk navigasi ke ProductDetailScreen
        final product = Product(
          id: p['id'] as int,
          name: name,
          description: '',
          price: price,
          discountPrice: discountPrice,
          imageUrl: imageUrl,
          images: imageUrl.isNotEmpty ? [imageUrl] : [],
          categoryId: 0,
          categoryName:
              (p['category'] as Map<String, dynamic>?)?['name'] as String? ??
              '',
          stock: stock,
          rating: 0,
          reviewCount: 0,
          isAvailable: isAvailable,
          unit: unit,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (hasDiscount)
                      Text(
                        'Rp ${_formatNum(price.toInt())}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      'Rp ${_formatNum(displayPrice.toInt())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Lihat Produk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 90,
      color: Colors.green.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.grass, color: Colors.green, size: 36),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _typingAnim,
              builder: (_, __) {
                final delay = i * 0.15;
                final opacity = (((_typingAnim.value + delay) % 1.0)).clamp(
                  0.3,
                  1.0,
                );
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: opacity),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _quickReplies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            return ActionChip(
              label: Text(
                _quickReplies[i],
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              side: const BorderSide(color: Colors.green, width: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              onPressed: () => _sendMessage(_quickReplies[i]),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Tanya seputar pertanian...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // HELPERS
  // ==================================================
  String _timeLabel() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatNum(int n) {
    return NumberFormat('#,###', 'id_ID').format(n);
  }
}
