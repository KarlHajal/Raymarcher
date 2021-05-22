

export const SCENES = [];

SCENES.push({
	name: "primitives",
	camera: {
		position: [0, 0, 0], target: [0, 0, 1], up: [0, 1, 0], fov: 75,
	},
	materials: [
		{name: 'green', color: [0.3, 1., 0.4], ambient: 0.2, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.},
		{name: 'black', color: [0.3, 0.3, 0.3], ambient: 0.2, diffuse: 0.9, specular: 0.1, shininess: 1., mirror: 0.},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.6, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'mirror', color: [0.9, 0.9, 0.9], ambient: 0., diffuse: 0., specular: 0., shininess: 0., mirror: 1.},
	],
	lights: [
		{position: [3., 0, -0.5], color: [1.0, 0.4, 0.2]},
		{position: [-3., -0.8, 3], color: [0.2, 0.4, 0.9]},
	],
	primitives:{
		spheres: [
			{center: [0.0, 0.0, 2.0], radius: 1.0, material: 'white'},
			{center: [0.3, 0.5, 1.5], radius: 0.45, material: 'black'},
			{center: [-0.3, 0.5, 1.5], radius: 0.45, material: 'black'},
			{center: [0., -0.1, 1.0], radius: 0.2, material: 'black'},
		],
		planes: [
			{center: [0.0, 1., 0.], normal: [0., -1., 0.], material: 'white'}, // top
			{center: [0.0, -1., 0.], normal: [0., 1., 0.], material: 'mirror'}, // bottom
		],
		cylinders: [
			{center: [0.0, -0.75, 1.5], radius: 0.5, height: 0.2, axis: [0., 1., 0.], material: 'green'},
		]
	}
});

SCENES.push({
	name: "cylinders",
	camera: {
		position: [0, 3, 8], target: [0, 1, 0], up: [0, 1, 0], fov: 45,
	},
	materials: [
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.3, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [20, 50, 0], color: [1.0, 0.4, 0.2]},
		{position: [50, 50, 50], color: [0.2, 0.4, 0.9]},
		{position: [-50, 50, 50], color: [0.2, 0.8, 0.2]},
	],
	primitives: {
		cylinders: [
			{center: [-1.5, 1.0, 0.0], radius: 0.5, height: 1.5, axis: [-1, 1, 1], material: 'white'},
			{center: [ 0.0, 1.0, 0.0], radius: 0.5, height: 1.5, axis: [0, 1, 1], material: 'white'},
			{center: [ 1.5, 1.0, 0.0], radius: 0.5, height: 1.5, axis: [1, 1, 1], material: 'white'},
		]
	}
});
	
SCENES.push({
	name: 'shading-example',
	camera: {
		position: [0, -4, 0], target: [0, 0, 0], up: [0, 0, 1], fov: 70,
	},
	lights: [
		{position: [0, 0, 0], color: [1.0, 0.9, 0.5]},
	],
	materials: [
		{name: 'floor', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 2., mirror: 0.0},
		{name: 'shiny', color: [0.9, 0.3, 0.1], ambient: 0.1, diffuse: 0.3, specular: 0.9, shininess: 10., mirror: 0.2},
	],
	primitives: {
		spheres: [
			{center: [2, 0, 0.1], radius: 0.6, material: 'white'},
			{center: [-2, 0, 0.1], radius: 0.6, material: 'shiny'},
		],
		cylinders: [
			{center: [2, 0, 2], axis: [1, 0, 0], radius: 0.5, height: 4, material: 'shiny'},
			{center: [-2, 0, 2], axis: [1, 0, 0], radius: 0.6, height: 4, material: 'white'},
		],
		planes: [
			{center: [0, 4, 0], normal: [0, -1, 0], material: 'white'},
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		]
	}
})

