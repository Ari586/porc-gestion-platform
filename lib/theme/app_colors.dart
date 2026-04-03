import 'package:flutter/material.dart';

/// Cozy pastel palette inspired by mobile pet apps, adapted for PigIA.
/// Warm peach backgrounds, soft mint accents, and orange CTAs.
class AppColors {
  AppColors._();

  // ── Primary (Warm Orange) ────────────────────────────────────────────
  static const Color primary = Color(0xFFF39A2F);
  static const Color primaryDark = Color(0xFFD6781F);
  static const Color primaryLight = Color(0xFFF7BD73);
  static const Color primaryPale = Color(0xFFFFE9CD);

  // ── Secondary (Soft Mint / Sky) ──────────────────────────────────────
  static const Color secondary = Color(0xFF8FBCC3);
  static const Color secondaryLight = Color(0xFFB6D8DD);
  static const Color secondaryPale = Color(0xFFE9F4F6);

  // ── Backgrounds & Surfaces ───────────────────────────────────────────
  static const Color background = Color(0xFFF5D9C9);
  static const Color surface = Color(0xFFFFF8F2);
  static const Color surfaceContainer = Color(0xFFF9EBDD);
  static const Color cardSurface = Color(0xFFFFFCF9);

  // ── Sidebar ──────────────────────────────────────────────────────────
  static const Color sidebarDark = Color(0xFFF7E5D8);
  static const Color sidebarMedium = Color(0xFFFCEFE5);
  static const Color sidebarActiveBg = Color(0xFFFFBD69);
  static const Color sidebarText = Color(0xFF5E463C);
  static const Color sidebarTextActive = Color(0xFF2E2018);
  static const Color sidebarTextMuted = Color(0xFFA48374);
  static const Color sidebarUserCardBg = Color(0x99FFFFFF);
  static const Color sidebarUserCardBorder = Color(0x33D7B39B);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF3D2A22);
  static const Color textSecondary = Color(0xFF775E52);
  static const Color textMuted = Color(0xFFA18578);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Borders ──────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE4CAB8);
  static const Color borderLight = Color(0xFFEFDDCF);
  static const Color borderSubtle = Color(0xFFF6EBE3);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color error = Color(0xFFCB4B3F);
  static const Color errorLight = Color(0xFFFDE8E4);
  static const Color success = Color(0xFF4EA973);
  static const Color successLight = Color(0xFFE6F6EA);
  static const Color warning = Color(0xFFE49334);
  static const Color warningLight = Color(0xFFFFF2E2);
  static const Color info = Color(0xFF5CA4B2);
  static const Color infoLight = Color(0xFFE8F5F7);

  // ── Header ───────────────────────────────────────────────────────────
  static const Color headerBg = Color(0xFFFEF4EB);
  static const Color headerBorder = Color(0xFFEED8C8);

  // ── News-specific ────────────────────────────────────────────────────
  static const Color newsHeaderStart = Color(0xFFE8A56E);
  static const Color newsHeaderEnd = Color(0xFF9FC6CA);
  static const Color newsCanvasTop = Color(0xFFFFF5EC);
  static const Color newsCanvasBottom = Color(0xFFF1F8FA);
  static const Color newsCardSurface = Color(0xFFFFFCF7);
  static const Color newsCardBorder = Color(0xFFE9D8CC);
  static const Color newsMutedText = Color(0xFF766257);

  // ── Chat / Messenger ─────────────────────────────────────────────────
  static const Color chatHeader = Color(0xFF855445);
  static const Color chatHeaderSoft = Color(0xFFA16A58);
  static const Color chatOutgoingBubble = Color(0xFFFFE6C8);
  static const Color chatIncomingBubble = Color(0xFFFFFCF9);
  static const Color chatBackgroundTop = Color(0xFFFFF4EC);
  static const Color chatBackgroundBottom = Color(0xFFF5E8DE);
  static const Color chatInputSurface = Color(0xFFFBEDE3);

  // ── Dashboard Gradients ──────────────────────────────────────────────
  static const Color dashGradientGreenStart = Color(0xFF4FAE7B);
  static const Color dashGradientGreenEnd = Color(0xFF7FD2A7);
  static const Color dashGradientGoldStart = Color(0xFFE78F2B);
  static const Color dashGradientGoldEnd = Color(0xFFF7B566);
  static const Color dashGradientEarthStart = Color(0xFFC27656);
  static const Color dashGradientEarthEnd = Color(0xFFE5A17A);
  static const Color dashGradientSkyStart = Color(0xFF7FB7C2);
  static const Color dashGradientSkyEnd = Color(0xFFB8DDE2);

  // ── FAB ──────────────────────────────────────────────────────────────
  static const Color fab = Color(0xFFE9922A);
  static const Color fabForeground = Color(0xFFFFFFFF);

  // ── Login ────────────────────────────────────────────────────────────
  static const Color loginGradientStart = Color(0xFFF2D3C2);
  static const Color loginGradientEnd = Color(0xFFF9EBDD);
  static const Color loginSecurityBg = Color(0xFFFFF3E8);
  static const Color loginSecurityBorder = Color(0xFFEACFB9);
  static const Color loginSecurityText = Color(0xFF7A5F52);
}
