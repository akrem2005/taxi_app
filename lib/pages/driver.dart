import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter/services.dart'; // For clipboard functionality

// Provider for managing ride requests
final rideRequestsProvider =
    StateNotifierProvider<RideRequestsNotifier, List<ParseObject>>((ref) {
  return RideRequestsNotifier();
});

class RideRequestsNotifier extends StateNotifier<List<ParseObject>> {
  RideRequestsNotifier() : super([]) {
    _initLiveQuery();
  }

  Future<void> _initLiveQuery() async {
    final liveQuery = LiveQuery();
    final query = QueryBuilder<ParseObject>(ParseObject('Rides'))
      ..whereEqualTo('status', 'pending'); // Removed the time constraint

    // Fetch existing pending rides first
    final response = await query.query();
    if (response.success && response.results != null) {
      state = List<ParseObject>.from(response.results!);
    }

    // Subscribe to LiveQuery for real-time updates
    final subscription = await liveQuery.client.subscribe(query);

    subscription.on(LiveQueryEvent.create, (ParseObject ride) {
      state = [...state, ride];
    });

    subscription.on(LiveQueryEvent.update, (ParseObject updatedRide) {
      state = state
          .map((ride) =>
              ride.objectId == updatedRide.objectId ? updatedRide : ride)
          .toList();
    });

    subscription.on(LiveQueryEvent.delete, (ParseObject deletedRide) {
      state =
          state.where((ride) => ride.objectId != deletedRide.objectId).toList();
    });
  }
}

class DriverPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideRequests = ref.watch(rideRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text("Book Now", style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Logout"), value: 'logout'),
            ],
            onSelected: (value) => logout(context),
          ),
        ],
      ),
      body: rideRequests.isEmpty
          ? Center(
              child: Text("No recent ride requests",
                  style: TextStyle(color: Colors.white, fontSize: 18)))
          : ListView.builder(
              itemCount: rideRequests.length,
              itemBuilder: (context, index) {
                final request = rideRequests[index];

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup: ${request.get<String>('pickup')} \nDrop-off: ${request.get<String>('dropoff')}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Seats: ${request.get<int>('seats')}  |  Fare: 120 birr/hr",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  acceptRide(context, ref, request),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  rejectRide(context, ref, request),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> acceptRide(
      BuildContext context, WidgetRef ref, ParseObject ride) async {
    String phoneNumber = ride.get<String>('phone') ?? "N/A";

    ride.set('status', 'accepted');
    await ride.save();
    showSnackBar(context, "Ride accepted!");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ride Details",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Pickup: ${ride.get<String>('pickup')}",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text("Drop-off: ${ride.get<String>('dropoff')}",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text("Seats: ${ride.get<int>('seats')}  |  Fare: 150 birr/hr",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              SizedBox(height: 20),
              Text("Contact Rider",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Phone: $phoneNumber",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                  showSnackBar(context, "Phone number copied to clipboard!");
                },
                child: Text("Copy Phone Number",
                    style: TextStyle(color: Colors.blue)),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed: () async {
                    ride.set('status', 'pending');
                    await ride.save();
                    showSnackBar(context, "Ride has been canceled");
                    Navigator.pop(context);
                    ref.refresh(rideRequestsProvider);
                  },
                  child: Text("Cancel Ride"),
                ),
              ),
            ],
          ),
        );
      },
    );

    ref.refresh(rideRequestsProvider);
  }

  Future<void> rejectRide(
      BuildContext context, WidgetRef ref, ParseObject ride) async {
    await ride.delete();
    showSnackBar(context, "Ride rejected!");
    ref.refresh(rideRequestsProvider);
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void logout(BuildContext context) {
    showSnackBar(context, "Logged out!");
  }
}
