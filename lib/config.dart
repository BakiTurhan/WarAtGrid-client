/// Game Configuration - Runtime-configurable values
/// Can be modified via Settings screen during gameplay
library game_config;

class GameConfig {
  // Singleton for runtime access
  static final GameConfig _instance = GameConfig._();
  static GameConfig get instance => _instance;
  GameConfig._();
  
  // ========== PLAYER ==========
  double playerRadius = 20.0;
  double playerSpeed = 200.0;
  double playerKnifeSpeedMultiplier = 1.5;
  double playerMaxHealth = 100.0;
  double playerStartHealth = 100.0;
  double playerDamageCooldown = 0.5;
  
  // ========== DASH ==========
  double dashDistance = 300.0;
  double dashSpeed = 1500.0;
  double dashCooldown = 1.5;
  double dashAoeRadius = 45.0;
  int dashKillScore = 100;
  
  // ========== AMMO ==========
  int magazineSize = 12;
  double reloadTime = 1.5;
  
  // ========== GRENADE ==========
  double grenadeSpeed = 300.0;
  double grenadeRadius = 80.0;
  double grenadeDelay = 1.0; // Faster explosion
  double grenadeCooldown = 10.0;
  int grenadeKillScore = 75;
  
  // ========== BLADE WAVE ==========
  double bladeWaveRange = 200.0; // Longer range
  double bladeWaveAngle = 0.8; // ~45 degrees each side (narrower)
  double bladeWaveCooldown = 3.0;
  
  // ========== BULLET ==========
  double bulletRadius = 5.0;
  double bulletSpeed = 600.0;
  int bulletKillScore = 50;
  
  // ========== ENEMY ==========
  double enemyRadius = 15.0;
  double enemySpeed = 100.0;
  double enemyContactDamage = 10.0;
  double enemySpawnInterval = 2.0;
  int meleeKillScore = 50;
  
  // ========== WORLD ==========
  double worldWidth = 2000.0;
  double worldHeight = 2000.0;
  double gridSize = 50.0;
  double wallThickness = 20.0;
  int obstacleCount = 20;
  
  // ========== FOV ==========
  double viewRadius = 600.0;
  
  // ========== SCORING ==========
  int scoreDigits = 6;
  
  // Reset to defaults
  void resetToDefaults() {
    playerRadius = 20.0;
    playerSpeed = 200.0;
    playerKnifeSpeedMultiplier = 1.5;
    playerMaxHealth = 100.0;
    playerDamageCooldown = 0.5;
    dashDistance = 300.0;
    dashSpeed = 1500.0;
    dashCooldown = 1.5;
    dashAoeRadius = 45.0;
    magazineSize = 12;
    reloadTime = 1.5;
    grenadeRadius = 80.0;
    grenadeDelay = 2.0;
    grenadeCooldown = 10.0;
    bulletSpeed = 600.0;
    enemySpeed = 100.0;
    enemyContactDamage = 10.0;
    enemySpawnInterval = 2.0;
    viewRadius = 600.0;
  }
}

// Shorthand for accessing config
GameConfig get cfg => GameConfig.instance;
