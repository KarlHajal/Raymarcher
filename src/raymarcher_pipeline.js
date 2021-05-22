
import {load_text} from "./icg_web.js"
import {framebuffer_to_image_download} from "./icg_screenshot.js"
import * as vec3 from "../lib/gl-matrix_3.3.0/esm/vec3.js"
import { toRadian } from "../lib/gl-matrix_3.3.0/esm/common.js"

const mesh_quad_2d = {
	position: [
		// 4 vertices with 2 coordinates each
		[-1, -1],
		[1, -1],
		[1, 1],
		[-1, 1],
	],
	faces: [
		[0, 1, 2], // top right
		[0, 2, 3], // bottom left
	],
}

const SPHERE_ID = 1;
const PLANE_ID = 2;
const CYLINDER_ID = 3;
const BOX_ID = 4;
const TORUS_ID = 5;

export class Raymarcher {
	constructor({resolution, scenes}) {
		this.resolution = resolution
		this.scenes = scenes
		this.scenes_by_name = Object.fromEntries(scenes.map((sc) => [sc.name, sc]))
		this.scene_name = null
		this.num_reflections = 2
	}

	shader_inject_defines(shader_src, code_injections) {
		// Find occurences of "//#define NUM_X" in shader code and inject values
		const regexp_var = /\/\/#define ([A-Z_]+)/g
		// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replaceAll#specifying_a_function_as_a_parameter
		return shader_src.replaceAll(regexp_var, (match, varname) => {
			if(varname in code_injections) {
				const var_value = code_injections[varname]
				return `#define ${varname} ${var_value}`
			} else {
				return match // no change
			}
		})
	}

	gen_uniforms_camera(camera) {
		const fovx = camera.fov * Math.PI / 180.
		const fovx_half_tan = Math.tan(0.5 * fovx)
		const fovy_half_tan = fovx_half_tan * this.resolution[1] / this.resolution[0]

		return {
			field_of_view_half_tan: [fovx_half_tan, fovy_half_tan],
			camera_position: camera.position,
			camera_target: camera.target,
			camera_up: vec3.normalize([0, 0, 0], camera.up),
		}
	}

	ray_marcher_pipeline_for_scene(scene) {
		const {name, camera, materials, lights, spheres, planes, cylinders, boxes, toruses, mesh} = scene

		const uniforms = {}
		Object.assign(uniforms, this.gen_uniforms_camera(camera))
		uniforms['light_color_ambient'] = [1.0, 1.0, 1.0]

		const code_injections = {
			'NUM_REFLECTIONS': this.num_reflections,
		}

		// Materials
		const material_id_by_name = {}

		materials.forEach((mat, idx) => {
			material_id_by_name[mat.name] = idx
			uniforms[`materials[${idx}].color`] = mat.color
			uniforms[`materials[${idx}].ambient`] = mat.ambient
			uniforms[`materials[${idx}].diffuse`] = mat.diffuse
			uniforms[`materials[${idx}].specular`] = mat.specular
			uniforms[`materials[${idx}].shininess`] = mat.shininess
			uniforms[`materials[${idx}].mirror`] = mat.mirror
		})
		code_injections['NUM_MATERIALS'] = materials.length.toFixed(0)

		// Lights
		lights.forEach((li, idx) => {
			uniforms[`lights[${idx}].position`] = li.position
			uniforms[`lights[${idx}].color`] = li.color
		})
		code_injections['NUM_LIGHTS'] = lights.length.toFixed(0)
		

		const shapes = [];

		spheres.forEach((sph, idx) => {
			uniforms[`spheres_center_radius[${idx}]`] = sph.center.concat(sph.radius);
			
			shapes.push({shape_id: SPHERE_ID, shape_index: idx, material_id: material_id_by_name[sph.material] });
		})
		
		code_injections['NUM_SPHERES'] = spheres.length.toFixed(0)


		planes.forEach((pl, idx) => {
			const pl_norm = [0., 0., 0.]
			vec3.normalize(pl_norm, pl.normal)
			const pl_offset = vec3.dot(pl_norm, pl.center)
			uniforms[`planes_normal_offset[${idx}]`] = pl_norm.concat(pl_offset)
			
			shapes.push({shape_id: PLANE_ID, shape_index: idx, material_id: material_id_by_name[pl.material] });
		})

		code_injections['NUM_PLANES'] = planes.length.toFixed(0)


		cylinders.forEach((cyl, idx) => {
			uniforms[`cylinders[${idx}].center`] = cyl.center
			uniforms[`cylinders[${idx}].axis`] = vec3.normalize([0, 0, 0], cyl.axis)
			uniforms[`cylinders[${idx}].radius`] = cyl.radius
			uniforms[`cylinders[${idx}].height`] = cyl.height
			
			shapes.push({shape_id: CYLINDER_ID, shape_index: idx, material_id: material_id_by_name[cyl.material] });
		})
		
		code_injections['NUM_CYLINDERS'] = cylinders.length.toFixed(0)
		

		boxes.forEach((box, idx) => {
			uniforms[`boxes[${idx}].center`] = box.center
			uniforms[`boxes[${idx}].length`] = box.length
			uniforms[`boxes[${idx}].width`] = box.width
			uniforms[`boxes[${idx}].height`] = box.height
			uniforms[`boxes[${idx}].rotation_x`] = toRadian(box.rotation_x)
			uniforms[`boxes[${idx}].rotation_y`] = toRadian(box.rotation_y)
			uniforms[`boxes[${idx}].rotation_z`] = toRadian(box.rotation_z)
			uniforms[`boxes[${idx}].rounded_edges_radius`] = box.rounded_edges_radius

			shapes.push({shape_id: BOX_ID, shape_index: idx, material_id: material_id_by_name[box.material] });
		})
		
		code_injections['NUM_BOXES'] = boxes.length.toFixed(0)
		
		
		toruses.forEach((torus, idx) => {
			uniforms[`toruses[${idx}].center`] = torus.center
			uniforms[`toruses[${idx}].radi`  ] = torus.radi
			uniforms[`toruses[${idx}].rotation_x`] = toRadian(torus.rotation_x)
			uniforms[`toruses[${idx}].rotation_y`] = toRadian(torus.rotation_y)
			uniforms[`toruses[${idx}].rotation_z`] = toRadian(torus.rotation_z)
			
			shapes.push({shape_id: TORUS_ID, shape_index: idx, material_id: material_id_by_name[torus.material] });
		})
		
		code_injections['NUM_TORUSES'] = toruses.length.toFixed(0)

		shapes.forEach((shape, idx) => {
			uniforms[`shapes[${idx}].shape_id`] = shape.shape_id
			uniforms[`shapes[${idx}].shape_index`] = shape.shape_index
			uniforms[`shapes[${idx}].material_id`] = shape.material_id			
		})		
		code_injections['NUM_SHAPES'] = shapes.length.toFixed(0)
		
		const shader_frag = this.shader_inject_defines(this.resources_ready.raymarcher_frag, code_injections)
		
		const pipeline_raymarcher = this.regl({
			// Vertex attributes
			attributes: {
				vertex_position: mesh_quad_2d.position,
			},
			elements: mesh_quad_2d.faces,
				
			// Uniforms: global data available to the shader
			uniforms: uniforms,	
				
			depth: { enable: false },
		
			/* 
			Vertex shader program
			Given vertex attributes, it calculates the position of the vertex on screen
			and intermediate data ("varying") passed on to the fragment shader
			*/
			vert: this.resources_ready.raymarcher_vert,
				
			/* 
			Fragment shader program
			Calculates the color of each pixel covered by the mesh.
			The "varying" values are interpolated between the values given by the vertex shader on the vertices of the current triangle.
			*/
			frag: shader_frag,

			framebuffer: this.result_framebuffer,
			//viewport: {x:0, y:0, width: result_wh[0], height: result_wh[1]},
		})

		return pipeline_raymarcher
	}

