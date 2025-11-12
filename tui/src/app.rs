use anyhow::Result;

use ratatui::{
    DefaultTerminal, Frame,
    buffer::Buffer,
    crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind},
    layout::Rect,
    style::{Style, Stylize},
    symbols::border,
    text::Line,
    widgets::{Block, Paragraph, Widget},
};

pub struct App {
    pub exit: bool,
}

impl App {
    pub fn run(&mut self, terminal: &mut DefaultTerminal) -> anyhow::Result<()> {
        while !self.exit {
            terminal.draw(|frame| self.draw(frame))?;
            let _ = self.handle_events();
        }

        Ok(())
    }

    fn draw(&self, frame: &mut Frame) {
        frame.render_widget(self, frame.area());
    }

    fn handle_events(&mut self) -> Result<()> {
        match event::read()? {
            Event::Key(key_event) if key_event.kind == KeyEventKind::Press => {
                self.handle_key_events(key_event)
            }
            _ => {}
        };

        Ok(())
    }

    fn handle_key_events(&mut self, key_event: KeyEvent) {
        match key_event.code {
            KeyCode::Esc | KeyCode::Char('q') => self.exit_app(),
            _ => {}
        }
    }

    fn exit_app(&mut self) {
        self.exit = true;
    }
}

impl Widget for &App {
    fn render(self, area: Rect, buf: &mut Buffer)
    where
        Self: Sized,
    {
        let title = Line::from(" Torrents Digger ".bold());

        let instructions = Line::from(vec![" Quit ".into(), "<Q> | <Esc> ".blue().bold()]);
        let block = Block::bordered()
            .title(title.centered())
            .title_bottom(instructions.centered())
            .border_set(border::ROUNDED)
            .border_style(Style::new().green());

        Paragraph::new("Testing........")
            .centered()
            .block(block)
            .render(area, buf);
    }
}
