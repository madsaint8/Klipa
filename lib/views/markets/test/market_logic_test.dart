import 'package:flutter_test/flutter_test.dart';

import '../logic/market_formatters.dart';
import '../logic/market_search_logic.dart';
import '../models/market_item_model.dart';
import '../models/market_tab_model.dart';

MarketItem _item(String title, String subtitle,
        {MarketTab tab = MarketTab.tokens, List<String> tags = const []}) =>
    MarketItem(
      id: title,
      tab: tab,
      title: title,
      subtitle: subtitle,
      priceLabel: '\$1',
      tags: tags,
    );

void main() {
  final items = [
    _item('BTC', 'Bitcoin'),
    _item('Vaulted Gold', 'Tokenized gold bullion', tab: MarketTab.rwas),
    _item('Travel Cover', 'Medical & delays',
        tab: MarketTab.insurance, tags: ['Holiday']),
  ];

  group('MarketSearchLogic', () {
    test('empty query returns everything', () {
      expect(MarketSearchLogic.filter(items, '  ').length, 3);
    });

    test('matches across title, subtitle and tags', () {
      expect(MarketSearchLogic.filter(items, 'bitcoin').single.title, 'BTC');
      expect(MarketSearchLogic.filter(items, 'holiday').single.title,
          'Travel Cover');
    });

    test('multi-word queries need every word (AND)', () {
      expect(MarketSearchLogic.filter(items, 'gold bullion').length, 1);
      expect(MarketSearchLogic.filter(items, 'gold bitcoin'), isEmpty);
    });

    test('exact symbol outranks a loose match', () {
      final list = [
        _item('Bitcoin Cash', 'Fork of bitcoin'),
        _item('BTC', 'Bitcoin'),
      ];
      expect(MarketSearchLogic.filter(list, 'btc').first.title, 'BTC');
    });
  });

  group('MarketFormatters', () {
    test('price', () {
      expect(MarketFormatters.price(1234.5), '\$1,234.50');
      expect(MarketFormatters.price(0.000123), '\$0.000123');
      expect(MarketFormatters.price(null), '—');
    });
    test('percent', () {
      expect(MarketFormatters.percent(1.234), '+1.23%');
      expect(MarketFormatters.percent(-0.5), '-0.50%');
    });
  });
}
