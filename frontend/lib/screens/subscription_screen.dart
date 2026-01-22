import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/subscription_model.dart';

/// 구독 화면 (토핑 모듈)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final Set<String> _selectedToppings = {};

  final List<SubscriptionToppingModel> _toppings = [
    SubscriptionToppingModel(
      id: 'causality',
      name: '인과관계 분석',
      description: '뉴스 속 원인과 결과를 AI가 분석합니다',
      icon: '🔗',
      price: 5000,
      isPopular: true,
    ),
    SubscriptionToppingModel(
      id: 'insight',
      name: '투자 인사이트',
      description: '투자 관점의 핵심 정보를 제공합니다',
      icon: '💡',
      price: 8000,
      isPopular: true,
    ),
    SubscriptionToppingModel(
      id: 'alert',
      name: '실시간 알림',
      description: '중요 뉴스를 실시간으로 알려드립니다',
      icon: '🔔',
      price: 3000,
    ),
    SubscriptionToppingModel(
      id: 'premium',
      name: '프리미엄 리포트',
      description: '심층 분석 리포트를 매주 제공합니다',
      icon: '📊',
      price: 12000,
    ),
  ];

  int get _totalPrice {
    return _selectedToppings.fold(0, (sum, id) {
      final topping = _toppings.firstWhere((t) => t.id == id);
      return sum + topping.price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('구독 관리')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _toppings.length,
              itemBuilder: (context, index) {
                final topping = _toppings[index];
                final isSelected = _selectedToppings.contains(topping.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedToppings.add(topping.id);
                        } else {
                          _selectedToppings.remove(topping.id);
                        }
                      });
                    },
                    secondary: Text(topping.icon, style: const TextStyle(fontSize: 32)),
                    title: Row(
                      children: [
                        Text(topping.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (topping.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('인기', style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(topping.description),
                        const SizedBox(height: 4),
                        Text('월 ${topping.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),

          // 결제 하단바
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('총 ${_selectedToppings.length}개 선택', style: Theme.of(context).textTheme.bodySmall),
                      Text('월 ${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedToppings.isEmpty ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구독 기능은 추후 구현됩니다')));
                  },
                  child: const Text('구독하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
