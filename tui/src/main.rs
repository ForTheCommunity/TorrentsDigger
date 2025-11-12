use torrents_digger_tui::app::App;

fn main() -> anyhow::Result<()> {
    let mut terminal = ratatui::init();
    let mut app = App { exit: false };

    let _app_result = app.run(&mut terminal);

    ratatui::restore();

    Ok(())
}