SCENES.push({
	name: 'shadows-example',
	camera: {
		position: [0, -8, 6], target: [0, 0, 0], up: [0, 0, 1], fov: 70,
	},
	lights: [
		{position: [0, 1, 2], color: [0.0, 0.7, 0.9]},
		{position: [20, -3, 0], color: [1, 0.2, 0.1]},
	],
	materials: [
		{name: 'floor', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.5, specular: 0.4, shininess: 4., mirror: 0.4},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 2., mirror: 0.0},
		{name: 'shiny', color: [0.9, 0.3, 0.1], ambient: 0.1, diffuse: 0.3, specular: 0.9, shininess: 10., mirror: 0.2},
	],
	primitives: {
		cylinders: [0, 1, 2, 3, 4, 5, 6, 7].map((i) => { 
			const a = i * Math.PI * 2 / 8 + 0.123
			const r = 3
			return { center: [r*Math.cos(a), r*Math.sin(a), 0], axis: [0, 0, 1], radius: 0.25, height: 4, material: 'shiny' }
		}),
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		]
	}
})

SCENES.push({
	name: 'shading1',
	camera: {
		position: [0, -4, 0], target: [0, 0, 0], up: [0, 0, 1], fov: 70,
	},
	lights: [
		{position: [3, 0, 3], color: [0.0, 1.0, 0.0]},
		{position: [-3, 0, 3], color: [1.0, 0.0, 0.0]},
	],
	materials: [
		{name: 'floor', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 2., mirror: 0.0},
		{name: 'shiny', color: [0.9, 0.3, 0.1], ambient: 0.1, diffuse: 0.3, specular: 0.9, shininess: 10., mirror: 0.2},
	],
	primitives: {
		spheres: [
			{center: [0, 0, 0], radius: 1, material: 'white'},
		],
		planes: [
			{center: [0, 4, 0], normal: [0, -1, 0], material: 'white'},
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		]
	}
})

SCENES.push({
	name: 'desk',
	camera: {
		position: [0., 0., -1.], target: [0., 0, 0.], up: [0, 1, 0], fov: 65,
	},
	materials: [
		{name: 'wall', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.},
		{name: 'table', color: [0.49, 0.49, 0.38], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.03},
		{name: 'pot', color: [0.76, 0.76, 0.68], ambient: 0.2, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'pen', color: [1., 0.65, 0.17], ambient: 0.1, diffuse: 0.9, specular: 1.0, shininess: 8., mirror: 0.03},
		{name: 'rubber', color: [0.60, 0.30, 0.24], ambient: 0.2, diffuse: 0.5, specular: 0., shininess: 4., mirror: 0.1},
		{name: 'metal', color: [0.85, 0.85, 0.85], ambient: 0.2, diffuse: 0.5, specular: 1.0, shininess: 4., mirror: 0.3},
	],
	lights: [
		{position: [0.3, 0.35, -0.15], color: [0.9, 0.8, 0.7]},
	],
	primitives: {
		spheres: [
			{center: [-0.588, 0.096, 0.324], radius: 0.01, material: 'rubber'},
		],
		planes: [
			{center: [0., 0., 1.5], normal: [0., 0., 1.], material: 'wall'},
			{center: [0., -0.4, 0.], normal: [0., 1., 0.], material: 'table'},
		],
		cylinders: [
			{center: [-0.2, -0.25, 0.1], radius: 0.2, height: 0.3, axis: [0., 1., 0.], material: 'pot'},
			{center: [-0.304, -0.15, 0.16], radius: 0.01, height: 0.7, axis: [-0.693, 0.6, 0.4], material: 'pen'},
			{center: [-0.564, 0.075, 0.31], radius: 0.011, height: 0.05, axis: [-0.693, 0.6, 0.4], material: 'metal'},
		]
	}
});

