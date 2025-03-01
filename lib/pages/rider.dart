import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:async';

// Provider for managing the current user
final currentUserProvider = FutureProvider<ParseUser?>((ref) async {
  return await ParseUser.currentUser() as ParseUser?;
});

// Provider for managing the latest ride
final latestRideProvider = StateProvider<ParseObject?>((ref) => null);

// Provider for managing ride status updates
final rideStatusProvider = StateProvider<String>((ref) => 'pending');

class RiderPage extends HookConsumerWidget {
  const RiderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickupController = useTextEditingController();
    final dropoffController = useTextEditingController();
    final selectedCarType = useState<String>('Basic');
    final selectedSeat = useState<int>(1);

    final currentUserAsync = ref.watch(currentUserProvider);
    final latestRide = ref.watch(latestRideProvider);
    final rideStatus = ref.watch(rideStatusProvider);

    // Use useEffect to handle ride status updates
    useEffect(() {
      if (latestRide == null) return null;

      final timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        final query = QueryBuilder<ParseObject>(ParseObject('Rides'))
          ..whereEqualTo('objectId', latestRide.objectId);

        final response = await query.query();

        if (response.success && response.results != null) {
          final updatedRide = response.results!.first;
          final status = updatedRide.get<String>('status');
          ref.read(rideStatusProvider.notifier).state = status;

          if (status == 'accepted') {
            timer.cancel();
            _showDriverComingSheet(context);
          }
        }
      });

      return () => timer.cancel(); // Cleanup timer on dispose
    }, [latestRide]);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Book Now", style: TextStyle(color: Colors.white)),
            PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Text("Logout"),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  _logout(context, ref);
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/taxi.png',
                height: 100,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Taxi (${selectedCarType.value})",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    Text(" 4.2", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Text("Will arrive in less than 15 min.",
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            _inputField("Pickup", pickupController),
            SizedBox(height: 10),
            _inputField("Drop-off", dropoffController),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text("Seats",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return GestureDetector(
                        onTap: () {
                          selectedSeat.value = index + 1;
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedSeat.value == index + 1
                                ? Colors.yellow
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("${index + 1}",
                              style: TextStyle(
                                  color: selectedSeat.value == index + 1
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 18)),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _bookRide(
                        context,
                        ref,
                        pickupController.text,
                        dropoffController.text,
                        selectedCarType.value,
                        selectedSeat.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Book Now",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _bookRide(BuildContext context, WidgetRef ref, String pickup,
      String dropoff, String carType, int seats) async {
    if (pickup.isEmpty || dropoff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter pickup and drop-off locations")),
      );
      return;
    }

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    final ride = ParseObject('Rides')
      ..set('user', currentUser)
      ..set('phone', currentUser.get<String>('phone'))
      ..set('status', 'pending')
      ..set('pickup', pickup)
      ..set('dropoff', dropoff)
      ..set('carType', carType)
      ..set('seats', seats);

    final response = await ride.save();
    if (response.success) {
      ref.read(latestRideProvider.notifier).state = ride;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ride booked successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to book ride")),
      );
    }
  }

  void _showDriverComingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car, color: Colors.yellow, size: 50),
              SizedBox(height: 10),
              Text(
                "Your driver is on the way!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Please be ready at your pickup location.",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("OK",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser != null) {
      await currentUser.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
