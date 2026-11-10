import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../../../../data/models/crypto/coin/coin_model.dart';
import '../../../../data/models/environment/environment.dart';


class TokenDetails extends StatefulWidget {
  final CoinModel coin;

  const TokenDetails({super.key, required this.coin});

  @override
  _TokenDetailsState createState() => _TokenDetailsState();
}

class _TokenDetailsState extends State<TokenDetails> {
  bool isLoading = true;
  List<FlSpot> flSpotList = [];
  double minX = 0;
  double minY = 0;
  double maxX = 0;
  double maxY = 0;
  String selectedPeriod = '1D';

  @override
  void initState() {
    super.initState();
    getChartData('1');
  }

  void getChartData(String days) async {
    setState(() {
      isLoading = true;
    });
    
    final coingeckoUrl = Environment.coingeckoApiUrl;

    String api =
        coingeckoUrl;
    final response = await http.get(Uri.parse(api));

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      List rawList = result['prices'];
      List<List> chartData = rawList.map((e) => e as List).toList();
      List<PriceAndTime> priceAndTimeList = chartData
          .map((e) => PriceAndTime(time: e[0] as int, price: e[1] as double))
          .toList();
      flSpotList = priceAndTimeList
          .map((chart) => FlSpot(chart.time.toDouble(), chart.price))
          .toList();
      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();
      priceAndTimeList.sort((a, b) => a.price.compareTo(b.price));
      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.coin.name}',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            color: Colors.red,
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Market Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(widget.coin.currentPrice.toString(),
                            'Market value'),
                        _buildStatColumn(widget.coin.currentPrice.toString(),
                            'Avg. Buy Price'),
                        _buildStatColumn(
                          '${widget.coin.priceChangePercentage24h}%',
                          'Profit',
                          isProfit: widget.coin.priceChangePercentage24h! > 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Coin Header
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Image.network(
                                    widget.coin.image ?? '',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.coin.symbol!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'R ${widget.coin.currentPrice!.toStringAsFixed(3)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${widget.coin.priceChangePercentage24h!.toStringAsFixed(2)}% ▲',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Time Period Selector
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCompactTimeButton('1D',
                                    isSelected: selectedPeriod == '1D',
                                    onPressed: () => updateChartData('1')),
                                _buildCompactTimeButton('1W',
                                    isSelected: selectedPeriod == '7',
                                    onPressed: () => updateChartData('7')),
                                _buildCompactTimeButton('1M',
                                    isSelected: selectedPeriod == '30',
                                    onPressed: () => updateChartData('30')),
                                _buildCompactTimeButton('1Y',
                                    isSelected: selectedPeriod == '365',
                                    onPressed: () => updateChartData('365')),
                              ],
                            ),

                            // Chart
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  minX: minX,
                                  maxX: maxX,
                                  minY: minY,
                                  maxY: maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: flSpotList,
                                      isCurved: true,
                                      color: Colors.grey,
                                      barWidth: 2,
                                      dotData: const FlDotData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Buy/Sell Buttons
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Buy',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Sell',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Action Buttons
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Recurring buy', Icons.refresh),
                        _buildActionButton('Limit order', Icons.show_chart),
                        _buildActionButton('More', Icons.more_horiz),
                      ],
                    ),
                    // What is Shiba Inu Section
                    const SizedBox(height: 24),
                    const Text(
                      'What is Shiba Inu?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Shiba Inu is a token that aspires to be an Ethereum-based alternative to Dogecoin, the popular memecoin. Unlike Bitcoin, which is designed to be scarce, SHIB is intentionally abundant — with a total supply of one quadrillion.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatColumn(String value, String label, {bool isProfit = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isProfit ? Colors.green : Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTimeButton(String text,
      {bool isSelected = false, required VoidCallback onPressed}) {
    return SizedBox(
      width: 45,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void updateChartData(String period) {
    setState(() {
      selectedPeriod = period;
    });
    getChartData(period);
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class PriceAndTime {
  final int time;
  final double price;

  PriceAndTime({required this.time, required this.price});
}
