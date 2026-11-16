
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osito_macabro/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isReady = false;

  // Colores principales de la aplicación.
  static const Color cafe = Color(0xFF49352D);
  static const Color crema = Color(0xFFF8F2E8);
  static const Color coral = Color(0xFFE88C72);
  static const Color verde = Color(0xFF82977B);
  static const Color texto = Color(0xFF594940);

  // Publicaciones del feed.
  
final List<Map<String, dynamic>> _ositos = [
  {
    'titulo': 'El osito más fachero 😎',
    'descripcion': 'Hoy desperté sintiéndome increíble.',
    'categoria': 'ESTILO',
    'imagen':
        'https://images.unsplash.com/photo-1602734846297-9299fc2d4703?fm=jpg&ixlib=rb-4.1.0&q=80&w=1200',
    'likes': 28,
    'liked': false,
  },
  {
    'titulo': 'Amor y amistad ❤️',
    'descripcion': 'Un abrazo de osito vale más que mil palabras.',
    'categoria': 'AMISTAD',
    'imagen':
        'https://cdn.igp.com/f_auto%2Cq_auto%2Ct_pnopt19prodlp/products/p-romantic-teddy-couple-red-and-cream-large-110004-m.jpg',
    'likes': 120,
    'liked': false,
  },
  {
    'titulo': 'El osito y su novia 💕',
    'descripcion': 'Cuando encuentras a tu persona favorita.',
    'categoria': 'ENAMORADOS',
    'imagen':
        'https://s3.amazonaws.com/emuncloud-staticassets/productImages/ctg080/large/19114_2.jpg',
    'likes': 95,
    'liked': false,
  },
  {
    'titulo': 'Una pareja muy elegante 🎀',
    'descripcion': 'Juntos hasta en los días más bonitos.',
    'categoria': 'PAREJITAS',
    'imagen':
        'https://fulmo-img-server.com/yawaraka-collection/a99d5493-e07c-4528-87f9-04a7fa459fac.jpg',
    'likes': 73,
    'liked': false,
  },
  {
    'titulo': 'Regalito de Navidad 🎁',
    'descripcion': 'La magia está en compartir momentos.',
    'categoria': 'REGALOS',
    'imagen':
        'https://cdn01.pinkoi.com/product/iyDDLTPp/0/1080x0.jpg',
    'likes': 64,
    'liked': false,
  },
];


  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _esperarCelebracion();
  }

  // Espera para no interrumpir la animación de éxito del Login.
  Future<void> _esperarCelebracion() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    setState(() {
      _isReady = true;
    });

    _animController.forward();
  }

  // Agrega o quita un corazón.
  void _toggleLike(int index) {
    setState(() {
      final osito = _ositos[index];
      final liked = osito['liked'] as bool;

      osito['liked'] = !liked;
      osito['likes'] = (osito['likes'] as int) + (liked ? -1 : 1);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: crema,
      body: SafeArea(
        child: !_isReady
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🧸', style: TextStyle(fontSize: 55)),
                    SizedBox(height: 16),
                    Text(
                      'Preparando tu espacio...',
                      style: TextStyle(
                        color: cafe,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: coral),
                  ],
                ),
              )
            : Column(
                children: [
                  // Encabezado.
                  Container(
                    color: cafe,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Text('🧸', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Osito Macabro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: () async {
                            await AuthService().logout();
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: CustomScrollView(
                          slivers: [
                            // Tarjeta de bienvenida.
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16, 18, 16, 20,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: verde,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '¡HOLAAAA! 💗',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Bienvenido a tu pequeño rincón '
                                            'de ternura. ¡Ponte cómodo!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            user?.email ?? '¡Hola!',
                                            style: const TextStyle(
                                              color: Color(0xFFFFE5D5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'ʕ •ᴥ• ʔ',
                                      style: TextStyle(
                                        fontSize: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Título del feed.
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'El rincón de los ositos 🧸',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: cafe,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Pequeñas dosis de felicidad para ti.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: texto,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Feed de una sola columna.
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 25,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final osito = _ositos[index];
                                    final liked = osito['liked'] as bool;

                                    return Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cafe.withOpacity(0.10),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Imagen desde internet.
                                          Image.network(
                                            osito['imagen'] as String,
                                            width: double.infinity,
                                            height: 250,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              progress,
                                            ) {
                                              if (progress == null) {
                                                return child;
                                              }

                                              return Container(
                                                height: 250,
                                                color: crema,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: coral,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                height: 250,
                                                width: double.infinity,
                                                color: crema,
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '🧸',
                                                      style: TextStyle(
                                                        fontSize: 65,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'No se pudo cargar la imagen',
                                                      style: TextStyle(
                                                        color: cafe,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(17),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 11,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFE6EEE3,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    osito['categoria']
                                                        as String,
                                                    style: const TextStyle(
                                                      color: Color(0xFF52694E),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 11),
                                                Text(
                                                  osito['titulo'] as String,
                                                  style: const TextStyle(
                                                    color: cafe,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  osito['descripcion']
                                                      as String,
                                                  style: const TextStyle(
                                                    color: texto,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 13),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _toggleLike(index),
                                                      child: AnimatedScale(
                                                        scale: liked ? 1.2 : 1,
                                                        duration:
                                                            const Duration(
                                                          milliseconds: 180,
                                                        ),
                                                        child: Icon(
                                                          liked
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: liked
                                                              ? coral
                                                              : cafe,
                                                          size: 27,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${osito['likes']} me gusta',
                                                      style: const TextStyle(
                                                        color: cafe,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    const Icon(
                                                      Icons
                                                          .auto_awesome_rounded,
                                                      color: coral,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: _ositos.length,
                                ),
                              ),
                            ),

                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 25),
                                child: Center(
                                  child: Text(
                                    'Hecho con mucho amor 🧸',
                                    style: TextStyle(
                                      color: cafe,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
