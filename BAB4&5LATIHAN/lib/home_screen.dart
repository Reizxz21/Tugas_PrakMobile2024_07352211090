import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'edit_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Data berita statis
Future<List<Map<String, String>>> fetchNews() async  {
  final response = await http
      .get(Uri.parse('https://events.hmti.unkhair.ac.id/api/posts'));
    
    if(response.statusCode == 200){
      try{
        List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, String>>((item) {
          return{
            'imageUrl': 'https://events.hmti.unkhair.ac.id/storage/' + (item['image']?? ''),
            'title': item['title']?.toString() ?? 'No Title',
            'author': item['author']?.toString() ?? 'Unknown',
            'description': item['content']?.toString() ?? 'No Description',
            'time': item['update_at']?.toString() ?? 'Unknown',
          };
        }).toList();
      }catch (e) {
        print("Error parsing data: $e");
        throw Exception('Failed to parse news data');
      }
    }else {
      print('Failed to load news with status: ${response.statusCode}');
      throw Exception('Failed to load news');
    }
}

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FutureBuilder<List<Map<String, String>>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          } else {
            List<Map<String, String>> news = snapshot.data!;
            return ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: news[index]['title'].toString(),
                            description: news[index]['description'].toString(),
                            imageUrl: news[index]['imageUrl'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              news[index]['imageUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              news[index]['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${news[index]['author']} • ${news[index]['time']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      Center(child: Text('Explore Page')),
      Center(child: Text('Bookmark Page')),
      EditProfileScreen(),
      FutureBuilder<List<Map<String, String>>>(
        future: fetchNews(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text('No News Available'));
          }else{
            List<Map<String, String>> news = snapshot.data!;
            return ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: news[index]['title'].toString(),
                            description: news[index]['description'].toString(),
                            imageUrl: news[index]['imageUrl'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              news[index]['imageUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              news[index]['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: 
                              const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${news[index]['author']} - ${news[index]['time']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'HMTI',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'News',
              style: TextStyle(
                color: Color(0xFF1877F2),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Pengaturan', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                color: Color(0xFF1877F2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan'),
              onTap: (){
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ...pages,
          EditProfileScreen(),
          EditProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF1877F2),
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  final Map<String, String> news;

  const NewWidget({
    Key? key,
    required this.news,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                title: news['title'] ?? '',
                description: news['description'] ?? '',
                imageUrl: news['imageUrl'] ?? '',
              ),
            ),
          );
        },
        child: Card(
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  news['imageUrl']!,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  news['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${news['author']} - ${news['time']}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
