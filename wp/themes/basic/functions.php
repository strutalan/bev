<?php

function basic_theme_setup() {
    // Add theme support for post thumbnails
    add_theme_support('post-thumbnails');
    
    // Add theme support for title tag
    add_theme_support('title-tag');
}
add_action('after_setup_theme', 'basic_theme_setup');