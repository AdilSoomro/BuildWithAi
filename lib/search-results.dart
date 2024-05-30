import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:http/http.dart' as http;

class SearchResults extends StatefulWidget {
  const SearchResults({super.key, required this.title});

  final String title;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {

  late GenerativeModel geminiModel;
  final apiKey = "YOUR_OWN_API_KEY";

  TextEditingController inputController = TextEditingController();

  String _geminiResponse = "";
  bool _loading = false;
  final List<Message> _messages = [];
  @override
  void initState() {
    super.initState();
    // geminiModel = GenerativeModel(model: "gemini-pro-vision", apiKey: apiKey);
    geminiModel = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
  }

  Future<void> _askGemini() async {
    String text = inputController.text;

    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, Message(text: text, isCurrentUser: true));
      _loading = true;
    });
    List<Part> promptParts = [

      TextPart("you are assisting me in writing a POST query for a real estate app from understanding the user input. \nThe states we work in are as below in json:\n\n[\n  {\n    \"term_id\": 21,\n    \"name\": \"California\",\n    \"slug\": \"california\"\n  },\n  {\n    \"term_id\": 124,\n    \"name\": \"California / Los Angeles County\",\n    \"slug\": \"california-los-angeles-county\"\n  },\n  {\n    \"term_id\": 543,\n    \"name\": \"Cook County\",\n    \"slug\": \"cook-county\"\n  },\n  {\n    \"term_id\": 27,\n    \"name\": \"Florida\",\n    \"slug\": \"florida\"\n  },\n  {\n    \"term_id\": 34,\n    \"name\": \"Illinois\",\n    \"slug\": \"illinois\"\n  },\n  {\n    \"term_id\": 44,\n    \"name\": \"New York\",\n    \"slug\": \"new-york\"\n  },\n  {\n    \"term_id\": 504,\n    \"name\": \"Punjab\",\n    \"slug\": \"punjab\"\n  },\n  {\n    \"term_id\": 525,\n    \"name\": \"Texas\",\n    \"slug\": \"texas\"\n  }\n]\nThe cities we work in are as below in json:\n\n[\n  {\n    \"term_id\": 23,\n    \"name\": \"Chicago\",\n    \"slug\": \"chicago\"\n  },\n  {\n    \"term_id\": 85,\n    \"name\": \"Lahore\",\n    \"slug\": \"lahore\"\n  },\n  {\n    \"term_id\": 37,\n    \"name\": \"Los Angeles\",\n    \"slug\": \"los-angeles\"\n  },\n  {\n    \"term_id\": 39,\n    \"name\": \"Miami\",\n    \"slug\": \"miami\"\n  },\n  {\n    \"term_id\": 81,\n    \"name\": \"Mountain View\",\n    \"slug\": \"mountain-view\"\n  },\n  {\n    \"term_id\": 45,\n    \"name\": \"New York\",\n    \"slug\": \"new-york\"\n  },\n  {\n    \"term_id\": 88,\n    \"name\": \"Palo Alto\",\n    \"slug\": \"palo-alto\"\n  }\n]\nThe property types we deal in are as below:\n\n\n[\n  {\n    \"term_id\": 71,\n    \"name\": \"Apartment\",\n    \"slug\": \"apartment\"\n  },\n  {\n    \"term_id\": 25,\n    \"name\": \"Commercial\",\n    \"slug\": \"commercial\"\n  },\n  {\n    \"term_id\": 72,\n    \"name\": \"Condo\",\n    \"slug\": \"condo\"\n  },\n  {\n    \"term_id\": 73,\n    \"name\": \"Multi Family Home\",\n    \"slug\": \"multi-family-home\"\n  },\n  {\n    \"term_id\": 47,\n    \"name\": \"Office\",\n    \"slug\": \"office\"\n  },\n  {\n    \"term_id\": 55,\n    \"name\": \"Residential\",\n    \"slug\": \"residential\"\n  },\n  {\n    \"term_id\": 58,\n    \"name\": \"Shop\",\n    \"slug\": \"shop\"\n  },\n  {\n    \"term_id\": 59,\n    \"name\": \"Single Family Home\",\n    \"slug\": \"single-family-home\"\n  },\n  {\n    \"term_id\": 61,\n    \"name\": \"Studio\",\n    \"slug\": \"studio\"\n  },\n  {\n    \"term_id\": 65,\n    \"name\": \"Villa\",\n    \"slug\": \"villa\"\n  },\n  {\n    \"term_id\": 176,\n    \"name\": \"Warehouse\",\n    \"slug\": \"warehouse\"\n  }\n]\nThe property features that we have are as below:\n\n\n[\n  {\n    \"term_id\": 12,\n    \"name\": \"Air Conditioning\",\n    \"slug\": \"air-conditioning\"\n  },\n  {\n    \"term_id\": 16,\n    \"name\": \"Barbeque\",\n    \"slug\": \"barbeque\"\n  },\n  {\n    \"term_id\": 26,\n    \"name\": \"Dryer\",\n    \"slug\": \"dryer\"\n  },\n  {\n    \"term_id\": 31,\n    \"name\": \"Gym\",\n    \"slug\": \"gym\"\n  },\n  {\n    \"term_id\": 35,\n    \"name\": \"Laundry\",\n    \"slug\": \"laundry\"\n  },\n  {\n    \"term_id\": 36,\n    \"name\": \"Lawn\",\n    \"slug\": \"lawn\"\n  },\n  {\n    \"term_id\": 40,\n    \"name\": \"Microwave\",\n    \"slug\": \"microwave\"\n  },\n  {\n    \"term_id\": 50,\n    \"name\": \"Outdoor Shower\",\n    \"slug\": \"outdoor-shower\"\n  },\n  {\n    \"term_id\": 53,\n    \"name\": \"Refrigerator\",\n    \"slug\": \"refrigerator\"\n  },\n  {\n    \"term_id\": 56,\n    \"name\": \"Sauna\",\n    \"slug\": \"sauna\"\n  },\n  {\n    \"term_id\": 62,\n    \"name\": \"Swimming Pool\",\n    \"slug\": \"swimming-pool\"\n  },\n  {\n    \"term_id\": 63,\n    \"name\": \"TV Cable\",\n    \"slug\": \"tv-cable\"\n  },\n  {\n    \"term_id\": 66,\n    \"name\": \"Washer\",\n    \"slug\": \"washer\"\n  },\n  {\n    \"term_id\": 68,\n    \"name\": \"WiFi\",\n    \"slug\": \"wifi\"\n  },\n  {\n    \"term_id\": 69,\n    \"name\": \"Window Coverings\",\n    \"slug\": \"window-coverings\"\n  }\n]\nThe property statuses are as below:\n\n\n[\n  {\n    \"term_id\": 28,\n    \"name\": \"For Rent\",\n    \"slug\": \"for-rent\"\n  },\n  {\n    \"term_id\": 29,\n    \"name\": \"For Sale\",\n    \"slug\": \"for-sale\"\n  }\n]\n\nThe property labels are as below: \n\n\n[\n  {\n    \"term_id\": 474,\n    \"name\": \"Golden Offer\",\n    \"slug\": \"golden-offer\"\n  },\n  {\n    \"term_id\": 32,\n    \"name\": \"Hot Offer\",\n    \"slug\": \"hot-offer\"\n  },\n  {\n    \"term_id\": 48,\n    \"name\": \"Open House\",\n    \"slug\": \"open-house\"\n  },\n  {\n    \"term_id\": 60,\n    \"name\": \"Sold\",\n    \"slug\": \"sold\"\n  }\n]\n\nYour job is provide entities to construct POST query. Only include state, city, property type, property status, property label and property features mentioned above in your response. Anything that is included in the above data should be considered as keyword."),
      TextPart("I'm looking for villa in miami with suana and window coverings"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"villa\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"miami\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"sauna\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"window-coverings\"\n}\n]"),
      TextPart("Show me small multi family homes in los angels available for rent with air conditioning having 5 beds and 3 baths, parking will be nice."),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-rent\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"multi-family-home\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"los-angeles\"\n},\n{\n\"post_var\":\"max_area\",\n\"post_var_value\":\"1000\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"air-conditioning\"\n},\n{\n\"post_var\":\"label[]\",\n\"post_var_value\":\"golden-offer\"\n},\n{\n\"post_var\":\"bedroom\",\n\"post_var_value\":\"5\"\n},\n{\n\"post_var\":\"bathroom\",\n\"post_var_value\":\"3\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"beautiful, parking, modern\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"beautiful, parking, modern\"\n}\n]"),
      TextPart("Can you show me single-family homes for sale in Los Angeles with at least 3 bedrooms and 2 bathrooms?"),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-sale\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"single-family-home\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"los-angeles\"\n},\n{\n\"post_var\":\"bedroom\",\n\"post_var_value\":\"3\"\n},\n{\n\"post_var\":\"bathroom\",\n\"post_var_value\":\"2\"\n}\n]"),
      TextPart("Are there any apartments for rent in Chicago with a balcony, under \$1,500 per month?"),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-rent\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"chicago\"\n},\n{\n\"post_var\":\"max_price\",\n\"post_var_value\":\"1500\"\n}\n]"),
      TextPart("I'm looking for land in Florida with a minimum size of 1 acre. Are there any current listings?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"land\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"florida\"\n},\n{\n\"post_var\":\"max_area\",\n\"post_var_value\":\"43560\"\n}\n]"),
      TextPart("Are there any open houses this weekend for properties with pools in the Bay Area?"),
      TextPart("[\n{\n\"post_var\":\"label[]\",\n\"post_var_value\":\"open-house\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"pool\"\n}\n]"),
      TextPart("Show me all commercial properties for sale, including shops and offices, in New York City with a minimum area of 100 square meters."),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"shop\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"office\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"new-york\"\n},\n{\n\"post_var\":\"min_area\",\n\"post_var_value\":\"1076.39\"\n}\n]"),
      TextPart("Can you recommend any properties with a hot offer listing in miami?"),
      TextPart("[\n{\n\"post_var\":\"label[]\",\n\"post_var_value\":\"hot-offer\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"miami\"\n}\n]"),
      TextPart("I'm interested in a single-family home with a dishwasher and a yard. Are there any in California priced between \$200,000 and \$500,000?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"single-family-home\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"dishwasher\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"yard\"\n},\n{\n\"post_var\":\"state[]\",\n\"post_var_value\":\"california\"\n},\n{\n\"post_var\":\"min_price\",\n\"post_var_value\":\"200,000\"\n},\n{\n\"post_var\":\"max_price\",\n\"post_var_value\":\"500,000\"\n}\n]"),
      TextPart("Are there any recently built apartments (less than 2 years old) with at least 2 bedrooms and floor-to-ceiling windows available for rent?"),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-rent\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"windows\"\n},\n{\n\"post_var\":\"bedroom\",\n\"post_var_value\":\"2\"\n}\n]"),
      TextPart("Can you filter properties based on features like a sauna or an outdoor shower?"),
      TextPart("[\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"suana\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"outdoor-shower\"\n}\n]"),
      TextPart("Are there any pet-friendly houses for rent in my area with a fenced yard? Ideally, 2 bedrooms and under \$1,200 monthly."),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-rent\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"house\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"pet-friendly\"\n},\n{\n\"post_var\":\"bedroom\",\n\"post_var_value\":\"2\"\n},\n{\n\"post_var\":\"max_price\",\n\"post_var_value\":\"2000\"\n}\n]"),
      TextPart("Can you show me recently renovated apartments with modern kitchens (stainless steel appliances, granite countertops) in Chicago priced between \$1,800 and \$2,500?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"pet-friendly\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"renovated modern kitchen stainless steel appliances, granite countertops\"\n},\n{\n\"post_var\":\"min_price\",\n\"post_var_value\":\"1800\"\n},\n{\n\"post_var\":\"max_price\",\n\"post_var_value\":\"2500\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"chicago\"\n}\n]"),
      TextPart("Are there any historical homes for sale in any area with at least 3 bedrooms and a lot of character (e.g., exposed brick, fireplaces)?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"home\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"pet-friendly\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"historical, fireplaces, exposed brick\"\n},\n{\n\"post_var\":\"bedroom\",\n\"post_var_value\":\"3\"\n}\n]"),
      TextPart("Show me all available commercial properties for lease that are move-in ready, with good access for deliveries (e.g., loading dock)."),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-lease\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"commercial\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"loading-dock\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"move-in ready\"\n}\n]"),
      TextPart("I'm interested in a property with a finished basement that could be used as a home office. Are there any options in chicago illinois under \$400,000?"),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-sale\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"home\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"basement\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"home office\"\n},\n{\n\"post_var\":\"location[]\",\n\"post_var_value\":\"chicago\"\n},\n{\n\"post_var\":\"state[]\",\n\"post_var_value\":\"illinois\"\n}\n]"),
      TextPart("Can you recommend eco-friendly properties with features like solar panels or energy-efficient appliances?"),
      TextPart("[\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"solar-panel\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"eco friendly, energy efficient appliances\"\n}\n]"),
      TextPart("I'm looking for a property with a view. Can you find any apartments or houses for rent with a balcony overlooking a park or the city skyline?"),
      TextPart("[\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-rent\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"home\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"balcony\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"park\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"city skyline\"\n}\n]"),
      TextPart("Are there any listings for properties with a dedicated workspace, ideal for working from home? This could be a den, converted garage, or separate office space."),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"home\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"garage\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"work from home, working from home, workspace converted garage\"\n}\n]"),
      TextPart("Can you recommend properties in walkable areas with easy access to public transportation (subway, bus lines)?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"residential\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"subway bus line public transport\"\n}\n]"),
      TextPart("I'm looking for a property with smart home features, like a smart thermostat or doorbell. Can you find any options that fit this criteria?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"home\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"thermostate\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"doorbell\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"smart home features\"\n}\n]"),
      TextPart("Show me all available studios or one-bedroom apartments for rent that allow short-term leases (less than 6 months)."),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"studio\"\n},\n{\n\"post_var\":\"status[]\",\n\"post_var_value\":\"for-lease\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"doorbell\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"lease\"\n}\n]"),
      TextPart("I'm interested in a property with a fireplace for cozy nights. Can you filter your search to include this feature?"),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"residential\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"fireplace\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"cozy nights\"\n}\n]"),
      TextPart("Are there any listings for historic buildings converted into modern apartments or lofts? This could be a factory, warehouse, or school building."),
      TextPart("[\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"residential\"\n},\n{\n\"post_var\":\"type[]\",\n\"post_var_value\":\"apartment\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"modern historic\"\n}\n]"),
      TextPart("Can you show me any properties with unique architectural styles, like Victorian, mid-century modern, or Spanish Colonial?"),
      TextPart("[\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"architectural styles victorian, mid-century modern spanish colonia\"\n}\n]"),
      TextPart("Are there any listings for properties with a security system already installed? This could be a monitored system or a self-monitored option."),
      TextPart("[\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"security-system\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"security system\"\n}\n]"),
      TextPart("Can you filter your search results to show only properties with ample storage space, like walk-in closets or built-in bookshelves?"),
      TextPart("[\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"walk-in-closet\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"bookshelves\"\n},\n{\n\"post_var\":\"keyword\",\n\"post_var_value\":\"ample storage space\"\n}\n]"),
      TextPart("Are there any listings for properties with a community garden or rooftop terrace, perfect for outdoor lounging or socializing?"),
      TextPart("[\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"community-garden\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"rooftop-terrace\"\n},\n{\n\"post_var\":\"features[]\",\n\"post_var_value\":\"terrace\"\n}\n]"),
    ];

    final textPart = TextPart(text);
    promptParts.add(textPart);

    final promptContent = Content.multi(promptParts);

    final contents = [promptContent];
    var response = await geminiModel.generateContent(contents);
    _geminiResponse = response.text!;

    var articles = await doAnApiRequest(_geminiResponse);

    Message gemMessage = Message(text:articles.isNotEmpty ? "Here you go" : "We couldn't find any", isCurrentUser: false);
    gemMessage.articles = articles;

    _messages.insert(0, gemMessage);
    inputController.text = "";
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Gemini helps searching"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessage(message);
                  },
                ),
              ),
            ),
            if (_loading) CircularProgressIndicator(),
            if (!_loading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 4,
                        controller: inputController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _askGemini,
                    ),
                  ],
                ),
              ),
          ],
        )

      )
    );
  }
  Widget _buildMessage(Message message) {
    if (message.isCurrentUser) {
      final alignment = message.isCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft;
      final color = message.isCurrentUser ? Colors.blue[100] : Colors.grey[200];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: alignment,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(message.text),
          ),
        ),
      );
    } else {
      return _buildArticleList(message);
    }
  }
  Widget _buildArticleList(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Text(message.text),
            )
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: message.articles.length,
                itemBuilder: (BuildContext ctx, int index) {
                Article article = message.articles[index];
                    // return Text(article.title!);
                    return PropertyListItem(
                      title: article.title!,
                      size: article.size!,
                      bedrooms: article.bedroom!,
                      bathrooms: article.bathroom!,
                      imageUrl: article.image!,
                    );
                }),
          ),
        ],
      )
      );

  }
}

