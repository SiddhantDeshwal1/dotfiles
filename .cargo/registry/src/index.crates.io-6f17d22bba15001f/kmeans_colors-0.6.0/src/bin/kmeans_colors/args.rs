use std::path::PathBuf;

use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(
    name = "kmeans-colors",
    about = "Simple k-means clustering to find dominant colors in images"
)]
pub struct Opt {
    /// Input file(s), separated by commas.
    #[structopt(
        short,
        long,
        parse(from_os_str),
        value_delimiter = ",",
        conflicts_with("command")
    )]
    pub input: Vec<PathBuf>,

    /// Number of clusters.
    ///
    /// `RGB` tends to have more "appealing" contrast at lower number of
    /// clusters resembling a posterization filter while `Lab` will tend toward
    /// segments of color. `Lab` colors will tend to be truer to the image's
    /// inherent colors due to the model being more perceptually uniform than
    /// `RGB`.
    ///
    /// As `k` increases, it may take much longer to converge for `Lab` due to
    /// the convergence criteria. The algorithm can also fall in to local minima
    /// which aren't the "best" answer. In these cases, the algorithm should be
    /// run multiple times and the best result chosen.
    #[structopt(short, long, default_value = "8", required = false)]
    pub k: u8,

    /// Maximum number of iterations.
    ///
    /// One of the thresholds for halting calculation of k-means. The other is
    /// a distance metric determined by how much the k-means have changed since
    /// the previous iteration.
    ///
    /// `RGB` tends to converge within 10 iterations while `Lab` can take many
    /// more.
    #[structopt(short, long = "iterations", default_value = "20", required = false)]
    pub max_iter: usize,

    /// Convergence factor. Defaults to "10.0" for Lab and "0.0025" for RGB.
    ///
    /// One of the thresholds for halting calculation of k-means. The other is
    /// a limit on total iterations. Decrease the factor for a higher quality
    /// result at the expense of time and iteration count.
    ///
    /// `Lab` may have a very high number for the distance between iterations
    /// but it is possible to still have a good result. Images which tend toward
    /// monochromatic may suffer from not converging but have adequate colors.
    /// When a color has no matching pixels, it is reinitialized to a new random
    /// color.
    #[structopt(short, long)]
    pub factor: Option<f32>,

    /// Number of times to run the algorithm on the image, keeping the lowest
    /// score.
    #[structopt(short, long, default_value = "1", required = false)]
    pub runs: usize,

    /// Seed for the random number generator.
    #[structopt(long)]
    pub seed: Option<u64>,

    /// File extension of output.
    #[structopt(short, long = "ext", default_value = "png", required = false)]
    pub extension: String,

    /// Print the k-means colors.
    ///
    /// Due to the nature of the implementation, there may be less than `k`
    /// colors if the algorithm was unable to converge on a solution due to too
    /// few iterations.
    #[structopt(short, long)]
    pub print: bool,

    /// Print the percentage of each color in the image.
    #[structopt(long = "pct")]
    pub percentage: bool,

    /// Perform the k-means in `RGB` color space.
    #[structopt(long)]
    pub rgb: bool,

    /// Disable outputting the image. Used in combination with printing
    /// colors as output.
    #[structopt(long = "no-file")]
    pub no_file: bool,

    /// Enable printing the convergence distance and other internal
    /// information, such as iteration count.
    #[structopt(short, long)]
    pub verbose: bool,

    /// Save color palette of image to file. Defaults to `40 * k width x 40
    /// height`.
    #[structopt(long)]
    pub palette: bool,

    /// Display colors in order from highest to lowest percentage in the image.
    /// Applies to console and `--palette` image output.
    #[structopt(long)]
    pub sort: bool,

    /// Color palette output will be proportionally scaled.
    #[structopt(long)]
    pub proportional: bool,

    /// Height of color palette image. If width is omitted, palette will be
    /// `height * k` pixels wide.
    #[structopt(long, default_value = "40")]
    pub height: u32,

    /// Width of color palette image. Will be at least `k` pixels wide.
    #[structopt(long)]
    pub width: Option<u32>,

    /// Output file. When input is multiple files, this string will be appended
    /// to the filename. File type extension can be declared here for `.jpg`.
    #[structopt(short, long, parse(from_os_str))]
    pub output: Option<PathBuf>,

    /// Output file. When input is multiple files, this string will be appended
    /// to the filename. File type extension can be declared here for `.jpg`.
    #[structopt(long = "op", parse(from_os_str))]
    pub palette_output: Option<PathBuf>,

    /// Maps the image to the user supplied colors.
    #[structopt(subcommand, name = "command")]
    pub cmd: Option<Command>,

    /// Ignore pixels with any transparency for calculation of k-means, produce
    /// transparent output image.
    #[structopt(long)]
    pub transparent: bool,
}

#[derive(StructOpt, Debug)]
pub enum Command {
    /// More manual control over the k-means algorithm.
    ///
    /// The default behavior is to use the supplied colors as the centroids and
    /// color the pixels based on those colors. The `replace` flag calculates
    /// the k-means as usual and uses the supplied colors to replace those in
    /// the image.
    Find {
        /// Input file(s), separated by commas.
        #[structopt(
            short,
            long,
            parse(from_os_str),
            value_delimiter = ",",
            required = true
        )]
        input: Vec<PathBuf>,

        /// Colors to map the pixels to the nearest value of.
        #[structopt(
            short,
            long,
            min_values = 2,
            max_values = 255,
            value_delimiter = ",",
            required = true
        )]
        colors: Vec<String>,

        /// Replace the k-means-indexed colors in the image.
        #[structopt(long)]
        replace: bool,

        /// Maximum number of iterations.
        #[structopt(short, long = "iterations", default_value = "20", required = false)]
        max_iter: usize,

        /// Convergence factor.
        #[structopt(short, long)]
        factor: Option<f32>,

        /// Number of times to run the algorithm on the image, keeping the lowest
        /// score.
        #[structopt(short, long, default_value = "3", required = false)]
        runs: usize,

        /// Seed for the random number generator.
        #[structopt(long)]
        seed: Option<u64>,

        /// Print the percentage of each color in the image and the file
        /// name.
        #[structopt(short, long = "pct")]
        percentage: bool,

        /// Perform the k-means operations in `RGB` color space.
        #[structopt(long)]
        rgb: bool,

        /// Enable printing the convergence distance and other internal
        /// information, such as iteration count.
        #[structopt(short, long)]
        verbose: bool,

        /// Output file. When input is multiple files, this string will be appended
        /// to the filename. File type extension can be declared here for `.jpg`.
        #[structopt(short, long, parse(from_os_str))]
        output: Option<PathBuf>,

        /// Ignore pixels with any transparency for calculation of k-means, produce
        /// transparent output image.
        #[structopt(long)]
        transparent: bool,
    },
}
