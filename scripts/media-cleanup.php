#!/usr/bin/env php
<?php

ini_set('memory_limit', -1);

if (php_sapi_name() !== 'cli')
    die('This script can only be used on the command-line');

$arguments = $argv;
array_shift($arguments);

$options = [
    'live' => false,
    'directory' => null,
    'extensions' => 'jpg,jpeg,png,gif,mov,mp4,pdf',
    'verbose' => true,
    'debug' => false,
    'exclude' => null,
];

foreach ($arguments as $argument) {
    if (substr($argument, 0, 2) === '--') {

        $argument = substr($argument, 2);
        $argument = explode('=', $argument, 2);

        $key = $argument[0];
        
        if (!array_key_exists($key, $options))
            die("Option '$key' does not exist!" . PHP_EOL);

        if (isset($argument[1])) {
            $value = $argument[1];

            switch ($value) {
                case 'true':
                    $value = true;
                    break;
                case 'false':
                    $value = false;
                    break;
                case 'null':
                    $value = null;
                    break;
            }

            $options[$key] = $value;
        }
    }
}

if (!isset($options['directory']))
    die('Please provide a directory to search!' . PHP_EOL);

if (!isset($options['extensions']))
    die('Please provide extensions to search!' . PHP_EOL);

$options['directory'] = realpath($options['directory']);
$options['extensions'] = explode(',', $options['extensions']);

if (isset($options['exclude']))
    $options['exclude'] = explode(',', $options['exclude']);

if (!is_dir($options['directory']))
    die("Directory '$options[directory]' could not be found!" . PHP_EOL);

$results = walkdir($options['directory']);
$hashes = [];

foreach ($results as $path) {

    if (is_dir($path))
        continue;

    $extension = pathinfo($path, PATHINFO_EXTENSION);
    $extension = strtolower($extension);

    if (!in_array($extension, $options['extensions'])) {

        if ($options['debug'] === true)
            echo "Skipping extension '$extension'..." . PHP_EOL;

        continue;
    }

    $directories = explode(DIRECTORY_SEPARATOR, $path);
    $exclude = false;

    if (isset($options['exclude'])) {
        foreach ($directories as $directory) {
            if (in_array($directory, $options['exclude'])) {
                $exclude = true;
                break;
            }
        }
    
        if ($exclude !== false)
            continue;
    }

    $hash = hash('sha256', file_get_contents($path));

    if ($options['verbose'] === true)
        echo "Checking file '$path'..." . PHP_EOL;

    $hashes[$hash][] = $path;
}

foreach ($hashes as $hash => $paths) {
    if (count($paths) > 1) {
        array_pop($paths);
        
        foreach ($paths as $path)
            @unlink($path);
    }
}

function walkdir(string $directory, array &$results = [])
{
    $files = scandir($directory);

    foreach ($files as $value) {
        $path = realpath($directory . DIRECTORY_SEPARATOR . $value);

        if (!is_dir($path)) {
            $results[] = $path;
        } elseif ($value !== '.' && $value !== '..') {
            walkdir($path, $results);
            $results[] = $path;
        }
    }

    return $results;
}
