import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ReadingScreen extends StatefulWidget {
  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Book Creation Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetDaysController = TextEditingController();

  // Book Progress Logging Controllers
  final TextEditingController _pagesReadController = TextEditingController();

  // Method to add a new book
  void _addBook() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('books').add({
        'name': _nameController.text,
        'totalPages': int.parse(_pagesController.text),
        'description': _descriptionController.text,
        'targetDays': _targetDaysController.text.isNotEmpty 
            ? int.parse(_targetDaysController.text) 
            : null,
        'pagesRead': 0,
        'progress': 0.0,
        'dailyTasks': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear controllers and close dialog
      _nameController.clear();
      _pagesController.clear();
      _descriptionController.clear();
      _targetDaysController.clear();
      Navigator.of(context).pop();
    }
  }

  // Method to log daily progress
  void _logProgress(DocumentSnapshot book) async {
    int pagesRead = int.parse(_pagesReadController.text);
    int totalPages = book['totalPages'];

    if (pagesRead + book['pagesRead'] <= totalPages) {
      await _firestore.collection('books').doc(book.id).update({
        'pagesRead': FieldValue.increment(pagesRead),
        'progress': ((book['pagesRead'] + pagesRead) / totalPages) * 100,
        'dailyTasks': FieldValue.arrayUnion([
          {
            'date': DateTime.now().toIso8601String(),
            'pagesRead': pagesRead,
          }
        ])
      });

      _pagesReadController.clear();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot exceed total pages'))
      );
    }
  }

  // Method to delete a book
  void _deleteBook(String bookId) {
    _firestore.collection('books').doc(bookId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showBookCreationDialog(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var book = snapshot.data!.docs[index];
              return _buildBookCard(book);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(DocumentSnapshot book) {
    double progress = (book['pagesRead'] / book['totalPages']) * 100;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title and Pages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${book['pagesRead']} / ${book['totalPages']} pages',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.details, color: Colors.blue),
                      onPressed: () => _navigateToBookDetails(book),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBook(book.id),
                    ),
                  ],
                ),
              ],
            ),
          
            // Horizontal Progress Bar
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 50 
                  ? Colors.orange 
                  : progress < 75 
                    ? Colors.amber 
                    : Colors.green
              ),
              minHeight: 10,
            ),
          
            // Progress Percentage
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${progress.toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  void _showBookCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Book'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Book Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _pagesController,
                decoration: InputDecoration(labelText: 'Total Pages'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _targetDaysController,
                decoration: InputDecoration(labelText: 'Target Days'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Add Book'),
            onPressed: _addBook,
          ),
        ],
      ),
    );
  }

  void _navigateToBookDetails(DocumentSnapshot book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  Widget buildBookCard(DocumentSnapshot book) {
    double progress = (book['pagesRead'] / book['totalPages']) * 100;

    return Card(
      child: ListTile(
        title: Text(book['name']),
        subtitle: Text('${book['pagesRead']} / ${book['totalPages']} pages'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 5.0,
              percent: progress / 100,
              center: Text('${progress.toStringAsFixed(0)}%'),
              progressColor: Colors.blue,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteBook(book.id),
            ),
            IconButton(
              icon: Icon(Icons.details),
              onPressed: () => _navigateToBookDetails(book),
            ),
          ],
        ),
      ),
    );
  }
}
class BookDetailsPage extends StatelessWidget {
  final DocumentSnapshot book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['name']),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: (book['pagesRead'] / book['totalPages']),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${((book['pagesRead'] / book['totalPages']) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${book['pagesRead']} / ${book['totalPages']} pages',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  progressColor: Colors.green,
                ),
              ),
              SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text('Total Pages: ${book['totalPages']}'),
                      if (book['description'] != null && book['description'].isNotEmpty)
                        Text('Description: ${book['description']}'),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ElevatedButton(
                  child: Text('Log Progress'),
                  onPressed: () => _showProgressLogDialog(context, book),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),

              Text(
                'Daily Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: book['dailyTasks'].length > 0
                    ? ListView.builder(
                        itemCount: book['dailyTasks'].length,
                        itemBuilder: (context, index) {
                          var task = book['dailyTasks'][index];
                          return Card(
                            child: ListTile(
                              title: Text('Day ${index + 1}: Read ${task['pagesRead']} pages'),
                              subtitle: Text(
                                task['date'],
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No daily tasks yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgressLogDialog(BuildContext context, DocumentSnapshot book) {
    final TextEditingController _pagesReadController = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Progress'),
        content: TextField(
          controller: _pagesReadController,
          decoration: InputDecoration(
            labelText: 'Pages Read Today',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Log'),
            onPressed: () {
              int pagesRead = int.parse(_pagesReadController.text);
              int totalPages = book['totalPages'];

              if (pagesRead + book['pagesRead'] <= totalPages) {
                _firestore.collection('books').doc(book.id).update({
                  'pagesRead': FieldValue.increment(pagesRead),
                  'progress': ((book['pagesRead'] + pagesRead) / totalPages) * 100,
                  'dailyTasks': FieldValue.arrayUnion([
                    {
                      'date': DateTime.now().toIso8601String(),
                      'pagesRead': pagesRead,
                    }
                  ])
                });

                _pagesReadController.clear();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot exceed total pages'))
                );
              }
            },
          ),
        ],
      ),
    );
  }
}