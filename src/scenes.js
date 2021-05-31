

export const SCENES = [];

SCENES.push({
	name: 'Shading',
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
});

SCENES.push({
	name: "Environment-Mapping",
	camera: {
		position: [0, 1.5, -3], target: [0, 0, 1], up: [0, 1, 0], fov: 75,
	},
	materials: [
		{name: 'mirror', color: [0.9, 0.9, 0.9], ambient: 0., diffuse: 0., specular: 0., shininess: 0., mirror: 1.},
	],
	lights: [
		{position: [3., 0, -0.5], color: [1.0, 0.4, 0.2]},
		{position: [-3., -0.8, 3], color: [0.2, 0.4, 0.9]},
	],
	cubemap: "lycksele",
	primitives:{
		toruses: [
			{center: [0.0, 0.0, 2.0],  radi: [1.0, 0.7], rotation_x : 0 , rotation_y : 0, rotation_z : 0  , material : 'mirror'},
		],
	}
});

SCENES.push({
	name: "Environment-Mapping-2",
	camera: {
		position: [0, 1.5, -3], target: [0, 0, 1], up: [0, 1, 0], fov: 75,
	},
	materials: [
		{name: 'mirror', color: [0.9, 0.9, 0.9], ambient: 0., diffuse: 0., specular: 0., shininess: 0., mirror: 1.},
	],
	lights: [
		{position: [3., 0, -0.5], color: [1.0, 0.4, 0.2]},
		{position: [-3., -0.8, 3], color: [0.2, 0.4, 0.9]},
	],
	cubemap: "yokohama",
	primitives:{
		toruses: [
			{center: [0.0, 0.0, 2.0],  radi: [1.0, 0.7], rotation_x : 0 , rotation_y : 0, rotation_z : 0  , material : 'mirror'},
		],
	}
});

