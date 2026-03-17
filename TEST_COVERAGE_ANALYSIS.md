# Test Coverage Analysis

## Current State

The codebase contains **117 Dart source files** with approximately **44,849 lines of code** across three architectural layers (data, domain, presentation). There is currently **1 test file** (`test/widget_test.dart`) containing a 30-line boilerplate smoke test that doesn't even match the current app (it tests a counter widget).

**Effective test coverage: 0%**

---

## Priority Areas for Test Improvement

### 1. Model `fromJson` Factories (HIGH PRIORITY)

**Files:** 12 model files in `lib/domain/models/`

Models like `Order`, `Cart`, `User`, `Address`, and `Restaurant` all have `fromJson` factory constructors with non-trivial parsing logic — null coalescing, type casting, nested model parsing, and date formatting. These are pure functions with no dependencies, making them the easiest and highest-value targets for unit tests.

**Specific concerns:**
- `order_model.dart` has a `_parseBackendDateTime()` helper that normalizes date strings — this should be tested with edge cases (null, empty, malformed dates)
- `_composeBilingualName()` is duplicated in both `order_model.dart` and `cart_model.dart` — tests would verify consistency and catch divergence
- `cart_model.dart` computed getters (`subtotalDouble`, `deliveryFeeDouble`, `isEmpty`, `hasCoupon`) need validation with edge-case inputs

**Suggested tests:**
- Valid JSON → correct model fields
- Missing/null optional fields → defaults applied correctly
- Malformed JSON → graceful handling (no crashes)
- Nested model parsing (e.g., `CartItem` within `Cart`)

---

### 2. BLoC State Management (HIGH PRIORITY)

**Files:** 37 files across 13 BLoC modules in `lib/domain/bloc/`

The BLoCs contain the core business logic. Using the `bloc_test` package, each BLoC can be tested by mocking its service dependency and verifying state transitions.

**Key BLoCs to test first:**
- **`AuthBloc`** — login, registration, OTP verification, password reset flows. Incorrect state transitions here cause authentication bugs.
- **`CartBloc`** — add/remove/update items, coupon application, cart validation. Has internal state (`_currentCart`, `_currentRestaurantId`) that needs careful testing.
- **`OrdersBloc`** — order creation, cancellation, tracking, reordering. Manages `_activeOrders` and `_historyOrders` lists internally.

**Suggested tests per BLoC:**
- Initial state is correct
- Each event produces the expected state sequence (Loading → Loaded/Error)
- Error states are emitted on service failures
- Edge cases: empty lists, 404 treated as empty cart, etc.

---

### 3. Form Validators (HIGH PRIORITY — easy win)

**File:** `lib/presentation/utils/form_validator.dart`

13 validators with clear input/output contracts. These are nearly pure functions (they depend on `BuildContext` only for localization strings). With a mock `AppLocalizations`, these are straightforward to test.

**Validators to cover:**
| Validator | Edge cases to test |
|---|---|
| `phoneValidator` | empty, too short (<8), too long (>15), special chars, valid |
| `passwordValidator` | empty, too short (<8), valid |
| `passwordMatchValidator` | empty, mismatch, match |
| `emailValidator` | empty (returns null — optional), invalid format, valid |
| `otpValidator` | empty, wrong length, non-numeric, valid |
| `firstNameValidator` / `lastNameValidator` | empty, too short, too long, whitespace-only |

---

### 4. Date/Time Formatting (MEDIUM PRIORITY — easy win)

**File:** `lib/presentation/utils/date_time_formatter.dart`

5 static formatting methods with deterministic logic (except `formatRelative` and `formatDateTimeWithTodayLabel` which depend on `DateTime.now()`). Pure logic, easy to test.

**Suggested tests:**
- `formatTimeAmPm`: midnight (12 AM), noon (12 PM), single-digit minutes
- `formatDate` / `formatDayMonth`: single-digit day/month padding
- `formatRelative`: boundaries at 1 min, 60 min, 24 hours, 7 days

---

### 5. Data Services (MEDIUM PRIORITY)

**Files:** 13 service files in `lib/data/services/`

Services like `auth_service.dart`, `cart_service.dart`, and `order_service.dart` make HTTP calls. These need integration-style tests with mocked HTTP clients to verify:

- Correct URL construction and HTTP methods
- Request headers (auth tokens) are included
- Response JSON is correctly parsed into models
- HTTP error codes are translated to meaningful exceptions
- Token refresh/retry logic works correctly

**Recommendation:** Use the `http` package's `MockClient` for testing.

---

### 6. Secure Storage (MEDIUM PRIORITY)

**File:** `lib/data/local_secure/secure_storage.dart`

Handles token persistence, user data caching, and logout cleanup. A bug here can lock users out or leak sessions. Test with a mock `FlutterSecureStorage`.

---

### 7. Widget / Screen Tests (LOWER PRIORITY)

**Files:** 35 screen files, 5 component files

While important long-term, widget tests are more complex to set up (requiring mocked BLoCs, navigation, and localization). Start with reusable components:

- **`custom_button.dart`** — renders correctly, handles taps, shows loading state
- **`custom_form_field.dart`** — displays validation errors, handles input
- **`custom_text.dart`** — renders with correct styles

---

## Recommended Action Plan

| Phase | Scope | Estimated Tests | Difficulty |
|-------|-------|----------------|------------|
| **Phase 1** | Model `fromJson` + computed properties | ~60 tests | Easy |
| **Phase 2** | Form validators + DateTimeFormatter | ~50 tests | Easy |
| **Phase 3** | BLoC state transitions (auth, cart, orders) | ~80 tests | Medium |
| **Phase 4** | Remaining BLoCs (address, menu, restaurant, etc.) | ~50 tests | Medium |
| **Phase 5** | Data services with mocked HTTP | ~40 tests | Medium |
| **Phase 6** | Reusable widget components | ~20 tests | Medium |
| **Phase 7** | Screen-level widget tests | ~30 tests | Hard |

## Additional Recommendations

1. **Add `bloc_test` and `mocktail` (or `mockito`) to dev dependencies** for BLoC and service testing.
2. **Configure coverage reporting** — run `flutter test --coverage` and add `lcov` to CI.
3. **Delete the existing `widget_test.dart`** — it tests a counter widget that doesn't exist in the app.
4. **Extract `_composeBilingualName`** into a shared utility — it's duplicated across model files.
5. **Set up CI/CD** (GitHub Actions) to run tests on every push and enforce a minimum coverage threshold.
