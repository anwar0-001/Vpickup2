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
- Pickup headlights that automatically illuminate the road in low daylight, with braking-before-reverse handling, speed-sensitive steering, and collision slowdown against walls and vehicles.
- Visible pickup/drop-off markers, a parcel displayed in the pickup bed, and saved mission progress.
- Persistent mission objective HUD showing the current delivery step and live distance to the village pickup or city drop-off.
- Food purchase interaction, house purchasing, and an infinite-money toggle.
- Local save file for money, infinite-money setting, house ownership, mission progress, world time and vehicle position; progress autosaves every 10 seconds and when the app pauses or closes.
- Android export preset and GitHub Actions workflow intended to build a debug APK.

## Controls
- Android: use the on-screen left/right, accelerate and brake buttons. Drive near the dealership, food market or one of the six sale houses, then tap Interact.
- Desktop: WASD or arrow keys to drive/walk; E to interact; F to exit or re-enter the parked vehicle; M to open the map.
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

توجد لعبة ثلاثية الأبعاد مستقلة في مجلد `web-pickups/`، وتبقى متاحة على المسار الفرعي `/web-pickups/`. ينشر سير العمل `.github/workflows/web-pickups-pages.yml` أيضاً لعبة العالم المفتوح الموجودة في `index.html` على الصفحة الرئيسية لـ GitHub Pages، مع فحص JavaScript قبل النشر. تدعم النسخة القديمة التحكم بلوحة المفاتيح واللمس ومهام نقاط التفتيش ومكافآت الرصيد داخل الجولة.

شغّل خادم ملفات محليًا من `web-pickups/` (مثل `python -m http.server 8000`) ثم افتح الصفحة عبر `http://localhost:8000`. تحتاج اللعبة اتصالًا بالإنترنت لتحميل Three.js من CDN. التقدم والرصيد في نسخة المتصفح مؤقتان خلال الجولة ولا يُحفظان بعد إغلاق الصفحة.

## Browser game — Open World upgrade

The repository root now also contains a standalone browser edition in `index.html`. It is a separate Three.js implementation and does not replace or modify the Godot project files.

### Browser edition features
- Procedurally generated 3D city with a downtown district, suburban blocks, industrial area, highway corridor, bridge, waterfront and rural hills.
- Phase 1 expanded the playable world bounds to roughly 2.8 km × 2.8 km and added distinct procedural regions: downtown/suburbs, airport runway and terminal, industrial docks and container yard, coral beach and islands, Emerald Lake with an island, pine forest, northern mountain range, desert dunes and rural outskirts.
- New outer highways and a continuous coastal crossing connect remote regions; region groups stream by distance and the full map now labels districts while the minimap tracks the active player locally.
- Generated geometry and canvas-made landmark signs; no downloaded models, image textures, logos, characters or audio files.
- Grid road network, lane markings, sidewalks, traffic signals, ambient traffic and simple pedestrian movement.
- Day/night lighting cycle and dynamic clear, fog and rain weather; rain changes road material response.
- Four selectable vehicle profiles (pickup, van, sports car and truck), steering, acceleration, braking, handbrake, collision damage, fuel and service stations.
- Phase 1 driving update: speed-sensitive steering, acceleration and braking response, road/off-road grip, wet-road traction loss, aerodynamic and rolling drag, handbrake slip, tire wear saved locally, repairable tire condition, wheel steering/rotation and improved obstacle/building collision response.
- Delivery contracts with pickup and drop-off stages, fragile/heavy/urgent and long-distance jobs, time limits, traffic fines, rewards, repair and fuel services.
- Phase 1 delivery contracts now dispatch pickups across the airport, port, forest, mountains, desert, beach, lake and residential districts, with distance-scaled rewards and deadlines before returning cargo to the central delivery hub.
- Garage upgrades for engine, grip, fuel tank and cargo; local browser save and migration of the earlier web game's coin balance when available.
- Chase, hood and cinematic camera modes, mobile touch controls, keyboard controls, minimap/full map with a route line, Low/Medium/High quality presets and optional FPS counter.
- On-foot third-person character mode: safely exit only after stopping, walk and turn with the same touch/keyboard controls, re-enter near the parked vehicle, and use nearby fuel, repair and garage services while on foot.
- Walk to mission parcels and the delivery hub to collect and complete contracts on foot; carried parcels transfer between the character and vehicle. The full map and minimap follow whichever mode is active.
- Original pedestrian character geometry with simple limb animation, walking collision against trees/rocks, pedestrian avoidance, added vehicle body details, rotating wheels and visible body roll/pitch under steering and braking.
- Web Audio generated engine tone, a simple synthesized radio melody loop and UI effects, plus vibration feedback where supported.

