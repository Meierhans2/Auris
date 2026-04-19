# Troubleshooting

## Linux 32-bit: `libvulkan.so.1: cannot open shared object file`

**Error:**
```
[auris] addons/auris/lua/autorun/server/sv_auris_init.lua:3: Couldn't load module library! (libvulkan.so.1: cannot open shared object file: No such file or directory)
  1. require - [C]:-1
   2. unknown - addons/auris/lua/autorun/server/sv_auris_init.lua:3
```

**Cause:** GMod runs as 32-bit; the system only has the 64-bit `libvulkan` installed.

**Fix:**
```bash
sudo apt-get install libvulkan1:i386
```

If that fails (i386 architecture not enabled):
```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libvulkan1:i386
```