SCENES.push({
	name: 'Ambient-Occlusion',
	camera: {
		position: [1, 3, 10], target: [1, 0, 3], up: [0, 1, 0], fov: 65,
	},
	materials: [
		{name: 'floor', color: [0., 0.8, 0.8], ambient: 0.5, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.8, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
		{name: 'green', color: [0.48, 0.68, 0.28], ambient: 0.95, diffuse: 0., specular: 0., shininess: 0., mirror: 0.},
	],
	lights: [
		{position: [1, 10, 3], color: [1.0, 1.0, 1.0]},
		//{position: [-10, 0, 10], color: [1.0, 1.0, 1.0]},
	],
	primitives: {
		spheres: [
			{center: [0, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [0, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [0, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [0.5, 0.6, 3.5], radius: 0.5, material: 'white'},
			{center: [0.5, 0.6, 2.5], radius: 0.5, material: 'white'},
			{center: [1.5, 0.6, 3.5], radius: 0.5, material: 'white'},
			{center: [1.5, 0.6, 2.5], radius: 0.5, material: 'white'},
			{center: [1, 1.1, 3], radius: 0.5, material: 'green'},
		],
		planes: [
			{center: [0, -1, 0], normal: [0, 1, 0], material: 'floor'},
		],
		cylinders: [
			{center: [-0.7, 0.5, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 0, material: 'white'},
			{center: [-1., 0.95, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 1, material: 'white'},
			{center: [-1.3, 1.4, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 0, material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Spheres + Cylinders + Capsules',
	camera: {
		position: [1, 3, 10], target: [1, 0, 3], up: [0, 1, 0], fov: 65,
	},
	materials: [
		{name: 'floor', color: [1., 1., 1.], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.8},
		{name: 'white', color: [0.9, 0.9, 0.9], ambient: 0.3, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'green', color: [0.48, 0.68, 0.28], ambient: 0.3, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	lights: [
		{position: [2.5, 4, 2.5], color: [0.5, 0.8, 1.0]},
		{position: [0.5, -0.1, -2.5], color: [0.5, 0.8, 1.0]},
	],
	cubemap: "yokohama",
	primitives: {
		spheres: [
			{center: [0, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [0, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [0, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [1, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 2], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 3], radius: 0.5, material: 'white'},
			{center: [2, 0.1, 4], radius: 0.5, material: 'white'},
			{center: [0.5, 0.6, 3.5], radius: 0.5, material: 'white'},
			{center: [0.5, 0.6, 2.5], radius: 0.5, material: 'white'},
			{center: [1.5, 0.6, 3.5], radius: 0.5, material: 'white'},
			{center: [1.5, 0.6, 2.5], radius: 0.5, material: 'white'},
			{center: [1, 1.1, 3], radius: 0.5, material: 'green'},
		],
		planes: [
			{center: [0, -1, 0], normal: [0, 1, 0], material: 'floor'},
		],
		cylinders: [
			{center: [-0.7, 0.5, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 0, material: 'white'},
			{center: [-1., 0.95, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 1, material: 'white'},
			{center: [-1.3, 1.4, 3], radius: 0.3, height: 3, axis: [0, 0, 1], is_capsule: 0, material: 'white'},
		]
	}
});

SCENES.push({
	name: 'Box - Triangles - Box Frame - Cones - Hexagonal - Triangular - Ellipse - Pyramid - OctaHedron',
	camera: {
		position: [4.8, 6.4, 13], target: [1, 0, 3], up: [0, 1, 0], fov: 65,
	},
	materials: [
		{name: 'floor', color: [1., 1., 1.], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.5},
		{name: 'white', color: [0.9, 0.8, 0.8],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'color1', color: [0.6, 0.2, 0.2],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'color2', color: [0.2, 0.6, 0.2],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'color3', color: [0.2, 0.2, 0.6],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'color4', color: [0.6, 0.2, 0.6],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
		{name: 'color5', color: [0.4, 0.5, 0.2],ambient: 0.7, diffuse: 0.7, specular: 0.4, shininess: 6., mirror: 0.4},
		{name: 'color6', color: [0.7, 0.8, 0.6],ambient: 0.7, diffuse: 0.7, specular: 0.4, shininess: 6., mirror: 0.4},
		],
	lights: [
		{position: [2.5, 2.5, 4], color: [0.5, 0.8, 1.0]},
		{position: [0.5, -2.5, -0.1], color: [0.5, 0.8, 1.0]},
	],
	cubemap: "interstellar",
	primitives: {
		boxes: [
			{center: [2, 0.1, 2], length: 1, width: 1, height: 1, rotation_x: 40, rotation_y: 0, rotation_z: 0, rounded_edges_radius:0, is_frame:1, material: 'white'},
			//{center: [-2, 2, 0.1], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 40, rotation_z: 0, rounded_edges_radius:0, is_frame:0, material: 'color1'},
			//{center: [0, 2, 0.1], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius:0, is_frame:0, material: 'color4'},
			//{center: [0, -3, 0.4], length: 2, width: 3, height: 4, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius:0.2, is_frame:0, material: 'white'},
			//{center: [3, -3, 2], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: -40, rounded_edges_radius: 0.3, is_frame:0, material: 'color2'},
			{center: [-3, 2, -3], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius:0.1, is_frame:1, material: 'color4'},
		],
		planes: [
			{center: [0, -1, 0], normal: [0, 1, 0], material: 'floor'},
		],
		triangles: [
			{vertice1: [4,3,3], vertice2: [4,3,3], vertice3: [4,3,3], material: 'color2'},
			{vertice1: [5,1, 2.4], vertice2: [4,1, 3.1], vertice3: [3.5,2.5, 2.4], material: 'color5'},
		],
		links: [
			{center: [5,1, -2.3], length: 1, radius1: 0.2, radius2: 0.1, material:'color1'},
		],
		cones: [
			{center: [-5,0.4, 4], sin_cos: [5, 33], height:4, material:'color3'}
		],
		hexagonals: [
			{center: [-10, 0.15, -6], heights: [1,1.5], material:'color3'}
		],
		triangulars: [
			{center: [6.5, 0.2, 1.2], heights: [0.6,1], material:'color1'}
		],
		ellipsoids: [
			{center: [6.5, 0.1, 4.6], radius: [0.85,0.7, 0.2], material:'color6'}
		],
		octahedrons: [
			{center: [-6.5, 0.1, 4.6], length: 1, material:'color6'}
		],
		pyramids: [
			{center: [0.5, 0.1, 6.2], height: 1.3, material:'color6'}
		],
	}
});

SCENES.push({
	name: 'Box',
	camera: {
		position: [-1, 3, 10], target: [-1, 0, 3], up: [0, 1, 0], fov: 65,
	},
	materials: [
		{name: 'floor', color: [1., 1., 1.], ambient: 0.1, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.5},
		{name: 'white', color: [0.9, 0.9, 0.9],ambient: 0.4, diffuse: 0.9, specular: 0.1, shininess: 4., mirror: 0.1},
	],
	cubemap: "lycksele",
	lights: [
		{position: [2.5, 4, 2.5], color: [0.5, 0.8, 1.0]},
		{position: [0.5, -0.1, -2.5], color: [0.5, 0.8, 1.0]},
	],
	soft_shadows_factor: 20.0,
	primitives: {
		planes: [
			{center: [0, -2, 0], normal: [0, 1, 0], material: 'floor'},
		],
		boxes: [
			{center: [2, 0.1, 2], length: 1, width: 1, height: 1, rotation_x: 40, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0, is_frame:0, material: 'white'},
			{center: [-2, 0.1, 2], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 40, rotation_z: 0, rounded_edges_radius: 0, is_frame:0, material: 'white'},
			{center: [0, 0.1, 2], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius: 0, is_frame:0, material: 'white'},
			{center: [0, 0.1, -3], length: 2, width: 5, height: 3, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0.2, is_frame:0, material: 'white'},
			{center: [3, 2, -3], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: -40, rounded_edges_radius: 0.3, is_frame:0, material: 'white'},
			{center: [-3, 2, -3], length: 1, width: 1, height: 1, rotation_x: 0, rotation_y: 0, rotation_z: 40, rounded_edges_radius: 0.3, is_frame:0, material: 'white'},
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
			smooth_factor: 0.2,
			shapes: [
				{type: 'torus', center: [1, 0, 0],  radi: [1.5,0.75], rotation_x : 0 , rotation_y : 0, rotation_z : 0},
				{type: 'box', center: [1, 0, 0.5], length: 3, width: 3, height: 3, rotation_x: 0, rotation_y: 0, rotation_z: 0, is_frame:0, rounded_edges_radius: 0}
			]
		},
		{	
			material: 'white',
			smooth_factor: 0,
			shapes: [
				{type: 'cylinder', center: [-2, 3, 0], radius: 1.5, height: 3, is_capsule: 0, axis: [0, 1, 0]},
				{type: 'torus', center: [-2,3,0], radi: [1.5,0.75], rotation_x : 45, rotation_y : 0, rotation_z : -45}
			]
		},
	]
});

SCENES.push({
	name: 'Unions',
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
	unions: [
		{	
			material: 'white',
			smooth_factor: 0.7,
			shapes: [
				{type: 'box', center: [-1, 2, 0.1], length: 2.5, width: 2.5, height: 0.7, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0.1, is_frame: 0},
				{type: 'sphere', center: [-1, 2, 0.5], radius: 0.8}
			]
		},
		{	
			material: 'white',
			smooth_factor: 0.3,
			shapes: [
				{type: 'sphere', center: [2.8, 2, 0.1], radius: 0.5},
				{type: 'sphere', center: [1.8, 2, 0.1], radius: 0.5}
			]
		},
	]
});

SCENES.push({
	name: 'Subtractions',
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
	subtractions: [
		{	
			material: 'white',
			smooth_factor: 0.05,
			shapes: [
				{type: 'sphere', center: [-1, 2, 0.5], radius: 1.4},
				{type: 'box', center: [-1, 2, 0.1], length: 2.5, width: 2.5, height: 0.7, rotation_x: 0, rotation_y: 0, rotation_z: 0, rounded_edges_radius: 0.1, is_frame: 0}
			]
		},
		{	
			material: 'white',
			smooth_factor: 0,
			shapes: [
				{type: 'sphere', center: [1.8, 2, 0.1], radius: 0.8},
				{type: 'sphere', center: [2.5, 2, 0.1], radius: 0.8}
			]
		},
	]
});

SCENES.push({
	name: '3D-Perlin-Noise',
	is_noise: 1,
	camera: {
		position: [0, 0, 0], target: [0, 0, 1], up: [0, 1, 0], fov: 75,
	},
});

SCENES.push({
	name: '3D-Perlin-Noise+FBM',
	is_noise: 1,
	fbm: 1,
	camera: {
		position: [0, 0, 0], target: [0, 0, 1], up: [0, 1, 0], fov: 75,
	},
});

SCENES.push({
	name: 'Waves',
	is_noise: 1,
	camera: {
		position: [0, 1, 0], target: [0, 0.3, 1], up: [0, 1, 0], fov: 75,
	},
});

SCENES.push({
	name: 'Clouds',
	is_noise: 1,
	camera: {
		position: [0, 5, 0], target: [5, 0, 5], up: [0, 1, 0], fov: 75,
	},
});

export const SCENES_BY_NAME = Object.fromEntries(SCENES.map((sc) => [sc.name, sc]))
