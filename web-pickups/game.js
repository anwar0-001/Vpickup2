import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.165.0/build/three.module.js';

// Pickups: مدينة ثلاثية الأبعاد مصغرة، شخصية، سيارات ومهمة نقطة تفتيش.
const root=document.querySelector('#game'), statusEl=document.querySelector('#status'), promptEl=document.querySelector('#prompt'), missionText=document.querySelector('#missionText'), timerBar=document.querySelector('#timer'), messageEl=document.querySelector('#message');
const scene=new THREE.Scene();scene.background=new THREE.Color(0x8fc7e8);scene.fog=new THREE.Fog(0x8fc7e8,100,270);
const camera=new THREE.PerspectiveCamera(68,innerWidth/innerHeight,.1,500);
let renderer;try{renderer=new THREE.WebGLRenderer({antialias:true,powerPreference:'high-performance'});renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,1.6));renderer.shadowMap.enabled=true;renderer.shadowMap.type=THREE.PCFSoftShadowMap;renderer.outputColorSpace=THREE.SRGBColorSpace;renderer.toneMapping=THREE.ACESFilmicToneMapping;root.appendChild(renderer.domElement)}catch(error){statusEl.textContent='تعذر تشغيل الرسوم ثلاثية الأبعاد';messageEl.textContent='يرجى استخدام متصفح يدعم WebGL وتحديث تعريف الرسوميات';console.error('WebGL initialization failed',error);throw error}
const hemi=new THREE.HemisphereLight(0xc4e8ff,0x526044,2);scene.add(hemi);
const sun=new THREE.DirectionalLight(0xfff0d5,3);sun.position.set(-65,95,50);sun.castShadow=true;sun.shadow.mapSize.set(1536,1536);sun.shadow.camera.left=-100;sun.shadow.camera.right=100;sun.shadow.camera.top=100;sun.shadow.camera.bottom=-100;scene.add(sun);
const material=(c,r=.8,m=0)=>new THREE.MeshStandardMaterial({color:c,roughness:r,metalness:m});
const M={grass:material(0x679553),road:material(0x30363c),line:material(0xe7e4d3),side:material(0xb8b7ad),build:[0xc4b8a4,0x9daeb5,0xc8c7bd,0xb9a28c,0x89969d].map(c=>material(c)),glass:material(0x6ab0d1,.3,.15),dark:material(0x1b2a34,.25,.15),black:material(0x181a1c),tire:material(0x111315),trunk:material(0x60432b),leaf:material(0x36734a),gold:new THREE.MeshStandardMaterial({color:0xffc52d,emissive:0x805000,emissiveIntensity:.7}),white:material(0xf5f0db),skin:material(0xd0a078),shirt:material(0x263d56),pants:material(0x242a32)};
function add(g,m,p=scene,x=0,y=0,z=0,cast=true){const o=new THREE.Mesh(g,m);o.position.set(x,y,z);o.castShadow=cast;o.receiveShadow=true;p.add(o);return o}
function box(p,m,x,y,z,w,h,d){return add(new THREE.BoxGeometry(w,h,d),m,p,x,y,z)}
const ground=add(new THREE.PlaneGeometry(420,420),M.grass,scene,0,-.15,0,false);ground.rotation.x=-Math.PI/2;
const buildings=[],block=34,grid=5;
for(let i=-grid;i<=grid;i++){const p=i*block;
 let a=add(new THREE.PlaneGeometry(420,13),M.road,scene,0,-.08,p,false);a.rotation.x=-Math.PI/2;
 let b=add(new THREE.PlaneGeometry(13,420),M.road,scene,p,-.08,0,false);b.rotation.x=-Math.PI/2;
 for(let n=-12;n<=12;n++){const q=n*15;let l=add(new THREE.PlaneGeometry(4,.12),M.line,scene,q,.005,p,false);l.rotation.x=-Math.PI/2;l=add(new THREE.PlaneGeometry(.12,4),M.line,scene,p,.005,q,false);l.rotation.x=-Math.PI/2}
 for(const s of [-1,1]){let sw=add(new THREE.PlaneGeometry(420,1.5),M.side,scene,0,.01,p+s*7.6,false);sw.rotation.x=-Math.PI/2;sw=add(new THREE.PlaneGeometry(1.5,420),M.side,scene,p+s*7.6,.01,0,false);sw.rotation.x=-Math.PI/2}
}
for(let gx=-grid;gx<grid;gx++)for(let gz=-grid;gz<grid;gz++){if(Math.random()<.12)continue;const x=(gx+.5)*block,z=(gz+.5)*block,w=12+Math.random()*8,d=12+Math.random()*8,h=7+Math.random()*22,bmat=M.build[Math.floor(Math.random()*M.build.length)],g=new THREE.Group();scene.add(g);g.position.set(x,0,z);box(g,bmat,0,h/2,0,w,h,d);box(g,material(0x51565a),0,h+.12,0,w+.3,.24,d+.3);
 for(let y=1.5;y<h-1;y+=2.8){for(let xx=-w/2+1.4;xx<w/2-1;xx+=2.8){box(g,M.glass,xx,y,d/2+.02,1.1,1.25,.06);box(g,M.glass,xx,y,-d/2-.02,1.1,1.25,.06)}for(let zz=-d/2+1.4;zz<d/2-1;zz+=2.8){box(g,M.glass,w/2+.02,y,zz,.06,1.25,1.1);box(g,M.glass,-w/2-.02,y,zz,.06,1.25,1.1)}}
 buildings.push({x,z,w,d})}
