class AppSettingsModel {
  final CompanyInfo companyInfo;
  final StorePresentation storePresentation;
  final CommercialPolicies commercialPolicies;
  final List<SampleProduct> sampleProducts;
  final SettingsData settings;

  AppSettingsModel({
    required this.companyInfo,
    required this.storePresentation,
    required this.commercialPolicies,
    required this.sampleProducts,
    required this.settings,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      companyInfo: CompanyInfo.fromJson(json['company_info'] as Map<String, dynamic>),
      storePresentation: StorePresentation.fromJson(json['store_presentation'] as Map<String, dynamic>),
      commercialPolicies: CommercialPolicies.fromJson(json['commercial_policies'] as Map<String, dynamic>),
      sampleProducts: (json['sample_products'] as List)
          .map((e) => SampleProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: SettingsData.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }
}

class CompanyInfo {
  final String legalName;
  final String commercialName;
  final String taxId;
  final String headquartersAddress;
  final PrimaryContact primaryContact;

  CompanyInfo({
    required this.legalName,
    required this.commercialName,
    required this.taxId,
    required this.headquartersAddress,
    required this.primaryContact,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      legalName: json['legal_name'] as String,
      commercialName: json['commercial_name'] as String,
      taxId: json['tax_id'] as String,
      headquartersAddress: json['headquarters_address'] as String,
      primaryContact: PrimaryContact.fromJson(json['primary_contact'] as Map<String, dynamic>),
    );
  }
}

class PrimaryContact {
  final String name;
  final String phone;
  final String email;

  PrimaryContact({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory PrimaryContact.fromJson(Map<String, dynamic> json) {
    return PrimaryContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }
}

class StorePresentation {
  final String storeName;
  final String slogan;
  final String description;
  final List<String> categories;
  final String logo;

  StorePresentation({
    required this.storeName,
    required this.slogan,
    required this.description,
    required this.categories,
    required this.logo,
  });

  factory StorePresentation.fromJson(Map<String, dynamic> json) {
    return StorePresentation(
      storeName: json['store_name'] as String,
      slogan: json['slogan'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List).cast<String>(),
      logo: json['logo'] as String,
    );
  }
}

class CommercialPolicies {
  final ReturnPolicy returnPolicy;
  final DeliveryPolicy deliveryPolicy;

  CommercialPolicies({
    required this.returnPolicy,
    required this.deliveryPolicy,
  });

  factory CommercialPolicies.fromJson(Map<String, dynamic> json) {
    return CommercialPolicies(
      returnPolicy: ReturnPolicy.fromJson(json['return_policy'] as Map<String, dynamic>),
      deliveryPolicy: DeliveryPolicy.fromJson(json['delivery_policy'] as Map<String, dynamic>),
    );
  }
}

class ReturnPolicy {
  final int returnPeriodDays;
  final List<String> conditions;
  final String excludedProducts;

  ReturnPolicy({
    required this.returnPeriodDays,
    required this.conditions,
    required this.excludedProducts,
  });

  factory ReturnPolicy.fromJson(Map<String, dynamic> json) {
    return ReturnPolicy(
      returnPeriodDays: json['return_period_days'] as int,
      conditions: (json['conditions'] as List).cast<String>(),
      excludedProducts: json['excluded_products'] as String,
    );
  }
}

class DeliveryPolicy {
  final String coverageZones;
  final int preparationTimeHours;
  final ShippingFees shippingFees;

  DeliveryPolicy({
    required this.coverageZones,
    required this.preparationTimeHours,
    required this.shippingFees,
  });

  factory DeliveryPolicy.fromJson(Map<String, dynamic> json) {
    return DeliveryPolicy(
      coverageZones: json['coverage_zones'] as String,
      preparationTimeHours: json['preparation_time_hours'] as int,
      shippingFees: ShippingFees.fromJson(json['shipping_fees'] as Map<String, dynamic>),
    );
  }
}

class ShippingFees {
  final String niamey;
  final String interior;

  ShippingFees({
    required this.niamey,
    required this.interior,
  });

  factory ShippingFees.fromJson(Map<String, dynamic> json) {
    return ShippingFees(
      niamey: json['niamey'] as String,
      interior: json['interior'] as String,
    );
  }
}

class SampleProduct {
  final int id;
  final String name;
  final String shortDescription;
  final List<String> category;
  final int price;
  final String currency;
  final int initialStock;
  final String images;

  SampleProduct({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.category,
    required this.price,
    required this.currency,
    required this.initialStock,
    required this.images,
  });

  factory SampleProduct.fromJson(Map<String, dynamic> json) {
    return SampleProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String,
      category: (json['category'] as List).cast<String>(),
      price: json['price'] as int,
      currency: json['currency'] as String,
      initialStock: json['initial_stock'] as int,
      images: json['images'] as String,
    );
  }
}

class SettingsData {
  final AboutData about;
  final PrivacyPolicy privacyPolicy;
  final TermsOfUse termsOfUse;

  SettingsData({
    required this.about,
    required this.privacyPolicy,
    required this.termsOfUse,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      about: AboutData.fromJson(json['about'] as Map<String, dynamic>),
      privacyPolicy: PrivacyPolicy.fromJson(json['privacy_policy'] as Map<String, dynamic>),
      termsOfUse: TermsOfUse.fromJson(json['terms_of_use'] as Map<String, dynamic>),
    );
  }
}

class AboutData {
  final String title;
  final String content;
  final ContactInfo contact;

  AboutData({
    required this.title,
    required this.content,
    required this.contact,
  });

  factory AboutData.fromJson(Map<String, dynamic> json) {
    return AboutData(
      title: json['title'] as String,
      content: json['content'] as String,
      contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>),
    );
  }
}

class ContactInfo {
  final String email;
  final String phone;
  final String address;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.address,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }
}

class PrivacyPolicy {
  final String title;
  final String lastUpdated;
  final List<PolicySection> sections;

  PrivacyPolicy({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      title: json['title'] as String,
      lastUpdated: json['last_updated'] as String,
      sections: (json['sections'] as List)
          .map((e) => PolicySection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TermsOfUse {
  final String title;
  final String lastUpdated;
  final List<PolicySection> sections;

  TermsOfUse({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory TermsOfUse.fromJson(Map<String, dynamic> json) {
    return TermsOfUse(
      title: json['title'] as String,
      lastUpdated: json['last_updated'] as String,
      sections: (json['sections'] as List)
          .map((e) => PolicySection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PolicySection {
  final String heading;
  final String content;

  PolicySection({
    required this.heading,
    required this.content,
  });

  factory PolicySection.fromJson(Map<String, dynamic> json) {
    return PolicySection(
      heading: json['heading'] as String,
      content: json['content'] as String,
    );
  }
}
