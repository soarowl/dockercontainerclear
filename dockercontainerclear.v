#!/usr/bin/env -S v run

import os

const (
	headers = ['CONTAINER ID', 'IMAGE', 'COMMAND', 'CREATED', 'STATUS', 'PORTS', 'NAMES']
)

fn header_start_positions(header string) []int {
	mut result := []int{}
	for h in headers {
		if pos := header.index(h) {
			result << pos
		}
	}
	return result
}

fn get_field(s string, positions []int, index int) string {
	len := positions.len
	mut result := ''
	if index >= 0 && index < len {
		if index == len - 1 {
			result = s[positions[index]..]
		} else {
			result = s[positions[index]..positions[index + 1]]
		}
	}
	return result
}

fn main() {
	println('dockercontainerclear v0.0.1 by Zhuo Nengwen at 2022-06-17')
	containers := os.execute_or_exit('sudo docker container ls -a')
	if containers.exit_code == 0 {
		lines := containers.output.split_into_lines()
		header := lines[0]
		positions := header_start_positions(header)
		for line in lines[1..] {
			status := get_field(line, positions, 4).trim_space()
			if status.starts_with('Exited') {
				id := get_field(line, positions, 0).trim_space()
				cmd := 'sudo docker container rm $id'
				println('\n$cmd')
				os.system(cmd)
			}
		}
	}
}
