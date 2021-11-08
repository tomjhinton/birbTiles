import './style.scss'
import * as THREE from 'three'

import { gsap } from 'gsap'

import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'


import * as Tone from 'tone'

import Prism from 'prismjs'


import vertexShader from './shaders/vertex.glsl'

import fragmentShader1 from './shaders/fragment-1.glsl'

import fragmentShader2 from './shaders/fragment-2.glsl'

import fragmentShader3 from './shaders/fragment-3.glsl'

import fragmentShader4 from './shaders/fragment-4.glsl'

import fragmentShader5 from './shaders/fragment-5.glsl'

import fragmentShader6 from './shaders/fragment-6.glsl'

import template from './shaders/template.glsl'

import Bach from './bach.json'

const textureLoader = new THREE.TextureLoader()

// const synth = new Tone.MembraneSynth().toMaster();

const now = Tone.now()
const currentMidi = Bach
const synths = []
let notPlaying = true
const freeverb = new Tone.Freeverb().toDestination()
freeverb.dampening = 500
const vol = new Tone.Volume(-22).toDestination()
document.querySelector('#tone-play-toggle').addEventListener('click', (e) => {


  if (notPlaying && currentMidi) {
    notPlaying = false
    const now = Tone.now() + 0.5
    currentMidi.tracks.forEach((track) => {
      //create a synth for each track
      const synth = new Tone.PolySynth(Tone.FMSynth, {
        envelope: {
          attack: 0.02,
          decay: 0.1,
          sustain: 0.3,
          release: 1
        }
      }).toDestination()
      console.log(synth)
      synth.connect(freeverb)
      synth.connect(vol)
      synths.push(synth)
      //schedule all of the events
      track.notes.forEach((note) => {
        synth.triggerAttackRelease(
          note.name,
          note.duration,
          note.time + now,
          note.velocity
        )
      })
    })
  } else {
    //dispose the synth and make a new one
    while (synths.length) {
      const synth = synths.shift()
      synth.disconnect()
    }
    notPlaying = true
  }
})




const fragArray = [fragmentShader1, fragmentShader2, fragmentShader3, fragmentShader4, fragmentShader5, fragmentShader6]

let open = 0

const window1Selected = 0
const window2Selected = 1
const window3Selected = 2
const window4Selected = 3
const window5Selected = 4
const window6Selected = 5



const selectedArray = [window1Selected, window2Selected, window3Selected, window4Selected, window5Selected, window6Selected]


const snippet = document.getElementById('snipp')
snippet.textContent = template
const points =[
  {
    position: new THREE.Vector3(4.55, -1.3, 4.),
    element: document.querySelector('.point-0')
  },
  {
    position: new THREE.Vector3(4.55, -1.3, -1.),
    element: document.querySelector('.point-1')
  },

  {
    position: new THREE.Vector3(4.55, -1.3, -6.),
    element: document.querySelector('.point-2')
  },

  {
    position: new THREE.Vector3(-5.55, -1.3, 4.),
    element: document.querySelector('.point-5')
  },

  {
    position: new THREE.Vector3(-5.55, -1.3, -1.),
    element: document.querySelector('.point-4')
  },

  {
    position: new THREE.Vector3(-5.55, -1.3, -6.),
    element: document.querySelector('.point-3')
  }

]


Prism.highlightAll()

var modal = document.getElementById('myModal')

// Get the button that opens the modal
var btn = document.querySelectorAll('.myBtn')

// Get the <span> element that closes the modal
var span = document.getElementsByClassName('close')[0]

// When the user clicks on the button, open the modal
for(let i = 0; i < btn.length; i ++){
  btn[i].onclick = function(e) {
    modal.style.display = 'block'
    snippet.textContent = materials[parseInt(e.target.parentNode.className.replace(/[^0-9]/g,''))].fragmentShader
    Prism.highlightAll()
    open = parseInt(e.target.parentNode.className.replace(/[^0-9]/g,''))

  }
}


// When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = 'none'

  fragArray[selectedArray[open]] = snippet.textContent
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {

  if (event.target === modal) {
    modal.style.display = 'none'
    fragArray[selectedArray[open]] = snippet.textContent
    console.log(modal)
  }
}

function checkKey(e) {

  if (e.keyCode === 27) {
  // esc
    modal.style.display = 'none'
  }

}


