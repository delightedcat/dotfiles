#!/usr/bin/env php
<?php

if (php_sapi_name() !== 'cli')
    die('This script can only be run from the command-line!');

if ($argc < 2) {
    echo 'error: please specify the directory to clean and organize!' . PHP_EOL;
    echo 'usage: $ ' . $argv[0] . ' <directory>';
    exit(1);
}

$input_dir = rtrim($argv[1], '/') . '/';

if (!is_dir($input_dir)) {
    echo 'error: directory not found at `' . $input_dir . '`!' . PHP_EOL;
    exit(1);
}

$scandir = walkdir($input_dir);

foreach ($scandir as $file_path) {

    if (!is_file($file_path))
        continue;

    echo $file_path . PHP_EOL;
    $destination = $input_dir . basename($file_path);

    rename($file_path, $destination);
}

function walkdir($path, &$files = []) {

    $scandir = scandir($path);

    foreach ($scandir as $file) {

        if ($file === '..' || $file === '.')
            continue;

        $file_path = rtrim($path, '/') . '/' . $file;

        if (is_file($file_path)) {
            $files[] = $file_path;
            continue;
        }

        walkdir($file_path, $files);
    }

    return $files;
}

