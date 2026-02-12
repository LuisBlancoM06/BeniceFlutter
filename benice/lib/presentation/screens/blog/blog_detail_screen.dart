import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogDetailScreen extends StatelessWidget {
  final String slug;
  const BlogDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final article = _getArticle(slug);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[300]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article['category'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.purple[100],
                        child: Text(
                          (article['author'] as String)[0],
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['author'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            article['date'] as String,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article['readTime'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Content
                  ...(article['content'] as List<Map<String, String>>).map((
                    section,
                  ) {
                    if (section['type'] == 'heading') {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 12),
                        child: Text(
                          section['text']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        section['text']!,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.7,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Share & actions
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Guardar'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Related articles
                  const Text(
                    'Artículos Relacionados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _RelatedArticle(
                          title: '10 consejos para cuidar a tu gato en verano',
                          image:
                              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
                          onTap: () =>
                              context.push('/blog/cuidados-gato-verano'),
                        ),
                        const SizedBox(width: 12),
                        _RelatedArticle(
                          title: 'Guía de vacunación para cachorros',
                          image:
                              'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400',
                          onTap: () =>
                              context.push('/blog/vacunacion-cachorros'),
                        ),
                        const SizedBox(width: 12),
                        _RelatedArticle(
                          title: 'Los mejores juguetes interactivos',
                          image:
                              'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=400',
                          onTap: () => context.push(
                            '/blog/juguetes-interactivos-perros',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getArticle(String slug) {
    final articles = {
      'elegir-pienso-perro': {
        'title': 'Cómo elegir el mejor pienso para tu perro',
        'image':
            'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
        'category': 'Alimentación',
        'author': 'Dra. María García',
        'date': '15 Enero 2024',
        'readTime': '8 min lectura',
        'content': <Map<String, String>>[
          {
            'type': 'paragraph',
            'text':
                'Elegir el pienso adecuado para tu perro es una de las decisiones más importantes que tomarás como dueño responsable. La alimentación influye directamente en su salud, energía y longevidad.',
          },
          {'type': 'heading', 'text': '1. Conoce las necesidades de tu perro'},
          {
            'type': 'paragraph',
            'text':
                'Cada perro es único. Su edad, tamaño, raza, nivel de actividad y posibles alergias determinan qué tipo de alimentación necesita. Un cachorro de raza grande tiene necesidades muy diferentes a las de un perro senior de raza pequeña.',
          },
          {'type': 'heading', 'text': '2. Lee las etiquetas'},
          {
            'type': 'paragraph',
            'text':
                'Los ingredientes se listan por orden de peso. Busca piensos donde la primera fuente de proteína sea carne real (pollo, cordero, salmón) y no subproductos. Evita los que tienen demasiados cereales como primer ingrediente.',
          },
          {'type': 'heading', 'text': '3. Proteínas de calidad'},
          {
            'type': 'paragraph',
            'text':
                'Los perros son omnívoros con tendencia carnívora. Necesitan proteínas de alta calidad para mantener su musculatura, sistema inmune y pelaje. Busca un mínimo del 25% de proteína bruta.',
          },
          {'type': 'heading', 'text': '4. Evita aditivos innecesarios'},
          {
            'type': 'paragraph',
            'text':
                'Colorantes artificiales, saborizantes químicos y conservantes como BHA/BHT no aportan valor nutricional. Opta por piensos con conservantes naturales como tocoferoles (vitamina E).',
          },
          {'type': 'heading', 'text': '5. Consulta con tu veterinario'},
          {
            'type': 'paragraph',
            'text':
                'Tu veterinario conoce el historial de salud de tu perro y puede recomendarte la mejor opción. No dudes en consultarle, especialmente si tu perro tiene necesidades especiales.',
          },
        ],
      },
    };

    return articles[slug] ??
        {
          'title': 'Artículo del Blog',
          'image':
              'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
          'category': 'General',
          'author': 'Equipo BeniceAstro',
          'date': '2024',
          'readTime': '5 min lectura',
          'content': <Map<String, String>>[
            {
              'type': 'paragraph',
              'text':
                  'Contenido del artículo próximamente disponible. ¡Vuelve pronto para descubrir más consejos sobre el cuidado de tus mascotas!',
            },
          ],
        };
  }
}

class _RelatedArticle extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _RelatedArticle({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                height: 120,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 120, width: 160, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
