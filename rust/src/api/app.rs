// #[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
// pub fn greet(name: String) -> String {
//     format!("Hello, {name}!")
// }

// #[flutter_rust_bridge::frb(init)]
// pub fn init_app() {
//     // Default utilities - feel free to customize
//     flutter_rust_bridge::setup_default_user_utils();
// }

use crate::api::sources::nyaa::search_torrent;
#[tokio::main]
pub async fn dig_torrent(torrent_name: String) {
    println!("[RUST] Searching Torrent : {}", torrent_name);
    search_torrent(torrent_name).await;
}
