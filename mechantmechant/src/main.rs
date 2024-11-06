use tokio_tungstenite::connect_async;
use tokio_tungstenite::tungstenite::protocol::Message;
use url::Url;
use tokio;
use clipboard_win::get_clipboard_string;
use chrono::Local;
use std::time::Duration;
use tokio::time::sleep;
use futures_util::{StreamExt, SinkExt};
use std::time::Instant;
use xcap::Window;

fn normalized(filename: &str) -> String {
    filename
        .replace("|", "")
        .replace("\\", "")
        .replace(":", "")
        .replace("/", "")
}

#[tokio::main]
async fn main() {
    // URL du serveur WebSocket
    let url = Url::parse("ws://localhost:8765").expect("URL incorrecte");

    // Établissement de la connexion WebSocket
    let (ws_stream, _) = connect_async(url).await.expect("Échec de la connexion");
    println!("Connecté au serveur WebSocket");

    let (mut write, mut read) = ws_stream.split();
    let mut last_content = String::new();

    loop {
        match get_clipboard_string() {
            Ok(content) => {
                if content != last_content {
                    // Ajout de l'horodatage
                    let timestamp = Local::now().format("%Y-%m-%d %H:%M:%S").to_string();
                    let message = format!("[{}] {}", timestamp, content);

                    // Envoi du contenu horodaté du presse-papiers au serveur WebSocket
                    if let Err(e) = write.send(Message::Text(message.clone())).await {
                        eprintln!("Erreur lors de l'envoi du message : {}", e);
                    } else {
                        println!("Message envoyé : {}", message);
                    }

                    // Capture d'écran des fenêtres ouvertes
                    capture_screenshots(&timestamp);

                    last_content = content;
                }
            }
            Err(e) => eprintln!("Erreur lors de la lecture du presse-papiers : {}", e),
        }

        // Lecture de la réponse du serveur
        if let Some(Ok(response)) = read.next().await {
            println!("Réponse reçue : {:?}", response);
        }

        // Attente de 500 ms avant de vérifier à nouveau
        sleep(Duration::from_millis(500)).await;
    }
}

fn capture_screenshots(timestamp: &str) {
    let start = Instant::now();
    let windows = Window::all().unwrap();

    let mut i = 0;

    for window in windows {
        // Ignorer les fenêtres minimisées
        if window.is_minimized() {
            continue;
        }

        println!(
            "Window: {:?} {:?} {:?}",
            window.title(),
            (window.x(), window.y(), window.width(), window.height()),
            (window.is_minimized(), window.is_maximized())
        );

        let image = window.capture_image().unwrap();
        let filename = format!(
            "SCREENS/window-{}-{}-{}.png",
            i,
            normalized(window.title()),
            timestamp.replace(":", "-")
        );

        image.save(&filename).unwrap();

        i += 1;
    }

    println!("Capture d'écran terminée en: {:?}", start.elapsed());
}
