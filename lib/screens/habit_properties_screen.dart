import 'package:flutter/material.dart';
import '../habit_model.dart';

class HabitPropertiesScreen extends StatefulWidget {
  final Habit habit;
  final Function(Habit) onHabitUpdated;

  const HabitPropertiesScreen({
    Key? key,
    required this.habit,
    required this.onHabitUpdated,
  }) : super(key: key);

  @override
  State<HabitPropertiesScreen> createState() => _HabitPropertiesScreenState();
}

class _HabitPropertiesScreenState extends State<HabitPropertiesScreen> {
  late TextEditingController _whereAndWhenController;
  late TextEditingController _bareMinimumController;
  late TextEditingController _desirableLevelController;
  late TextEditingController _makeEasyAndObviousController;

  @override
  void initState() {
    super.initState();
    _whereAndWhenController = TextEditingController(text: widget.habit.whereAndWhen ?? '');
    _bareMinimumController = TextEditingController(text: widget.habit.bareMinimum ?? '');
    _desirableLevelController = TextEditingController(text: widget.habit.desirableLevel ?? '');
    _makeEasyAndObviousController = TextEditingController(text: widget.habit.makeEasyAndObvious ?? '');
  }

  @override
  void dispose() {
    _whereAndWhenController.dispose();
    _bareMinimumController.dispose();
    _desirableLevelController.dispose();
    _makeEasyAndObviousController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    final updatedHabit = Habit(
      id: widget.habit.id,
      name: widget.habit.name,
      history: widget.habit.history,
      streak: widget.habit.streak,
      points: widget.habit.points,
      solidLevel: widget.habit.solidLevel,
      consecutiveMisses: widget.habit.consecutiveMisses,
      whereAndWhen: _whereAndWhenController.text.trim(),
      bareMinimum: _bareMinimumController.text.trim(),
      desirableLevel: _desirableLevelController.text.trim(),
      makeEasyAndObvious: _makeEasyAndObviousController.text.trim(),
    );
    
    widget.onHabitUpdated(updatedHabit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  widget.habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Aleo',
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak and Points Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              '🔥',
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.habit.streak}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Aleo',
                              ),
                            ),
                            Text(
                              'Streak',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Aleo',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              '⭐',
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.habit.points}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Aleo',
                              ),
                            ),
                            Text(
                              'Points',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Aleo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Framework Section
                  const Text(
                    'Framework',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Aleo',
                      letterSpacing: 0.2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Where and When
                  _buildPropertyField(
                    controller: _whereAndWhenController,
                    label: 'Where and When',
                    hint: 'e.g., In my bedroom, right after I wake up at 7 AM',
                    icon: Icons.schedule,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bare Minimum
                  _buildPropertyField(
                    controller: _bareMinimumController,
                    label: 'Bare Minimum',
                    hint: 'e.g., Just 1 push-up',
                    icon: Icons.minimize,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Desirable Level
                  _buildPropertyField(
                    controller: _desirableLevelController,
                    label: 'Desirable Level',
                    hint: 'e.g., 20 push-ups',
                    icon: Icons.trending_up,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Make Easy and Obvious
                  _buildPropertyField(
                    controller: _makeEasyAndObviousController,
                    label: 'Make Easy and Obvious',
                    hint: 'e.g., Keep workout clothes by my bed',
                    icon: Icons.visibility,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Aleo',
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Aleo',
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Aleo',
            fontWeight: FontWeight.w400,
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.w300,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.tealAccent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
} 