Gain insight into the structure and statistics of any directory or file

```bash
chmod +x countf.sh
countf <file>
```

example output:
```bash
harrison@muchnic:~$ ./countf.sh --everything test.txt 
Analyzing file: test.txt
Summary:
Total lines: 7
Total elements: 15
Total characters: 359
Average elements per line: 2.14285714285714285714
```
Usage: ./countf.sh [options] filename_or_directory
```bash
Options:
  --comma              Use comma as delimiter instead of spaces
  --delimiter CHAR     Use specified character as delimiter
  --find WORD          Find and count instances of WORD
  --case-insensitive   Perform case-insensitive search with --find
  --chars              Count characters in each line
  --summary            Print total lines, words, and characters count
  --file-sizes         Display file sizes in the directory
  --all                Include all subdirectories (recursive)
  --verbose            Print detailed output
  --stats              Print statistical analysis of elements per line
  --header             Ignore the first line if there's a header
  --most               Show the line with the most elements
  --least              Show the line with the least elements
  --everything         Activate all flags together
  --help               Display this help message
```
