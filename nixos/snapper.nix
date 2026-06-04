# BTRFS snapshot scheduling.
{ ... }:
{
  services.snapper = {
    snapshotInterval = "daily";
    persistentTimer = true;
    configs.home = {
      SUBVOLUME = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_DAILY = 10;
      NUMBER_LIMIT = 5;
    };
  };
}
