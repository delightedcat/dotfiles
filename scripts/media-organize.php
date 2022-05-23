#!/usr/bin/env php
<?php

$prefixes = [
    'png' => 'IMG',
    'jpg' => 'IMG',
    'jpeg' => 'IMG',
    'gif' => 'IMG',
    'mp4' => 'VID',
    'mov' => 'VID',
    '3gpp' => 'VID',
];

if (php_sapi_name() !== 'cli')
    die('This script can only be run from the command-line!');

if ($argc < 2) {
    echo 'error: please specify the directory to clean and organize!' . PHP_EOL;
    echo 'usage: $ ' . $argv[0] . ' <directory>';
    exit(1);
}

$options = [
    'duplicates' => !in_array('--no-duplicates', $argv),
    'naming' => !in_array('--no-naming', $argv),
    'sorting' => !in_array('--no-sorting', $argv),
];

$input_dir = rtrim($argv[1], '/') . '/';

if (!is_dir($input_dir)) {
    echo 'error: directory not found at `' . $input_dir . '`!' . PHP_EOL;
    exit(1);
}

if ($options['duplicates'] !== false) {

    $scandir = scandir($input_dir);
    $count = 0;

    $hashset = [];
    $duplicates = [];

    echo 'checking a total of ' . (count($scandir) - 2) . ' files for duplicates...' . PHP_EOL;

    foreach ($scandir as $file) {

        if ($file === '.' || $file === '..')
            continue;

        $file_path = $input_dir . $file;
        $hash = hash_file('sha256', $file_path);

        echo '[' . ++$count . '/' . (count($scandir) - 2) . '] ';
        echo 'checking file `' . $file_path . '`... ' . PHP_EOL;

        if (in_array($hash, $hashset)) {
            $duplicates[] = $file_path;
            continue;
        }

        $hashset[] = $hash;
    }

    if (count($duplicates) > 0) {
        $duplicates_dir = $input_dir . 'duplicates/';

        echo 'found a total of ' . count($duplicates) . ' duplicates!' . PHP_EOL;
        echo 'moving duplicates to `' . $duplicates_dir . '`...' . PHP_EOL;

        @mkdir($duplicates_dir);

        foreach ($duplicates as $file_path) {
            $destination = $duplicates_dir . basename($file_path);
            rename($file_path, $destination);
        }
    }
    else {
        echo 'no duplicates found! keep it up' . PHP_EOL;
    }

    unset($hashset);
    unset($duplicates);
}

$scandir = scandir($input_dir);
$meta = [];

foreach ($scandir as $file) {

    if ($file === '.' || $file === '..')
        continue;

    if (is_dir($input_dir . $file))
        continue;

    $extension = pathinfo($file, PATHINFO_EXTENSION);
    $extension = strtolower($extension);

    if (!array_key_exists($extension, $prefixes)) {
        echo 'extension `' . $extension . '` is not recognized' . PHP_EOL;
        echo 'please add it to the $prefixes variable at the top of the file' . PHP_EOL;
        exit(1);
    }

    $prefix = $prefixes[$extension];
    $date = null;

    if (preg_match('/\d{4}\d{2}\d{2}/', $file, $matches)) {
        $date = substr($matches[0], 0, 4) . '-'
            . substr($matches[0], 4, 2) . '-'
            . substr($matches[0], 6, 2);
    }
    elseif (preg_match('/\d{4}[\-\_]\d{2}[\-\_]\d{2}/', $file, $matches)) {
        $date = substr($matches[0], 0, 4) . '-'
            . substr($matches[0], 5, 2) . '-'
            . substr($matches[0], 8, 2);
    }

    $meta[$input_dir . $file] = [
        'prefix' => $prefix,
        'date' => $date,
        'extension' => $extension,
    ];
}

if ($options['naming'] !== false) {

    foreach ($meta as $file_path => $data) {

        if (!is_null($data['date'])) {
            $basename = dirname($file_path) . '/' . $data['prefix'] . '_' . date('Ymd', strtotime($data['date']));
        } else {
            $basename = dirname($file_path) . '/' . $data['prefix'] . '_UNKOWN';
        }

        $destination = $basename . '.' . $data['extension'];
        $count = 0;

        while (is_file($destination)) {
            $destination = $basename . '_' . $count++ . '.' . $data['extension'];
        }

        rename($file_path, $destination);

        $meta[$destination] = $data;
        unset($meta[$file_path]);
    }
}

if ($options['sorting'] != false) {

    foreach ($meta as $file_path => $data) {

        if (!is_null($data['date'])) {
            $month_dir = date('Y-m', strtotime($data['date']));
        } else {
            $month_dir = 'unknown';
        }

        $destination = dirname($file_path) . '/' . $month_dir . '/' . basename($file_path);

        @mkdir(dirname($destination), 0777, true);
        rename($file_path, $destination);
    }
}
