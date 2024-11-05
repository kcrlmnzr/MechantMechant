use clipboard_win::get_clipboard_string;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::Path;
use std::thread;
use std::time::Duration;

fn main() {
    let mut last_content = String::new();
    loop {
        match get_clipboard_string() {
            Ok(content) => {
                if content != last_content {
                    let file_path = Path::new("clipboard_content.txt");
                    let mut file = OpenOptions::new().append(true).create(true).open(file_path).expect("Unable to open file");
                    writeln!(file, "{}", content).expect("Unable to write to file");
                    last_content = content;
                }
            }
            Err(e) => eprintln!("Erreur : {}", e),
        }
        thread::sleep(Duration::from_millis(500));
    }
}
