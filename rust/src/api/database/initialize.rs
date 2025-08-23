use lib_torrents_digger::database::initialize_database::initialize_database;
pub fn initialize_torrents_digger_database(torrents_digger_database_directory: String) {
    initialize_database(torrents_digger_database_directory);
}
