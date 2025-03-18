import 'package:flutter/material.dart';

class DestinationInfoBox extends StatelessWidget {
  final String name;
  final String description;
  final String imageurl;

  const DestinationInfoBox({
    Key? key,
    required this.name,
    required this.description,
    required this.imageurl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Display the image from the URL
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageurl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageurl,
                      fit: BoxFit.cover, // Ensure the image covers the container
                      width: double.infinity, // Take up full width
                      height: 100, // Match container height
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                  ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}