### Run the browser edition
1. Open [the GitHub Pages game](https://anwar0-001.github.io/Vpickup2/) after the Pages deployment finishes.
2. Allow the page to load the pinned Three.js 0.160.0 module from jsDelivr; an internet connection is required on first load.
3. On mobile, use the left steering pad and the right-side accelerator/brake controls. Use Interact near parcels, service stations or the delivery hub.
4. On desktop, use WASD or arrow keys to drive, E to interact and M to open the map.

### Current development status and limitations
Phase 1 is a playable procedural open-world foundation, not a finished AAA-scale simulation. The map and delivery loop are expanded, but enterable interiors, underwater exploration, aircraft/boats, story chapters, property systems and the wider life-simulation features are intentionally reserved for later approved phases. Traffic and pedestrians use lightweight waypoint-like movement rather than full city navigation; vehicle handling is arcade/simplified rather than a full tire-and-suspension physics solver; rain uses a procedural particle field and wet-looking road material rather than expensive planar reflections. A fully modelled vehicle interior, full cargo rigid-body simulation, advanced damage meshes, deeper pedestrian AI and richer character animation, radio music composition, and comprehensive device testing remain future work. Low/Medium/High settings adjust render resolution, shadows, rain and distance culling; performance depends on the phone/browser/GPU.

The browser save is stored locally in the current browser profile and is not synchronized with the Godot save or other devices. The original Godot project and its existing workflows remain unchanged.

## Phase 2 — المنازل القابلة للشراء والديكورات الداخلية

أضيفت في نسخة المتصفح:
- ثلاثة منازل إجرائية في مناطق مختلفة من الخريطة، ولكل منزل سعر شراء وموقع مستقل.
- شراء المنزل بالرصيد داخل اللعبة، مع حفظ الملكية محلياً في المتصفح.
- دخول المنزل والخروج منه بشخصية اللاعب سيراً على الأقدام.
- مساحة داخلية إجرائية مشتركة تضم غرفة معيشة وسريراً ومطبخاً وأثاثاً أساسياً، من دون تنزيل نماذج أو صور خارجية.
- التفاعل مع السرير لتجاوز الوقت إلى الساعة 07:00، والتفاعل مع المدخل للعودة إلى العالم المفتوح.
- إظهار مواقع المنازل على الخريطة، مع تمييز المنازل التي تم شراؤها.
- إيقاف تحديث حركة المرور والمشاة والطقس والوقت الخارجي أثناء وجود اللاعب داخل المنزل لتقليل العمل غير الضروري.

**طريقة التجربة:** ابدأ اللعبة، انزل من المركبة بعد توقفها، ثم اقترب سيراً من أحد المنازل الثلاثة واضغط «تفاعل». اشترِ المنزل إن لم يكن مملوكاً، ثم تحرك داخله للوصول إلى السرير أو الباب. الملكية تحفظ في بيانات المتصفح على الجهاز نفسه.

**حدود المرحلة:** هذه بداية لنظام العقارات وليست نظام حياة كاملاً؛ المنازل الثلاثة تستخدم تخطيطاً داخلياً واحداً، ولا توجد بعد ديكورات قابلة للتخصيص أو تخزين أغراض أو نظام عائلة أو حفظ سحابي. يجب اختبار الحركة والتفاعل فعلياً على الهاتف قبل اعتماد المرحلة نهائياً.
