import 'package:flutter/material.dart';
import '../../../../data/models/crypto/token.dart';

class TokenInfoScreen extends StatelessWidget {
  final Token token;

  const TokenInfoScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(token.logoUrl),
              radius: 14,
            ),
            const SizedBox(width: 8),
            Text(token.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Text(token.symbol, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Info", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildInfoTile("Name", token.name),
            _buildInfoTile("Symbol", token.symbol),
            _buildInfoTile("Network", token.network),
            _buildInfoTile("Market Cap", token.marketCap),
            _buildInfoTile("Total Supply", token.totalSupply),
            _buildInfoTile("Circulating Supply", token.circulatingSupply),
            const SizedBox(height: 20),
            const Text("About", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              token.description,
              style: const TextStyle(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text("Show More", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                if (token.website != null)
                  _buildLinkButton(Icons.language, "Website"),
                const SizedBox(width: 8),
                _buildLinkButton(Icons.close, "X"),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Trading perpetual contracts involves significant risk, including the potential for sudden and total loss of your investment...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLinkButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
