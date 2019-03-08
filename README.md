# ECE579
This is the working directory for the website found here:

[https://cooperstansbury.github.io/EDA_r_ece579/index.html](https://cooperstansbury.github.io/EDA_r_ece579/index.html)

## Project
This repository was created as part of a class assignment.

## Dev
#### Opening the Rmd Files
To open the project run the following line in Terminal (or whichever one you use).

```
rstudio EDA_r_ece579/EDA_r_ece579.Rproj
```

From inside RStudio you can navigate to different `.Rmd` files and re-run analysis or modify the code to get something different.

#### Building Pages
From inside the project (assuming opened in RStudio), open a notebook. During development of the notebook you need to run the following lines to configure `knit` to point .`html` output into the [`docs`](docs/) folder. Doing this will configure the `render_site` command to build each notebook and the index for GitHub pages. This needs to be done for all notebooks whose output is  to appear in GitHub pages.

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

- Push your changes. Note: [`_site.yml`](_site.yml) is responsible for the configuration the website. Just pushing a notebook is not enough for the page to render to GitHub pages. I know it's named wrong, long story...
