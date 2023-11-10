import 'package:flutter/material.dart';
import 'package:intinow/adminPanel/events/create_event_page.dart';
import 'package:intinow/adminPanel/events/event_details_page.dart';
import 'package:intinow/adminPanel/services/side_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageEventsPage extends StatefulWidget {
  @override
  State<AdminManageEventsPage> createState() => _AdminManageEventsPageState();
}

class _AdminManageEventsPageState extends State<AdminManageEventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  Future<DocumentSnapshot> _getUserDetails(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('Admin').doc(uid).get();
    if (userDoc.exists) return userDoc;
    return await _firestore.collection('Users').doc(uid).get();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Admin Manage Events',
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: SideNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                hintText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Events').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var filteredEvents = snapshot.data?.docs.where((doc) {
              return doc['title']
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.toLowerCase());
            }).toList() ??
            [];

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot event = filteredEvents[index];
            Map<String, dynamic>? eventData =
                event.data() as Map<String, dynamic>?;

            return FutureBuilder<DocumentSnapshot>(
              future: _getUserDetails(eventData!['createdBy']),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Loading data...'));
                }
                if (userSnapshot.hasError) {
                  return ListTile(title: Text('Error: ${userSnapshot.error}'));
                }
                if (userSnapshot.data == null) {
                  return const ListTile(title: Text('User not found'));
                }

                String startDate =
                    eventData!['startDate'] ?? 'No start date provided';
                String endDate = eventData['endDate'] ?? '';
                int attendeesNumber = eventData['attendeesNumber'] ?? 0;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(
                          eventData: eventData,
                          eventReference: event.reference,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    userSnapshot.data!['profilePicture'] ?? ''),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(userSnapshot.data!['name'],
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    eventData!['imageReferenceURL'] ?? ''),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            eventData!['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Start Date: $startDate',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (endDate.isNotEmpty)
                            Text(
                              'End Date: $endDate',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          Text(
                            '$attendeesNumber Attending',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
