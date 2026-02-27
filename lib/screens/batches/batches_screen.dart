import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'batch_details_screen.dart';
import 'add_batch_screen.dart';

class Batch {
  final String id;
  final String name;
  final String age;
  final int totalChicks;
  final int sold;
  final int mortality;
  final int live;

  Batch({
    required this.id,
    required this.name,
    required this.age,
    required this.totalChicks,
    required this.sold,
    required this.mortality,
    required this.live,
  });

  static List<Batch> getSampleBatches() {
    return [
      Batch(
        id: '1',
        name: 'Batch A',
        age: '2 weeks: 3 days',
        totalChicks: 1100,
        sold: 1000,
        mortality: 0,
        live: 100,
      ),
      Batch(
        id: '2',
        name: 'Batch B',
        age: '1 week: 5 days',
        totalChicks: 800,
        sold: 200,
        mortality: 10,
        live: 590,
      ),
      Batch(
        id: '3',
        name: 'Batch C',
        age: '3 weeks: 1 day',
        totalChicks: 1500,
        sold: 1200,
        mortality: 50,
        live: 250,
      ),
    ];
  }
}

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({super.key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  final List<Batch> _batches = Batch.getSampleBatches();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Batches',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Batches list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _batches.length,
                itemBuilder: (context, index) {
                  return _buildBatchCard(_batches[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBatchScreen(),
            ),
          );
          
          if (result != null) {
            // Add the new batch to the list
            setState(() {
              _batches.add(Batch(
                id: '${_batches.length + 1}',
                name: result['name'],
                age: '0 days',
                totalChicks: result['totalChicks'],
                sold: 0,
                mortality: 0,
                live: result['totalChicks'],
              ));
            });
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BatchDetailsScreen(batchId: batch.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch.age,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem('Total:', '${batch.totalChicks}', AppColors.primary),
                const SizedBox(width: 12),
                _buildStatItem('Sold:', '${batch.sold}', AppColors.textSecondary),
                const SizedBox(width: 12),
                _buildStatItem('Mortality:', '${batch.mortality}', Colors.red),
                const SizedBox(width: 12),
                _buildStatItem('Live:', '${batch.live}', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
