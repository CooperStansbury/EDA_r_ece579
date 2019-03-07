# ECE579
This is the working directory for the website found here:

[https://cooperstansbury.github.io/EDA_r_ece579/index.html](https://cooperstansbury.github.io/EDA_r_ece579/index.html)

## Project
This repository was created as part of a class assignment.

## Dev

#### Opening the Files
To open the project run the following line in Terminal (or whichever one you use).

```
rstudio EDA_r_ece579/EDA_r_ece579.Rproj
```

From inside RStudio you can navigate to different `.Rmd` files and re-run analysis.

#### Building Pages
From inside the project (assuming opened in RStudio):

- configure `Knit`:
```
knit: (
  function(input_file, encoding) {
      out_dir <- 'docs';
      rmarkdown::render(input_file,
      encoding=encoding,
      output_file=file.path(dirname(input_file), out_dir, 'index.html'))
      }
    )
```
- export each `.Rmd` file using `Knit` (`cmd+shift+k` on OSX).
- render the site using:

```
rmarkdown::render_site()
```

- Push your changes. Note: [`_site.yml`](_.site.yml) is responsible for the configuration the website. I know it's named wrong, long story...
