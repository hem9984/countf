#!/bin/bash

# Initialize variables
delimiter=' '
find_word=''
find_flag=false
case_insensitive=false
verbose=false
count_chars=false
summary=false
file_sizes=false
recursive=false
header=false
stats=false
most_flag=false
least_flag=false

usage() {
    echo "Usage: $0 [options] filename_or_directory"
    echo "Options:"
    echo "  --comma              Use comma as delimiter instead of spaces"
    echo "  --delimiter CHAR     Use specified character as delimiter"
    echo "  --find WORD          Find and count instances of WORD"
    echo "  --case-insensitive   Perform case-insensitive search with --find"
    echo "  --chars              Count characters in each line"
    echo "  --summary            Print total lines, words, and characters count"
    echo "  --file-sizes         Display file sizes in the directory"
    echo "  --all                Include all subdirectories (recursive)"
    echo "  --verbose            Print detailed output"
    echo "  --stats              Print statistical analysis of elements per line"
    echo "  --header             Ignore the first line if there's a header"
    echo "  --most               Show the line with the most elements"
    echo "  --least              Show the line with the least elements"
    echo "  --everything         Activate all flags together"
    echo "  --help               Display this help message"
}

# Parse arguments
while [[ "$1" == --* ]]; do
    case "$1" in
        --comma)
            delimiter=','
            shift
            ;;
        --delimiter)
            shift
            if [ -z "$1" ]; then
                echo "Error: --delimiter requires an argument"
                usage
                exit 1
            fi
            delimiter="$1"
            shift
            ;;
        --find)
            find_flag=true
            shift
            if [ -z "$1" ]; then
                echo "Error: --find requires an argument"
                usage
                exit 1
            fi
            find_word="$1"
            shift
            ;;
        --case-insensitive)
            case_insensitive=true
            shift
            ;;
        --chars)
            count_chars=true
            shift
            ;;
        --summary)
            summary=true
            shift
            ;;
        --file-sizes)
            file_sizes=true
            shift
            ;;
        --all)
            recursive=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --stats)
            stats=true
            shift
            ;;
        --header)
            header=true
            shift
            ;;
        --most)
            most_flag=true
            shift
            ;;
        --least)
            least_flag=true
            shift
            ;;
        --everything)
            find_flag=true
            case_insensitive=true
            count_chars=true
            summary=true
            file_sizes=true
            recursive=true
            verbose=true
            stats=true
            header=true
            most_flag=true
            least_flag=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check if file or directory is specified
if [ -z "$1" ]; then
    echo "Error: No file or directory specified."
    usage
    exit 1
fi

target="$1"

# Function to count elements per line and provide summary for a file
count_elements() {
    local file="$1"
    local line_num=1
    local total_lines=0
    local total_elements=0
    local total_chars=0

    while IFS= read -r line || [ -n "$line" ]; do
        # Ignore header if --header is set
        if [ "$header" = true ] && [ "$line_num" -eq 1 ]; then
            line_num=$((line_num + 1))
            continue
        fi

        # Count elements based on delimiter
        num_elements=$(echo "$line" | awk -F"$delimiter" '{print NF}')
        total_elements=$((total_elements + num_elements))

        # Count characters
        num_chars=${#line}
        total_chars=$((total_chars + num_chars))

        total_lines=$((total_lines + 1))
        line_num=$((line_num + 1))
    done < "$file"

    # Default output: total lines and average elements per line
    if [ "$summary" = false ]; then
        avg_elements=$(echo "$total_elements / $total_lines" | bc -l)
        echo "Total lines: $total_lines"
        echo "Average elements per line: $avg_elements"
    fi

    # Print detailed summary if --summary is set
    if [ "$summary" = true ]; then
        echo "Summary:"
        echo "Total lines: $total_lines"
        echo "Total elements: $total_elements"
        echo "Total characters: $total_chars"
        avg_elements=$(echo "$total_elements / $total_lines" | bc -l)
        echo "Average elements per line: $avg_elements"
    fi
}

# Function to provide default behavior for a directory
count_files_and_dirs() {
    local dir="$1"
    local num_files
    local num_dirs
    num_files=$(find "$dir" -maxdepth 1 -type f | wc -l)
    num_dirs=$(find "$dir" -maxdepth 1 -type d | wc -l)
    num_dirs=$((num_dirs - 1))  # Subtract 1 for the target directory itself

    echo "Number of files: $num_files"
    echo "Number of directories: $num_dirs"
}

# Main execution logic
if [ -f "$target" ]; then
    # It's a file: apply default behavior or other flags
    echo "Analyzing file: $target"
    count_elements "$target"
elif [ -d "$target" ]; then
    # It's a directory: apply default behavior or other flags
    echo "Analyzing directory: $target"
    count_files_and_dirs "$target"

    # Additional options for directory
    if [ "$file_sizes" = true ]; then
        echo "File sizes in directory $target (non-recursive):"
        find "$target" -maxdepth 1 -type f -exec ls -lh {} \; | awk '{print $9 ": " $5}'
    fi
else
    echo "Error: $target is not a valid file or directory"
    exit 1
fi
