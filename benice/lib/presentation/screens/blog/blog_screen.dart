import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog de Mascotas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7E22CE), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Blog de BeniceAstro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consejos, guías y todo lo que necesitas saber para cuidar a tus mascotas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Artículo destacado
          _BlogArticleCard(
            title: 'Cómo elegir el mejor pienso para tu perro',
            excerpt:
                'Guía completa para seleccionar la alimentación perfecta según la edad, tamaño y necesidades de tu perro.',
            imageUrl:
                'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
            category: 'Alimentación',
            categoryColor: Colors.purple,
            author: 'Dra. María García',
            date: '15 Enero 2024',
            readTime: '8 min',
            isFeatured: true,
            onTap: () => context.push('/blog/elegir-pienso-perro'),
          ),
          const SizedBox(height: 16),

          // Grid de artículos
          _BlogArticleCard(
            title: '10 consejos para cuidar a tu gato en verano',
            excerpt:
                'El calor puede afectar a los felinos. Descubre cómo mantener a tu gato fresco y saludable.',
            imageUrl:
                'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
            category: 'Cuidados',
            categoryColor: Colors.orange,
            author: 'Dr. Carlos López',
            date: '10 Enero 2024',
            readTime: '5 min',
            onTap: () => context.push('/blog/cuidados-gato-verano'),
          ),
          const SizedBox(height: 16),

          _BlogArticleCard(
            title: 'Guía de vacunación para cachorros',
            excerpt:
                'Todo sobre el calendario de vacunas que tu cachorro necesita durante su primer año de vida.',
            imageUrl:
                'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800',
            category: 'Salud',
            categoryColor: Colors.green,
            author: 'Dra. Ana Martínez',
            date: '5 Enero 2024',
            readTime: '6 min',
            onTap: () => context.push('/blog/vacunacion-cachorros'),
          ),
          const SizedBox(height: 16),

          _BlogArticleCard(
            title: 'Los mejores juguetes interactivos para perros',
            excerpt:
                'Mantén a tu perro estimulado y feliz con estos juguetes que potencian su inteligencia.',
            imageUrl:
                'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=800',
            category: 'Juguetes',
            categoryColor: Colors.blue,
            author: 'Pedro Sánchez',
            date: '28 Diciembre 2023',
            readTime: '4 min',
            onTap: () => context.push('/blog/juguetes-interactivos-perros'),
          ),
          const SizedBox(height: 16),

          _BlogArticleCard(
            title: 'Alimentación natural para gatos: BARF',
            excerpt:
                'Descubre los beneficios y riesgos de la dieta BARF para felinos.',
            imageUrl:
                'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
            category: 'Alimentación',
            categoryColor: Colors.purple,
            author: 'Dra. María García',
            date: '20 Diciembre 2023',
            readTime: '7 min',
            onTap: () => context.push('/blog/alimentacion-barf-gatos'),
          ),
          const SizedBox(height: 16),

          _BlogArticleCard(
            title: 'Cómo montar tu primer acuario',
            excerpt:
                'Guía paso a paso para principiantes que quieren iniciarse en la acuariofilia.',
            imageUrl:
                'https://images.unsplash.com/photo-1520302630591-fd1c66edc19d?w=800',
            category: 'Acuarios',
            categoryColor: Colors.teal,
            author: 'Luis Fernández',
            date: '15 Diciembre 2023',
            readTime: '10 min',
            onTap: () => context.push('/blog/primer-acuario'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BlogArticleCard extends StatelessWidget {
  final String title;
  final String excerpt;
  final String imageUrl;
  final String category;
  final Color categoryColor;
  final String author;
  final String date;
  final String readTime;
  final bool isFeatured;
  final VoidCallback onTap;

  const _BlogArticleCard({
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.category,
    required this.categoryColor,
    required this.author,
    required this.date,
    required this.readTime,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isFeatured) {
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Destacado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      excerpt,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.purple[100],
                          child: Text(
                            author[0],
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          readTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      excerpt,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          author,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          readTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
}
