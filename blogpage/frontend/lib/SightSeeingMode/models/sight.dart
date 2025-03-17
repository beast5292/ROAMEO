
//Sight object holding all the sights
class Sight {

  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final double? lat;
  final double? long;
  final List<String> imageUrls;

  //constructor
  Sight({
      required this.id,
      required this.name,
      required this.description,
      required this.tags,
      required this.lat,
      required this.long,
      required this.imageUrls, 
  });

  // Override the toString method to customize the print format
  @override
  String toString() {
    return 'Sight Info: {'
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'tags: ${tags.join(', ')}, '
        'lat: $lat, '
        'long: $long, '
        'imageUrls: ${imageUrls.join(', ')}'
        '}';
  }

}
