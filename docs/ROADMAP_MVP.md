## AbdoulExpress Roadmap to MVP

### 1. Foundation & Cleanup (Week 1) -- OK 
- **Project hygiene**
  - Verify all tests pass: `flutter test`.
  - Run analyzer and fix warnings: `flutter analyze`.
  - Remove unused imports, dead code, and TODOs that are not MVP-critical.
- **Branding & store basics**
  - Set final app name, icons, and primary colors.
  - Update Android `applicationId` / iOS bundle identifier to production values.
  - Configure Android/iOS signing profiles for release builds.

### 2. Core Shopping Flow (Week 1–2) -- OK
- **Product listing (Home)**
  - Finalize product grid UI (images, price, promo badge, favorites, add-to-cart).
  - Confirm search/filter behavior matches spec and is well tested.
  - Connect `ProductsCubit` to a real backend or stable mock API layer.
- **Product details**
  - Ensure `ProductDetailPage` covers: images, description, stock info, price, quantity selector.
  - Wire "Add to cart" and "Buy now" to `CartCubit` and navigation to checkout.
- **Favorites**
  - Ensure `FavoritesCubit` is fully integrated with product list and details.
  - Persist favorites locally (e.g., `shared_preferences`) for MVP.


### 3. Cart & Checkout (Week 2).  -- IN PROGRESS -- 
- **Cart experience**
  - Validate all `CartCubit` actions: add, remove, quantity change, clear.
  - Confirm cart summary fields (subtotal, shipping, total) match business rules.
  - Handle empty-cart UX gracefully.
- **Checkout form**
  - Finalize checkout fields (name, address, phone, notes if needed).
  - Add validation and inline error messages.
  - On success, create a mock `Order` and navigate to confirmation screen.

### 4. Authentication & Onboarding (Week 2–3) -- IN FUTURE. ---
- **Onboarding**
  - Show onboarding only on first launch (persist `onboarding_seen`).
  - Keep copy and visuals aligned with AbdoulExpress brand.
- **Auth flows**
  - Implement email/password login & signup in `AuthRepository` against real or staged backend.
  - Implement phone + OTP login flow (happy path + basic failure states).
  - Persist auth token and user profile locally; auto-login on app restart.

### 5. Addresses, Orders, and Profile (Week 3) -- IN PROGRESS
- **Addresses**
  - Ensure address CRUD (create/edit/delete) pages are complete and validated.
  - Integrate address selection into checkout flow.
- **Orders**
  - Implement `OrdersCubit` with real or mocked API calls.
  - Show order history list and order details; link from Profile and confirmation screens.
- **Profile**
  - Replace mock user data with real authenticated user data.
  - Wire favorites, orders, addresses, and payment history sections.

### 6. Payments (Week 3–4)
- **Payment methods**
  - Implement payment method selection screen based on `PAYMENT_SYSTEM.md`.
  - Support at least one mobile money / manual receipt flow for MVP.
- **Payment processing**
  - Use `PaymentCubit` to manage payment creation, pending states, and history.
  - Implement receipt upload (via `image_picker`) and link it to payments/orders.
  - Handle failure states (network errors, invalid receipt) with clear UX.

### 7. Offline & Performance (Week 4)
- **Offline behavior**
  - Use `OfflineActionQueue` for cart and critical user actions where possible.
  - Show user-friendly offline indicators and retry options.
- **Performance**
  - Ensure image loading uses `cached_network_image` with placeholders and error states.
  - Test on low-end devices and optimize scrolling, rebuilding, and text layout.

### 8. Polish, Compliance & Store Readiness (Week 4–5)
- **Internationalization & copy**
  - Ensure all user-facing strings are in French and consistent (naming, tone).
  - Centralize common strings for easier maintenance (optional for MVP).
- **Privacy & legal**
  - Finalize privacy policy (`policy/index.html`) and host it at a stable URL.
  - Add links to the privacy policy in Profile/settings and store listings.
  - For iOS, define required usage descriptions and privacy manifest (no tracking if not needed).
- **Store builds**
  - Prepare release builds: `flutter build apk --release`, `flutter build ios --release`.
  - Test install from release artifacts on real Android and iOS devices.
  - Create Play Store and App Store listings (screenshots, description, icons) based on MVP.

### 9. Nice-to-Have Post-MVP
- **Push notifications** for order status updates and promotions.
- **Deep links** for sharing products and opening specific screens.
- **Analytics** (non-invasive) for understanding user flows and improving UX.
- **A/B tests** on onboarding and home layout once user volume grows.
