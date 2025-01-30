import 'package:flutter/material.dart';
import 'package:homepage/components/location_list_tile.dart';
import 'package:homepage/components/network_utility.dart';
import 'package:homepage/models/autocomplate_prediction.dart';
import 'package:homepage/models/place_auto_complate_response.dart';

import 'constants.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

final apiKey = "AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0";

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePrediction> placePredictions = [];

  void placeAutocompleter(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": apiKey,
    });

    String? response = await NetworkUtiliti.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: Icon(
              Icons.location_on,
              color: secondaryColor40LightTheme,
            ),
          ),
        ),
        title: const Text(
          "Set Delivery Location",
          style: TextStyle(color: textColorLightTheme),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          const SizedBox(width: defaultPadding)
        ],
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                onChanged: (value) {
                  placeAutocompleter(value);
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search your location",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.place,
                      color: secondaryColor40LightTheme,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.my_location,
                color: secondaryColor40LightTheme,
              ),
              label: const Text("Use my Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor10LightTheme,
                foregroundColor: textColorLightTheme,
                elevation: 0,
                fixedSize: const Size(double.infinity, 40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),

          Expanded(
            child: ListView.builder(
            
              itemCount: placePredictions.length,
              itemBuilder: (context, index) => LocationListTile(
              press: () {},
              location: placePredictions[index].description!, 
              ),
            ),
          )
          
        ],
      ),
    );
  }
}
