import 'package:flutter/material.dart';
import 'package:hediaty/core/models/gift.dart';

class GiftListItem extends StatefulWidget {
  final Gift gift;
  final VoidCallback? onPublish;
  final VoidCallback? onEdit;
  final VoidCallback? onPledge;
  final VoidCallback? onPurchase;

  const GiftListItem({
    Key? key,
    required this.gift,
    this.onPublish,
    this.onEdit,
    this.onPledge,
    this.onPurchase,
  }) : super(key: key);

  @override
  _GiftListItemState createState() => _GiftListItemState();
}

class _GiftListItemState extends State<GiftListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    switch (widget.gift.status) {
      case "Published":
        return Colors.blue;
      case "Pledged":
        return Colors.green;
      case "Purchased":
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  Widget _buildActionButton() {
    if (widget.gift.status == "Available") {
      return ElevatedButton(
        onPressed: widget.onPublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
        ),
        child: const Text("Publish"),
      );
    } else if (widget.gift.status == "Published") {
      return ElevatedButton(
        key: const Key('PledgeButton'), // Add a unique key here
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
                    child: Image.network(
                      widget.gift.imagePath, // Attempt to load the image from the network
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Return the image if successfully loaded
                        }
                        return Center(
                          child: CircularProgressIndicator(), // Show a loading spinner while the image loads
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default_gift.png', // Fallback to asset image if loading fails
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
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
                if (widget.onEdit != null)
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
