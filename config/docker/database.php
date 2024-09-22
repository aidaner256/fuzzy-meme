<?php
/*
| For additional options see
| https://github.com/wintercms/winter/blob/master/config/database.php
|
| When using a container to serve a database, the host value will need to be
|  set as the service name defined in your docker-compose.yml
*/

return [
    'default' => env('DB_TYPE','mysql'), // sqlite, mysql, etc
    'connections' => [
        'sqlite' => [
            'database' => env('DB_PATH_SQLITE','storage/database.sqlite'),
        ],
        'mysql' => [
            'driver' => 'mysql',
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'forge'),
            'username' => env('DB_USERNAME', 'forge'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix' => '',
            'strict' => true,
            'engine' => null,
        ],
        'pgsql' => [
            'host'     => env('DB_HOST'),
            'port'     => env('DB_PORT'),
            'database' => env('DB_DATABASE'),
            'username' => env('DB_USERNAME'),
            'password' => env('DB_PASSWORD'),
        ],
    ],
    'redis' => [
        'default' => [
            'host'     => env('DB_REDIS_HOST','redis'),
            'password' => env('DB_REDIS_PASSWORD',null),
            'port'     => env('DB_REDIS_PORT',6379),
        ],
    ],
];
