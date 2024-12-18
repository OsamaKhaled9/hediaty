import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';

class GiftListItem extends StatefulWidget {
  final Gift gift;
  final VoidCallback? onPublish; // Nullable callbacks
  final VoidCallback? onEdit; // Nullable callbacks
  final VoidCallback? onPledge; // Nullable callbacks
  final VoidCallback? onPurchase; // Added for Purchase action

  const GiftListItem({
    Key? key,
    required this.gift,
    this.onPublish,
    this.onEdit,
    this.onPledge,
    this.onPurchase, // Nullable callback
  }) : super(key: key);

  @override
  _GiftListItemState createState() => _GiftListItemState();
}

class _GiftListItemState extends State<GiftListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPublished = false;

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
          .collection('gifts')
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
      return Colors.amber;
    }
  }

  Widget _buildActionButton() {
    if (!_isPublished) {
      return ElevatedButton(
        onPressed: widget.onPublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
        ),
        child: const Text("Publish"),
      );
    } else if (widget.gift.status == "Published") {
      return ElevatedButton(
        onPressed: widget.onPledge,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: const Text("Pledge"),
      );
    } else if (widget.gift.status == "Pledged") {
      return ElevatedButton(
        onPressed: widget.onPurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text("Mark as Purchased"),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: widget.onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border.all(color: _getBorderColor(), width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
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
                Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    widget.gift.imagePath,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Align(
                          alignment: Alignment.bottomRight,
                          child: _buildActionButton(),
                        ),
                      ],
                    ),
                  ),
                ),
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
      ),
    );
  }
}


