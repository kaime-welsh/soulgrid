package engine


Ability :: struct {
	name: string,
	exec: proc(_: ^World, _: ^Entity),
	dir:  [2]i32,
}

repel_ability :: proc(world: ^World, owner: ^Entity) {

}

blood_step_ability :: proc(world: ^World, owner: ^Entity) {

}

soul_siphon_ability :: proc(world: ^World, owner: ^Entity) {

}

