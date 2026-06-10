# Hardware peripherals (shared across all machines).
{ ... }:

{
  hardware = {
    bluetooth.enable = true;
    i2c.enable = true;
  };
}
