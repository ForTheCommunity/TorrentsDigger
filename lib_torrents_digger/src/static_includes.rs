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

static APP_CURRENT_VERSION: Lazy<String> = Lazy::new(|| {
    // file content.
    let file_content = include_str!("../current_version.txt");

    // String to store current version.
    let mut current_version_string = String::new();

    for a_line in file_content.lines() {
        if !a_line.trim().is_empty() {
            current_version_string.push_str(a_line);
        }
    }
    current_version_string
});

pub fn get_current_version() -> Result<String, Box<dyn std::error::Error>> {
    Ok(APP_CURRENT_VERSION.clone())
}
