import 'package:flutter/material.dart';
import 'services/voting_service.dart';

class CandidateManagementScreen extends StatefulWidget {
  const CandidateManagementScreen({super.key});

  @override
  State<CandidateManagementScreen> createState() =>
      _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen> {
  List<Map<String, dynamic>> _candidates = List.from(VotingService.candidates);
  final _formKey = GlobalKey<FormState>();
  String _selectedPosition = 'President';
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addCandidate() {
    if (_formKey.currentState!.validate()) {
      final newCandidate = {
        'id':
            '${_selectedPosition.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        'name': _nameController.text,
        'year': _yearController.text,
        'position': _selectedPosition,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : "https://picsum.photos/id/${DateTime.now().millisecondsSinceEpoch % 1000}/150/150",
      };

      setState(() {
        _candidates.add(newCandidate);
        VotingService.candidates = _candidates; // Update the service
      });

      _clearForm();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate added successfully')),
      );
    }
  }

  void _removeCandidate(int index) {
    setState(() {
      _candidates.removeAt(index);
      VotingService.candidates = _candidates; // Update the service
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Candidate removed successfully')),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _yearController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
  }

  void _showAddCandidateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Candidate'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: const InputDecoration(labelText: 'Position'),
                  items: ['President', 'Vice-President', 'Secretary']
                      .map(
                        (position) => DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value!;
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a year' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    hintText: 'Leave empty for random image',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addCandidate, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Candidates',
          style: TextStyle(
            color: Color(0xFF2E3A8C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2E3A8C)),
            onPressed: _showAddCandidateDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _candidates.length,
          itemBuilder: (context, index) {
            final candidate = _candidates[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(candidate['imageUrl']),
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
                title: Text(candidate['name']),
                subtitle: Text(
                  '${candidate['position']} - ${candidate['year']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCandidate(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
