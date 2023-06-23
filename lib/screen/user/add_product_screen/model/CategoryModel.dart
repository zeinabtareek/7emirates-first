class Category {
  final String id;
  final String community;
  final String name;
  final String arabicName;
  final String vip;
  final String stories;
  final String general;
  final String detail;
  final String arabicDetail;
  final String image;
  final String banner;
  final String showHome;
  final String order;
  final String active;
  final String dated;

  Category({
    required this.id,
    required this.community,
    required this.name,
    required this.arabicName,
    required this.vip,
    required this.stories,
    required this.general,
    required this.detail,
    required this.arabicDetail,
    required this.image,
    required this.banner,
    required this.showHome,
    required this.order,
    required this.active,
    required this.dated,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['c_id'] as String,
      community: json['community'] as String,
      name: json['c_name'] as String,
      arabicName: json['c_name_arab'] as String,
      vip: json['vip'] as String,
      stories: json['stories'] as String,
      general: json['general'] as String,
      detail: json['c_detail'] as String,
      arabicDetail: json['c_detail_arab'] as String,
      image: json['c_image'] as String,
      banner: json['c_banner'] as String,
      showHome: json['c_showhome'] as String,
      order: json['c_order'] as String,
      active: json['c_active'] as String,
      dated: json['c_dated'] as String,
    );
  }
}

class CategoryResponse {
  final bool success;
  final List<Category> categories;

  CategoryResponse({
    required this.success,
    required this.categories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawCategories = json['catslist'] as List<dynamic>;
    final categories = rawCategories.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    return CategoryResponse(
      success: json['success'] as bool,
      categories: categories,
    );
  }
}