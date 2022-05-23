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

$scandir = scandir($input_dir);

foreach ($scandir as $file) {

    if ($file === '..' || $file === '.')
        continue;

    $file_path = $input_dir . $file;

    $extension = pathinfo($file_path, PATHINFO_EXTENSION);
    $extension = strtolower($extension);

    $basename = substr($file_path, 0, strlen($extension) * -1);
    $destination = $basename . hash('sha256', $file_path) . '.' . $extension;

    rename($file_path, $destination);
}
