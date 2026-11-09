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

### Phase 2 — realistic vehicle physics
- Automatic 7-speed gearbox with RPM response, engine torque band and short shift interruptions.
- Vehicle mass affects acceleration; cargo load, damage, upgrades and tire wear continue to influence performance.
- Spring-like per-wheel travel, visible body pitch under acceleration/braking and body roll under cornering.
- Lateral inertia and handbrake drift with traction recovery; grip changes with road, rain and tire condition.
- ABS-style braking modulation on low-grip surfaces, with a live RPM / gear / ABS dashboard readout.
- Fuel consumption now responds to throttle and vehicle load. All physics and visual effects are procedural; no external vehicle assets were added.

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

## Phase 3 — خامات إجرائية للعشب والأسفلت والأرصفة

تم تحسين المواد المرئية في نسخة المتصفح باستخدام خامات تُنشأ داخل المتصفح عند تشغيل اللعبة، من دون تحميل صور أو نماذج خارجية:
- خامة عشب بتدرجات لونية وتفاصيل دقيقة قابلة للتكرار على مساحة العالم.
- خامة أسفلت أكثر واقعية مع حبيبات وتفاوتات لونية خفيفة، وتكرار مضبوط حسب أبعاد الطريق حتى لا تتمدد على الطرق الطويلة.
- خامة خرسانة للأرصفة مع خشونة سطحية خفيفة.
- خرائط bump منخفضة الشدة لإظهار التفاصيل مع الحفاظ على مظهر هادئ.
- استخدام خامات صغيرة مشتركة لتقليل الذاكرة وتجنب إنشاء خامة منفصلة لكل طريق.
- تبقى المواد متوافقة مع إعدادات جودة الرسوم الحالية، ولا تتطلب ملفات أصول إضافية.

**ملاحظة:** التحسين يخص خامات الأرض والطرق والأرصفة؛ لا يعني إضافة نظام تضاريس واقعي كامل أو مواد PBR عالية الدقة. يلزم اختبار الأداء والمظهر على الهاتف الفعلي.


## Phase 4 — تحسين تفاصيل المنازل والواجهات

تم تطوير المنازل الثلاثة القابلة للشراء في نسخة المتصفح مع الحفاظ على نظام الشراء والملكية والدخول والخروج كما هو:
- استبدال السقف المسطح بسقف مائل ذي واجهتين مثلثتين، مع اختلاف ألوان الأسقف بين المنازل.
- إضافة قاعدة حجرية، وإطارات للنوافذ، وألواح زجاجية وتقسيمات داخلية ومصاريع جانبية.
- تحسين المدخل بإطار خشبي ومقبض وغطاء علوي وعمودين ودرجات أمامية.
- إضافة نوافذ جانبية ومدخنة ومصابيح خارجية وأحواض نباتية صغيرة.
- استخدام هندسة ومواد إجرائية أصلية من Three.js، من دون تنزيل أصول خارجية أو تغيير نظام الحفظ.

**حدود المرحلة:** التفاصيل تخص المنازل الثلاثة القابلة للشراء في نسخة المتصفح؛ لم يتم بعد إعادة بناء جميع مباني المدينة كنماذج معمارية فريدة. أضفنا التفاصيل إلى عدد محدود من المباني لتقليل أثرها على أداء الهواتف. يلزم اختبار المظهر والأداء على الهاتف الفعلي قبل اعتماد المرحلة نهائياً.


## Phase 5 — تحسين نظام الطقس الحي

تم تطوير نظام الطقس في نسخة المتصفح مع الحفاظ على التبديل التلقائي:
- إضافة زر «طقس» للتبديل المباشر بين الجو الصافي والمطر والضباب، لتسهيل التجربة دون انتظار الدورة التلقائية.
- انتقال تدريجي بين ألوان السماء وكثافة الضباب بدلاً من التغيير المفاجئ.
- تحسين قطرات المطر إلى خطوط مائلة متحركة مع تأثير الرياح وإعادة تدوير الجسيمات حول اللاعب.
- ضبط ظهور المطر حسب إعداد الجودة؛ يتوقف تأثير المطر المرئي في وضع Low لتقليل الحمل.
- تحسين مظهر الأسفلت المبتل، مع الإبقاء على انخفاض التماسك أثناء المطر ضمن فيزياء القيادة الموجودة.
- لا توجد ملفات صور أو مؤثرات خارجية جديدة؛ التأثيرات مولّدة برمجياً، وعدد الجسيمات محدود بحسب الجودة.