document.onkeydown = checkKey




const canvas = document.querySelector('canvas.webgl')

const scene = new THREE.Scene()
// scene.background = new THREE.Color( 0xffffff )
const loadingBarElement = document.querySelector('.loading-bar')
const loadingBarText = document.querySelector('.loading-bar-text')
const loadingManager = new THREE.LoadingManager(
  // Loaded
  () =>{
    window.setTimeout(() =>{
      gsap.to(overlayMaterial.uniforms.uAlpha, { duration: 3, value: 0, delay: 1 })

      loadingBarElement.classList.add('ended')
      loadingBarElement.style.transform = ''

      loadingBarText.classList.add('fade-out')

    }, 500)
  },

  // Progress
  (itemUrl, itemsLoaded, itemsTotal) =>{
    const progressRatio = itemsLoaded / itemsTotal
    loadingBarElement.style.transform = `scaleX(${progressRatio})`

  }
)

const gtlfLoader = new GLTFLoader(loadingManager)

const overlayGeometry = new THREE.PlaneGeometry(2, 2, 1, 1)
const overlayMaterial = new THREE.ShaderMaterial({
  depthWrite: false,
  uniforms:
    {
      uAlpha: { value: 1 }
    },
  transparent: true,
  vertexShader: `
        void main()
        {
            gl_Position = vec4(position, 1.0);
        }
    `,
  fragmentShader: `
  uniform float uAlpha;
        void main()
        {
            gl_FragColor = vec4(0.0, 0.0, 0.0, uAlpha);
        }
    `
})

const overlay = new THREE.Mesh(overlayGeometry, overlayMaterial)
scene.add(overlay)


const window1Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window1Selected],
  side: THREE.DoubleSide
})

const window2Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window2Selected],
  side: THREE.DoubleSide
})


const window3Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window3Selected],
  side: THREE.DoubleSide
})


const window4Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window4Selected],
  side: THREE.DoubleSide
})


const window5Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window5Selected],
  side: THREE.DoubleSide
})


const window6Material  = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: true,
  uniforms: {
    uTime: { value: 0},
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    }
  },
  vertexShader: vertexShader,
  fragmentShader: fragArray[window6Selected],
  side: THREE.DoubleSide
})


const materials = [window1Material, window2Material, window3Material, window4Material, window5Material, window6Material]


const bakedTexture = textureLoader.load('church.jpg')


bakedTexture.flipY = false
bakedTexture.encoding = THREE.sRGBEncoding

const bakedMaterial = new THREE.MeshBasicMaterial({ map: bakedTexture})



let sceneGroup, window1, window2, window3, window4, window5, window6 , church, mixer
const intersectsArr = []
gtlfLoader.load(
  'church.glb',
  (gltf) => {
    gltf.scene.scale.set(4.5,4.5,4.5)
    sceneGroup = gltf.scene
    sceneGroup.needsUpdate = true
    sceneGroup.position.y -= 3
    scene.add(sceneGroup)


    church = gltf.scene.children.find((child) => {
      return child.name === 'church'
    })


    window1 = gltf.scene.children.find((child) => {
      return child.name === 'window1'
    })

    window2 = gltf.scene.children.find((child) => {
      return child.name === 'window2'
    })

    window3 = gltf.scene.children.find((child) => {
      return child.name === 'window3'
    })

    window4 = gltf.scene.children.find((child) => {
      return child.name === 'window4'
    })

    window5 = gltf.scene.children.find((child) => {
      return child.name === 'window5'
    })

    window6 = gltf.scene.children.find((child) => {
      return child.name === 'window6'
    })


    intersectsArr.push( window1, window2, window3,  window4, window5, window6)
    window1.needsUpdate = true

    window1.material = window1Material
    window2.material = window2Material
    window3.material = window3Material
    window4.material = window4Material
    window5.material = window5Material
    window6.material = window6Material

    church.material = bakedMaterial

  }
)


// gtlfLoader.load(
//   'birds.glb',
//   (gltf) => {
//
//     gltf.scene.scale.set(5.5,5.5,5.5)
//     sceneGroup = gltf.scene
//     sceneGroup.needsUpdate = true
//     sceneGroup.position.z -= 15
//     sceneGroup.position.y -= 3
//     sceneGroup.position.x += 6
//     scene.add(sceneGroup)
//
//     if(gltf.animations[0]){
//       mixer = new THREE.AnimationMixer(gltf.scene)
//
//       const action2 = mixer.clipAction(gltf.animations[1])
//
//       action2.play()
//
//     }
//
//
//   }
// )


