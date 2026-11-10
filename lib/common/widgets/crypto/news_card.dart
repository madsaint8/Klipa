import 'package:flutter/material.dart';
import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';

Widget buildNewsCard(CryptoNewsArticle news) {
  return Container(
    width: 270,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.black, // Outline color
        width: 1.0, // Thickness of the outline
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder for graph
        Container(
          height: 100,
          width: 210,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset(
              news.imageUrl ?? 'assets/images/default_news_image.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              news.title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
