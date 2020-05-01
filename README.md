# bender-salaries

Scraping and parsing NBA contract salaries from Patricia Bender's NBA salary database https://www.eskimo.com/~pbender/

# Organization:

The structure of the repository is as follows:

- [0-data/](0-data/)
    - `0-bender-scrape.R` - script to download data from [Patricia Bender](https://www.eskimo.com/~pbender/)
    - `0-bender-parse.R` - script to parse through each file of salaries to gather player salary information
    - salaries/ 
        - raw/
            - All downloaded text files from the `0-bender-scrape.R` script.
        - [`bender_raw.csv`](0-data/salaries/bender_raw.csv) - raw version of the parsed salary information
- [1-tidy/](1-tidy/)
    - `1-bender-tidy.R` - script to gather and format data in a usable way by each component
    - [`bender_salaries.csv`](1-tidy/bender_salaries.csv)
 