// const light = new THREE.AmbientLight( 0x404040 )
// scene.add( light )
// const directionalLight = new THREE.DirectionalLight( 0xffffff, 0.5 )
// scene.add( directionalLight )

const sizes = {
  width: window.innerWidth,
  height: window.innerHeight
}

window.addEventListener('resize', () =>{



  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2 ))


})


/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(45, sizes.width / sizes.height, 0.1, 100)
camera.position.x = 10
camera.position.y = -10
camera.position.z = 15
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true
controls.maxPolarAngle = Math.PI / 2 - 0.1
//controls.enableZoom = false;

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
  antialias: true,
  alpha: true
})
renderer.outputEncoding = THREE.sRGBEncoding
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.setClearColor( 0x000000, 1)
const raycaster = new THREE.Raycaster()
const mouse = new THREE.Vector2()

function changeShader(name){
  selectedArray[parseInt(name.replace(/[^0-9]/g,'') -1)]


  if(selectedArray[parseInt(name.replace(/[^0-9]/g,'') -1)] < fragArray.length -1){
    selectedArray[parseInt(name.replace(/[^0-9]/g,'') -1)] ++



  } else  if(selectedArray[parseInt(name.replace(/[^0-9]/g,'') -1)] === fragArray.length -1){
    selectedArray[parseInt(name.replace(/[^0-9]/g,'') -1)] = 0



  }
}




renderer.domElement.addEventListener( 'pointerdown', onClick, false )

function onClick() {
  event.preventDefault()

  mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1
  mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1
  raycaster.setFromCamera( mouse, camera )

  var intersects = raycaster.intersectObjects( intersectsArr, true )

  if ( intersects.length > 0 ) {

    changeShader(intersects[0].object.name)
  }


}

window.addEventListener('mousemove', function (e) {

  materials.map( x=> {
    x.uniforms.uMouse.value.x =  (e.clientX / window.innerWidth) * 2 - 1
    x.uniforms.uMouse.value.y = -(event.clientY / window.innerHeight) * 2 + 1
  })


})



const clock = new THREE.Clock()

const tick = () =>{
  if ( mixer ) mixer.update( clock.getDelta() )
  const elapsedTime = clock.getElapsedTime()


  // Update controls
  controls.update()

  window1Material.uniforms.uTime.value = elapsedTime
  window1Material.needsUpdate=true
  window1Material.fragmentShader = fragArray[selectedArray[0]]

  window2Material.uniforms.uTime.value = elapsedTime
  window2Material.needsUpdate=true
  window2Material.fragmentShader = fragArray[selectedArray[1]]

  window3Material.uniforms.uTime.value = elapsedTime
  window3Material.needsUpdate=true
  window3Material.fragmentShader = fragArray[selectedArray[2]]

  window4Material.uniforms.uTime.value = elapsedTime
  window4Material.needsUpdate=true
  window4Material.fragmentShader = fragArray[selectedArray[3]]

  window5Material.uniforms.uTime.value = elapsedTime
  window5Material.needsUpdate=true
  window5Material.fragmentShader = fragArray[selectedArray[4]]

  window6Material.uniforms.uTime.value = elapsedTime
  window6Material.needsUpdate=true
  window6Material.fragmentShader = fragArray[selectedArray[5]]


  if(sceneGroup){
    for(const point of points){
      const screenPosition = point.position.clone()
      screenPosition.project(camera)
      raycaster.setFromCamera(screenPosition, camera)

      const intersects = raycaster.intersectObjects(scene.children, true)
      if(intersects.length === 0){
        point.element.classList.add('visible')
      }else{
        const intersectionDistance  = intersects[0].distance
        const pointDistance = point.position.distanceTo(camera.position)
        if(intersectionDistance < pointDistance){
          point.element.classList.remove('visible')
        } else {
          point.element.classList.add('visible')
        }

      }

      const translateX = screenPosition.x * sizes.width * 0.5
      const translateY = - screenPosition.y * sizes.height * 0.5
      point.element.style.transform = `translate(${translateX}px, ${translateY}px)`

    }

  }

  // Render
  renderer.render(scene, camera)

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
