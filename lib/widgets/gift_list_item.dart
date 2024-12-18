import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';

class GiftListItem extends StatefulWidget {
  final Gift gift;
  final VoidCallback onPublish;
  final VoidCallback onEdit;
  final VoidCallback onPledge;

  const GiftListItem({
    Key? key,
    required this.gift,
    required this.onPublish,
    required this.onEdit,
    required this.onPledge,
  }) : super(key: key);

  @override
  _GiftListItemState createState() => _GiftListItemState();
}

class _GiftListItemState extends State<GiftListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPublished = false; // Track if the gift is published

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkIfPublished();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkIfPublished() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gifts') // Adjust collection name as needed
          .where('name', isEqualTo: widget.gift.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isPublished = true;
        });
      }
    } catch (e) {
      print("Error checking gift publication status: $e");
    }
  }

  Color _getBorderColor() {
    if (_isPublished) {
      return widget.gift.status == "Pledged" ? Colors.green : Colors.blue;
    } else {
      return Colors.amber; // Not published
    }
  }

  Widget _buildPublishButton() {
    if (!_isPublished) {
      return ElevatedButton(
        onPressed: widget.onPublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
        ),
        child: const Text("Publish"),
      );
    } else if (widget.gift.status == "Available") {
      return ElevatedButton(
        onPressed: widget.onPledge,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: const Text("Pledge"),
      );
    }
    return Text(
      "Status: ${widget.gift.status}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onEdit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: _getBorderColor(), width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image with Opacity
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  widget.gift.imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Overlay Details
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gift Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gift.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.white,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Category: ${widget.gift.category}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.white,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${widget.gift.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.white,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Publish or Pledge Button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _buildPublishButton(),
                      ),
                    ],
                  ),
                ),
              ),

              // Edit Icon
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.white,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
