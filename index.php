<?php
/**
 * HTTP Accept-Language based redirector.
 */

/**
 * Default language
 */
$default_language = 'en';

$target_pages = array(
    '',
);

function valid_language($lang) {
    $lang = preg_replace('/[^a-zA-Z_-]/', '_', $lang);
    return file_exists('./' . $lang . '/index.html');
}

/**
 * Detects language based on Accept-Language header.
 */
function get_language() {
    global $default_language;

    // Set default for the case no match is found.
    $preferred_language = $default_language;

    // Was headerr present?
    if (!isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
        return $preferred_language;
    }

    // Parse header
    preg_match_all(
        '/([[:alpha:]]{1,8})(-([[:alpha:]|-]{1,8}))?(\s*;\s*q\s*=\s*(1\.0{0,3}|0\.\d{0,3}))?\s*(,|$)/i',
        $_SERVER['HTTP_ACCEPT_LANGUAGE'],
        $languages,
        PREG_SET_ORDER
    );

    $best_qvalue = 0;

    foreach ($languages as $language_items) {
        $language_prefix = strtolower($language_items[1]);
        $language = $language_prefix . (!empty($language_items[3]) ? '_' . strtoupper($language_items[3]) : '');
        $qvalue = !empty($language_items[5]) ? floatval($language_items[5]) : 1.0;

        if (valid_language($language) && ($qvalue > $best_qvalue)) {
            $preferred_language = $language;
            $best_qvalue = $qvalue;
        } else if (valid_language($language_prefix) && (($qvalue*0.9) > $best_qvalue)) {
            $preferred_language = $language_prefix;
            $best_qvalue = $qvalue * 0.9;
        }
    }

    return $preferred_language;
}

/**
 * Set language cookie, expires in half year.
 */
function set_language($lang) {
    setcookie('weblate-lang', $lang, time() + 13824000, '/', false, false);
}

if (isset($_GET['lang']) && valid_language($_GET['lang'])) {
    /* Handle explicit language requests */
    $lang = $_GET['lang'];
    set_language($lang);
} elseif (isset($_COOKIE['weblate-lang']) && valid_language($_COOKIE['weblate-lang'])) {
    /* Cookie preset */
    $lang = $_COOKIE['weblate-lang'];
    set_language($lang);
} else {
    /* Auto detection */
    $lang = get_language();
}

/* Target page */
if (isset($_GET['target']) && in_array($_GET['target'], $target_pages)) {
    $target = $_GET['target'];
} else {
    $target = '';
}

/* Redirect to actual page */
header('Location: http://weblate.org/' . $lang . '/' . $target);
