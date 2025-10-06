use lib_torrents_digger::database::initialize_database::initialize_database;
pub fn initialize_torrents_digger_database(
    torrents_digger_database_directory: String,
) -> Result<(), String> {
    match initialize_database(torrents_digger_database_directory) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}