// Trees and street lights
for(let i=-grid;i<=grid;i++)for(const s of [-1,1])for(let n=-4;n<=4;n+=2){if(Math.random()<.4)continue;const g=new THREE.Group();scene.add(g);g.position.set(i*block+s*10.5,n*block*1.1,0);add(new THREE.CylinderGeometry(.15,.23,2,7),M.trunk,g,0,1,0);add(new THREE.SphereGeometry(1.15,8,7),M.leaf,g,0,2.5,0)}
for(let i=-grid;i<=grid;i+=2){const x=i*block+9,z=i*block+4;add(new THREE.CylinderGeometry(.07,.11,4.5,8),material(0x353a3d),scene,x,2.25,z);box(scene,material(0x353a3d),x+.35,4.4,z,.8,.08,.08);add(new THREE.SphereGeometry(.18,8,8),material(0xffe7a0,.3),scene,x+.7,4.35,z,false)}
// Third-person player model
const player=new THREE.Group();scene.add(player);const body=new THREE.Group();player.add(body);
add(new THREE.CapsuleGeometry(.35,.72,4,8),M.shirt,body,0,1.1,0);add(new THREE.SphereGeometry(.28,12,10),M.skin,body,0,1.85,0);box(body,M.black,0,2.04,0,.58,.13,.5);
const legs=[-.17,.17].map(x=>box(body,M.pants,x,.48,0,.18,.65,.2)),arms=[-.47,.47].map(x=>box(body,M.shirt,x,1.15,0,.15,.58,.17));player.position.set(0,0,3);
const keys={};addEventListener('keydown',e=>{keys[e.code]=true;if(['Space','ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.code))e.preventDefault();if(e.code==='KeyF'||e.code==='KeyE')toggleCar();if(e.code==='KeyN')toggleDay()});addEventListener('keyup',e=>keys[e.code]=false);
const touchControls=document.querySelector('#touchControls');touchControls?.querySelectorAll('button').forEach(button=>{const code=button.dataset.key;button.addEventListener('pointerdown',e=>{e.preventDefault();if(code==='KeyF'){toggleCar();return}keys[code]=true;button.setPointerCapture(e.pointerId)});for(const eventName of ['pointerup','pointercancel','lostpointercapture'])button.addEventListener(eventName,()=>{keys[code]=false})});addEventListener('blur',()=>{for(const code of Object.keys(keys))keys[code]=false});
let cameraYaw=0,cameraPitch=.2,drag=false,lx=0,ly=0;renderer.domElement.addEventListener('pointerdown',e=>{drag=true;lx=e.clientX;ly=e.clientY;renderer.domElement.setPointerCapture(e.pointerId)});renderer.domElement.addEventListener('pointerup',()=>drag=false);renderer.domElement.addEventListener('pointermove',e=>{if(!drag)return;cameraYaw-=(e.clientX-lx)*.005;cameraPitch=THREE.MathUtils.clamp(cameraPitch+(e.clientY-ly)*.003,-.05,.8);lx=e.clientX;ly=e.clientY});
const cars=[],colors=[0xc43b35,0x287bb9,0xd4d8dc,0x25292c,0xd9a92d,0x38875b,0x7946a5];
function makeCar(x,z,angle,color){const g=new THREE.Group();scene.add(g);g.position.set(x,.15,z);g.rotation.y=angle;const paint=material(color,.35,.2);box(g,paint,0,.55,0,1.9,.55,3.8);box(g,paint,0,.98,-.2,1.52,.5,1.9);box(g,M.dark,0,1.02,-.2,1.4,.36,1.7);box(g,paint,0,.54,1.4,1.75,.2,.7);box(g,M.black,0,.32,1.94,1.8,.18,.13);for(const xw of [-1,1])for(const zw of [-1.25,1.25]){const wh=add(new THREE.CylinderGeometry(.34,.34,.2,12),M.tire,g,xw,.34,zw);wh.rotation.z=Math.PI/2;const hub=add(new THREE.CylinderGeometry(.17,.17,.215,10),material(0xa9b1b4,.3,.7),g,xw,.34,zw);hub.rotation.z=Math.PI/2}box(g,M.white,-.58,.6,1.94,.3,.15,.05);box(g,M.white,.58,.6,1.94,.3,.15,.05);box(g,material(0xff332c),-.58,.6,-1.94,.28,.13,.05);box(g,material(0xff332c),.58,.6,-1.94,.28,.13,.05);const v={group:g,speed:0,parked:true};cars.push(v);return v}
for(let i=-4;i<=4;i++){makeCar(-5.1,i*block+2,0,colors[(i+10+colors.length)%colors.length]);makeCar(5.1,i*block+14,Math.PI,colors[(i+12+colors.length)%colors.length])}
let activeCar=null;const starter=makeCar(2.5,3,Math.PI,0x2878cb);
function toggleCar(){if(activeCar){player.position.copy(activeCar.group.position);player.position.x+=2.2*Math.cos(activeCar.group.rotation.y);player.position.z-=2.2*Math.sin(activeCar.group.rotation.y);player.visible=true;activeCar=null;notify('نزلت من السيارة');return}let near=null,dist=4.3;for(const c of cars){const d=player.position.distanceTo(c.group.position);if(d<dist){near=c;dist=d}}if(near){activeCar=near;near.parked=false;player.visible=false;notify('أنت تقود الآن')}}
function notify(s){messageEl.textContent=s;setTimeout(()=>{if(messageEl.textContent===s)messageEl.textContent=''},1500)}
let day=true;function toggleDay(){day=!day;scene.background.set(day?0x8fc7e8:0x071322);scene.fog.color.set(day?0x8fc7e8:0x071322);sun.intensity=day?3:.3;hemi.intensity=day?2:.35;sun.color.set(day?0xfff0d5:0x789bd8);notify(day?'وضع النهار':'وضع الليل')}
function blocked(x,z){return buildings.some(b=>Math.abs(x-b.x)<b.w/2+.5&&Math.abs(z-b.z)<b.d/2+.5)}
let vy=0,grounded=true,phase=0;
function movePlayer(dt){if(activeCar)return;const f=(keys.KeyW||keys.ArrowUp?1:0)-(keys.KeyS||keys.ArrowDown?1:0),s=(keys.KeyD||keys.ArrowRight?1:0)-(keys.KeyA||keys.ArrowLeft?1:0),spd=keys.ShiftLeft||keys.ShiftRight?9.5:5.3;const v=new THREE.Vector3(Math.sin(cameraYaw),0,-Math.cos(cameraYaw)).multiplyScalar(f).add(new THREE.Vector3(Math.cos(cameraYaw),0,Math.sin(cameraYaw)).multiplyScalar(s));if(v.lengthSq()){v.normalize();const x=player.position.x+v.x*spd*dt,z=player.position.z+v.z*spd*dt;if(!blocked(x,player.position.z))player.position.x=x;if(!blocked(player.position.x,z))player.position.z=z;player.rotation.y=Math.atan2(v.x,v.z);phase+=dt*9;legs[0].rotation.x=Math.sin(phase)*.6;legs[1].rotation.x=-Math.sin(phase)*.6;arms[0].rotation.x=-Math.sin(phase)*.4;arms[1].rotation.x=Math.sin(phase)*.4}if(keys.Space&&grounded){vy=7;grounded=false}vy-=18*dt;player.position.y+=vy*dt;if(player.position.y<0){player.position.y=0;vy=0;grounded=true}player.position.x=THREE.MathUtils.clamp(player.position.x,-195,195);player.position.z=THREE.MathUtils.clamp(player.position.z,-195,195)}
function moveCars(dt){for(const c of cars){if(c!==activeCar)continue;const g=c.group,a=(keys.KeyW||keys.ArrowUp?1:0)-(keys.KeyS||keys.ArrowDown?1:0),s=(keys.KeyD||keys.ArrowRight?1:0)-(keys.KeyA||keys.ArrowLeft?1:0),boost=keys.ShiftLeft||keys.ShiftRight;c.speed+=a*(boost?18:11)*dt;c.speed*=Math.pow(.985,dt*60);c.speed=THREE.MathUtils.clamp(c.speed,-7,boost?25:17);if(keys.Space)c.speed*=Math.pow(.9,dt*60);g.rotation.y-=s*dt*(.8+Math.min(Math.abs(c.speed)/18,1))*Math.sign(c.speed||1);const x=g.position.x+Math.sin(g.rotation.y)*c.speed*dt,z=g.position.z+Math.cos(g.rotation.y)*c.speed*dt;if(!blocked(x,z)){g.position.x=x;g.position.z=z}else c.speed*=-.2;player.position.copy(g.position)}}
const marker=new THREE.Group();scene.add(marker);const ring=add(new THREE.TorusGeometry(2.1,.15,10,32),M.gold,marker,0,1.5,0,false);ring.rotation.x=Math.PI/2;add(new THREE.CylinderGeometry(.08,.08,3,8),M.gold,marker,0,1.5,0,false);add(new THREE.CylinderGeometry(.08,.6,5,12,1,true),new THREE.MeshBasicMaterial({color:0xffc52d,transparent:true,opacity:.12,side:THREE.DoubleSide}),marker,0,3,0,false);
const spots=[new THREE.Vector3(68,0,-68),new THREE.Vector3(-68,0,68),new THREE.Vector3(34,0,102),new THREE.Vector3(-102,0,-34),new THREE.Vector3(0,0,-102)];function newSpot(){marker.position.copy(spots[Math.floor(Math.random()*spots.length)])}newSpot();let mission='ready',remaining=45,done=0,cash=0;
function missionUpdate(dt){
  marker.rotation.y+=dt*.7;
  const position=activeCar?activeCar.group.position:player.position;
  const distance=position.distanceTo(marker.position);
  if(mission==='ready'){
    missionText.textContent='اذهب إلى العلامة الذهبية لبدء تحدي الوقت.';
    timerBar.style.width='100%';
    if(distance<5){mission='active';remaining=45;notify('انطلق! لديك 45 ثانية')}
    return;
  }
  remaining-=dt;
  missionText.textContent='وصل إلى العلامة الذهبية قبل انتهاء الوقت: '+Math.max(0,remaining).toFixed(1)+' ث';
  timerBar.style.width=Math.max(0,remaining/45*100)+'%';
  if(distance<5){
    done++;cash+=500;mission='ready';newSpot();
    notify('نجحت المهمة! أضيف $500 إلى رصيدك (المجموع $'+cash+')');
  }else if(remaining<=0){
    mission='ready';newSpot();timerBar.style.width='100%';
    notify('انتهى الوقت، حاول مجدداً');
  }
}
function updateCamera(dt){
  const p=activeCar?activeCar.group.position:player.position;
  const yaw=activeCar?activeCar.group.rotation.y:cameraYaw,dist=activeCar?8:6.5;
  const dest=new THREE.Vector3(p.x+Math.sin(yaw)*dist*Math.cos(cameraPitch),p.y+(activeCar?3.3:2.8)+cameraPitch*2.5,p.z+Math.cos(yaw)*dist*Math.cos(cameraPitch));
  camera.position.lerp(dest,1-Math.pow(.001,dt));camera.lookAt(p.x,p.y+(activeCar?1.1:1.3),p.z);
}
function hud(){
  statusEl.textContent=(day?'☀ نهار':'☾ ليل')+'  |  '+(activeCar?'🚗 '+Math.round(Math.abs(activeCar.speed)*5)+' كم/س':'🚶 على الأقدام')+'  |  المهام: '+done+'  |  الرصيد: $'+cash;
  if(activeCar)promptEl.textContent='F/E: النزول • W/S: قيادة • A/D: انعطاف • Shift: تسارع';
  else promptEl.textContent=cars.some(c=>player.position.distanceTo(c.group.position)<4.3)?'اضغط F أو E لركوب السيارة':'استكشف المدينة وابحث عن العلامة الذهبية';
}
statusEl.textContent='المدينة جاهزة';
let last=performance.now();
function loop(now){
  requestAnimationFrame(loop);
  const dt=Math.min((now-last)/1000,.04);last=now;
  movePlayer(dt);moveCars(dt);missionUpdate(dt);updateCamera(dt);hud();renderer.render(scene,camera);
}
requestAnimationFrame(loop);
addEventListener('resize',()=>{
  camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();
  renderer.setSize(innerWidth,innerHeight);
});
