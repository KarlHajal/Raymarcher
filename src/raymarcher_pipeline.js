
import {load_text, load_image} from "./icg_web.js"
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
const TRIANGLE_ID = 6;
const LINK_ID = 7;
const CONE_ID = 8;
const HEXAGONAL_ID = 9;
const TRIANGULAR_ID = 10;
const ELLIPSOID_ID = 11;
const OCTAHEDRON_ID = 12;
const PYRAMID_ID = 13;


export class Raymarcher {
	constructor({resolution, scenes}) {
		this.resolution = resolution
		this.scenes = scenes
		this.scenes_by_name = Object.fromEntries(scenes.map((sc) => [sc.name, sc]))
		this.scene_name = null
		this.num_reflections = 2
		this.noise_iteration = 0;
		this.noise_interval = null;
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

	process_primitives(scene, uniforms, material_id_by_name, code_injections){
		
		if(scene.primitives){
			const primitives = scene.primitives;
			const object_material_id = [];

			function next_object_material(mat_name) {
				object_material_id.push(material_id_by_name[mat_name]);
			}

			const spheres = primitives.spheres ? primitives.spheres : [];
			spheres.forEach((sph, idx) => {
				uniforms[`spheres_center_radius[${idx}]`] = sph.center.concat(sph.radius)
				
				next_object_material(sph.material)
			})
			code_injections['NUM_SPHERES'] = spheres.length.toFixed(0)


			const planes = primitives.planes ? primitives.planes : [];
			planes.forEach((pl, idx) => {
				const pl_norm = [0., 0., 0.]
				vec3.normalize(pl_norm, pl.normal)
				const pl_offset = vec3.dot(pl_norm, pl.center)
				uniforms[`planes_normal_offset[${idx}]`] = pl_norm.concat(pl_offset)
				
				next_object_material(pl.material)
			})
			code_injections['NUM_PLANES'] = planes.length.toFixed(0)


			const cylinders = primitives.cylinders ? primitives.cylinders : [];
			cylinders.forEach((cyl, idx) => {
				uniforms[`cylinders[${idx}].center`] = cyl.center
				uniforms[`cylinders[${idx}].axis`] = vec3.normalize([0, 0, 0], cyl.axis)
				uniforms[`cylinders[${idx}].radius`] = cyl.radius
				uniforms[`cylinders[${idx}].height`] = cyl.height
				uniforms[`cylinders[${idx}].is_capsule`] = cyl.is_capsule

				
				next_object_material(cyl.material)
			})
			code_injections['NUM_CYLINDERS'] = cylinders.length.toFixed(0)
			

			const boxes = primitives.boxes ? primitives.boxes : [];
			boxes.forEach((box, idx) => {
				uniforms[`boxes[${idx}].center`] = box.center
				uniforms[`boxes[${idx}].length`] = box.length
				uniforms[`boxes[${idx}].width`] = box.width
				uniforms[`boxes[${idx}].height`] = box.height
				uniforms[`boxes[${idx}].rotation_x`] = toRadian(box.rotation_x)
				uniforms[`boxes[${idx}].rotation_y`] = toRadian(box.rotation_y)
				uniforms[`boxes[${idx}].rotation_z`] = toRadian(box.rotation_z)
				uniforms[`boxes[${idx}].rounded_edges_radius`] = box.rounded_edges_radius
				uniforms[`boxes[${idx}].is_frame`] = box.is_frame

				next_object_material(box.material)
			})
			code_injections['NUM_BOXES'] = boxes.length.toFixed(0);
			
			
			const toruses = primitives.toruses ? primitives.toruses : [];
			toruses.forEach((torus, idx) => {
				uniforms[`toruses[${idx}].center`] = torus.center
				uniforms[`toruses[${idx}].radi`  ] = torus.radi
				uniforms[`toruses[${idx}].rotation_x`] = toRadian(torus.rotation_x)
				uniforms[`toruses[${idx}].rotation_y`] = toRadian(torus.rotation_y)
				uniforms[`toruses[${idx}].rotation_z`] = toRadian(torus.rotation_z)
				
				next_object_material(torus.material)
			})
			code_injections['NUM_TORUSES'] = toruses.length.toFixed(0);

			const triangles = primitives.triangles ? primitives.triangles : [];
			triangles.forEach((triangle, idx) => {
				uniforms[`triangles[${idx}].vertice1`] = triangle.vertice1
				uniforms[`triangles[${idx}].vertice2`] = triangle.vertice2
				uniforms[`triangles[${idx}].vertice3`] = triangle.vertice3
	
				next_object_material(triangle.material)
			})
			code_injections['NUM_TRIANGLES'] = triangles.length.toFixed(0)

			const links = primitives.links ? primitives.links : [];
			links.forEach((link, idx) => {
				uniforms[`links[${idx}].center`] = link.center
				uniforms[`links[${idx}].length`] = link.length
				uniforms[`links[${idx}].radius1`] = link.radius1
				uniforms[`links[${idx}].radius2`] = link.radius2
	
				next_object_material(link.material)
			})
			code_injections['NUM_LINKS'] = links.length.toFixed(0)


			const cones = primitives.cones ? primitives.cones : [];
			cones.forEach((cone, idx) => {
				uniforms[`cones[${idx}].center`] = cone.center
				uniforms[`cones[${idx}].height`] = cone.height
				uniforms[`cones[${idx}].sin_cos`] = cone.sin_cos
	
				next_object_material(cone.material)
			})
			code_injections['NUM_CONES'] = cones.length.toFixed(0)

			
			const hexagonals = primitives.hexagonals ? primitives.hexagonals : [];
			hexagonals.forEach((hexagonal, idx) => {
				uniforms[`hexagonals[${idx}].center`] = hexagonal.center
				uniforms[`hexagonals[${idx}].heights`] = hexagonal.heights
	
				next_object_material(hexagonal.material)
			})
			code_injections['NUM_HEXAGONALS'] = hexagonals.length.toFixed(0)


			const triangulars = primitives.triangulars ? primitives.triangulars : [];
			triangulars.forEach((triangular, idx) => {
				uniforms[`triangulars[${idx}].center`] = triangular.center
				uniforms[`triangulars[${idx}].heights`] = triangular.heights
	
				next_object_material(triangular.material)
			})
			code_injections['NUM_TRIANGULARS'] = triangulars.length.toFixed(0)


			const ellipsoids = primitives.ellipsoids ? primitives.ellipsoids : [];
			ellipsoids.forEach((ellipsoid, idx) => {
				uniforms[`ellipsoids[${idx}].center`] = ellipsoid.center
				uniforms[`ellipsoids[${idx}].radius`] = ellipsoid.radius
	
				next_object_material(ellipsoid.material)
			})
			code_injections['NUM_ELLIPSOIDS'] = ellipsoids.length.toFixed(0)


			const octahedrons = primitives.octahedrons ? primitives.octahedrons : [];
			octahedrons.forEach((octahedron, idx) => {
				uniforms[`octahedrons[${idx}].center`] = octahedron.center
				uniforms[`octahedrons[${idx}].length`] = octahedron.length
	
				next_object_material(octahedron.material)
			})
			code_injections['NUM_OCTAHEDRONS'] = octahedrons.length.toFixed(0)

			
			const pyramids = primitives.pyramids ? primitives.pyramids : [];
			pyramids.forEach((pyramid, idx) => {
				uniforms[`pyramids[${idx}].center`] = pyramid.center
				uniforms[`pyramids[${idx}].height`] = pyramid.height
	
				next_object_material(pyramid.material)
			})
			code_injections['NUM_PYRAMIDS'] = pyramids.length.toFixed(0)

			// regl 2.1.0 loads a uniform array all at once
			if(object_material_id.length > 1) {
				uniforms['object_material_id'] = object_material_id
			} else if (object_material_id.length == 1) {
				uniforms['object_material_id[0]'] = object_material_id[0]
			}
		}
	}

	add_shape(shape, idx, shapes_collection, primitives_collection){
		const {type, ...shape_properties} = shape;
		if(type === 'sphere'){
			shapes_collection[idx].push({shape_id: SPHERE_ID, shape_index: primitives_collection.spheres.length});
			primitives_collection.spheres.push(shape_properties);
		}
		else if (type === 'plane'){
			shapes_collection[idx].push({shape_id: PLANE_ID, shape_index: primitives_collection.planes.length});
			primitives_collection.planes.push(shape_properties);
		}
		else if (type === 'cylinder'){
			shapes_collection[idx].push({shape_id: CYLINDER_ID, shape_index: primitives_collection.cylinders.length});
			primitives_collection.cylinders.push(shape_properties);
		}
		else if (type === 'box'){
			shapes_collection[idx].push({shape_id: BOX_ID, shape_index: primitives_collection.boxes.length});
			primitives_collection.boxes.push(shape_properties);
		}
		else if (type === 'torus'){
			shapes_collection[idx].push({shape_id: TORUS_ID, shape_index: primitives_collection.toruses.length});
			primitives_collection.toruses.push(shape_properties);
		}
		else if (type === 'triangle'){
			shapes_collection[idx].push({shape_id: TRIANGLE_ID, shape_index: primitives_collection.triangles.length});
			primitives_collection.triangles.push(shape_properties);
		}
		else if (type === 'link'){
			shapes_collection[idx].push({shape_id: LINK_ID, shape_index: primitives_collection.links.length});
			primitives_collection.links.push(shape_properties);
		}
		else if (type === 'cone'){
			shapes_collection[idx].push({shape_id: CONE_ID, shape_index: primitives_collection.cones.length});
			primitives_collection.cones.push(shape_properties);
		}
		else if (type === 'hexagonal'){
			shapes_collection[idx].push({shape_id: HEXAGONAL_ID, shape_index: primitives_collection.hexagonals.length});
			primitives_collection.hexagonals.push(shape_properties);
		}
		else if (type === 'triangular'){
			shapes_collection[idx].push({shape_id: TRIANGULAR_ID, shape_index: primitives_collection.triangulars.length});
			primitives_collection.triangulars.push(shape_properties);
		}
		else if (type === 'ellipsoid'){
			shapes_collection[idx].push({shape_id: ELLIPSOID_ID, shape_index: primitives_collection.ellipsoids.length});
			primitives_collection.ellipsoids.push(shape_properties);
		}
		else if (type === 'octahedron'){
			shapes_collection[idx].push({shape_id: OCTAHEDRON_ID, shape_index: primitives_collection.octahedrons.length});
			primitives_collection.octahedrons.push(shape_properties);
		}
		else if (type === 'pyramid'){
			shapes_collection[idx].push({shape_id: PYRAMID_ID, shape_index: primitives_collection.pyramids.length});
			primitives_collection.pyramids.push(shape_properties);
		}
	}

	add_collection_of_shapes(combinations_to_add, shapes_collection, primitives_collection, material_id_by_name){
		if(combinations_to_add){
			const init_shapes_nb = shapes_collection.length;
			combinations_to_add.forEach((combination, idx) => {
				const shape1 = combination.shapes[0];
				const shape2 = combination.shapes[1];
				const shape_index = init_shapes_nb + idx;
				shapes_collection[shape_index] = [];

				this.add_shape(shape1, shape_index, shapes_collection, primitives_collection);
				this.add_shape(shape2, shape_index, shapes_collection, primitives_collection);

				shapes_collection[shape_index].push({
					material_id: material_id_by_name[combination.material],
					smooth_factor: combination.smooth_factor ? combination.smooth_factor : 0
				});
			});
		}
	}

	process_combinations(scene, uniforms, material_id_by_name, code_injections){

		const combination_shapes = [];
		const combination_primitives = {
			planes: [],
			spheres: [],
			boxes: [],
			cylinders: [],
			toruses: [],
			triangles: [],
			links: [],
			cones: [],
			hexagonals: [],
			triangulars: [],
			ellipsoids: [],
			octahedrons: [],
			pyramids: []
		};

		this.add_collection_of_shapes(scene.intersections, combination_shapes, combination_primitives, material_id_by_name);
		this.add_collection_of_shapes(scene.unions, combination_shapes, combination_primitives, material_id_by_name);
		this.add_collection_of_shapes(scene.subtractions, combination_shapes, combination_primitives, material_id_by_name);

		combination_shapes.forEach((shapes, idx) => {
			uniforms[`combinations[${idx}].shape1_id`] = shapes[0].shape_id
			uniforms[`combinations[${idx}].shape1_index`] = shapes[0].shape_index
			uniforms[`combinations[${idx}].shape2_id`] = shapes[1].shape_id
			uniforms[`combinations[${idx}].shape2_index`] = shapes[1].shape_index
			uniforms[`combinations[${idx}].material_id`] = shapes[2].material_id
			uniforms[`combinations[${idx}].smooth_factor`] = shapes[2].smooth_factor				
		});			

		combination_primitives.spheres.forEach((sph, idx) => {
			uniforms[`combination_spheres_center_radius[${idx}]`] = sph.center.concat(sph.radius);
		});

		combination_primitives.planes.forEach((pl, idx) => {
			const pl_norm = [0., 0., 0.];
			vec3.normalize(pl_norm, pl.normal);
			const pl_offset = vec3.dot(pl_norm, pl.center);
			uniforms[`combination_planes_normal_offset[${idx}]`] = pl_norm.concat(pl_offset);
		});

		combination_primitives.cylinders.forEach((cyl, idx) => {
			uniforms[`combination_cylinders[${idx}].center`] = cyl.center
			uniforms[`combination_cylinders[${idx}].axis`] = vec3.normalize([0, 0, 0], cyl.axis)
			uniforms[`combination_cylinders[${idx}].radius`] = cyl.radius
			uniforms[`combination_cylinders[${idx}].height`] = cyl.height
			uniforms[`combination_cylinders[${idx}].is_capsule`] = cyl.is_capsule
		});

		combination_primitives.boxes.forEach((box, idx) => {
			uniforms[`combination_boxes[${idx}].center`] = box.center;
			uniforms[`combination_boxes[${idx}].length`] = box.length;
			uniforms[`combination_boxes[${idx}].width`] = box.width;
			uniforms[`combination_boxes[${idx}].height`] = box.height;
			uniforms[`combination_boxes[${idx}].rotation_x`] = toRadian(box.rotation_x);
			uniforms[`combination_boxes[${idx}].rotation_y`] = toRadian(box.rotation_y);
			uniforms[`combination_boxes[${idx}].rotation_z`] = toRadian(box.rotation_z);
			uniforms[`combination_boxes[${idx}].rounded_edges_radius`] = box.rounded_edges_radius;
			uniforms[`combination_boxes[${idx}].is_frame`] = box.is_frame

		});

		combination_primitives.toruses.forEach((torus, idx) => {
			uniforms[`combination_toruses[${idx}].center`] = torus.center
			uniforms[`combination_toruses[${idx}].radi`  ] = torus.radi
			uniforms[`combination_toruses[${idx}].rotation_x`] = toRadian(torus.rotation_x)
			uniforms[`combination_toruses[${idx}].rotation_y`] = toRadian(torus.rotation_y)
			uniforms[`combination_toruses[${idx}].rotation_z`] = toRadian(torus.rotation_z)
		});

		combination_primitives.triangles.forEach((triangle, idx) => {
			uniforms[`combination_triangles[${idx}].vertice1`] = triangle.vertice1
			uniforms[`combination_triangles[${idx}].vertice2`] = triangle.vertice2
			uniforms[`combination_triangles[${idx}].vertice3`] = triangle.vertice3
		})

		combination_primitives.links.forEach((link, idx) => {
			uniforms[`combination_links[${idx}].center`] = link.center
			uniforms[`combination_links[${idx}].length`] = link.length
			uniforms[`combination_links[${idx}].radius1`] = link.radius1
			uniforms[`combination_links[${idx}].radius2`] = link.radius2
		})

		combination_primitives.cones.forEach((cone, idx) => {
			uniforms[`combination_cones[${idx}].center`] = cone.center
			uniforms[`combination_cones[${idx}].height`] = cone.height
			uniforms[`combination_cones[${idx}].sin_cos`] = cone.sin_cos
		})

		combination_primitives.hexagonals.forEach((hexagonal, idx) => {
			uniforms[`combination_hexagonals[${idx}].center`] = hexagonal.center
			uniforms[`combination_hexagonals[${idx}].heights`] = hexagonal.heights
		})

		combination_primitives.triangulars.forEach((triangular, idx) => {
			uniforms[`combination_triangulars[${idx}].center`] = triangular.center
			uniforms[`combination_triangulars[${idx}].heights`] = triangular.heights
		})

		combination_primitives.ellipsoids.forEach((ellipsoid, idx) => {
			uniforms[`combination_ellipsoids[${idx}].center`] = ellipsoid.center
			uniforms[`combination_ellipsoids[${idx}].radius`] = ellipsoid.radius
		})

		combination_primitives.octahedrons.forEach((octahedron, idx) => {
			uniforms[`combination_octahedrons[${idx}].center`] = octahedron.center
			uniforms[`combination_octahedrons[${idx}].length`] = octahedron.length
		})
		
		combination_primitives.pyramids.forEach((pyramid, idx) => {
			uniforms[`combination_pyramids[${idx}].center`] = pyramid.center
			uniforms[`combination_pyramids[${idx}].height`] = pyramid.height
		})

		code_injections['COMBINATION_NUM_SPHERES'] = combination_primitives.spheres.length.toFixed(0);
		code_injections['COMBINATION_NUM_PLANES'] = combination_primitives.planes.length.toFixed(0);
		code_injections['COMBINATION_NUM_CYLINDERS'] = combination_primitives.cylinders.length.toFixed(0);
		code_injections['COMBINATION_NUM_BOXES'] = combination_primitives.boxes.length.toFixed(0);
		code_injections['COMBINATION_NUM_TORUSES'] = combination_primitives.toruses.length.toFixed(0);
		code_injections['COMBINATION_NUM_TRIANGLES'] = combination_primitives.triangles.length.toFixed(0);
		code_injections['COMBINATION_NUM_LINKS'] = combination_primitives.links.length.toFixed(0);
		code_injections['COMBINATION_NUM_CONES'] = combination_primitives.cones.length.toFixed(0);
		code_injections['COMBINATION_NUM_HEXAGONALS'] = combination_primitives.hexagonals.length.toFixed(0);
		code_injections['COMBINATION_NUM_TRIANGULARS'] = combination_primitives.triangulars.length.toFixed(0);
		code_injections['COMBINATION_NUM_ELLIPSOIDS'] = combination_primitives.ellipsoids.length.toFixed(0);
		code_injections['COMBINATION_NUM_OCTAHEDRONS'] = combination_primitives.octahedrons.length.toFixed(0);
		code_injections['COMBINATION_NUM_PYRAMIDS'] = combination_primitives.pyramids.length.toFixed(0);
		code_injections['NUM_COMBINATIONS'] = combination_shapes.length.toFixed(0);

		code_injections['NUM_INTERSECTIONS'] = scene.intersections ? scene.intersections.length.toFixed(0) : "0";
		code_injections['NUM_UNIONS'] = scene.unions ? scene.unions.length.toFixed(0) : "0";
		code_injections['NUM_SUBTRACTIONS'] = scene.subtractions ? scene.subtractions.length.toFixed(0) : "0";
	}

	ray_marcher_pipeline_for_scene(scene) {

		const camera = scene.camera;
		const uniforms = {}
		Object.assign(uniforms, this.gen_uniforms_camera(camera))
		uniforms['light_color_ambient'] = [1.0, 1.0, 1.0]

		const code_injections = {
			'NUM_REFLECTIONS': this.num_reflections,
		}


		const material_id_by_name = {}

		const materials = scene.materials ? scene.materials : [];
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


		const lights = scene.lights ? scene.lights : [];
		lights.forEach((li, idx) => {
			uniforms[`lights[${idx}].position`] = li.position
			uniforms[`lights[${idx}].color`] = li.color
		})
		code_injections['NUM_LIGHTS'] = lights.length.toFixed(0)
		

		this.process_primitives(scene, uniforms, material_id_by_name, code_injections);
		this.process_combinations(scene, uniforms, material_id_by_name, code_injections);

		if(scene.cubemap){
			const cubemap = this.regl.cube(
				this.resources_ready[scene.cubemap + '_posx'], this.resources_ready[scene.cubemap + '_negx'],
				this.resources_ready[scene.cubemap + '_posy'], this.resources_ready[scene.cubemap + '_negy'],
				this.resources_ready[scene.cubemap + '_posz'], this.resources_ready[scene.cubemap + '_negz']);

			code_injections['ENVIRONMENT_MAPPING'] = "1";
			uniforms[`cubemap_texture`] = cubemap;
		}
		else{
			code_injections['ENVIRONMENT_MAPPING'] = "0";
		}


		const shader_frag = this.shader_inject_defines(this.resources_ready.raymarcher_frag, code_injections)
		
		const pipeline_raymarcher = this.regl({
			attributes: {
				vertex_position: mesh_quad_2d.position,
			},
			elements: mesh_quad_2d.faces,
			uniforms: uniforms,	
				
			depth: { enable: false },
			vert: this.resources_ready.raymarcher_vert,
			frag: shader_frag,

			framebuffer: this.result_framebuffer,
		})

		return pipeline_raymarcher
	}

	ray_marcher_pipeline_for_noise(scene) {
		const camera = scene.camera;
		const uniforms = {}
		Object.assign(uniforms, this.gen_uniforms_camera(camera))

		uniforms[`current_time`] = this.noise_iteration;

		const code_injections = {};

		const shader_frag = this.shader_inject_defines(this.resources_ready.raymarcher_noise_frag, code_injections)
		
		const pipeline_raymarcher = this.regl({
			attributes: {
				vertex_position: mesh_quad_2d.position,
			},
			elements: mesh_quad_2d.faces,
			uniforms: uniforms,	
			depth: { enable: false },
			vert: this.resources_ready.raymarcher_vert,
			frag: shader_frag,
			framebuffer: this.result_framebuffer,
		})

		return pipeline_raymarcher
	}

	add_cubemap(resources, cubemap_name){
		const path = "./textures/cubemaps/" + cubemap_name + "/";
		resources[cubemap_name + "_posx"] = load_image(path + 'posx.jpg');
		resources[cubemap_name + "_posy"] = load_image(path + 'posy.jpg');
		resources[cubemap_name + "_posz"] = load_image(path + 'posz.jpg');
		resources[cubemap_name + "_negx"] = load_image(path + 'negx.jpg');
		resources[cubemap_name + "_negy"] = load_image(path + 'negy.jpg');
		resources[cubemap_name + "_negz"] = load_image(path + 'negz.jpg');
	}

	async init(regl) {
		this.regl = regl

		this.resources = {
			raymarcher_frag: load_text('./src/shaders/raymarcher.frag.glsl'),
			raymarcher_noise_frag: load_text('./src/shaders/raymarcher_noise.frag.glsl'),
			raymarcher_vert: load_text('./src/shaders/raymarcher.vert.glsl'),
			show_frag: load_text('./src/shaders/show_buffer.frag.glsl'),
			show_vert: load_text('./src/shaders/show_buffer.vert.glsl'),
		}

		const cubemaps = ["lycksele", "yokohama", "interstellar"];
		cubemaps.forEach((cubemap) => {
			this.add_cubemap(this.resources, cubemap);
		});

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

	execute_pipeline(pipeline){
		pipeline();
		pipeline.destroy();
		this.regenerate_view();
	}

	async draw_scene({scene_name, num_reflections}) {

		const scene_def = this.scenes_by_name[scene_name];

		if(! scene_def) {
			console.error(`No scene ${scene_name}`)
			return 
		}

		if (num_reflections === undefined || num_reflections < 0) {
			num_reflections = this.num_reflections
		}

		if(scene_name !== this.scene_name && scene_name === "3D Perlin Noise"){
			if(this.noise_interval !== null){
				clearInterval(this.noise_interval);
				this.noise_interval = null;
			}

			this.scene_name = scene_name

			this.noise_iteration = 0;
			this.noise_interval = setInterval(() => {
				this.execute_pipeline(this.ray_marcher_pipeline_for_noise(scene_def))
				this.noise_iteration += 1;
			}, 100);
		}		
		else if(scene_name !== this.scene_name || num_reflections !== this.num_reflections) {
			if(this.noise_interval !== null){
				clearInterval(this.noise_interval);
				this.noise_interval = null;
			}

			this.scene_name = scene_name
			this.num_reflections = num_reflections
			this.execute_pipeline(this.ray_marcher_pipeline_for_scene(scene_def));
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

