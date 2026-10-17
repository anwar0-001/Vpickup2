import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const html=readFileSync('web-pickups/index.html','utf8');
const css=readFileSync('web-pickups/style.css','utf8');
const js=readFileSync('web-pickups/game.js','utf8');
assert.ok(html.includes('<script type="module" src="game.js"></script>'),'HTML must load the game module');
assert.ok(html.includes('<div id="game"></div>'),'HTML must provide the rendering root');
assert.ok(css.includes('#touchControls{'),'Touch controls must have styles');
for(const name of ['missionUpdate','updateCamera','hud','loop']) {
  assert.equal(js.split('function '+name+'(').length-1,1,name+' must be defined exactly once');
}
assert.ok(js.includes('تعذر تشغيل الرسوم ثلاثية الأبعاد'),'WebGL failure must be visible');
assert.ok(js.includes("['pointerup','pointercancel','lostpointercapture']"),'camera drag must stop on pointer release or cancellation');
console.log('Web game structure checks passed');