SCENES.push({
	name: 'mirror1',
	camera: {
		position: [0.5, -2, 0.4], target: [0.5, 0, 0.4], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.2, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'mirror', color: [0.9, 0.9, 0.9], ambient: 0., diffuse: 0., specular: 1.0, shininess: 8., mirror: 0.9},
		{name: 'particleR', color: [0.9, 0.3, 0.1], ambient: 0.2, diffuse: 0.5, specular: 0.9, shininess: 10., mirror: 0.1},
		{name: 'particleB', color: [0.1, 0.3, 0.9], ambient: 0.2, diffuse: 0.5, specular: 0.9, shininess: 10., mirror: 0.1},

	],
	lights: [
		{position: [2.5, 2.5, 4], color: [1.0, 0.8, 0.5]},
		{position: [0.5, -2.5, -0.1], color: [0.5, 0.8, 1.0]},
	],
	primitives:{
		spheres: [
			{center: [2, 2, 0.1], radius: 0.5, material: 'particleR'},
			{center: [2, 4, 0.1], radius: 0.5, material: 'particleB'},
			{center: [2, 4, 2.1], radius: 0.5, material: 'particleR'},
		],
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		],
		cylinders: [
			{center: [-2, 4, 0.0], radius: 2, height: 4, axis: [0, 0, 1], material: 'mirror'},
			{center: [2, 3, 0.1], radius: 0.1, height: 2, axis: [0, 1, 0], material: 'white'},
			{center: [2, 4, 1.1], radius: 0.1, height: 2, axis: [0, 0, 1], material: 'white'},
		]
	}
});

