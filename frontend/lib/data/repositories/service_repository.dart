import '../models/service_model.dart';
import '../services/listing_service.dart';

class ServiceRepository {
  final ServiceService _serviceService;

  const ServiceRepository(this._serviceService);

  Future<List<ServiceModel>> getServices({bool forceRefresh = false}) =>
      _serviceService.getServices(forceRefresh: forceRefresh);

  Future<void> invalidateCache() => _serviceService.invalidateCache();
}