# Vpickup2 — الإصدار الثاني

**اسم النسخة الحالية:** Vpickup2 - الإصدار الثاني

This second edition focuses on improved world visuals, more detailed pickup geometry, and a richer city environment.

Vpickup2 is an independent 3D driving and life-simulation game for Android, made with Godot 4 and original procedural geometry. It is inspired by the broad genre, not copied from PickUp Beta, and does not include that game's code or assets.

## Included in the current source
- A green open-world test map with a village, a small city, and connecting roads.
- A player-driven pickup with arcade acceleration, braking, reverse and steering.
- Touch buttons for left/right steering, acceleration and braking, plus an interact button.
- A car dealership, food shop and six houses for sale.
- A work button that pays $150, food purchase interaction, house purchasing, and an infinite-money toggle.
- Local save file for money, infinite-money setting and house ownership.
- Android export preset and GitHub Actions workflow intended to build a debug APK.

## Controls
- Android: use the on-screen left/right, accelerate and brake buttons. Drive near the dealership, food market or one of the six sale houses, then tap Interact.
- Desktop: WASD or arrow keys to drive; E to interact.
- Tap Work +$150 to earn money.
- Toggle Infinite to switch between normal spending and unlimited money.

## Build locally
1. Install Godot 4.3 and its Android export templates.
2. Configure the Android SDK and Java SDK in Godot Editor settings.
3. Open/import this repository project.godot.
4. Choose Project > Export > Android and export a debug APK.

## Build on GitHub
The workflow at .github/workflows/android.yml runs on pushes to main that change game files and can also be started manually from Actions > Build Vpickup2 Android APK > Run workflow. If the workflow succeeds, download the Vpickup2-Android-APK artifact from that run.

## Important status
The repository is source code, not a guarantee that a build has passed. The first successful GitHub Actions run is required to verify the export environment and catch engine/parser issues. The game is still an early prototype: its world uses primitive shapes, the vehicle physics and collisions are basic, and interiors, pedestrians, traffic, missions, audio, polished models and release signing remain future development work. Do not distribute a release build until it has been tested on real devices.

## Intellectual property
All current scene geometry is generated from simple built-in Godot meshes. Use only original or properly licensed assets when expanding the game.
