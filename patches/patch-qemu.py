#!/usr/bin/env python3
'''
epic script to hack QEMU source code
qemu? more like asus...

made it cuz the chinese fella who posted the qemu patch on github
isnt updating it quickly enough, so i made this script to do it instead
this script will:
- replace all vendor IDs with random ones
- replace all device strings that begin with "QEMU " with "ASUS "
- replace all device strings that are "QEMUQEMUQEMUQEMU" with "ASUSASUSASUSASUS"
- generate a patch file for the modifications
'''
import os
import re
import random
import argparse
import difflib

def random_vendor_id():
    # generate a random 16-bit hex number (e.g. 0x1a2b)
    return f"0x{random.randint(0, 0xFFFF):04x}"

def process_file(filepath):
    """process a single file and return a diff patch if modifications are made."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            original_content = f.read()
    except Exception as e:
        print(f"error reading {filepath}: {e}")
        return None

    new_content = original_content

    # replace vendor IDs (e.g. vendor_id = 0x1af4;)
    vendor_pattern = re.compile(r'(\bvendor_id\s*=\s*0x)([0-9a-fA-F]{1,4})\b')
    def vendor_repl(match):
        prefix = match.group(1)
        new_id = random_vendor_id()
        print(f"In {filepath}: replacing {match.group(0)} with {prefix}{new_id[2:]}")
        return prefix + new_id[2:]
    new_content = vendor_pattern.sub(vendor_repl, new_content)

    # replace device strings that begin with "QEMU "
    string_pattern = re.compile(r'(")QEMU( [^"]*")')
    def string_repl(match):
        return f'{match.group(1)}ASUS{match.group(2)}'
    new_content = string_pattern.sub(string_repl, new_content)

    # replace device strings that are "QEMUQEMUQEMUQEMU"
    string_pattern2 = re.compile(r'(")QEMUQEMUQEMUQEMU([^"]*")')
    def string_repl2(match):
        return f'{match.group(1)}ASUSASUSASUSASUS{match.group(2)}'
    new_content = string_pattern2.sub(string_repl2, new_content)

    # diff the original and modified content
    # if there are changes, create a unified diff
    if new_content != original_content:
        original_lines = original_content.splitlines(keepends=True)
        new_lines = new_content.splitlines(keepends=True)
        diff = difflib.unified_diff(
            original_lines, new_lines,
            fromfile=filepath, tofile=filepath,
            lineterm='\n'  # ensure each line ends with a newline
        )
        return ''.join(diff)
    return None

def process_directory(directory):
    patch_chunks = []
    # walk recursively through the directory, processing relevant source files.
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(('.c', '.h', '.cpp', '.cc')):
                filepath = os.path.join(root, file)
                diff_chunk = process_file(filepath)
                if diff_chunk:
                    patch_chunks.append(diff_chunk)
    return patch_chunks

def main():
    parser = argparse.ArgumentParser(
        description="generate a patch file for QEMU source code modifications"
    )
    parser.add_argument(
        "directory",
        help="path to the QEMU source tree directory"
    )
    parser.add_argument(
        "-o", "--output",
        default="qemu_modifications.patch",
        help="output patch file name (default: qemu_modifications.patch)"
    )
    args = parser.parse_args()

    patches = process_directory(args.directory)
    if patches:
        with open(args.output, 'w', encoding='utf-8') as patch_file:
            for chunk in patches:
                patch_file.write(chunk)
                patch_file.write("\n")
        print(f"patch file created: {args.output}")
    else:
        print("no modifications were made; no patch file created.")

if __name__ == "__main__":
    main()
