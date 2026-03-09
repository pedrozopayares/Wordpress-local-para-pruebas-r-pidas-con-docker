<?php
require '/var/www/html/wp-load.php';

// COD
update_option('woocommerce_cod_settings', [
    'enabled' => 'yes',
    'title' => 'Pago contra entrega',
    'description' => 'Paga al recibir tu pedido.',
    'instructions' => 'Paga al recibir tu pedido en la puerta de tu casa u oficina.',
    'enable_for_methods' => '',
    'enable_for_virtual' => 'yes',
]);

// BACS
update_option('woocommerce_bacs_settings', [
    'enabled' => 'yes',
    'title' => 'Transferencia bancaria',
    'description' => 'Realiza tu pago mediante transferencia bancaria.',
    'instructions' => "Transferir a: Banco de prueba, Cuenta 1234567890, Titular Impactos Test",
]);

// Cheque
update_option('woocommerce_cheque_settings', [
    'enabled' => 'yes',
    'title' => 'Pago con cheque',
    'description' => 'Envia un cheque a nuestra direccion.',
    'instructions' => 'Envia tu cheque a: Calle Test 123, Bogota, Colombia.',
]);

echo 'Payment methods configured.' . PHP_EOL;

// Verify
$gateways = WC()->payment_gateways()->payment_gateways();
foreach ($gateways as $id => $gw) {
    echo $id . ': ' . ($gw->enabled === 'yes' ? 'ENABLED' : 'disabled') . ' - ' . $gw->title . PHP_EOL;
}