class PropertyListItem extends StatelessWidget {
  final String title;
  final String size;
  final String bedrooms;
  final String bathrooms;
  final String imageUrl;

  const PropertyListItem({
    required this.title,
    required this.size,
    required this.bedrooms,
    required this.bathrooms,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(10.0),
        width: 300,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 16.0),
                      const SizedBox(width: 4.0),
                      Text(size),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.bedroom_baby_outlined, size: 16.0),
                      const SizedBox(width: 4.0),
                      Text(bedrooms.toString()),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.bathroom_outlined, size: 16.0),
                      const SizedBox(width: 4.0),
                      Text(bathrooms.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Message {
  final String text;
  final bool isCurrentUser;
  late List<Article> articles;
  Message({required this.text, required this.isCurrentUser});
}
Future<List<Article>> doAnApiRequest(String jsonParams) async {
  print("search string are is $jsonParams");
  if (jsonParams.startsWith("{") && jsonParams.endsWith("}")) {
    jsonParams = "[$jsonParams]";
  }
  List<dynamic> geminiParams = jsonDecode(jsonParams) as List<dynamic>;
  print("search params are is $geminiParams");
  List<Article> resultArticle = [];

  final request = await http.MultipartRequest('POST',
    Uri.parse("https://houzi01.booleanbites.com/wp-json/houzez-mobile-api/v1/search-properties")
  );

  for (Map<String, dynamic> geminiParam in geminiParams) {
    request.fields[geminiParam["post_var"]!] = geminiParam["post_var_value"]!;
  }
  final response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();
    var responseToString = String.fromCharCodes(responseData);
    print("api resopnse is $responseToString");
    // Parse the JSON response
    Map<String, dynamic> responseBody =  jsonDecode(responseToString) as Map<String, dynamic>;
    List<dynamic> lists = responseBody["result"];
    for (Map<String, dynamic> item in lists) {
      resultArticle.add(UtilityMethods.parseArticleMap(item));
    }


    return resultArticle;
  } else {
    // Handle error
    throw Exception('Failed to send POST request! Status code: ${response.statusCode}');
  }

}
class Article {

