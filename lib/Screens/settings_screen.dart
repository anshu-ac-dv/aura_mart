import 'package:aura_mart/core_services/theme_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _faceIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: Stack(
        children: [
          // Ambient Glows
          if (isDarkMode) ...[
            Positioned(right: -100, top: -100, child: _buildGlow(primaryColor.withAlpha(20), 400)),
            Positioned(left: -50, bottom: 100, child: _buildGlow(Colors.blueAccent.withAlpha(10), 300)),
          ],

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Cinematic Header
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SETTINGS",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 8,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "CONFIGURE YOUR EXPERIENCE",
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Settings Sections
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                    _buildSectionHeader("PREFERENCES", isDarkMode),
                    _buildSwitchTile(
                      Icons.notifications_none_rounded, 
                      "Push Notifications", 
                      "Get updates on your orders", 
                      _notificationsEnabled, 
                      (v) => setState(() => _notificationsEnabled = v), 
                      isDarkMode, 
                      primaryColor
                    ),
                    _buildSwitchTile(
                      Icons.face_unlock_rounded, 
                      "Face ID / Bio-Auth", 
                      "Secure your transactions", 
                      _faceIdEnabled, 
                      (v) => setState(() => _faceIdEnabled = v), 
                      isDarkMode, 
                      primaryColor
                    ),
                    
                    const SizedBox(height: 30),
                    _buildSectionHeader("APPEARANCE", isDarkMode),
                    _buildSwitchTile(
                      Icons.settings_suggest_outlined, 
                      "System Theme", 
                      "Match your device settings", 
                      themeService.isSystemMode, 
                      (v) {
                        setState(() {
                          if (v) {
                            themeService.setSystemTheme();
                          } else {
                            // If turning off system theme, default to current brightness
                            themeService.toggleTheme(isDarkMode);
                          }
                        });
                      }, 
                      isDarkMode, 
                      primaryColor
                    ),
                    
                    if (!themeService.isSystemMode)
                      _buildSwitchTile(
                        Icons.dark_mode_outlined, 
                        "Dark Mode", 
                        "Enable dark interface manually", 
                        themeService.isDarkMode, 
                        (v) {
                          setState(() {
                            themeService.toggleTheme(v);
                          });
                        }, 
                        isDarkMode, 
                        primaryColor
                      ),
                    
                    const SizedBox(height: 30),
                    _buildSectionHeader("ACCOUNT", isDarkMode),
                    _buildSimpleTile(Icons.person_outline_rounded, "Edit Profile", isDarkMode),
                    _buildSimpleTile(Icons.lock_outline_rounded, "Change Password", isDarkMode),
                    _buildSimpleTile(Icons.language_rounded, "Language", isDarkMode, trailing: "English"),
                    
                    const SizedBox(height: 30),
                    _buildSectionHeader("ABOUT", isDarkMode),
                    _buildSimpleTile(Icons.info_outline_rounded, "Privacy Policy", isDarkMode),
                    _buildSimpleTile(Icons.description_outlined, "Terms of Service", isDarkMode),
                    _buildSimpleTile(Icons.code_rounded, "App Version", isDarkMode, trailing: "1.0.0"),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: isDarkMode ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged, bool isDarkMode, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
          activeTrackColor: primaryColor.withAlpha(50),
          inactiveTrackColor: isDarkMode ? Colors.white10 : Colors.black.withAlpha(13),
        ),
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, bool isDarkMode, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: isDarkMode ? Colors.white38 : Colors.black38, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: trailing != null 
          ? Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 12))
          : Icon(Icons.chevron_right_rounded, size: 20, color: isDarkMode ? Colors.white10 : Colors.black12),
        onTap: () {},
      ),
    );
  }
}
