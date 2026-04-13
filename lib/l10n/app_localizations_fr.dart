// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'AbdoulExpress';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get navHome => 'Achat';

  @override
  String get navCart => 'Panier';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navCategories => 'Catégories';

  @override
  String get categoriesAll => 'Tous';

  @override
  String get search => 'Rechercher';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get searchNoResults => 'Aucun produit trouvé';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get price => 'Prix';

  @override
  String get quantity => 'Quantité';

  @override
  String get inStock => 'En stock';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptyMessage => 'Ajoutez des produits pour commencer!';

  @override
  String get cartSubtotal => 'Sous-total';

  @override
  String get cartShipping => 'Livraison';

  @override
  String get cartTotal => 'Total';

  @override
  String get checkout => 'Passer la commande';

  @override
  String get continueShoping => 'Continuer mes achats';

  @override
  String get currency => 'F CFA';

  @override
  String currencyFormat(String amount) {
    return '$amount F CFA';
  }

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginEmail => 'Email ou téléphone';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié?';

  @override
  String get loginSignupPrompt => 'Pas encore de compte?';

  @override
  String get loginSignupLink => 'S\'inscrire';

  @override
  String get signupTitle => 'Inscription';

  @override
  String get signupFirstName => 'Prénom';

  @override
  String get signupLastName => 'Nom de famille';

  @override
  String get signupName => 'Nom complet';

  @override
  String get signupEmail => 'Email';

  @override
  String get signupPhone => 'Numéro de téléphone';

  @override
  String get signupPassword => 'Mot de passe';

  @override
  String get signupConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get signupButton => 'Créer un compte';

  @override
  String get signupLoginPrompt => 'Vous avez déjà un compte?';

  @override
  String get signupLoginLink => 'Se connecter';

  @override
  String get otpTitle => 'Vérifier le code';

  @override
  String otpMessage(String phone) {
    return 'Entrez le code envoyé à $phone';
  }

  @override
  String get otpResend => 'Renvoyer le code';

  @override
  String get otpVerify => 'Vérifier';

  @override
  String get otpMessageGeneric =>
      'Nous avons envoyé un code à 6 chiffres à votre numéro';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get loginWithoutAccount => 'Se connecter sans compte';

  @override
  String get emailTab => 'Email';

  @override
  String get phoneTab => 'Téléphone';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileOrders => 'Mes commandes';

  @override
  String get profileAddresses => 'Adresses';

  @override
  String get profilePayments => 'Historique des paiements';

  @override
  String get profileFavorites => 'Favoris';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageHausa => 'Hausa';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get ordersTitle => 'Mes commandes';

  @override
  String get ordersEmpty => 'Aucune commande';

  @override
  String get ordersEmptyMessage =>
      'Commencez à acheter pour voir vos commandes ici';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get orderStatus => 'Statut';

  @override
  String get orderDate => 'Date de commande';

  @override
  String get orderTotal => 'Total';

  @override
  String get orderTrack => 'Suivre la commande';

  @override
  String get orderCancel => 'Annuler la commande';

  @override
  String get orderReorder => 'Commander à nouveau';

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusProcessing => 'En cours';

  @override
  String get orderStatusShipped => 'Expédiée';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmpty => 'Aucun favori';

  @override
  String get favoritesEmptyMessage =>
      'Appuyez sur le cœur sur les produits que vous aimez';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get newArrivals => 'Nouveautés';

  @override
  String get specialOffers => 'Offres spéciales';

  @override
  String get recentlyViewed => 'Vus récemment';

  @override
  String get errorGeneric => 'Une erreur s\'est produite';

  @override
  String get errorNetwork => 'Vérifiez votre connexion Internet';

  @override
  String get errorEmpty => 'Aucun résultat trouvé';

  @override
  String get errorLoading => 'Échec du chargement des données';

  @override
  String get errorTryAgain => 'Réessayer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionOk => 'OK';

  @override
  String get actionYes => 'Oui';

  @override
  String get actionNo => 'Non';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionApply => 'Appliquer';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionSort => 'Trier';

  @override
  String testCredentials(String email, String password, String phone) {
    return 'Test: $email / $password\nOu: $phone';
  }

  @override
  String get validationRequired => 'Ce champ est requis';

  @override
  String get validationEmail => 'Entrez un email valide';

  @override
  String get validationPhone => 'Entrez un numéro de téléphone valide';

  @override
  String get validationPassword =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingProducts => 'Chargement des produits...';

  @override
  String get loadingOrders => 'Chargement des commandes...';

  @override
  String get processingPayment => 'Traitement du paiement...';
}