  final String? title;
  final String? content;

  final String? image;
  final String? bedroom;
  final String? bathroom;
  final String? size;


  Article({
    this.title,
    this.content,
    this.image,
    this.bedroom,
    this.bathroom,
    this.size
  });
}
class UtilityMethods{
  static Article parseArticleMap(Map<String, dynamic> json) {
    String? title;
    String? content;

    String? image;
    String? bedroom;
    String? bathroom;
    String? size;
    String? sizeUnit;

    dynamic dataHolder;

    if(json.containsKey("content")){
      dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "content") ?? {};
      if(dataHolder.isNotEmpty){
        content = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
      }
    }
    if(json.containsKey("post_content")){
      content = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_content") ?? "";
    }

    image = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "thumbnail") ?? "";

    if(json.containsKey("title")){
      dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "title") ?? {};
      if(dataHolder.isNotEmpty){
        title = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
      }
    }

    if(json.containsKey("post_title")){
      title = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_title") ?? "";
    }

    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_size");
      size = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_size_prefix");
      sizeUnit = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);


      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_bedrooms");
      bedroom = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_bathrooms");
      bathroom = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);


    }

    Article article;
    article = Article(
      title: title,
      content: content,
      image: image,
      bedroom: bedroom,
      bathroom: bathroom,
      size: "$size $sizeUnit"
    );
    return article;
  }
  static String? getStringItemValueFromMap(
      {required Map inputMap, required String key}) {
    if (inputMap.containsKey(key) &&
        inputMap[key] != null &&
        inputMap[key] is String &&
        inputMap[key].isNotEmpty) {
      return inputMap[key];
    }

    return null;
  }

  static int? getIntegerItemValueFromMap(
      {required Map inputMap, required String key}) {
    if (inputMap.containsKey(key) &&
        inputMap[key] != null &&
        inputMap[key] is int) {
      return inputMap[key];
    }

    return null;
  }

  static List? getListItemValueFromMap(
      {required Map inputMap, required String key}) {
    if (inputMap.containsKey(key) &&
        inputMap[key] != null &&
        inputMap[key] is List &&
        inputMap[key].isNotEmpty) {
      return inputMap[key];
    }

    return null;
  }

  static List<String>? getStringListItemValueFromMap(
      {required Map inputMap, required String key}) {
    if (inputMap.containsKey(key) &&
        inputMap[key] != null &&
        inputMap[key] is List &&
        inputMap[key].isNotEmpty) {
      return List<String>.from(inputMap[key]);
    }

    return null;
  }
  static Map? getMapItemValueFromMap({required Map inputMap, required String key}){
    if(inputMap.containsKey(key) && inputMap[key] != null &&
        inputMap[key] is Map && inputMap[key].isNotEmpty){
      return inputMap[key];
    }

    return null;
  }
  static Map<String, dynamic> convertMap(Map<dynamic, dynamic> inputMap){
    Map<String, dynamic> convertedMap =  <String, dynamic>{};
    if(inputMap.isNotEmpty){
      for (dynamic type in inputMap.keys) {
        convertedMap[type.toString()] = inputMap[type];
      }
    }
    return convertedMap;
  }
  static dynamic getItemValueFromMap({required Map inputMap, required String key}){
    if(inputMap.containsKey(key) && inputMap[key] != null){
      return inputMap[key];
    }

    return null;
  }
  static String getStringValueFromDynamicItem({required dynamic item}){
    if (item != null) {
      if (item is List && item.isNotEmpty){
        return item[0] ?? "";
      } else if (item is String) {
        return item;
      }
    }

    return "";
  }

}
