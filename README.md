# Vpickup2 — الإصدار الثاني

**اسم النسخة الحالية:** Vpickup2 - الإصدار الثاني

This second edition focuses on improved world visuals, more detailed pickup geometry, and a richer city environment.

Vpickup2 is an independent 3D driving and life-simulation game for Android, made with Godot 4 and original procedural geometry. It is inspired by the broad genre, not copied from PickUp Beta, and does not include that game's code or assets.

## Included in the current source
- A green open-world test map with a village, a small city, and connecting roads.
- A player-driven pickup with arcade acceleration, braking, reverse and steering.
- Touch buttons for left/right steering, acceleration and braking, plus an interact button.
- A car dealership, food shop and six houses for sale.
- A delivery mission loop: start a job, collect a parcel at the village marker, deliver it to the city marker, and earn $350.
- Four moving ambient traffic cars using two city-road lanes.
- Automatic day/night cycle with a persistent in-game clock and warm street lights that turn on after dark.
- Pickup headlights that automatically illuminate the road in low daylight, with braking-before-reverse handling and speed-sensitive steering.
- Visible pickup/drop-off markers, a parcel displayed in the pickup bed, and saved mission progress.
- Food purchase interaction, house purchasing, and an infinite-money toggle.
- Local save file for money, infinite-money setting and house ownership.
- Android export preset and GitHub Actions workflow intended to build a debug APK.

## Controls
- Android: use the on-screen left/right, accelerate and brake buttons. Drive near the dealership, food market or one of the six sale houses, then tap Interact.
- Desktop: WASD or arrow keys to drive; E to interact.
- Tap Delivery +$350 to accept a delivery job; collect the parcel at the yellow village marker and deliver it to the blue city marker.
- Toggle Infinite to switch between normal spending and unlimited money.

## Build locally
1. Install Godot 4.3 and its Android export templates.
2. Configure the Android SDK and Java SDK in Godot Editor settings.
3. Open/import this repository project.godot.
4. Choose Project > Export > Android and export a debug APK.

## Build on GitHub
The workflow at .github/workflows/android.yml runs on pushes to main that change game files and can also be started manually from Actions > Build Vpickup2 Android APK > Run workflow. If the workflow succeeds, download the Vpickup2-Android-APK artifact from that run.

## Important status
The repository is source code, not a guarantee that a build has passed. The first successful GitHub Actions run is required to verify the export environment and catch engine/parser issues. The game is still an early prototype: its world uses primitive shapes, the vehicle physics and collisions are basic, and interiors, pedestrians, advanced traffic navigation, audio, polished models and release signing remain future development work. Do not distribute a release build until it has been tested on real devices.

## Intellectual property
All current scene geometry is generated from simple built-in Godot meshes. Use only original or properly licensed assets when expanding the game.


## نسخة الويب

توجد لعبة ثلاثية الأبعاد مستقلة في مجلد `web-pickups/` ويمكن نشر ذلك المجلد عبر GitHub Pages باستخدام سير العمل الموجود في `.github/workflows/web-pickups-pages.yml`. تدعم نسخة الويب التحكم بلوحة المفاتيح واللمس، ومهام نقاط التفتيش ومكافآت الرصيد داخل الجولة.

شغّل خادم ملفات محليًا من `web-pickups/` (مثل `python -m http.server 8000`) ثم افتح الصفحة عبر `http://localhost:8000`. تحتاج اللعبة اتصالًا بالإنترنت لتحميل Three.js من CDN. التقدم والرصيد في نسخة المتصفح مؤقتان خلال الجولة ولا يُحفظان بعد إغلاق الصفحة.
