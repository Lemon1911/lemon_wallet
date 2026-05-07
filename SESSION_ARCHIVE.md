# LemonWallet Session Archive
*Date: May 7, 2026*

## Project State Overview
LemonWallet is a Flutter financial application built with **Clean Architecture** and **Bloc State Management**. The UI relies heavily on a custom "Midnight Kinetic" design system featuring glassmorphism (`GlassCard`).

### Accomplishments in this Session:
1. **Domain & Data Layers**: 
   - Expanded `TransactionBloc` to handle category loading (`GetCategoriesUseCase`).
   - Integrated dependency injection via `service_locator.dart`.
2. **UI & Presentation**:
   - Created the **Add Transaction Screen** with a dynamic category selector and transaction type toggle (Income/Expense).
   - Refactored `TransactionsScreen` and `DashboardScreen` to dynamically load data based on the active wallet.
3. **Performance Optimization**: 
   - Identified a significant lag issue caused by overlapping `BackdropFilter` widgets in lists. 
   - Updated `GlassCard` with a `hasBlur: false` toggle and applied it to transaction items and action pills to resolve frame drops.
4. **Code Quality**:
   - Resolved UI compilation errors by adding missing color constants (`bgDark`, `glassBorder`, etc.) to `AppColors` and adding the `border` property to `GlassCard`.

## Roadmap for Next Session
When resuming development, focus on the following immediate tasks:

1. **Wire up the "Pay" Button**: 
   - In `DashboardScreen`, the "Income" button routes to `AddTransactionScreen`. Wire up the "Pay" button to route there as well, but pass a parameter to automatically select "Expense" as the default transaction type.
2. **Real-time Auto-Refresh**: 
   - The Dashboard and Transactions list do not currently auto-update after a new transaction is recorded. Add a `BlocListener` in the navigation pop callback or listen to the `TransactionBloc` globally to re-fetch wallet balances and the transaction list.
3. **Category Icons Mapping**: 
   - In `TransactionsScreen`, transactions use a generic icon. Map category names (e.g., Food, Salary, Transport) to specific unique icons for better scannability.

## Important Context for Next Agent
- **Project Path**: `d:\Personal Project\lemon_money`
- **Architecture**: `lib/features/{feature}/` containing `data/`, `domain/`, and `presentation/` folders.
- **UI Core Component**: Rely on `GlassCard` for styling. Use `hasBlur: false` when using it inside `ListView` or multiple times on a screen to maintain 60fps performance.
- The latest changes have been successfully committed and pushed to GitHub.
