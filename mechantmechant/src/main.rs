use clipboard_win::get_clipboard_string;

fn main() {
    match get_clipboard_string() {
        Ok(content) => println!("Contenu du presse-papiers : {}", content),
        Err(e) => eprintln!("Erreur : {}", e),
    }
}
