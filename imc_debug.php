<?php
// Simulate admin AJAX context BEFORE WordPress loads
define('WP_ADMIN', true);
define('DOING_AJAX', true);

$_COOKIE['imc_currency'] = 'USD';
$_SERVER['HTTP_REFERER'] = 'http://localhost:8080/wp-admin/post.php?post=123&action=edit';
$_REQUEST['action'] = 'woocommerce_save_variations';

require '/var/www/html/wp-load.php';

echo '=== Context checks ===' . PHP_EOL;
echo 'is_admin(): ' . (is_admin() ? 'YES' : 'NO') . PHP_EOL;
echo 'wp_doing_ajax(): ' . (wp_doing_ajax() ? 'YES' : 'NO') . PHP_EOL;
echo 'HTTP_REFERER: ' . ($_SERVER['HTTP_REFERER'] ?? 'none') . PHP_EOL;
echo 'admin_url(): ' . admin_url() . PHP_EOL;
echo 'Cookie: ' . ($_COOKIE['imc_currency'] ?? 'none') . PHP_EOL;

echo PHP_EOL . '=== Scenario: Admin AJAX variation save, USD cookie ===' . PHP_EOL;
echo 'wc_get_price_decimal_separator(): ' . wc_get_price_decimal_separator() . PHP_EOL;
echo 'wc_get_price_thousand_separator(): ' . wc_get_price_thousand_separator() . PHP_EOL;
echo 'wc_format_decimal("11,50"): ' . wc_format_decimal('11,50') . PHP_EOL;
echo 'wc_format_decimal("11.50"): ' . wc_format_decimal('11.50') . PHP_EOL;
echo 'wc_format_localized_price("11.50"): ' . wc_format_localized_price('11.50') . PHP_EOL;
