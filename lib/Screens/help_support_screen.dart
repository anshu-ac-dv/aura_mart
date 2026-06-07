import 'package:flutter/material.dart';
import 'dart:ui';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: Stack(
        children: [
          // Ambient Glows
          if (isDarkMode) ...[
            Positioned(left: -100, top: -100, child: _buildGlow(primaryColor.withAlpha(20), 400)),
            Positioned(right: -50, bottom: 100, child: _buildGlow(Colors.blueAccent.withAlpha(10), 300)),
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
                          "HELP CENTER",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 8,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "WE ARE HERE FOR YOU",
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

              // Search Bar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: _buildGlassSearchBar(isDarkMode),
                ),
              ),

              // Contact Channels
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                  child: Row(
                    children: [
                      Text("CONTACT CHANNELS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: isDarkMode ? Colors.white24 : Colors.black26)),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      _buildContactCard(Icons.chat_bubble_outline_rounded, "Live Chat", "2 min wait", Colors.blue, isDarkMode),
                      _buildContactCard(Icons.email_outlined, "Email Us", "24h response", Colors.orange, isDarkMode),
                      _buildContactCard(Icons.phone_in_talk_outlined, "Call Center", "9am - 6pm", Colors.green, isDarkMode),
                    ],
                  ),
                ),
              ),

              // FAQ Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 40, 25, 10),
                  child: Text("FREQUENTLY ASKED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: isDarkMode ? Colors.white24 : Colors.black26)),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFaqTile("How do I track my order?", "You can track your order in the 'My Orders' section of your profile.", isDarkMode),
                    _buildFaqTile("What is the return policy?", "We offer a 30-day return policy for most items in their original condition.", isDarkMode),
                    _buildFaqTile("How can I change my address?", "Go to Profile > Shipping Address to manage your saved locations.", isDarkMode),
                    _buildFaqTile("Is my payment secure?", "Yes, Aura Mart uses industry-standard encryption for all transactions.", isDarkMode),
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

  Widget _buildGlassSearchBar(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "How can we help you?",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color color, bool isDarkMode) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
        boxShadow: [
          if (!isDarkMode) BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedAlignment: Alignment.topLeft,
        iconColor: Colors.deepPurple,
        collapsedIconColor: Colors.grey,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
