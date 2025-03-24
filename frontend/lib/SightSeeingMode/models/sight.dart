
//Sight object holding all the sights
class Sight {
  
  String modeName;
  String modeDescription;
  final String username;
  final String id;
  String? name;
  String? description;
  List<String>? tags;
  final double? lat;
  final double? long;
  List<String> imageUrls;


  //constructor
  Sight({
      required this.modeName,
      required this.modeDescription,
      required this.username,
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
        'modeName: $modeName,'
        'modeDescription: $modeDescription,'
        'username: $username,'
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'tags: ${tags!.join(', ')}, '
        'lat: $lat, '
        'long: $long, '
        'imageUrls: ${imageUrls.join(', ')}'
        '}';
  }

}
