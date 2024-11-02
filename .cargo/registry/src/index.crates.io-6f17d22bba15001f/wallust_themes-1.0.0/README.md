# wallust-themes - built in colorschemes for `wallust`

This is a simple crate that stores `const`s colorschemes in arrays (slices).
Indexing in either of `COLS_VALUE` or `COLS_KEY` will result in the array
values (see the spec) or the name of the colorscheme, that's why they both have
the same `len()`ght.

_NOTE_: `COLS_VALUE` and `COLS_KEY` will have the same `LEN` as the number of files in `colorschemes/`.

## Spec

`COLS_VALUE` will **always** store the variables in this order (starting with index 0):

0.  `color0`
1.  `color1`
2.  `color2`
3.  `color3`
4.  `color4`
5.  `color5`
6.  `color6`
7.  `color7`
8.  `color8`
9.  `color9`
10. `color10`
11. `color11`
12. `color12`
13. `color13`
14. `color14`
15. `color15`
16. `background`
17. `foreground`
18. `cursor`

Making a total of 19 items. Each one of them is a `u32` number that represents
`[u8; 3]` and can be decoded by `.to_le_bytes()`

# Example
Remember that `COLS_VALUE` is an array (quantity of `coloschemes/`) that
contains arrays (19 `u32`s, as defined above) itself.
```rust
use wallust_themes::COLS_VALUE;
let some_color = COLS_VALUE[0][0]; //random color
// a (alpha) will always be 0, since we don't use RGBA, but RGB
let [b, g, r, a] = some_color.to_le_bytes();
```

# New Themes
If you feel like a very well known colorscheme is missing, you should request
it's addition with a json file following this format:

```json
{
  "colors": {
    "color0": "#090300",
    "color1": "#db2d20",
    "color10": "#01a252",
    "color11": "#fded02",
    "color12": "#01a0e4",
    "color13": "#a16a94",
    "color14": "#b5e4f4",
    "color15": "#f7f7f7",
    "color2": "#01a252",
    "color3": "#fded02",
    "color4": "#01a0e4",
    "color5": "#a16a94",
    "color6": "#b5e4f4",
    "color7": "#a5a2a2",
    "color8": "#5c5855",
    "color9": "#db2d20"
  },
  "special": {
    "background": "#090300",
    "cursor": "#db2d20",
    "foreground": "#a5a2a2"
  }
}
```
