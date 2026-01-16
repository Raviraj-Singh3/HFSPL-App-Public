import 'dart:convert';
import 'dart:io';
import 'package:advertising_id/advertising_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentification {
  static const String _customIdKey = 'app_device_id';
  static const String _nullAdId = '00000000-0000-0000-0000-000000000000';
  
  /// Gets a robust device identifier with multiple fallbacks
  static Future<String> getDeviceId() async {
    try {
      // First try advertising ID
      final adId = await _getAdvertisingId();
      if (adId != null && adId != _nullAdId && adId.isNotEmpty) {
        print('Using Advertising ID: $adId');
        return adId;
      }
      
      // Fallback 1: Android ID (for Android) or identifierForVendor (for iOS)
      final deviceInfo = await _getDeviceSpecificId();
      if (deviceInfo.isNotEmpty) {
        print('Using Device Specific ID: $deviceInfo');
        return deviceInfo;
      }
      
      // Fallback 2: Device fingerprint based on hardware characteristics
      final fingerprint = await _generateDeviceFingerprint();
      if (fingerprint.isNotEmpty) {
        print('Using Device Fingerprint: $fingerprint');
        return fingerprint;
      }
      
      // Fallback 3: App-specific custom ID (persistent across app installs if possible)
      final customId = await _getOrCreateCustomId();
      print('Using Custom ID: $customId');
      return customId;
      
    } catch (e) {
      print('Error getting device ID: $e');
      // Last resort: Generate a custom ID
      return await _getOrCreateCustomId();
    }
  }
  
  /// Get advertising ID with proper error handling
  static Future<String?> _getAdvertisingId() async {
    try {
      final adId = await AdvertisingId.id(false); // Don't throw if tracking is limited
      if (adId != null && adId != _nullAdId && adId.trim().isNotEmpty) {
        return adId;
      }
    } catch (e) {
      print('Failed to get Advertising ID: $e');
    }
    return null;
  }
  
  /// Get platform-specific device identifier
  static Future<String> _getDeviceSpecificId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        
        // Check if this is an emulator
        final isEmulator = _isEmulator(androidInfo);
        
        // First try Android ID (unique per device) - but validate it's not a build fingerprint
        if (androidInfo.id.isNotEmpty && 
            androidInfo.id != 'unknown' && 
            androidInfo.id != '9774d56d682e549c' && // Avoid common test device ID
            !_looksLikeBuildFingerprint(androidInfo.id)) {
          return 'android_id_${androidInfo.id}';
        }
        
        // For emulators or invalid Android IDs, use a different approach
        if (isEmulator) {
          print('Detected emulator environment - Brand: ${androidInfo.brand}, Model: ${androidInfo.model}, Hardware: ${androidInfo.hardware}');
          print('Invalid Android ID detected: ${androidInfo.id} (looks like build fingerprint)');
          return ''; // Will fall through to fingerprint method
        }
        
        // Fallback: Try serial number if available (API < 26)
        if (androidInfo.serialNumber.isNotEmpty && 
            androidInfo.serialNumber != 'unknown' &&
            androidInfo.serialNumber != 'UNKNOWN') {
          return 'android_serial_${androidInfo.serialNumber}';
        }
        
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Use identifierForVendor (unique per vendor per device)
        if (iosInfo.identifierForVendor != null && iosInfo.identifierForVendor!.isNotEmpty) {
          return 'ios_vendor_${iosInfo.identifierForVendor}';
        }
      }
    } catch (e) {
      print('Failed to get device specific ID: $e');
    }
    
    return '';
  }
  
  /// Check if the device is an emulator
  static bool _isEmulator(dynamic androidInfo) {
    try {
      // Common emulator indicators
      final brand = androidInfo.brand?.toLowerCase() ?? '';
      final model = androidInfo.model?.toLowerCase() ?? '';
      final product = androidInfo.product?.toLowerCase() ?? '';
      final device = androidInfo.device?.toLowerCase() ?? '';
      final hardware = androidInfo.hardware?.toLowerCase() ?? '';
      final fingerprint = androidInfo.fingerprint?.toLowerCase() ?? '';
      
      // Check for common emulator identifiers
      final emulatorIndicators = [
        brand.contains('google') && model.contains('sdk'),
        product.contains('sdk'),
        product.contains('emulator'),
        device.contains('emulator'),
        hardware.contains('ranchu'),
        hardware.contains('goldfish'),
        fingerprint.contains('generic'),
        model.contains('emulator'),
        brand == 'generic',
      ];
      
      return emulatorIndicators.any((indicator) => indicator);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if the Android ID looks like a build fingerprint instead of a real Android ID
  static bool _looksLikeBuildFingerprint(String androidId) {
    // Build fingerprints typically have patterns like:
    // SE1A.211212.001.B1, TP1A.220624.014, etc.
    // They usually contain periods and uppercase letters in specific patterns
    final buildFingerprintPattern = RegExp(r'^[A-Z0-9]{2,4}\.[0-9]{6}\.[0-9]{3}\.?[A-Z0-9]*$');
    return buildFingerprintPattern.hasMatch(androidId);
  }
  
  /// Generate device fingerprint based on hardware characteristics
  static Future<String> _generateDeviceFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      String fingerprint = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final isEmulator = _isEmulator(androidInfo);
        
        // Create a more unique fingerprint by combining multiple characteristics
        final components = <String>[];
        
        // Basic device info
        if (androidInfo.brand.isNotEmpty) components.add('brand:${androidInfo.brand}');
        if (androidInfo.model.isNotEmpty) components.add('model:${androidInfo.model}');
        if (androidInfo.device.isNotEmpty) components.add('device:${androidInfo.device}');
        if (androidInfo.product.isNotEmpty) components.add('product:${androidInfo.product}');
        if (androidInfo.board.isNotEmpty) components.add('board:${androidInfo.board}');
        if (androidInfo.hardware.isNotEmpty) components.add('hardware:${androidInfo.hardware}');
        
        // System info
        if (androidInfo.version.release.isNotEmpty) components.add('release:${androidInfo.version.release}');
        components.add('sdk:${androidInfo.version.sdkInt}');
        if (androidInfo.version.incremental.isNotEmpty) components.add('incremental:${androidInfo.version.incremental}');
        
        // Hardware specifics that might vary between devices/emulators
        if (androidInfo.bootloader.isNotEmpty) components.add('bootloader:${androidInfo.bootloader}');
        if (androidInfo.host.isNotEmpty) components.add('host:${androidInfo.host}');
        if (androidInfo.tags.isNotEmpty) components.add('tags:${androidInfo.tags}');
        if (androidInfo.type.isNotEmpty) components.add('type:${androidInfo.type}');
        
        // Physical characteristics
        components.add('physicalDevice:${androidInfo.isPhysicalDevice}');
        
        // Add some randomness based on supported features
        final supportedAbis = androidInfo.supportedAbis.join(',');
        if (supportedAbis.isNotEmpty) components.add('abis:$supportedAbis');
        
        final supported32BitAbis = androidInfo.supported32BitAbis.join(',');
        if (supported32BitAbis.isNotEmpty) components.add('abis32:$supported32BitAbis');
        
        final supported64BitAbis = androidInfo.supported64BitAbis.join(',');
        if (supported64BitAbis.isNotEmpty) components.add('abis64:$supported64BitAbis');
        
        // For emulators, add additional entropy sources
        if (isEmulator) {
          // Add timestamp-based component for emulator uniqueness
          final prefs = await SharedPreferences.getInstance();
          String? emulatorSeed = prefs.getString('emulator_seed');
          if (emulatorSeed == null) {
            emulatorSeed = DateTime.now().millisecondsSinceEpoch.toString();
            await prefs.setString('emulator_seed', emulatorSeed);
            print('Generated emulator seed: $emulatorSeed');
          }
          components.add('emulatorSeed:$emulatorSeed');
        }
        
        if (components.isNotEmpty) {
          final combinedFingerprint = components.join('|');
          final prefix = isEmulator ? 'android_emu_fp' : 'android_fp';
          fingerprint = '${prefix}_${_generateHash(combinedFingerprint)}';
        }
        
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        
        final components = <String>[];
        
        if (iosInfo.model.isNotEmpty) components.add('model:${iosInfo.model}');
        if (iosInfo.name.isNotEmpty) components.add('name:${iosInfo.name}');
        if (iosInfo.systemName.isNotEmpty) components.add('system:${iosInfo.systemName}');
        if (iosInfo.systemVersion.isNotEmpty) components.add('version:${iosInfo.systemVersion}');
        if (iosInfo.localizedModel.isNotEmpty) components.add('localModel:${iosInfo.localizedModel}');
        if (iosInfo.utsname.machine.isNotEmpty) components.add('machine:${iosInfo.utsname.machine}');
        components.add('physical:${iosInfo.isPhysicalDevice}');
        
        if (components.isNotEmpty) {
          final combinedFingerprint = components.join('|');
          fingerprint = 'ios_fp_${_generateHash(combinedFingerprint)}';
        }
      }
      
      return fingerprint;
    } catch (e) {
      print('Failed to generate device fingerprint: $e');
      return '';
    }
  }
  
  /// Get or create a custom app-specific device ID
  static Future<String> _getOrCreateCustomId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customId = prefs.getString(_customIdKey);
      
      if (customId == null || customId.isEmpty) {
        // Generate a new custom ID with multiple entropy sources
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomComponent = _generateRandomString(12);
        final hashComponent = _generateHash(timestamp.toString() + randomComponent);
        customId = 'custom_${timestamp}_${hashComponent.substring(0, 8)}';
        
        // Save it for future use
        await prefs.setString(_customIdKey, customId);
        print('Generated new custom device ID: $customId');
      }
      
      return customId;
    } catch (e) {
      print('Failed to get/create custom ID: $e');
      // Fallback to timestamp-based ID with hash
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final hashComponent = _generateHash(timestamp.toString());
      return 'fallback_${timestamp}_${hashComponent.substring(0, 8)}';
    }
  }
  
  /// Generate hash from string
  static String _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Use first 16 characters
  }
  
  /// Generate random string
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final now = DateTime.now();
    final seed = now.millisecondsSinceEpoch + now.microsecond;
    
    return List.generate(length, (index) {
      final charIndex = (seed + index * 31 + index * index) % chars.length;
      return chars[charIndex];
    }).join();
  }
  
  /// Get detailed device information for debugging
  static Future<Map<String, dynamic>> getDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();
    final details = <String, dynamic>{};
    
    try {
      details['advertising_id'] = await _getAdvertisingId();
      details['device_specific_id'] = await _getDeviceSpecificId();
      details['fingerprint'] = await _generateDeviceFingerprint();
      details['custom_id'] = await _getOrCreateCustomId();
      details['final_device_id'] = await getDeviceId();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        details['platform'] = 'Android';
        details['android_details'] = {
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'id': androidInfo.id,
          'serialNumber': androidInfo.serialNumber,
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'fingerprint': androidInfo.fingerprint,
          'bootloader': androidInfo.bootloader,
          'board': androidInfo.board,
          'hardware': androidInfo.hardware,
          'product': androidInfo.product,
          'host': androidInfo.host,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          // 'user' property not available in newer device_info_plus versions
          'incremental': androidInfo.version.incremental,
          'supported_abis': androidInfo.supportedAbis,
          'is_physical_device': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        details['platform'] = 'iOS';
        details['ios_details'] = {
          'name': iosInfo.name,
          'model': iosInfo.model,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'localized_model': iosInfo.localizedModel,
          'utsname_machine': iosInfo.utsname.machine,
          'is_physical_device': iosInfo.isPhysicalDevice,
        };
      }
    } catch (e) {
      details['error'] = e.toString();
    }
    
    return details;
  }
  
  /// Test device uniqueness by generating multiple device IDs
  /// This method is for testing purposes only
  static Future<void> testDeviceUniqueness() async {
    print('\n=== DEVICE UNIQUENESS TEST ===');
    
    try {
      final deviceDetails = await getDeviceDetails();
      
      print('Platform: ${deviceDetails['platform']}');
      print('Advertising ID: ${deviceDetails['advertising_id']}');
      print('Device Specific ID: ${deviceDetails['device_specific_id']}');
      print('Device Fingerprint: ${deviceDetails['fingerprint']}');
      print('Custom ID: ${deviceDetails['custom_id']}');
      print('Final Device ID: ${deviceDetails['final_device_id']}');
      
      if (deviceDetails['platform'] == 'Android') {
        final androidDetails = deviceDetails['android_details'] as Map<String, dynamic>;
        print('\n--- Android Specific Details ---');
        print('Android ID: ${androidDetails['id']}');
        print('Serial Number: ${androidDetails['serialNumber']}');
        print('Model: ${androidDetails['model']}');
        print('Brand: ${androidDetails['brand']}');
        print('Device: ${androidDetails['device']}');
        print('Fingerprint: ${androidDetails['fingerprint']}');
        print('Hardware: ${androidDetails['hardware']}');
        print('Product: ${androidDetails['product']}');
        print('Bootloader: ${androidDetails['bootloader']}');
        print('Board: ${androidDetails['board']}');
        print('Host: ${androidDetails['host']}');
        print('Tags: ${androidDetails['tags']}');
        print('Type: ${androidDetails['type']}');
        // User property not available in newer device_info_plus versions
        print('Incremental: ${androidDetails['incremental']}');
        print('Supported ABIs: ${androidDetails['supported_abis']}');
      }
      
    } catch (e) {
      print('Error during uniqueness test: $e');
    }
    
    print('============================\n');
  }
}
