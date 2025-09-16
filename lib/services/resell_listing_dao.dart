import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ResellListingDao {
  final dbService = DatabaseService();

  Future<int> createListing(ResellListing listing) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final currentListings = await dbService.getWebListings();
      final data = _listingToMap(listing);
      currentListings.add(data);
      await dbService.saveWebListings(currentListings);
      return 1; // Return success indicator
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      final data = _listingToMap(listing);
      return await db.insert(
        'resell_listings',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<ResellListing>> getActiveListings() async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final listings = await dbService.getWebListings();
      final activeListings = listings.where((listing) =>
        listing['status'] == 'ListingStatus.active'
      ).toList();
      return activeListings.map((map) => _mapToListing(map)).toList();
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      final List<Map<String, dynamic>> maps = await db.query(
        'resell_listings',
        where: 'status = ?',
        whereArgs: ['ListingStatus.active'],
      );
      return List.generate(maps.length, (i) {
        return _mapToListing(maps[i]);
      });
    }
  }

  Future<List<ResellListing>> getUserListings(String sellerId) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final listings = await dbService.getWebListings();
      final userListings = listings.where((listing) =>
        listing['seller_id'] == sellerId
      ).toList();
      return userListings.map((map) => _mapToListing(map)).toList();
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      final List<Map<String, dynamic>> maps = await db.query(
        'resell_listings',
        where: 'seller_id = ?',
        whereArgs: [sellerId],
      );
      return List.generate(maps.length, (i) {
        return _mapToListing(maps[i]);
      });
    }
  }

  Future<List<ResellListing>> getAllListings() async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final listings = await dbService.getWebListings();
      return listings.map((map) => _mapToListing(map)).toList();
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      final List<Map<String, dynamic>> maps = await db.query('resell_listings');
      return List.generate(maps.length, (i) {
        return _mapToListing(maps[i]);
      });
    }
  }

  Future<int> updateListing(ResellListing listing) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final currentListings = await dbService.getWebListings();
      final index = currentListings.indexWhere((l) => l['id'] == listing.id);
      if (index != -1) {
        currentListings[index] = _listingToMap(listing);
        await dbService.saveWebListings(currentListings);
        return 1;
      }
      return 0;
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      final data = _listingToMap(listing);
      return await db.update(
        'resell_listings',
        data,
        where: 'id = ?',
        whereArgs: [listing.id],
      );
    }
  }

  Future<int> deleteListing(String id) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final currentListings = await dbService.getWebListings();
      final filteredListings = currentListings.where((listing) =>
        listing['id'] != id
      ).toList();
      if (filteredListings.length != currentListings.length) {
        await dbService.saveWebListings(filteredListings);
        return 1;
      }
      return 0;
    } else {
      // Mobile implementation using SQLite
      final db = await dbService.database as Database;
      return await db.delete('resell_listings', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Helper method to convert ResellListing to database map
  Map<String, dynamic> _listingToMap(ResellListing listing) {
    return {
      'id': listing.id,
      'seller_id': listing.sellerId,
      'device_passport': jsonEncode(listing.devicePassport.toJson()),
      'category': listing.category.toString(),
      'condition': listing.condition.toString(),
      'asking_price': listing.askingPrice,
      'ai_suggested_price': listing.aiSuggestedPrice,
      'title': listing.title,
      'description': listing.description,
      'location': listing.location,
      'image_urls': jsonEncode(listing.imageUrls),
      'status': listing.status.toString(),
      'created_at': listing.createdAt.toIso8601String(),
      'updated_at': listing.updatedAt?.toIso8601String(),
      'sold_at': listing.soldAt?.toIso8601String(),
      'buyer_id': listing.buyerId,
      'ai_market_insights': listing.aiMarketInsights != null
          ? jsonEncode(listing.aiMarketInsights)
          : null,
      'interested_buyers': listing.interestedBuyers != null
          ? jsonEncode(listing.interestedBuyers)
          : null,
      'is_featured': listing.isFeatured ? 1 : 0,
      'shipping_info': listing.shippingInfo != null
          ? jsonEncode(listing.shippingInfo)
          : null,
    };
  }

  // Helper method to convert database map to ResellListing
  ResellListing _mapToListing(Map<String, dynamic> map) {
    return ResellListing(
      id: map['id'],
      sellerId: map['seller_id'],
      devicePassport: DevicePassport.fromJson(
        jsonDecode(map['device_passport']),
      ),
      category: ListingCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => ListingCategory.other,
      ),
      condition: ConditionGrade.values.firstWhere(
        (e) => e.toString() == map['condition'],
        orElse: () => ConditionGrade.good,
      ),
      askingPrice: map['asking_price'].toDouble(),
      aiSuggestedPrice: map['ai_suggested_price']?.toDouble(),
      title: map['title'],
      description: map['description'],
      location: map['location'],
      imageUrls: List<String>.from(jsonDecode(map['image_urls'] ?? '[]')),
      status: ListingStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ListingStatus.draft,
      ),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      soldAt: map['sold_at'] != null ? DateTime.parse(map['sold_at']) : null,
      buyerId: map['buyer_id'],
      aiMarketInsights: map['ai_market_insights'] != null
          ? jsonDecode(map['ai_market_insights'])
          : null,
      interestedBuyers: map['interested_buyers'] != null
          ? List<String>.from(jsonDecode(map['interested_buyers']))
          : null,
      isFeatured: map['is_featured'] == 1,
      shippingInfo: map['shipping_info'] != null
          ? jsonDecode(map['shipping_info'])
          : null,
    );
  }
}
