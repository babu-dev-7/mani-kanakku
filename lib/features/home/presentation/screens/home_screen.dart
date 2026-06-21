import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../calculator/presentation/bloc/calculator_bloc.dart';
import '../../../calculator/presentation/bloc/calculator_event.dart';
import '../../../calculator/presentation/bloc/calculator_state.dart';
import '../../../calculator/presentation/screens/calculator_screen.dart';
import '../../../calculator/presentation/widgets/rate_bottom_sheet.dart';
import '../../../instant/presentation/bloc/instant_bloc.dart';
import '../../../instant/presentation/bloc/instant_event.dart';
import '../../../instant/presentation/screens/instant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: IndexedStack(
                  key: ValueKey(_currentIndex),
                  index: _currentIndex,
                  children: const [
                    InstantScreen(),
                    CalculatorScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildTabButton(
                  index: 0,
                  icon: Icons.bolt_rounded,
                  label: l10n.instant,
                ),
                _buildTabButton(
                  index: 1,
                  icon: Icons.calculate_outlined,
                  label: l10n.calculator,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textMuted,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App logo
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
                Text(
                  l10n.appSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Rate chip (disabled with reduced opacity when amount calculation is OFF)
          _buildRateChip(context, l10n),
          const SizedBox(width: 4),
          // Amount calculation toggle
          _buildAmountToggle(context),
          const SizedBox(width: 2),
          // History icon — only shows Calculator history
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/history');
              },
              icon: const Icon(
                Icons.history_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      buildWhen: (prev, curr) =>
          prev.rate != curr.rate ||
          prev.isAmountCalculationEnabled != curr.isAmountCalculationEnabled,
      builder: (context, calcState) {
        final enabled = calcState.isAmountCalculationEnabled;
        return Opacity(
          opacity: enabled ? 1.0 : 0.35,
          child: IgnorePointer(
            ignoring: !enabled,
            child: GestureDetector(
              onTap: () => _showRateSheet(context, calcState.rate),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '₹${calcState.rate.toInt()}${l10n.ratePerHour}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amber,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountToggle(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      buildWhen: (prev, curr) =>
          prev.isAmountCalculationEnabled != curr.isAmountCalculationEnabled,
      builder: (context, calcState) {
        final enabled = calcState.isAmountCalculationEnabled;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.currency_rupee_rounded,
              size: 11,
              color: enabled ? AppColors.primaryGreen : AppColors.textMuted,
            ),
            Transform.scale(
              scale: 0.62,
              child: Switch(
                value: enabled,
                onChanged: (_) {
                  context
                      .read<CalculatorBloc>()
                      .add(const ToggleAmountCalculation());
                  context
                      .read<InstantBloc>()
                      .add(const InstantToggleAmountCalculation());
                },
                activeThumbColor: AppColors.primaryGreen,
                activeTrackColor: AppColors.primaryGreenLight,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRateSheet(BuildContext context, double currentRate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return RateBottomSheet(
          currentRate: currentRate,
          onRateSaved: (rate) {
            // Update rate in both blocs so both tabs stay in sync
            context.read<CalculatorBloc>().add(RateChanged(rate));
            context.read<InstantBloc>().add(InstantRateChanged(rate));
          },
        );
      },
    );
  }
}
