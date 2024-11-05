use clipboard_win::get_clipboard_string;
use std::fs::write;
use std::path::Path;

fn main() {
    match get_clipboard_string() {
        Ok(content) => {
            let file_path = Path::new("clipboard_content.txt");
            match write(file_path, content) {
                Ok(_) => println!("Contenu du presse-papiers écrit dans le fichier clipboard_content.txt"),
                Err(e) => eprintln!("Erreur lors de l'écriture dans le fichier : {}", e),
            }
        }
        Err(e) => eprintln!("Erreur : {}", e),
    }
}