SCENES.push({
	name: 'mirror2',
	camera: {
		position: [0.5, -2, 0.4], target: [0.5, 0, 0.4], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0.9, 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.2, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'mirror', color: [0.9, 0.9, 0.9], ambient: 0., diffuse: 0., specular: 1.0, shininess: 8., mirror: 0.9},
		{name: 'particleR', color: [0.9, 0.3, 0.1], ambient: 0.2, diffuse: 0.5, specular: 0.9, shininess: 10., mirror: 0.1},
		{name: 'particleB', color: [0.1, 0.3, 0.9], ambient: 0.2, diffuse: 0.5, specular: 0.9, shininess: 10., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 2.5, 4], color: [1.0, 0.8, 0.5]},
		{position: [0.5, -2.5, -0.1], color: [0.5, 0.8, 1.0]},
	],
	primitives: {
		spheres: [
			{center: [2, 2, 0.1], radius: 0.5, material: 'particleR'},
			{center: [2, 4, 0.1], radius: 0.5, material: 'particleB'},
			{center: [2, 4, 2.1], radius: 0.5, material: 'particleR'},
		],
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
			{center: [-5, 5, 0], normal: [-2, 1, 0], material: 'mirror'},
			{center: [ 5, 5, 0], normal: [1.5, 1, 0], material: 'mirror'},

		],
		cylinders: [
			{center: [2, 3, 0.1], radius: 0.1, height: 2, axis: [0, 1, 0], material: 'white'},
			{center: [2, 4, 1.1], radius: 0.1, height: 2, axis: [0, 0, 1], material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Ambient-Occlusion',
	camera: {
		position: [1, 10, 3], target: [1, 3, 0], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.9, 0.9], ambient: 0.5, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.8, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
		{name: 'green', color: [0.48, 0.68, 0.28], ambient: 0.9, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
	],
	lights: [
		{position: [1, 3, 10], color: [1.0, 1.0, 1.0]},
		//{position: [-10, 0, 10], color: [1.0, 1.0, 1.0]},
	],
	primitives: {
		spheres: [
			{center: [0, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [0, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [0, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [0.5, 3.5, 0.6], radius: 0.5, material: 'white'},
			{center: [0.5, 2.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1.5, 3.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1.5, 2.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1, 3, 1.1], radius: 0.5, material: 'green'},
			//{center: [-3, 0, 1.1], radius: 1.5, material: 'green'},
			//{center: [-3, 0, 3.], radius: 1., material: 'green'},
			//{center: [-2.5, 1, 3.5], radius: 0.2, material: 'white'},
			//{center: [-3.1, 1, 3.5], radius: 0.2, material: 'white'},
			//{center: [-2.8, 1, 3.2], radius: 0.1, material: 'white'},
		],
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		],
		cylinders: [
			{center: [2.7, 3, 0.5], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
			{center: [3., 3, 0.95], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
			{center: [3.3, 3, 1.4], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Spheres+Cylinders',
	camera: {
		position: [1, 10, 3], target: [1, 3, 0], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.3, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'green', color: [0.48, 0.68, 0.28], ambient: 0.3, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 2.5, 4], color: [0.5, 0.8, 1.0]},
		{position: [0.5, -2.5, -0.1], color: [0.5, 0.8, 1.0]},
	],
	primitives: {
		spheres: [
			{center: [0, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [0, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [0, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [1, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 2, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 3, 0.1], radius: 0.5, material: 'white'},
			{center: [2, 4, 0.1], radius: 0.5, material: 'white'},
			{center: [0.5, 3.5, 0.6], radius: 0.5, material: 'white'},
			{center: [0.5, 2.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1.5, 3.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1.5, 2.5, 0.6], radius: 0.5, material: 'white'},
			{center: [1, 3, 1.1], radius: 0.5, material: 'green'},
		],
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		],
		cylinders: [
			{center: [2.7, 3, 0.5], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
			{center: [3., 3, 0.95], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
			{center: [3.3, 3, 1.4], radius: 0.3, height: 3, axis: [0, 1, 0], material: 'white'},
			{center: [-2, 3, 1.4], radius: 0.3, height: 3, axis: [0, 1, 1], material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Box',
	camera: {
		position: [1, 10, 3], target: [1, 3, 0], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 2.5, 4], color: [0.5, 0.8, 1.0]},
		{position: [0.5, -2.5, -0.1], color: [0.5, 0.8, 1.0]},
	],
	primitives: {
		planes: [
			{center: [0, 0, -1], normal: [0, 0, 1], material: 'floor'},
		],
		boxes: [
			{center: [2, 2, 0.1], length: 1, width: 1, height: 1, rotation_x: 40, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0, material: 'white'},
			{center: [-2, 2, 0.1], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 40, rotation_z: 0, rounded_edges_radius: 0,  material: 'white'},
			{center: [0, 2, 0.1], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius: 0, material: 'white'},
			{center: [0, -3, 0.1], length: 2, width: 3, height: 5, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0.2, material: 'white'},
			{center: [3, -3, 2], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: -40, rounded_edges_radius: 0.3, material: 'white'},
			{center: [-3, -3, 2], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius: 0.3, material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Torus',
	camera: {
		position: [1, 10, 3], target: [1, 3, 0], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 2.5, 4], color: [0.5, 0.8, 1.0]},
	],
	primitives: {
		planes: [
			{center: [0, 0, -3], normal: [0, 0, 1], material: 'floor'},
		],
		toruses: [
			{center: [1,0,0],  radi: [1.5,0.75], rotation_x : 0 , rotation_y : 0, rotation_z : 0  , material : 'white'},
			{center: [4,3,0],  radi: [1.5,0.75], rotation_x : 45, rotation_y : 0, rotation_z : 45 , material : 'white'},
			{center: [-2,3,0], radi: [1.5,0.75], rotation_x : 45, rotation_y : 0, rotation_z : -45, material : 'white'},
		]
	}
});

SCENES.push({
	name: 'Intersections',
	camera: {
		position: [1, 10, 3], target: [1, 3, 0], up: [0, 0, 1], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.9, 0.9], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.2},
		{name: 'white', color: [0.9, 0.9, 0.9],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 2.5, 4], color: [0.5, 0.8, 1.0]},
	],
	primitives: {
		planes: [
			{center: [0, 0, -3], normal: [0, 0, 1], material: 'floor'},
		]
	},
	intersections: [
		{	
			material: 'white',
			shapes: [
				{type: 'box', center: [0, 2, 0.1], length: 2, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0},
				{type: 'sphere', center: [1, 2, 0.1], radius: 0.8}
			]
		},
		{	
			material: 'white',
			shapes: [
				{type: 'sphere', center: [2.5, 2, 0.1], radius: 0.8},
				{type: 'sphere', center: [2, 2, 0.1], radius: 0.8}
			]
		},
	]
});


export const SCENES_BY_NAME = Object.fromEntries(SCENES.map((sc) => [sc.name, sc]))
