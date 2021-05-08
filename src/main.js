
import {createREGL} from "../lib/regljs_2.1.0/regl.module.js"
import {setMatrixArrayType} from "../lib/gl-matrix_3.3.0/esm/common.js"
import {DOM_loaded_promise, register_button_with_hotkey} from "./icg_web.js"

import {Raymarcher} from "./raymarcher_pipeline.js"
import {SCENES} from "./scenes.js"

import {init_menu} from "./menu.js"

setMatrixArrayType(Array);

function init_dom_elems(elem_canvas, on_resize_func) {
	const elem_body = document.getElementsByTagName('body')[0]

	// Resize canvas to fit the window, but keep it square.
	function resize_canvas() {
		const s = Math.min(window.innerHeight, window.innerWidth) - 10
		elem_canvas.width = s
		elem_canvas.height = s

		if(window.innerHeight < window.innerWidth) {
			elem_body.style['flex-flow'] = 'row'
		} else {
			elem_body.style['flex-flow'] = 'column'
		}
	}
	window.addEventListener('resize', () => {
		resize_canvas()
		if(on_resize_func) {
			on_resize_func()
		}
	})
	resize_canvas()
}

async function main() {
	const elem_canvas = document.getElementById('viewport')
	const debug_text = document.getElementById('debug-text')

	const regl = createREGL({
		canvas: elem_canvas,
		profile: true, // if we want to measure the size of buffers/textures in memory
		extensions: [
		], 
	})
	console.log('MAX_VERTEX_UNIFORM_VECTORS', regl._gl.MAX_VERTEX_UNIFORM_VECTORS)

	// Init ray-marching
	const raymarcher = new Raymarcher({
		resolution: [640, 640],
		scenes: SCENES,
	})
	await raymarcher.init(regl)
	
	init_dom_elems(elem_canvas, () => raymarcher.regenerate_view())

	// Saving the image
	register_button_with_hotkey('btn-screenshot', 's', () => {
		raymarcher.save_image()
	})

	init_menu(raymarcher, 'primitives')
}

async function entrypoint() {
	await DOM_loaded_promise
	await main()
}

entrypoint()