**طريقة التجربة:** ابدأ اللعبة ثم اضغط «طقس: صافٍ» أعلى الشاشة للتبديل بين المطر والضباب والجو الصافي. جرّب القيادة أثناء المطر لملاحظة اختلاف تماسك الإطارات ومظهر الطريق.

**حدود المرحلة:** المطر والضباب هنا مؤثرات بصرية خفيفة وليسا محاكاة مناخية كاملة؛ لا توجد بعد برك مياه ديناميكية أو مساحات انعكاس حقيقية أو عواصف رعدية. يلزم اختبار فعلي على الهاتف للتأكد من ثبات معدل الإطارات.

## Phase 6 — ملفات جودة الرسوم والأداء للهواتف

تم توحيد إعدادات الرسوم في ملفات جودة فعلية تُطبّق عند التشغيل وعند تغيير المستوى، بدلاً من تغيير دقة العرض والظلال بشكل منفصل:
- **Low:** دقة عرض مستهدفة 0.8×، إيقاف الظلال، تقليل مدى المباني والمناطق وحركة المرور والمشاة، وتقليل المطر إلى 140 خطاً.
- **Medium:** دقة 1×، ظلال بخريطة 512×512، مدى تفاصيل متوسط، ومطر محدود إلى 360 خطاً. هذا هو الخيار المتوازن المقترح لمعظم الهواتف.
- **High:** دقة مستهدفة 1.35×، ظلال أنعم بخريطة 1024×1024، مدى رؤية أوسع، ومطر حتى 650 خطاً.
- تحديث مدى التفاصيل حول اللاعب بحسب الملف المختار لتقليل العناصر البعيدة التي لا يحتاج عرضها حالياً.
- تخصيص سعة المطر مرة واحدة ثم تغيير عدد الخطوط النشطة فقط عند تبديل الجودة، لتجنب إعادة إنشاء هندسة المطر.
- تطبيق الإعدادات على زر الجودة السريع وعلى شاشة الإعدادات، وحفظ المستوى المختار محلياً.
- إظهار معلومات الدقة والظلال ومدى التفاصيل داخل شاشة إعدادات الرسوم.

**طريقة التجربة:** من القائمة افتح «الجودة والإعدادات»، ثم جرّب Low وMedium وHigh. ويمكن تبديل المستوى سريعاً من زر Q أثناء اللعب. راقب عداد FPS الاختياري، واختر Medium إذا لم يكن الأداء مستقراً.

**حدود الاختبار:** هذه القيم ملفات ضبط مستهدفة وليست ضماناً لعدد إطارات محدد؛ الأداء الفعلي يعتمد على الهاتف والمتصفح وحرارة الجهاز. لم يُجرَ اختبار ميداني على أجهزة أندرويد ضمن هذا التعديل، ويجب اختبار المستويات الثلاثة على الهاتف قبل اعتبار الأداء معتمداً نهائياً.


## Phase 7 — حركة مرور أكثر واقعية

تم تحسين حركة المركبات المدنية في نسخة المتصفح من دون إضافة نماذج أو ملفات أصول خارجية:
- توزيع السيارات في مسارين متعاكسين داخل الطرق بدلاً من تكدس الاتجاهين في خط واحد.
- إضافة مصابيح أمامية وخلفية مرئية للمركبات المحيطة.
- جعل السيارات تتسارع وتتباطأ تدريجياً بدلاً من التوقف والتشغيل الفوري.
- إضافة مسافة أمان ومتابعة للمركبة التي تسير أمام السيارة في المسار والاتجاه نفسيهما، لتقليل تداخل المركبات.
- تحسين التوقف عند الإشارات الحمراء والمشاة، مع إظهار أضواء الفرامل أثناء التباطؤ.
- الحفاظ على عدد المركبات المحدود وحركة خفيفة مناسبة لنسخة المتصفح والهواتف.

**حدود المرحلة:** حركة المرور ما زالت تعتمد مسارات مستقيمة ودوراناً عند حدود المنطقة، وليست نظام ملاحة مدن كاملاً؛ لم نضف بعد تقاطعات ذكية متعددة المسارات أو تغيير حارات أو قيادة ذاتية متقدمة. يجب اختبار السلوك فعلياً داخل اللعبة وعلى الهاتف.


## Phase 8 — إعادة تصميم مركبة اللاعب

