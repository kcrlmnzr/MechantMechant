use tokio_tungstenite::connect_async;
use tokio_tungstenite::tungstenite::protocol::Message;
use url::Url;
use tokio;
use clipboard::ClipboardProvider;
use clipboard::ClipboardContext;
use futures_util::{StreamExt, SinkExt}; // Ajout de `SinkExt` pour `send`

fn get_clipboard_string() -> Result<String, Box<dyn std::error::Error>> {
    let mut ctx: ClipboardContext = ClipboardProvider::new()?;
    let content = ctx.get_contents()?;
    Ok(content)
}

#[tokio::main]
async fn main() {
    // Récupération du contenu du presse-papiers
    let clipboard_content = match get_clipboard_string() {
        Ok(content) => content,
        Err(e) => {
            eprintln!("Erreur lors de la lecture du presse-papiers : {}", e);
            return;
        }
    };

    // URL du serveur WebSocket
    let url = Url::parse("ws://localhost:8765").expect("URL incorrecte");

    // Établissement de la connexion WebSocket
    let (ws_stream, _) = connect_async(url).await.expect("Échec de la connexion");
    println!("Connecté au serveur WebSocket");

    // Séparation du stream pour envoyer et recevoir des messages
    let (mut write, mut read) = ws_stream.split();

    // Envoi du contenu du presse-papiers
    let msg = Message::Text(clipboard_content);
    write.send(msg).await.expect("Échec de l'envoi du message");

    // Lecture de la réponse
    if let Some(Ok(response)) = read.next().await {
        println!("Réponse reçue : {:?}", response);
    }
}
