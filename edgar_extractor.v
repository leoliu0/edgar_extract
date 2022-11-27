import os
import flag
import io

fn main() {
	file := os.args[1]
	f := os.open_file(file, 'r')!
	mut r := io.new_buffered_reader(reader: f)
	mut fp := flag.new_flag_parser(os.args)
	limit := fp.int('limit', `l`, 1000, 'number of files to be generated')
	// mut header := []string{cap: 1000}
	// mut has_header := false
	mut html := []string{cap: 1000000}
	mut has_html := false
	mut html_counter := 1
	mut txt := []string{cap: 1000000}
	mut has_txt := false
	mut txt_counter := 1
	// mut line_num := 0
	for {
		mut l := r.read_line() or { break }
		l = l.trim_space()
		// line_num += 1

		if l.contains('<HTML>') || l.contains('<XBRL>') || l.contains('<html>')
			|| l.contains('<xbrl>') {
			has_html = true
			has_txt = false
			continue
		}
		if l.contains('</HTML>') || l.contains('</XBRL>') || l.contains('</html>')
			|| l.contains('</xbrl>') {
			has_html = false
			if html.len == 0 {
				continue
			}
			content := html.join('\n')
			os.write_file(file.split('.')[0] + '_' + html_counter.str() + '.html', content)!
			html_counter += 1
			html.clear()
			continue
		}
		if l.starts_with('<TEXT>') || l.starts_with('<text>') {
			has_txt = true
			continue
		}
		if l.contains('</TEXT>') || l.contains('</text>') {
			has_txt = false
			if txt.len == 0 {
				continue
			}
			content := txt.join('\n')
			os.write_file(file.split('.')[0] + '_' + txt_counter.str() + '.text', content)!
			txt_counter += 1
			txt.clear()
			continue
		}
		if has_html == true && html_counter <= limit {
			html << l
		}
		if has_txt == true && txt_counter <= limit {
			txt << l
		}
	}
}