تم تطوير بناء المركبة الإجرائي في نسخة المتصفح باستخدام هندسة Three.js أصلية، مع الإبقاء على ملفات الأصول الخارجية غير مطلوبة:
- تحسين الهيكل السفلي والواجهة الأمامية والصدامات والشبك المعدني.
- إضافة زجاج أمامي وخلفي وجانبي، ومرايا جانبية، ومقابض أبواب وخطوط تقسيم الأبواب.
- إضافة مقصورة داخلية مبسطة تشمل لوحة قيادة ومقاعد ومقوداً مرئياً من الزجاج.
- تطوير العجلات بإطارات أعرض ومحاور وجنوط وأغطية مركزية وتفاصيل تثبيت.
- إضافة مصابيح أمامية وخلفية وأجزاء معدنية جانبية.
- بناء صندوق خلفي مفتوح للـPickup بجوانب مرتفعة وحواف معدنية وأرضية، مع إبقاء بقية أنواع المركبات على هيكلها العام المحسّن.
- الإبقاء على أسماء المركبات وسرعاتها وسعاتها وكتلتها، وعلى نظام تغيير المركبة والتحكم والفيزياء والكاميرا والحفظ كما هي.

**حدود المرحلة:** النموذج أكثر تفصيلاً لكنه ما زال مبنياً من أشكال إجرائية وليس نموذجاً مصنعياً عالي الدقة أو نظام تعليق ميكانيكياً مفصلاً. يلزم فحص التشغيل في المتصفح وتجربة المركبات الأربع على الهاتف.


## Phase 9 — تضاريس طبيعية وتفاصيل المناطق الخارجية

تم تحسين تضاريس المناطق الخارجية في نسخة المتصفح باستخدام هندسة إجرائية أصلية وخفيفة:
- إضافة رقع تضاريس شبكية منخفضة الكثافة بارتفاعات ناعمة ومتدرجة حول غابة الصنوبر وسفوح جبال الشمال والصحراء وشاطئ المرجان.
- تشكيل الارتفاعات بمزيج من تموجات طبيعية وقمم منخفضة موزعة ببذور ثابتة، مع تلوين رأسي بسيط يمنح السطح اختلافاً بصرياً.
- الحفاظ على الطرق الرئيسية وممرات المناطق كما هي، وإبقاء التضاريس الجديدة ضمن رقع محلية حتى لا تغطي شبكة الطرق أو المباني.
- استخدام شبكة 28×28 لكل رقعة، وخامات مشتركة منخفضة الكلفة، ومنع الظلال الذاتية لهذه الرقع لتقليل الحمل على الهواتف.
- عدم إضافة أي ملفات أو نماذج أو صور خارجية؛ جميع الأشكال تُنشأ داخل Three.js.

**حدود المرحلة:** الارتفاعات الحالية تحسين بصري للتلال والسفوح وليست نظام تضاريس فيزيائياً كاملاً؛ أرضية القيادة والتصادمات ما زالت تعتمد المستوى الأساسي، لذلك لا ينبغي اعتبار التلال الجديدة مسارات قيادة وعرة قابلة للصعود. لم يُجرَ اختبار ميداني على هاتف ضمن هذا التعديل.


## Phase 10 — شبكة الطرق الريفية والممرات والجسور

- إنشاء مسار جبلي متعرج على شكل مقاطع متصلة يربط سفوح الجبل بالطريق الرئيسي، مع نقطة توقف جانبية مطلة.
- إضافة تفاصيل حواف وحواجز بصرية على أجزاء من الطرق الريفية، مع إبقاء بيانات الطرق في شبكة العالم حتى تظهر على الخريطة المصغرة وتُحتسب ضمن تماسك سطح القيادة.
- توسيع الوصول الساحلي بمقطع جانبي وتفرع إلى منطقة مطلة قرب الشاطئ.
- إضافة بنية جسر مرتفع قصيرة مع حواجز جانبية ودعامات، وربطها بممر الساحل.
- جميع العناصر هندسة Three.js أصلية، دون تنزيل أصول خارجية.

**حدود المرحلة:** المقاطع الجديدة متعامدة ومتدرجة وليست منحنيات قيادة حقيقية ذات مسار ملاحي؛ الجسر عنصر بصري فوق مسار موجود وليس نظام جسور ديناميكيّاً. الحواجز الجانبية زخرفية ولا تعمل كتصادمات مادية مستقلة. لم يُجرَ اختبار قيادة فعلي على هاتف.

## Roadmap Phase 3 — تحكم اللمس والكاميرات

