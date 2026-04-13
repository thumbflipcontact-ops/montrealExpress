AExpress
 1.0.0 
OAS 3.0
Api A Express


Authorize
Authentication
Endpoints d'authentification



POST
/api/v1/auth/register
Inscription d'un nouvel utilisateur


POST
/api/v1/auth/phone/initiate
Initiate phone authentication (Login or Register)


POST
/api/v1/auth/phone/verify
Verify OTP and authenticate user


POST
/api/v1/auth/login
Connexion d'un utilisateur

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "email": "user@example.com",
  "password": "Password123!"
}
Responses
Code	Description	Links
200	
Connexion réussie

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Connexion réussie",
  "data": {
    "user": {
      "id": "string",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "fullName": "string",
      "role": "string",
      "isActive": true,
      "lastLogin": "string"
    },
    "accessToken": "string"
  }
}
No links
401	
Identifiants invalides

No links

GET
/api/v1/auth/profile
Récupérer le profil de l'utilisateur connecté



PUT
/api/v1/auth/profile
Mettre à jour le profil de l'utilisateur



POST
/api/v1/auth/change-password
Changer le mot de passe



POST
/api/v1/auth/verify-email-otp
Verify email OTP code


POST
/api/v1/auth/forgot-password
Demander la réinitialisation du mot de passe


POST
/api/v1/auth/verify-reset-otp
Vérifier le code OTP et réinitialiser le mot de passe


POST
/api/v1/auth/reset-password
Réinitialiser le mot de passe

Users
Gestion des utilisateurs



POST
/api/v1/users
Créer un nouvel utilisateur (Admin uniquement)



GET
/api/v1/users
Récupérer la liste des utilisateurs



GET
/api/v1/users/stats
Récupérer les statistiques des utilisateurs (Admin uniquement)



GET
/api/v1/users/{id}
Récupérer un utilisateur par son ID



PATCH
/api/v1/users/{id}
Mettre à jour un utilisateur (Admin uniquement)



DELETE
/api/v1/users/{id}
Supprimer un utilisateur (Admin uniquement)



PATCH
/api/v1/users/{id}/toggle-active
Activer/Désactiver un utilisateur (Admin uniquement)



POST
/api/v1/users/{id}/assign-merchant-role
Attribuer le rôle marchand pour 3 mois (Admin uniquement)



GET
/api/v1/users/{id}/merchant-role-info
Obtenir les informations sur le rôle vendeur d'un utilisateur



POST
/api/v1/users/{id}/check-merchant-role
Vérifier et révoquer le rôle marchand s'il a expiré (Admin uniquement)



POST
/api/v1/users/check-expired-merchant-roles
Vérifier et révoquer tous les rôles marchands expirés (Admin uniquement)


Products
Gestion des lieux



POST
/api/v1/products
Create a new product (Admin/Vendor only)



GET
/api/v1/products
Get all products with filtering and pagination


GET
/api/v1/products/featured
Get featured products


GET
/api/v1/products/{id}
Get a single product by ID


PUT
/api/v1/products/{id}
Update a product (Admin/Vendor only)



DELETE
/api/v1/products/{id}
Delete a product (Admin only)



GET
/api/v1/products/{id}/related
Get related products

Application


GET
/api/v1
Vérification de l'état de l'application


GET
/api/v1/health
Vérification de santé de l'application

Categories


POST
/api/v1/categories
Create a new category



GET
/api/v1/categories
Get all categories


GET
/api/v1/categories/tree
Get category tree


GET
/api/v1/categories/{id}
Get a category by ID


PUT
/api/v1/categories/{id}
Update a category



DELETE
/api/v1/categories/{id}
Delete a category (soft delete)



GET
/api/v1/categories/slug/{slug}
Get a category by slug


GET
/api/v1/categories/{id}/products
Get products in a category


DELETE
/api/v1/categories/{id}/hard
Permanently delete a category



POST
/api/v1/categories/{id}/update-product-count
Update product count for a category


Cart


GET
/api/v1/cart
Get current cart



DELETE
/api/v1/cart
Clear cart



POST
/api/v1/cart/items
Add item to cart



PUT
/api/v1/cart/items/{id}
Update cart item quantity



DELETE
/api/v1/cart/items/{id}
Remove item from cart



POST
/api/v1/cart/apply-coupon
Apply coupon to cart



DELETE
/api/v1/cart/coupon
Remove coupon from cart



POST
/api/v1/cart/merge
Merge guest cart into user cart



POST
/api/v1/cart/validate
Validate cart


Orders


POST
/api/v1/orders
Créer une commande depuis le panier



GET
/api/v1/orders/me
Obtenir l'historique de mes commandes



GET
/api/v1/orders/me/{id}
Obtenir les détails d'une de mes commandes



GET
/api/v1/orders/me/number/{orderNumber}
Obtenir une commande par son numéro



PUT
/api/v1/orders/me/{id}/cancel
Annuler une de mes commandes



GET
/api/v1/orders/vendor/my-orders
[VENDOR] Obtenir les commandes contenant mes produits



