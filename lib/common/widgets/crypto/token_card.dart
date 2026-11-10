import 'package:flutter/material.dart';
import '../../../data/models/crypto/token.dart';
import '../../../config/theme/colors/app_colors.dart';

class TokenCard extends StatelessWidget {
  const TokenCard(this.token, {super.key});
  final Token token;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _IconWithRank(token: token),
          const SizedBox(width: 16),
          Expanded(child: _NameAndSymbol(token: token)),
          _PriceChange(token: token),
        ],
      ),
    );
  }
}

class _IconWithRank extends StatelessWidget {
  const _IconWithRank({required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/ozow.png'),
              image: AssetImage(token.iconPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${token.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameAndSymbol extends StatelessWidget {
  const _NameAndSymbol({required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          token.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          token.symbol,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PriceChange extends StatelessWidget {
  const _PriceChange({required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    final isUp = token.changePercent >= 0;
    final changeColor = isUp ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'R${token.price.toStringAsFixed(8)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: changeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 16,
              ),
              Text(
                '${token.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
