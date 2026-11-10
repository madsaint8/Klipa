abstract class CacheService {
  Future<void> savePortfolio(String json);

  Future<String?> loadPortfolio();

  Future<void> clearPortfolio();
}