GET
/api/v1/orders/admin/all
[ADMIN] Obtenir toutes les commandes



GET
/api/v1/orders/admin/statistics
[ADMIN] Obtenir les statistiques des commandes



GET
/api/v1/orders/admin/{id}
[ADMIN] Obtenir les détails d'une commande



PUT
/api/v1/orders/admin/{id}/status
[ADMIN] Mettre à jour le statut d'une commande



PUT
/api/v1/orders/admin/{id}/cancel
[ADMIN] Annuler une commande


Analytics


GET
/api/v1/analytics/dashboard


GET
/api/v1/analytics/top-products


GET
/api/v1/analytics/recent-orders


GET
/api/v1/analytics/inventory


GET
/api/v1/analytics/revenue


GET
/api/v1/analytics/sales


GET
/api/v1/analytics/users


GET
/api/v1/analytics/products

Payments


GET
/api/v1/payments


GET
/api/v1/payments/{id}


POST
/api/v1/payments/process


POST
/api/v1/payments/refund

Coupons


GET
/api/v1/coupons


POST
/api/v1/coupons


GET
/api/v1/coupons/{id}


PUT
/api/v1/coupons/{id}


DELETE
/api/v1/coupons/{id}


POST
/api/v1/coupons/apply


Schemas
RegisterDto{
email*	string
example: user@example.com
Adresse email de l'utilisateur

password*	string
example: Password123!
minLength: 6
Mot de passe (minimum 6 caractères, doit contenir au moins une lettre majuscule, une minuscule et un chiffre)

firstName*	string
example: John
minLength: 1
maxLength: 50
Prénom de l'utilisateur

lastName*	string
example: Doe
minLength: 1
maxLength: 50
Nom de l'utilisateur

}
InitiatePhoneAuthDto{
phoneNumber*	[...]
}
VerifySMSOTPDto{
phoneNumber*	[...]
otpCode*	[...]
}
LoginDto{
email*	[...]
password*	[...]
}
UpdateProfileDto{
firstName	[...]
lastName	[...]
avatar	[...]
}
ChangePasswordDto{
currentPassword*	[...]
newPassword*	[...]
}
VerifyEmailOTPDto{
email*	[...]
otpCode*	[...]
}
ForgotPasswordDto{
email*	[...]
}
VerifyResetOTPDto{
email*	[...]
otpCode*	[...]
newPassword*	[...]
}
ResetPasswordDto{
token*	[...]
newPassword*	[...]
}
CreateUserDto{
email*	[...]
password*	[...]
firstName*	[...]
lastName*	[...]
role	[...]
isActive	[...]
avatar	[...]
isEmailVerified	[...]
phoneNumber	[...]
isPhoneVerified	[...]
}
UpdateUserDto{
email	[...]
password	[...]
firstName	[...]
lastName	[...]
role	[...]
isActive	[...]
avatar	[...]
isEmailVerified	[...]
phoneNumber	[...]
isPhoneVerified	[...]
}
DimensionsDto{
length*	[...]
width*	[...]
height*	[...]
}
CreateProductDto{
title*	[...]
description*	[...]
category*	[...]
subcategory	[...]
price*	[...]
compareAtPrice	[...]
imageUrl*	[...]
imageUrls	[...]
stock*	[...]
lowStockThreshold	[...]
tags	[...]
vendor	[...]
sku	[...]
weight	[...]
dimensions	{...}
isActive	[...]
isFeatured	[...]
}
UpdateProductDto{
title	string
example: Sac à main élégant
minLength: 3
maxLength: 200
Product title

description	[...]
category	[...]
subcategory	[...]
price	[...]
compareAtPrice	[...]
imageUrl	[...]
imageUrls	[...]
stock	[...]
lowStockThreshold	[...]
tags	[...]
vendor	[...]
sku	[...]
weight	[...]
dimensions	{...}
isActive	[...]
isFeatured	[...]
}
CreateCategoryDto{
name*	[...]
description	[...]
image	[...]
parentId	[...]
sortOrder	[...]
isActive	[...]
}
UpdateCategoryDto{
name	[...]
description	[...]
image	[...]
parentId	[...]
sortOrder	[...]
isActive	[...]
}
AddToCartDto{
productId*	[...]
quantity*	[...]
}
UpdateCartItemDto{
quantity*	[...]
}
ApplyCouponDto{
}
AddressDto{
fullName*	[...]
phone*	[...]
street*	[...]
city*	[...]
region*	[...]
postalCode	[...]
country*	[...]
}
CreateOrderDto{
shippingAddress*	{...}
billingAddress	{...}
paymentMethod*	[...]
notes	[...]
phoneNumber	[...]
}
CancelOrderDto{
cancellationReason	[...]
}
UpdateOrderStatusDto{
status	[...]
trackingNumber	[...]
adminNotes	[...]
}
ProcessPaymentDto{
}
RefundPaymentDto{
}
CreateCouponDto{
}
UpdateCouponDto{
}