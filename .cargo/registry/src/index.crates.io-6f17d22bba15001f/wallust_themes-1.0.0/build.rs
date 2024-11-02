use std::path::Path;

use serde::{Serialize,Deserialize};

#[allow(unused)]
macro_rules! p {
    ($($tokens: tt)*) => {
        println!("cargo:warning={}", format!($($tokens)*))
    }
}

type Colors = [u32; 19];

/// tbh when using `build.rs` is more acceptable to use `.uwnrap()` because the big context it
/// gives you, allowing you to fix it at 'compile time' (before even making it to the real sauce).

/// NOTE: Adding the ~150 of lines below `main()` is worth 0.1mb of 'savings' (roughly), also seeing
///       `"colors": { color0: "#eeeeee", .." and so on in the binary was kinda ugly.
/// Another reason for this change was to allow easily adding more themes, which builds automagically.
/// TODO: replace anyhow result with unwraps.
fn main() {
    let out = std::env::var_os("OUT_DIR").unwrap();
    let dir = "./colorschemes/";

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=colorschemes/");

    // p!("Building and embedding colorschemes..");

    let val_dir = Path::new(&out).join("value.rs");
    let len_dir = Path::new(&out).join("len.rs");
    let key_dir = Path::new(&out).join("col.rs");

    let d = std::fs::read_dir(dir).unwrap();

    let len = std::fs::read_dir(dir).unwrap().count();
    let mut keys  = String::new();
    let mut vals = String::new();

    keys.push_str("[");
    vals.push_str("[");

    for i in d {
        let i = i.unwrap().path();
        let name = i.file_name().unwrap().to_string_lossy();
        // remove .json from the name
        let name = &name[..name.len() - 5];
        // p!("{name}");

        let f = std::fs::read_to_string(&i).unwrap();
        let ser = serde_json::from_str::<WalTheme>(&f).unwrap();
        let c: Colors = ser.to_colors();

        keys.push_str(&format!("\"{name}\","));
        vals.push_str(&printcols(c));
    }

    //NO SEMICOLON AT THE END
    //<https://doc.rust-lang.org/stable/nightly-rustc/rustc_lint/builtin/static.INCOMPLETE_INCLUDE.html>
    keys.push_str("]");
    vals.push_str("]");

    std::fs::write(key_dir, &keys).unwrap();
    std::fs::write(val_dir, &vals).unwrap();
    std::fs::write(len_dir, &len.to_string()).unwrap();

    // p!("{vals}");

    fn printcols(a: Colors) -> String {
        let mut s = String::new();
        s.push_str("[");
        for i in a {
            s.push_str(&format!("{i},"));
        }
        s.push_str("],");
        s
    }
}

impl WalTheme {
    /// This SHOULD follows the Spec that the readme indicates.
    fn to_colors(&self) -> Colors {
        let c = &self.colors;
        let s = &self.special;
        [
            c.color0 .decode_hex(),
            c.color1 .decode_hex(),
            c.color2 .decode_hex(),
            c.color3 .decode_hex(),
            c.color4 .decode_hex(),
            c.color5 .decode_hex(),
            c.color6 .decode_hex(),
            c.color7 .decode_hex(),
            c.color8 .decode_hex(),
            c.color9 .decode_hex(),
            c.color10.decode_hex(),
            c.color11.decode_hex(),
            c.color12.decode_hex(),
            c.color13.decode_hex(),
            c.color14.decode_hex(),
            c.color15.decode_hex(),
            s.background.decode_hex(),
            s.foreground.decode_hex(),
            s.cursor    .decode_hex(),
        ]
    }
}

impl HexConversion for String {
    fn decode_hex(&self) -> u32 {
        let s = if &self[..1] == "#" { &self[1..] } else { &self };
        u32::from_str_radix(s, 16).unwrap()
    }
}

pub trait HexConversion {
    fn decode_hex(&self) -> u32;
}

#[derive(Deserialize, Serialize)]
pub struct WalColors {
    pub color0 : String,
    pub color1 : String,
    pub color2 : String,
    pub color3 : String,
    pub color4 : String,
    pub color5 : String,
    pub color6 : String,
    pub color7 : String,
    pub color8 : String,
    pub color9 : String,
    pub color10: String,
    pub color11: String,
    pub color12: String,
    pub color13: String,
    pub color14: String,
    pub color15: String,
}

/// Pywal colorscheme
#[derive(Deserialize, Serialize)]
pub struct WalTheme {
    pub special: WalSpecial,
    pub colors: WalColors,
}

#[derive(Deserialize, Serialize)]
pub struct WalSpecial {
    pub background: String,
    pub foreground: String,
    pub cursor: String,
}
