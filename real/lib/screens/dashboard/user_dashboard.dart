import 'package:flutter/material.dart';
import '../address/address_form.dart';
import '../profile/profile_page.dart';
import '../booking/category_services_page.dart';
import '../booking/date_time_page.dart';
import '../booking/worker_selection_page.dart';
import '../booking/booking_detail_page.dart';
import '../booking/confirmation_page.dart';
import '../bookings/bookings_page.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {

  int currentIndex = 0;
  int currentPage = 0;

  String selectedCategory = "";
  Map<String, dynamic>? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? selectedWorker;
  Map<String, String>? bookingDetails;



  String userAddress = "Coimbatore, Tamil Nadu";
  String userName = "Ravi Kumar";
  String userEmail = "ravi@email.com";
  String userPhone = "9876543210";

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      drawer: buildDrawer(width),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,  // 👈 USE currentIndex here
          children: [

            // 🔹 HOME + BOOKING FLOW
            IndexedStack(
              index: currentPage,
              children: [

                buildHomePage(width),

                CategoryServicesPage(
                  category: selectedCategory,
                  onSubmit: (selectedServices) {
                    setState(() {
                      currentPage = 2;
                    });
                  },
                ),

                DateTimePage(
                  onWorkerSubmit: (worker) {
                    setState(() {
                      selectedWorker = worker;
                      currentPage = 3;
                    });
                  },
                ),

                BookingDetailPage(
                  homeAddress: userAddress,
                  onSubmit: () {
                    setState(() {
                      currentPage = 4;
                    });
                  },
                ),

                ConfirmationPage(
                  onBackHome: () {
                    setState(() {
                      currentPage = 0;
                    });
                  },
                ),
              ],
            ),

            // 🔹 BOOKINGS PAGE
            const BookingsPage(),

            // 🔹 CHAT PAGE (temporary)
            const Center(child: Text("Chat Page")),

            // 🔹 PROFILE PAGE
            ProfilePage(
              name: userName,
              email: userEmail,
              phone: userPhone,
              address: userAddress,
            ),
          ],
        ),
      ),






      bottomNavigationBar: buildBottomNav(),
    );
  }

  // ================= HOME PAGE =================

  Widget buildHomePage(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: ListView(
        children: [

          SizedBox(height: width * 0.04),
          buildGreeting(width),

          SizedBox(height: width * 0.05),
          buildLocationCard(width),

          SizedBox(height: width * 0.05),
          buildCategoryGrid(width),

          SizedBox(height: width * 0.05),
          buildEmergencySection(width),

          SizedBox(height: width * 0.06),
          buildUpcomingSection(width),

          SizedBox(height: width * 0.06),
          buildCompletedSection(width),
        ],
      ),
    );
  }

  // ================= GREETING =================

  Widget buildGreeting(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: width * 0.07,
            backgroundImage:
            const AssetImage("assets/images/electrician.jpg"),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              "Hello, $userName 👋\nFind Trusted Services",
              style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.notifications),
        ],
      ),
    );
  }

  // ================= LOCATION =================

  Widget buildLocationCard(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          SizedBox(width: width * 0.03),
          Expanded(child: Text(userAddress)),
          TextButton(
            onPressed: () async {
              final newAddress =
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddressFormPage(
                        currentAddress: userAddress,
                      ),
                ),
              );

              if (newAddress != null) {
                setState(() {
                  userAddress = newAddress;
                });
              }
            },
            child: const Text("Change"),
          )
        ],
      ),
    );
  }

  // ================= CATEGORY =================

  Widget buildCategoryGrid(double width) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: width * 0.04,
      mainAxisSpacing: width * 0.04,
      childAspectRatio: 1.1,
      children: [

        categoryCard("Electrical",
            "assets/images/home_wiring.jpg"),

        categoryCard("Plumbing",
            "assets/images/leakage_fix.jpg"),
      ],
    );
  }

  Widget categoryCard(String title, String image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
          currentPage = 1;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Image.asset(image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
  Widget buildCategoryPage(double width) {

    List<Map<String, String>> services = selectedCategory == "Electrical"
        ? [
      {
        "title": "Fan Repair",
        "description": "Repair ceiling and table fans.",
        "image": "assets/images/fan_repair.jpg"
      },
      {
        "title": "Switch Repair",
        "description": "Fix switches and sockets safely.",
        "image": "assets/images/switch_socket_repair.jpg"
      },
    ]
        : [
      {
        "title": "Pipe Leakage",
        "description": "Fix leaking pipes quickly.",
        "image": "assets/images/leakage_fix.jpg"
      },
      {
        "title": "Tap Installation",
        "description": "Install new taps professionally.",
        "image": "assets/images/tap_install.jpg"
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        children: [

          SizedBox(height: width * 0.04),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentPage = 0;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                selectedCategory,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),

          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {

                final service = services[index];

                return Card(
                  margin: EdgeInsets.only(bottom: width * 0.04),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: Image.asset(
                            service["image"]!,
                            height: width * 0.45,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: width * 0.03),

                        Text(
                          service["title"]!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold),
                        ),

                        SizedBox(height: width * 0.02),

                        Text(service["description"]!),

                        SizedBox(height: width * 0.03),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedService = service;
                              });
                            },
                            child: const Text("Select"),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2563EB),
              ),
              onPressed: selectedService == null
                  ? null
                  : () {
                setState(() {
                  currentPage = 2;
                });
              },
              child: const Text("Submit"),
            ),
          ),

          SizedBox(height: width * 0.04),
        ],
      ),
    );
  }


  // ================= EMERGENCY =================

  Widget buildEmergencySection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Emergency Services",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold)),

        SizedBox(height: width * 0.04),

        Container(
          padding: EdgeInsets.symmetric(
              vertical: width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [

              quickIcon(Icons.electrical_services, "Power"),
              quickIcon(Icons.water_drop, "Leak"),
              quickIcon(Icons.lightbulb, "Lights"),
              quickIcon(Icons.plumbing, "Pipe"),
            ],
          ),
        )
      ],
    );
  }

  Widget quickIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.red.shade100,
          child: Icon(icon, color: Colors.red),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12))
      ],
    );
  }

  // ================= UPCOMING =================

  Widget buildUpcomingSection(double width) {
    return const Text("Upcoming Demo Service");
  }

  Widget buildCompletedSection(double width) {
    return const Text("Completed Demo Services");
  }

  // ================= CATEGORY PAGE =================

  Widget buildBookingDetailPage(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        children: [

          SizedBox(height: width * 0.04),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentPage = 1;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                "Select Date & Time",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),

          SizedBox(height: width * 0.06),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              selectedTime == null
                  ? "Select Time"
                  : selectedTime!.format(context),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedTime = picked;
                });
              }
            },
          ),

          SizedBox(height: width * 0.06),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2563EB),
              ),
              onPressed: (selectedDate == null ||
                  selectedTime == null)
                  ? null
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                    Text("Booking Confirmed!"),
                  ),
                );

                setState(() {
                  currentPage = 0;
                  selectedService = null;
                });
              },
              child: const Text("Confirm Booking"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER =================

  Widget buildDrawer(double width) {
    return Drawer(
      width: width * 0.80,
      child: Container(
        color: const Color(0xFF1E293B),
        child: SafeArea(
          child: ListView(
            children: [

              SizedBox(height: width * 0.08),

              CircleAvatar(
                radius: width * 0.12,
                backgroundImage:
                const AssetImage("assets/images/electrician.jpg"),
              ),

              SizedBox(height: width * 0.04),

              const Center(
                child: Text(
                  "Ravi Kumar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20),
                ),
              ),

              SizedBox(height: width * 0.08),

              drawerItem(Icons.person, "Profile"),
              drawerItem(Icons.book, "Bookings"),
              drawerItem(Icons.support_agent, "Support"),
              drawerItem(Icons.message, "Messages"),
              drawerItem(Icons.notifications, "Notifications"),
              drawerItem(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  // ================= BOTTOM NAV =================

  Widget buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2563EB),
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.book), label: "Bookings"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
