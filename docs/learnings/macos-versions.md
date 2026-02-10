# macOS Version-Specific Behaviors

Mole supports macOS 10.14+. This doc tracks version-specific quirks.

## General Patterns

- Always use `sw_vers -productVersion` to detect macOS version
- Feature-gate version-specific code with comparison functions
- Test on both Intel and Apple Silicon when possible

## Known Behaviors

### Network Volume Detection
- **Timeouts:** NFS/SMB/AFP can hang indefinitely. Always use 5-second timeout for volume checks.
- `stat` on network volumes may return empty or hang. Use `run_with_timeout` wrapper.

### SIP (System Integrity Protection)
- Cannot modify `/System`, `/usr`, `/bin`, `/sbin` even with sudo
- `cmd/analyze/` respects SIP by running as standard user
- Error code `MOLE_ERR_SIP_PROTECTED=10` for SIP-blocked operations

### Time Machine
- Check `tmutil status` before cleanup operations
- If Time Machine is running OR status is unclear, skip all cleanup
- This prevents data loss during backup snapshots

### LaunchAgent Behaviors
- `com.apple.*` items are system-managed, never touch them
- `launchctl` behavior changed between macOS versions -- always check exit codes
- Stop services before removing their plist files

## Testing Across Versions

CI tests on macOS-14 and macOS-15. For local testing:
- Use `sw_vers -productVersion` to log the test environment
- Conditional tests: skip version-specific tests when running on wrong version
