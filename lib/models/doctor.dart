class Doctor {
  final int id;
  final String name;
  final String nameBn; // Bangla name
  final String specialty;
  final String specialtyBn;
  final String location;
  final String locationBn;
  final String phone;
  final String? availability;
  final double? distance; // in km, optional

  Doctor({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.specialty,
    required this.specialtyBn,
    required this.location,
    required this.locationBn,
    required this.phone,
    this.availability,
    this.distance,
  });
}

/// Pre-populated directory of mental health professionals in rural Bangladesh.
/// In a real app, this could be fetched from Firebase or a local JSON file.
class DoctorDirectory {
  static final List<Doctor> doctors = [
    Doctor(
      id: 1,
      name: 'Dr. Fatema Akhter',
      nameBn: 'ডাঃ ফাতেমা আক্তার',
      specialty: 'Psychiatrist',
      specialtyBn: 'মনোরোগ বিশেষজ্ঞ',
      location: 'Rangpur Medical College Hospital',
      locationBn: 'রংপুর মেডিকেল কলেজ হাসপাতাল',
      phone: '01712-345678',
      availability: 'Sun-Thu, 9AM-2PM',
    ),
    Doctor(
      id: 2,
      name: 'Dr. Mahbub Hasan',
      nameBn: 'ডাঃ মাহবুব হাসান',
      specialty: 'Clinical Psychologist',
      specialtyBn: 'ক্লিনিক্যাল সাইকোলজিস্ট',
      location: 'Dinajpur General Hospital',
      locationBn: 'দিনাজপুর জেনারেল হাসপাতাল',
      phone: '01819-876543',
      availability: 'Sat-Wed, 10AM-4PM',
    ),
    Doctor(
      id: 3,
      name: 'Dr. Nazmul Karim',
      nameBn: 'ডাঃ নাজমুল করিম',
      specialty: 'Psychiatrist',
      specialtyBn: 'মনোরোগ বিশেষজ্ঞ',
      location: 'Bogura Shaheed Ziaur Rahman Medical College',
      locationBn: 'বগুড়া শহীদ জিয়াউর রহমান মেডিকেল কলেজ',
      phone: '01675-112233',
      availability: 'Sun-Thu, 8AM-1PM',
    ),
    Doctor(
      id: 4,
      name: 'Dr. Tasneem Rahman',
      nameBn: 'ডাঃ তাসনীম রহমান',
      specialty: 'Counseling Psychologist',
      specialtyBn: 'কাউন্সেলিং সাইকোলজিস্ট',
      location: 'Mymensingh Medical College Hospital',
      locationBn: 'ময়মনসিংহ মেডিকেল কলেজ হাসপাতাল',
      phone: '01911-445566',
      availability: 'Sat-Thu, 9AM-3PM',
    ),
    Doctor(
      id: 5,
      name: 'Dr. Rahim Uddin',
      nameBn: 'ডাঃ রহিম উদ্দিন',
      specialty: 'Psychiatrist',
      specialtyBn: 'মনোরোগ বিশেষজ্ঞ',
      location: 'Sylhet MAG Osmani Medical College',
      locationBn: 'সিলেট এমএজি ওসমানী মেডিকেল কলেজ',
      phone: '01612-778899',
      availability: 'Sun-Wed, 10AM-2PM',
    ),
    Doctor(
      id: 6,
      name: 'Dr. Salma Begum',
      nameBn: 'ডাঃ সালমা বেগম',
      specialty: 'Clinical Psychologist',
      specialtyBn: 'ক্লিনিক্যাল সাইকোলজিস্ট',
      location: 'Rajshahi Medical College Hospital',
      locationBn: 'রাজশাহী মেডিকেল কলেজ হাসপাতাল',
      phone: '01855-334455',
      availability: 'Sun-Thu, 9AM-1PM',
    ),
    Doctor(
      id: 7,
      name: 'Dr. Aminul Islam',
      nameBn: 'ডাঃ আমিনুল ইসলাম',
      specialty: 'Psychiatrist',
      specialtyBn: 'মনোরোগ বিশেষজ্ঞ',
      location: 'Khulna Medical College Hospital',
      locationBn: 'খুলনা মেডিকেল কলেজ হাসপাতাল',
      phone: '01733-998877',
      availability: 'Sat-Thu, 8AM-2PM',
    ),
    Doctor(
      id: 8,
      name: 'Dr. Razia Sultana',
      nameBn: 'ডাঃ রাজিয়া সুলতানা',
      specialty: 'Counseling Psychologist',
      specialtyBn: 'কাউন্সেলিং সাইকোলজিস্ট',
      location: 'Barishal Sher-e-Bangla Medical College',
      locationBn: 'বরিশাল শেরেবাংলা মেডিকেল কলেজ',
      phone: '01944-112244',
      availability: 'Sun-Thu, 10AM-3PM',
    ),
  ];

  /// Filter doctors by location keyword.
  static List<Doctor> filterByLocation(String query) {
    final q = query.toLowerCase();
    return doctors.where((d) =>
      d.location.toLowerCase().contains(q) ||
      d.locationBn.contains(q)
    ).toList();
  }

  /// Filter doctors by specialty.
  static List<Doctor> filterBySpecialty(String specialty) {
    final q = specialty.toLowerCase();
    return doctors.where((d) =>
      d.specialty.toLowerCase().contains(q) ||
      d.specialtyBn.contains(q)
    ).toList();
  }
}
