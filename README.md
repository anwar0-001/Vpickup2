# Vpickup2

Vpickup2 is a **new, independent Android driving/life-simulation game prototype**. It is not a modified copy of PickUp Beta and does not include its proprietary game files or assets.

## Current prototype features
- Procedurally built village and city zones joined by roads.
- A simple player-controlled pickup built from original primitive geometry.
- A basic city car dealership and food market.
- Six individually purchasable houses.
- A work button that awards money.
- A single-player infinite-money toggle.
- Keyboard driving controls for desktop testing.

## Engine
- Godot 4.x
- GDScript
- 3D primitive meshes, generated at runtime

## Run
1. Install Godot 4.3 or a compatible Godot 4.x release.
2. Import this folder as a project.
3. Open `project.godot` and press Play.
4. Drive using **WASD** or arrow keys. Press **E** or the on-screen Interact button near shops/houses.

## Android build
Android export requires Godot's Android export templates and Android SDK/JDK configured in the editor. This repository currently contains the source prototype, not a prebuilt APK.

## Planned next milestones
1. Add touch steering/throttle controls for Android.
2. Improve driving physics, collisions, camera follow and vehicle purchase/selection.
3. Add usable house interiors, ownership persistence and more jobs.
4. Replace prototype primitive geometry with original or properly licensed 3D assets.
5. Test performance and build a signed Android APK.

## Assets and intellectual property
All current visual elements are generated from simple geometric primitives. The game is inspired by the broad genre of pickup driving and open-world life simulation, not a reproduction of another game's source code or proprietary assets.
