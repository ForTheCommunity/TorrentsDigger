use once_cell::sync::Lazy;

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
