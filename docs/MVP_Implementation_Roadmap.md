# AbdoulExpress MVP Implementation Roadmap
## Pixel-Perfect UI/UX Development Plan

### Overview
This roadmap provides a step-by-step implementation plan to achieve MVP readiness with a focus on creating a simple, intuitive, elegant, and modern minimalist e-commerce app that feels natural and is understandable by all users, particularly in the African market.

---

## Phase 1: Critical Foundation (Week 1)
### Week 1.1: Core Missing Screens

#### 1. Order Confirmation Page
**File**: `lib/features/orders/presentation/pages/order_confirmation_page.dart`

```dart
class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final double total;
  final String estimatedDelivery;

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Success Animation
              Lottie.asset('assets/animations/success.json'),

              // Order Details
              Text('Commande Confirmée!'),
              Text('N°: $orderId'),

              // Estimated Delivery
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Livraison prévue: $estimatedDelivery'),
                  ],
                ),
              ),

              // Action Buttons
              Spacer(),
              PrimaryButton(
                label: 'Suivre ma commande',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(orderId: orderId),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                label: 'Continuer mes achats',
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 2. Product Image Gallery
**File**: `lib/core/widgets/product_image_gallery.dart`

```dart
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String heroTag;
  final bool allowZoom;

  const ProductImageGallery({
    required this.images,
    required this.heroTag,
    this.allowZoom = true,
  });

  @override
  _ProductImageGalleryState createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Image Viewer
        Container(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: '${widget.heroTag}_$index',
                child: GestureDetector(
                  onTap: widget.allowZoom
                    ? () => _showImageViewer(index)
                    : null,
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => SkeletonLoader(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
        ),

        // Thumbnail Strip
        SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

#### 3. Search Results Page
**File**: `lib/features/search/presentation/pages/search_results_page.dart`

```dart
class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({required this.query});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  String _sortBy = 'relevance';
  RangeValues _priceRange = RangeValues(0, 50000);
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats pour "${widget.query}"'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filters
          if (_selectedCategories.isNotEmpty || _priceRange.end < 50000)
            Container(
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Catégories (${_selectedCategories.length})'),
                    _buildFilterChip('Prix: ${_priceRange.start} - ${_priceRange.end}'),
                    TextButton(
                      child: Text('Effacer'),
                      onPressed: _clearFilters,
                    ),
                  ],
                ),
              ),
            ),

          // Results Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('248 résultats'),
                Spacer(),
                Text('Trier: $_sortBy'),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 248,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: dummyProducts[index],
                  showAddToCart: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Week 1.2: Enhanced UI Components

#### 1. Skeleton Loading States
**File**: `lib/core/widgets/skeleton_loader.dart`

```dart
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: _shimmerEffect(),
    );
  }

  Widget _shimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(width: double.infinity, height: double.infinity),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 150, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: double.infinity),
                SizedBox(height: 4),
                SkeletonLoader(height: 14, width: 100),
                SizedBox(height: 8),
                SkeletonLoader(height: 20, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. Empty States
**File**: `lib/core/widgets/empty_state.dart`

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null) ...[
              SizedBox(height: 24),
              PrimaryButton(
                label: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Phase 2: Enhanced User Experience (Week 2-3)

### Week 2.1: Product Discovery

#### 1. Category Landing Page
**File**: `lib/features/categories/presentation/pages/category_landing_page.dart`

```dart
class CategoryLandingPage extends StatelessWidget {
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: category.imageUrl,
                fit: BoxFit.cover,
              ),
              title: Text(category.name),
            ),
          ),

          // Subcategories
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sous-catégories', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: category.subcategories.map((sub) {
                      return Chip(
                        label: Text(sub.name),
                        onPressed: () => _navigateToSubcategory(sub),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Featured Products
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Produits populaires', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(product: category.products[index]),
                childCount: category.products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. Product Variants Selector
**File**: `lib/core/widgets/product_variant_selector.dart`

```dart
class ProductVariantSelector extends StatefulWidget {
  final Product product;
  final Function(Variant) onVariantChanged;

  @override
  _ProductVariantSelectorState createState() => _ProductVariantSelectorState();
}

class _ProductVariantSelectorState extends State<ProductVariantSelector> {
  String? _selectedSize;
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size Selector
        if (widget.product.sizes.isNotEmpty) ...[
          Text('Taille', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.product.sizes.map((size) {
              final isSelected = _selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedSize = size);
                  widget.onVariantChanged(_getSelectedVariant());
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),
        ],

        // Color Selector
        if (widget.product.colors.isNotEmpty) ...[
          Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.product.colors.map((color) {
              final isSelected = _selectedColor == color.name;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color.name);
                  widget.onVariantChanged(_getSelectedVariant());
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.hex.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: isSelected
                      ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                      : Border.all(color: Colors.grey[300]!),
                  ),
                  child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
```

### Week 2.2: Trust & Credibility

#### 1. Product Reviews Component
**File**: `lib/features/products/presentation/widgets/product_reviews.dart`

```dart
class ProductReviews extends StatelessWidget {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor()
                          ? Icons.star
                          : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  Text('$totalReviews avis'),
                ],
              ),
              SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final stars = 5 - index;
                    final percentage = _getRatingPercentage(stars);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('$stars'),
                          SizedBox(width: 8),
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Reviews List
        SizedBox(height: 16),
        Text('Avis des clients', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length > 3 ? 3 : reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewCard(review: review);
          },
          separatorBuilder: (_, __) => Divider(),
        ),

        // View All Button
        if (reviews.length > 3)
          Center(
            child: TextButton(
              child: Text('Voir tous les avis ($totalReviews)'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllReviewsPage(reviews: reviews),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

#### 2. Trust Badges
**File**: `lib/core/widgets/trust_badges.dart`

```dart
class TrustBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadge(
            icon: Icons.verified_user,
            label: 'Paiement sécurisé',
            subtitle: '100% sécurisé',
          ),
          _buildBadge(
            icon: Icons.local_shipping,
            label: 'Livraison rapide',
            subtitle: '24-48h',
          ),
          _buildBadge(
            icon: Icons.refresh,
            label: 'Retour facile',
            subtitle: '30 jours',
          ),
          _buildBadge(
            icon: Icons.support_agent,
            label: 'Support 24/7',
            subtitle: 'Toujours là',
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

---

## Phase 3: Conversion Optimization (Week 4-5)

### Week 4.1: Cart & Checkout Enhancements

#### 1. Cart Preview Modal
**File**: `lib/features/cart/presentation/widgets/cart_preview.dart`

```dart
class CartPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Mon panier',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Spacer(),
                TextButton(
                  child: Text('Voir tout'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartPreviewItem(item: item);
              },
            ),
          ),

          // Checkout Button
          Padding(
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              icon: Icons.lock,
              label: 'Commander (${cart.totalItems} articles) - ${cart.total} F CFA',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/checkout');
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. Delivery Time Slot Selector
**File**: `lib/features/checkout/presentation/widgets/delivery_time_slot.dart`

```dart
class DeliveryTimeSlotSelector extends StatefulWidget {
  @override
  _DeliveryTimeSlotSelectorState createState() => _DeliveryTimeSlotSelectorState();
}

class _DeliveryTimeSlotSelectorState extends State<DeliveryTimeSlotSelector> {
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quand souhaitez-vous recevoir votre commande ?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),

        // Date Selection
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _selectedDate?.day == date.day;
              final isToday = index == 0;
              final isTomorrow = index == 1;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    border: Border.all(
                      color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday
                          ? "Aujourd'hui"
                          : isTomorrow
                            ? 'Demain'
                            : DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16),

        // Time Slots
        if (_selectedDate != null) ...[
          Text('Créneaux horaires', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _generateTimeSlots().map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              final isAvailable = slot.isAvailable;

              return FilterChip(
                label: Text(slot.displayTime),
                selected: isSelected,
                backgroundColor: isAvailable ? null : Colors.grey[100],
                onSelected: isAvailable
                  ? (selected) {
                      setState(() => _selectedTimeSlot = slot);
                    }
                  : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
```

### Week 4.2: Post-Purchase Experience

#### 1. Order Tracking Page
**File**: `lib/features/orders/presentation/pages/order_tracking_page.dart`

```dart
class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  OrderStatus _currentStatus = OrderStatus.confirmed;
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suivi de commande')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commande #${widget.orderId}'),
                    SizedBox(height: 8),
                    Text(
                      'Statut: ${_getStatusText(_currentStatus)}',
                      style: TextStyle(
                        color: _getStatusColor(_currentStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Timeline
            Text('Historique de la livraison', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),

            OrderTimeline(
              status: _currentStatus,
              events: [
                TimelineEvent(
                  time: '10:30',
                  title: 'Commande confirmée',
                  description: 'Votre commande a été confirmée',
                  completed: true,
                ),
                TimelineEvent(
                  time: '11:00',
                  title: 'Préparation en cours',
                  description: 'Votre commande est en cours de préparation',
                  completed: _currentStatus.index >= OrderStatus.preparing.index,
                ),
                TimelineEvent(
                  time: '11:45',
                  title: 'En route',
                  description: 'Votre livreur est en route',
                  completed: _currentStatus.index >= OrderStatus.shipped.index,
                ),
                TimelineEvent(
                  time: '12:30',
                  title: 'Livré',
                  description: 'Votre commande a été livrée',
                  completed: _currentStatus.index >= OrderStatus.delivered.index,
                ),
              ],
            ),

            // Map Toggle
            if (_currentStatus == OrderStatus.shipped) ...[
              SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Voir sur la carte'),
                trailing: Switch(
                  value: _showMap,
                  onChanged: (value) => setState(() => _showMap = value),
                ),
              ),

              if (_showMap)
                Container(
                  height: 300,
                  margin: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Text('Carte de suivi en temps réel'),
                  ),
                ),
            ],

            // Delivery Info
            if (_currentStatus == OrderStatus.shipped) ...[
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/driver.jpg'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Votre livreur', style: Theme.of(context).textTheme.titleMedium),
                            Text('Mohamed - 4.8 ⭐'),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () => _callDriver(),
                          ),
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () => _messageDriver(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Phase 4: Polish & Optimization (Week 6)

### 1. Performance Optimizations
- Implement proper image caching
- Add lazy loading for product lists
- Optimize state management
- Reduce app startup time

### 2. Accessibility Implementation
- Add semantic labels for screen readers
- Implement high contrast mode
- Add text scaling support
- Ensure all interactive elements have proper focus states

### 3. Error Handling
- Network error states with retry
- Graceful degradation for poor connections
- Offline mode for browsing
- Clear error messages in simple French

### 4. Final Polish
- Smooth animations and transitions
- Consistent spacing and typography
- Proper loading indicators
- Success feedback for actions

## Key Design Principles for MVP

1. **Simplicity First**
   - Clean, uncluttered interface
   - Clear visual hierarchy
   - Obvious navigation paths

2. **Trust Building**
   - Transparent pricing
   - Clear return policies
   - Seller information
   - Customer reviews visible

3. **Mobile-First**
   - Large tap targets (minimum 44px)
   - Thumb-friendly navigation
   - Optimized for one-handed use

4. **Cultural Adaptation**
   - Simple French language
   - Local payment methods prominent
   - Prices always in F CFA
   - Images reflecting local context

5. **Performance**
   - Fast loading times
   - Smooth scrolling
   - Responsive interactions
   - Works on 3G networks

## Success Metrics for MVP

1. **Technical Metrics**
   - App start time < 3 seconds
   - Page load time < 2 seconds
   - 0 critical crashes
   - Works offline for browsing

2. **User Experience**
   - Checkout process < 3 steps
   - Add to cart in < 2 taps
   - Search results in < 1 second
   - Clear product information

3. **Conversion**
   - Cart abandonment rate < 70%
   - Checkout completion rate > 60%
   - User registration rate > 30%
   - Return user rate > 20%

This roadmap provides a clear path to MVP readiness while maintaining the principles of simplicity, elegance, and accessibility that are crucial for success in the African e-commerce market.