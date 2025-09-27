use once_cell::sync::Lazy;

static TRACKERS_STRING: Lazy<String> = Lazy::new(|| {
    // file content.
    let trackers_file_content = include_str!("../all_active_public_trackers.txt");

    // String to store trackers.
    let mut trackers = String::new();

    for a_tracker in trackers_file_content.lines() {
        // check for empty lines / gap
        if !a_tracker.trim().is_empty() {
            trackers.push_str("&tr=");
            trackers.push_str(a_tracker);
        }
    }
    trackers
});

pub fn get_trackers() -> Result<String, Box<dyn std::error::Error>> {
    Ok(TRACKERS_STRING.clone())
}