	async init(regl) {
		this.regl = regl

		this.resources = {
			raymarcher_frag: load_text('./src/raymarcher.frag.glsl'),
			raymarcher_vert: load_text('./src/raymarcher.vert.glsl'),
			show_frag: load_text('./src/show_buffer.frag.glsl'),
			show_vert: load_text('./src/show_buffer.vert.glsl'),
		}

		this.result_buffer = regl.texture({
			width: this.resolution[0],
			height: this.resolution[1],
			format: 'rgba',
			min: 'linear',
			mag: 'linear',
		})
		
		this.result_framebuffer = regl.framebuffer({
			color: [this.result_buffer],
			depth: false, stencil: false,
		})

		this.pipeline_show = regl({
			attributes: {
				vertex_position: mesh_quad_2d.position,
			},
			elements: mesh_quad_2d.faces,
			uniforms: {
				tex: this.result_buffer,
			},
			depth: { enable: false },
			vert: await this.resources.show_vert,
			frag: await this.resources.show_frag,
		})

		this.resources_ready = {}
		for (const key in this.resources) {
			if (this.resources.hasOwnProperty(key)) {
				this.resources_ready[key] = await this.resources[key]
			}
		}
	}

	get_scene_names() {
		return this.scenes.map((s) => s.name)
	}

	async draw_scene({scene_name, num_reflections}) {
		if (num_reflections === undefined || num_reflections < 0) {
			num_reflections = this.num_reflections
		}

		const scene_def = this.scenes_by_name[scene_name]

		if(! scene_def) {
			console.error(`No scene ${scene_name}`)
			return 
		}

		if(scene_name != this.scene_name || num_reflections != this.num_reflections) {
			this.scene_name = scene_name
			this.num_reflections = num_reflections

			const pipe = this.ray_marcher_pipeline_for_scene(scene_def)

			pipe()

			pipe.destroy()

			this.regenerate_view()
		}
	}

	regenerate_view() {
		this.regen_needed = true

		requestAnimationFrame(() => {
			if(this.regen_needed) {
				// display the result on the canvas
				this.regl.poll()
				this.pipeline_show()

				this.regen_needed = false
			}
		})
	}

	save_image() {
		framebuffer_to_image_download(this.regl, this.result_framebuffer, `${this.scene_name}.png`)
	}
}

