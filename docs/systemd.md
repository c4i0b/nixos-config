# Systemd Services & Timers on NixOS

## System-level (`systemd.services` / `systemd.timers`)

Runs as root or a specified user. Active at boot.

```nix
systemd.services.my-daemon = {
  description = "My system service";
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = ''${pkgs.my-package}/bin/daemon'';
    User = "nobody";
  };
};
```

### System timer

```nix
systemd.timers."hello-world" = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnBootSec = "5m";
    OnUnitActiveSec = "5m";
    Unit = "hello-world.service";
  };
};

systemd.services."hello-world" = {
  script = ''
    ${pkgs.coreutils}/bin/echo "Hello World"
  '';
  serviceConfig.Type = "oneshot";
};
```

### Shorthand `startAt`

Auto-creates a timer from `OnCalendar`:

```nix
systemd.services.hello-world = {
  script = ''
    ${pkgs.coreutils}/bin/echo "Hello World"
  '';
  serviceConfig.Type = "oneshot";
  startAt = "*:0/5";  # every 5 minutes
};
```

---

## User-level (`systemd.user.services` / `systemd.user.timers`)

Runs as the logged-in user. Stops on logout unless linger is enabled.

```nix
systemd.user.services.my-service = {
  enable = true;
  after = [ "network.target" ];
  wantedBy = [ "default.target" ];
  description = "My Cool User Service";
  serviceConfig = {
    Type = "simple";
    ExecStart = ''/path/to/binary'';
  };
};
```

### User timer

```nix
systemd.user.timers.my-timer = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "daily";
    RandomizedDelaySec = "30min";
    Persistent = true;
  };
};

systemd.user.services.my-timer = {
  description = "My scheduled job";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = ''${pkgs.my-package}/bin/my-command'';
  };
};
```

### Lingering (run after logout)

```nix
users.users.<name>.linger = true;
```

Or: `sudo loginctl enable-linger <user>`

With linger enabled, use `wantedBy = [ "multi-user.target" ]` to keep services running after logout.

### Targeting specific users

```nix
systemd.user.services.my-service = {
  unitConfig.ConditionUser = "caio";
  # ...
};
```

---

## Commands

| Scope | Command |
|-------|---------|
| System | `systemctl status <service>` |
| System | `journalctl -u <service>` |
| System | `systemctl list-timers` |
| User   | `systemctl --user status <service>` |
| User   | `journalctl --user-unit <service>` |
| User   | `systemctl --user list-timers` |

## Validate calendar expressions

```bash
systemd-analyze calendar --iterations=5 "daily"
systemd-analyze calendar --iterations=5 "Mon *-*-* 10:00:00"
```