تم تطوير التحكم والكاميرا في نسخة المتصفح مع الحفاظ على أزرار القيادة الحالية:
- إضافة خيار اختياري لتوجيه المركبة بميل الهاتف يميناً ويساراً عبر مستشعر Device Orientation؛ لا يطلب المتصفح الإذن إلا بعد ضغط اللاعب على زر «ميل الهاتف».
- دمج توجيه الميل مع عصا اللمس وأزرار لوحة المفاتيح، كما يعمل أثناء قيادة الشخصية سيراً على الأقدام.
- إعادة ضبط حساسية الميل حول المنتصف لتقليل الاهتزاز، مع تحديد أقصى زاوية توجيه.
- تحسين توزيع أحجام وأماكن عصا التوجيه والدواسات والأزرار على الشاشات الصغيرة، وإضافة تخطيط أفقي للشاشات القصيرة.
- توضيح أسماء أوضاع الكاميرا على زر الكاميرا: مطاردة، داخل المركبة، وسينمائية.
- تطوير الوضع السينمائي بحركة جانبية بطيئة وارتفاع متغير بسلاسة، مع بقاء وضع المطاردة والوضع الداخلي منفصلين.
- جميع التعديلات برمجية ولا تضيف صوراً أو نماذج أو ملفات خارجية.

**طريقة التجربة:** افتح اللعبة على هاتف يدعم مستشعر الاتجاه، وابدأ القيادة، ثم اضغط «ميل الهاتف: OFF» واسمح بالإذن إن طلبه المتصفح. أمل الهاتف تدريجياً للتوجيه، واضغط الزر مرة أخرى للعودة إلى عصا اللمس. اضغط زر الكاميرا للتنقل بين الأوضاع الثلاثة.

**حدود الاختبار:** يعتمد التحكم بالميل على دعم الجهاز والمتصفح ومستشعر الاتجاه؛ قد لا يظهر طلب الإذن في بعض أجهزة Android، وقد لا يعمل المستشعر داخل بعض المتصفحات أو عند حجب صلاحيات الحركة. لم يتم اختبار التفاعل فعلياً على الهاتف أو تأكيد نشر GitHub Pages في هذه المرحلة.

## Roadmap Phase 4 — القوائم والإعدادات وخانات الحفظ

تم توسيع واجهة نسخة المتصفح وإضافة نظام حفظ محلي متعدد الخانات:
- إضافة شاشة «إدارة خانات الحفظ» من القائمة الرئيسية، مع ثلاث خانات مستقلة.
- عرض حالة كل خانة ورصيدها وأفضل نتيجة، مع خيارات تحميل الخانة أو نسخ التقدم الحالي إليها أو حذفها.
- إنشاء خانة جديدة فارغة دون الكتابة فوق خانة مستخدمة.
- حفظ الخانة النشطة تلقائياً مع تقدم اللعبة، وإظهار رقمها في القائمة الرئيسية وشاشة الإيقاف المؤقت.
- إضافة الوصول إلى خانات الحفظ من شاشة الإيقاف المؤقت، وتوسيع الإعدادات لتشمل خيار التحكم بميل الهاتف إلى جانب مستويات الجودة وعداد FPS.
- ترحيل الحفظ القديم pickup_openworld_v1 إلى الخانة الأولى عند التحديث لأول مرة، مع استمرار كتابة نسخة توافقية بالمفتاح القديم.
- إعادة ضبط حالة العالم والمركبة عند تحميل خانة أو إنشاء خانة جديدة، مع استعادة المركبة والأضواء وإعداد الجودة.
- التخزين محلي داخل المتصفح وعلى الجهاز نفسه؛ لا يوجد تزامن سحابي بين الأجهزة.

**طريقة التجربة:** افتح القائمة الرئيسية ثم «إدارة خانات الحفظ». أنشئ خانة فارغة، أو استخدم «نسخ التقدم» لنسخ تقدمك الحالي إلى خانة أخرى، ثم جرّب تحميل الخانة أو حذفها. ستظهر الخانة النشطة في القائمة وشاشة الإيقاف المؤقت.

**حدود الاختبار:** لم يتم اختبار دورة إنشاء/تحميل/حذف الخانات فعلياً على متصفح الهاتف في هذه المرحلة. حذف الخانة نهائي من تخزين المتصفح المحلي، لذا تأكد من اختيار الخانة الصحيحة قبل الحذف.

## Roadmap Phase 5 — أساس الأداء والتحسين التكيفي

