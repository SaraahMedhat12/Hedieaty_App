import '../models/gift.dart';

class GiftController {
  List<Gift> _gifts = [];
  int _nextId = 1;

  // Load gifts associated with a specific event (mock implementation)
  void loadGiftsForEvent(String eventName) {
    _gifts = [
      Gift(id: _nextId++, name: 'Watch', category: 'Accessories', isPledged: false),
      Gift(id: _nextId++, name: 'Book', category: 'Education', isPledged: true),
      Gift(id: _nextId++, name: 'Shoes', category: 'Fashion', isPledged: false),
    ];
  }

  // Get sorted list of gifts
  List<Gift> getSortedGifts(String sortBy, bool ascending) {
    List<Gift> sortedGifts = List.from(_gifts);

    sortedGifts.sort((a, b) {
      int comparison = 0;
      if (sortBy == 'name') {
        comparison = a.name.compareTo(b.name);
      } else if (sortBy == 'category') {
        comparison = a.category.compareTo(b.category);
      } else if (sortBy == 'status') {
        comparison = a.isPledged ? 1 : -1;
      }

      return ascending ? comparison : -comparison;
    });

    return sortedGifts;
  }

  // Add a new gift
  void addGift(Gift gift) {
    gift = Gift(id: _nextId++, name: gift.name, category: gift.category, isPledged: gift.isPledged);
    _gifts.add(gift);
  }

  // Update an existing gift
  void updateGift(int giftId, String newName, String newCategory) {
    Gift? gift = _findGiftById(giftId);  // Changed method to handle null
    if (gift != null && !gift.isPledged) {
      gift.name = newName;
      gift.category = newCategory;
    }
  }

  // Delete a gift by ID
  void deleteGift(int giftId) {
    _gifts.removeWhere((gift) => gift.id == giftId && !gift.isPledged);
  }

  // Helper method to find a gift by its ID
  Gift? _findGiftById(int id) {
    try {
      return _gifts.firstWhere((gift) => gift.id == id);
    } catch (e) {
      return null; // Return null if no gift is found with the given id
    }
  }
}
