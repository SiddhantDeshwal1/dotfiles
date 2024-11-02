/// number of files in colorschemes/
pub const LEN: usize = include!(concat!(env!("OUT_DIR"), "/len.rs"));

/// theme names
pub const COLS_KEY: [&str; LEN] = include!(concat!(env!("OUT_DIR"), "/col.rs"));

/// This is colors from 0 to 15 (16 colors), background, foreground and cursor
//type Colors = [[u8; 3]; 19];
type Colors = [u32; 19];

/// theme values, in Colors
pub const COLS_VALUE: [Colors; LEN] = include!(concat!(env!("OUT_DIR"), "/value.rs"));
