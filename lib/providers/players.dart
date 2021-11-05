import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/player.dart';
import 'package:http/http.dart' as http;

class Players with ChangeNotifier {
  final List<Player> _allPlayer = [];

  List<Player> get allPlayer => _allPlayer;

  int get jumlahPlayer => _allPlayer.length;

  Player selectById(String id) =>
      _allPlayer.firstWhere((element) => element.id == id);

  Future<void> addPlayer(
    String name,
    String position,
    String image,
  ) async {
    DateTime datetimeNow = DateTime.now();

    Uri url = Uri.parse(
        "https://http-req-f1594-default-rtdb.asia-southeast1.firebasedatabase.app/players.json");
    http
        .post(
      url,
      body: json.encode(
        {
          "name": name,
          "position": position,
          "imageUrl": image,
          "createdAt": datetimeNow.toString(),
        },
      ),
    )
        .then((response) {
      _allPlayer.add(
        Player(
          id: json.decode(response.body)['name'].toString(),
          name: name,
          position: position,
          imageUrl: image,
          createdAt: datetimeNow,
        ),
      );

      notifyListeners();
    });
  }

  Future<void> editPlayer(
    String id,
    String name,
    String position,
    String image,
  ) async {
    Uri url = Uri.parse(
        "https://http-req-f1594-default-rtdb.asia-southeast1.firebasedatabase.app/players/$id.json");

    /**
     * Bedanya PUT dengan PATCH itu
     * kalau patch akan update data
     *
     * sedangkan
     *
     * put akan replace data
     */
    http
        .patch(
      url,
      body: json.encode(
        {
          "name": name,
          "position": position,
          "imageUrl": image,
        },
      ),
    )
        .then((response) {
      Player selectPlayer =
          _allPlayer.firstWhere((element) => element.id == id);
      selectPlayer.name = name;
      selectPlayer.position = position;
      selectPlayer.imageUrl = image;
      notifyListeners();
    });
  }

  Future<void> deletePlayer(String id) async {
    Uri url = Uri.parse(
        "https://http-req-f1594-default-rtdb.asia-southeast1.firebasedatabase.app/players/$id.json");
    http
        .delete(
      url,
    )
        .then(
      (response) {
        _allPlayer.removeWhere((element) => element.id == id);
        notifyListeners();
      },
    );
  }

  Future<void> initialData() async {
    Uri url = Uri.parse(
        "https://http-req-f1594-default-rtdb.asia-southeast1.firebasedatabase.app/players.json");

    var hasilGetData = await http.get(url);
    var dataResponse = (json.decode(hasilGetData.body) as Map<String, dynamic>);
    dataResponse.forEach(
      (key, value) {
        var dateTimeParse =
            DateFormat("yyyy-mm-dd hh:mm:ss").parse(value['createdAt']);
        allPlayer.add(
          Player(
            id: key,
            createdAt: dateTimeParse,
            imageUrl: value['imageUrl'],
            name: value['name'],
            position: value['position'],
          ),
        );
      },
    );
    notifyListeners();
  }
}
