
function scene_chooser(elem, raymarcher, initial_scene, video) {

	const video_rec = video;
	const buttons = {}

	function update() {
		Object.values(buttons).forEach((item) => {
			item.classList.remove('selected')
		})
		buttons[raymarcher.scene_name].classList.add('selected')

		document.location.hash = raymarcher.scene_name
	}

	function set_scene(sc_name) {
		if(sc_name != raymarcher.scene_name) {
			raymarcher.draw_scene({scene_name: sc_name}, video_rec)
			update()
		}
	}

	function set_scene_from_url() {
		const url_hash = document.location.hash
		
		if(url_hash !== "") {
			const sc_from_url = url_hash.substr(1)
			if( buttons.hasOwnProperty(sc_from_url)) {
				set_scene(sc_from_url)
				return sc_from_url
			}	
		}
		return false
	}

	window.addEventListener('popstate', set_scene_from_url)

	raymarcher.get_scene_names().forEach((scn) => {
		const item = document.createElement('li')
		item.textContent = scn
		item.addEventListener('click', () => set_scene(scn))
		elem.appendChild(item)
		buttons[scn] = item
	})

	if(! set_scene_from_url() ) {
		set_scene(initial_scene)
	}
}

function reflection_chooser(elem, raymarcher, video) {

	const video_rec = video;
	const buttons = []

	function update() {
		Object.values(buttons).forEach((item) => {
			item.classList.remove('selected')
		})
		buttons[raymarcher.num_reflections].classList.add('selected')
	}

	function set_num_reflections(num_reflections) {
		if(num_reflections >= 0 && num_reflections != raymarcher.num_reflections) {
			raymarcher.draw_scene({
				scene_name: raymarcher.scene_name,
				num_reflections: num_reflections,
			}, video_rec)
			update()
		}
	}

	const available_num_reflections = [0, 1, 2, 3, 4]

	available_num_reflections.forEach((nr) => {
		const item = document.createElement('li')
		item.textContent = nr.toFixed(0)
		item.addEventListener('click', () => set_num_reflections(nr))
		elem.appendChild(item)
		buttons[nr] = item
	})

	update()
}

export function init_menu(raymarcher, initial_scene, video) {
	const elem_scenes = document.querySelector('#menu-scenes')
	scene_chooser(elem_scenes, raymarcher, initial_scene, video)

	const elem_reflections = document.querySelector('#menu-reflections')
	reflection_chooser(elem_reflections, raymarcher, video)
}