أضيفت طبقة أولية لموازنة الأداء في نسخة المتصفح:
- خيار «الضبط التلقائي للأداء» من الإعدادات، وهو متوقف افتراضياً ويمكن تشغيله أو إيقافه.
- قياس متوسط معدل الإطارات على نوافذ زمنية متتابعة بدلاً من اتخاذ قرار من قراءة لحظية واحدة.
- عند هبوط الأداء دون الحد المستهدف لفترتين متتاليتين، يخفض النظام مستوى الجودة خطوة واحدة حتى يصل إلى Low.
- عند استقرار الأداء فوق الحد الأعلى لثلاث فترات متتالية، يرفع الجودة تدريجياً خطوة واحدة حتى High.
- إعادة استخدام ملفات الجودة الحالية لتغيير دقة العرض والظلال ومدى التفاصيل وعدد جسيمات المطر، بدلاً من إنشاء إعدادات متضاربة.
- تقليل تحديث عناصر HUD إلى نحو 8 مرات في الثانية أثناء اللعب، مع إبقاء تحديثات الأحداث المهمة الفورية.
- يبقى اختيار الجودة اليدوي متاحاً، كما أن الضبط التلقائي لا يعمل إلا أثناء اللعب وبعد تفعيله صراحةً.

**طريقة التجربة:** افتح «الإعدادات» وفعّل «الضبط التلقائي للأداء»، ثم قد السيارة في مناطق مختلفة وراقب FPS إن فعّلت العداد. سيغير النظام الجودة تدريجياً عند استمرار انخفاض أو ارتفاع الأداء.

**حدود الاختبار:** حدود FPS المستخدمة مؤشرات تقريبية وليست ضماناً لمعدل إطارات معين. لا تتوفر حتى الآن نتائج قياس فعلية على أجهزة مختلفة، ولم يتم اختبار الهاتف ميدانياً ضمن هذه المرحلة.

## Roadmap Phase 6 — تحسين شبكة شوارع المدينة

تمت إضافة علامات مرورية حضرية إلى التقاطعات الرئيسية:
- إنشاء ممرات مشاة مخططة بخطوط عبور واضحة عند 25 تقاطعاً رئيسياً داخل شبكة المدينة.
- إضافة خطوط توقف قبل ممرات العبور على مداخل التقاطعات الأربعة.
- استخدام InstancedMesh لمشاركة هندسة الخطوط وتقليل عدد أوامر الرسم بدلاً من إنشاء مئات المجسمات المستقلة.
- إبقاء شبكة الطرق الحالية وبياناتها المستخدمة في حساب التماسك والخريطة كما هي دون تغيير مسارات القيادة.
- وضع العلامات على ارتفاع بسيط فوق الأسفلت لتقليل تداخل السطحين، مع تعطيل الظلال غير الضرورية لهذه العلامات.

**طريقة التجربة:** قد إلى التقاطعات الرئيسية في وسط المدينة، خصوصاً قرب الإحداثيات الوسطية للشبكة، وستظهر ممرات المشاة وخطوط التوقف على الأسفلت.

**حدود المرحلة:** هذه إضافة للعلامات الأرضية والتخطيط البصري؛ لم تتم إضافة نظام عبور مشاة ذكي أو إشارات مرور متعددة المراحل أو مسارات انعطاف مستقلة في هذه المرحلة. يلزم اختبار المظهر والأداء فعلياً على الهاتف.

## Roadmap Phase 7 — تضاريس المناطق والانتقالات الطبيعية

تم تحسين شبكة التضاريس الإجرائية للمناطق الطبيعية الموجودة في العالم:
- إضافة تلاشي ارتفاعات التضاريس تدريجياً عند حدود كل رقعة بدلاً من انتهاء التلال بشكل حاد.
- استخدام منحنى انتقال ناعم (smoothstep) لدمج الارتفاعات مع الأرض المحيطة وتقليل الحواف الهندسية الواضحة.
- جعل تلوين الرؤوس يعود إلى لون الأساس عند حواف الرقع، لتقليل اختلاف اللون المفاجئ بين التضاريس والسطح المحيط.
- الإبقاء على البذور الإجرائية وشبكات التضاريس الخفيفة للمناطق: غابة الصنوبر، جبال الشمال، صحراء الرمال، وشاطئ المرجان.
- الحفاظ على تقسيم المناطق وقواعد إخفاء المناطق البعيدة وإعدادات الجودة الحالية.

**طريقة التجربة:** تجول بين أطراف الغابة والجبال والصحراء والشاطئ ولاحظ انتقال التلال إلى الأرض المحيطة بشكل تدريجي.

**حدود المرحلة:** التحسين بصري وهندسي؛ لا تزال القيادة والتصادمات تعتمد سطحاً أساسياً مستوياً، ولم تتحول التلال إلى تضاريس فيزيائية قابلة للصعود والهبوط. لم يتم اختبار الأداء فعلياً على الهاتف.
